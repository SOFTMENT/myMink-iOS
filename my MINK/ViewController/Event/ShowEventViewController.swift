//
//  ShowEventViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 27/01/24.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import MapKit
import SDWebImage
import EventKit
import TTGSnackbar

class ShowEventViewController : UIViewController {
    @IBOutlet weak var bottomBarView: UIView!
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var headerCollectionView: UICollectionView!
    @IBOutlet weak var myPageView: UIPageControl!
    
    @IBOutlet weak var navigationBar: UIView!
    
    @IBOutlet weak var topProfileImage: SDAnimatedImageView!
    
    
    @IBOutlet weak var tagsCollectionView: UICollectionView!
    
    @IBOutlet weak var ticketBtn: UIButton!
    
    @IBOutlet weak var topOrganizerName: UILabel!
    
    @IBOutlet weak var eventTitle: UILabel!
    
    @IBOutlet weak var eventStartDate: UILabel!
    
    @IBOutlet weak var eventTime: UILabel!
    
    @IBOutlet weak var eventAddToCalendar: UILabel!
    
    @IBOutlet weak var addressName: UILabel!
    
    @IBOutlet weak var fullAddress: UILabel!
    
    @IBOutlet weak var eventDescritption: UILabel!
    
    @IBOutlet weak var navigationTitle: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var ticketPrice: UILabel!
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var viewProfile: UIView!
    
    var event : Event?
    var imgArr : [String] = []
    var timer = Timer()
    var counter = 0
    var tags : [String] = []
    var dateAndTimeCellSelectedIndex = 0
    var userModel : UserModel?
    var organizerName : String?
    var organizerEmail : String?
    
    override func viewDidLoad() {

        updateUI(event: event)
        
    }
    func updateUI(event : Event?){
      
        
        guard let event = event else {
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
            return
            
        }
    
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backClicked)))
        
        viewProfile.layer.cornerRadius = 8
        viewProfile.isUserInteractionEnabled = true
        viewProfile.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewProfileClick)))
        
        headerCollectionView.delegate = self
        headerCollectionView.dataSource = self
        
        tagsCollectionView.delegate = self
        tagsCollectionView.dataSource = self
        
        myPageView.currentPage = 0
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.changeImage), userInfo: nil, repeats: true)
        }
        
      
        //MapView
        mapView.delegate = self
      
        topProfileImage.makeRounded()
        ticketBtn.layer.cornerRadius = 8
        
        getUserDataByID(uid: event.eventOrganizerUid!) { userModel, error in
            if let userModel = userModel {
                self.userModel = userModel
                self.topOrganizerName.text = userModel.fullName ?? ""
                self.userName.text = "@\(userModel.username!)"
                
                if let path = userModel.profilePic,!path.isEmpty {
                    self.topProfileImage.setImage(imageKey: path, placeholder: "profile-placeholder",shouldShowAnimationPlaceholder: true)
                }
                
            }
        }

        //Get Organizer
        getUserDataByID(uid: event.eventOrganizerUid!) { userModel, error in
            if let userModel = userModel {
                self.organizerName = userModel.fullName
                self.organizerEmail = userModel.email
            }
        }
        
       
        
        //Mapping
     
        eventTitle.text = event.eventTitle ?? "Something Went Wrong"
        navigationTitle.text = event.eventTitle ?? "Something Went Wrong"
        
       
        
        eventStartDate.text = self.convertDateForEvent(event.eventStartDate ?? Date())
        eventTime.text = "\(self.convertTimeFormater(event.eventStartDate ?? Date())) - \(self.convertTimeFormater(event.eventEndDate ?? Date()))"
        
        eventAddToCalendar.isUserInteractionEnabled = true
        eventAddToCalendar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addEventToCalendar)))
        
       
        
        eventDescritption.text = event.eventDescription ?? "Something Went Wrong"
        
        let coordinates = CLLocationCoordinate2D(latitude: event.latitude ?? 0, longitude: event.longitude ?? 0)
        
        setCoordinatesOnMap(with: coordinates)
        
        if let tag = event.tags, tag != "" {
            tags = tag.components(separatedBy: ",")
            tagsCollectionView.reloadData()
        }
        
        if let img1 = event.eventImage1, img1 != "" {
            imgArr.append(img1)
        }
        if let img2 = event.eventImage2, img2 != "" {
            imgArr.append(img2)
        }
        if let img3 = event.eventImage3, img3 != "" {
            imgArr.append(img3)
        }
        if let img4 = event.eventImage4, img4 != "" {
            imgArr.append(img4)
        }
        headerCollectionView.reloadData()
        myPageView.numberOfPages = imgArr.count
        
        if let isFree = event.isFree, isFree {
            ticketPrice.text = "Free!"
            ticketBtn.setTitle("Register", for: .normal)
        }
        else {
            let price = event.ticketPrice ?? 0
            ticketPrice.text = "US$ \(String(format: "%.2f", Double(price)))"
            ticketBtn.setTitle("Ticket", for: .normal)
        }
        

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewProfileSeg" {
            if let VC = segue.destination as? ViewUserProfileController {
                VC.user = self.userModel
            }
        }
        else if segue.identifier == "ticketSuccessSeg" {
            if let VC = segue.destination as? TicketPurchaseSuccessViewController {
                if let ticketModel = sender as? TicketModel {
                    VC.ticketModel = ticketModel
                }
            }
        }
    }
    
    @objc func viewProfileClick(){
        performSegue(withIdentifier: "viewProfileSeg", sender: nil)
    }
    
    func setCoordinatesOnMap(with coordinates : CLLocationCoordinate2D) {
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
    
        let anonation = mapView.annotations
        mapView.removeAnnotations(anonation)
        
        mapView.addAnnotation(pin)
        mapView.setRegion(MKCoordinateRegion(
                            center: coordinates,
                            span: MKCoordinateSpan(
                                latitudeDelta: 0.02,
                                longitudeDelta: 0.02)),
                            animated: true)
        mapView.isScrollEnabled = false
        
        
    }

    @IBAction func ticketBtnClicked(_ sender: Any) {
        
        let ticketModel = TicketModel()
       
        ticketModel.quantity = 1
        ticketModel.userName = UserModel.data!.fullName
        ticketModel.eventName = event!.eventTitle
        ticketModel.eventId = event!.eventId
        ticketModel.eventStartDate = event!.eventStartDate
        ticketModel.eventEndDate = event!.eventEndDate
        ticketModel.addressName = event!.addressName
  
        ticketModel.orderNumber = "A495DMNKOCX84VR"
        ticketModel.eventSummary = event!.eventDescription
        ticketModel.organizerName = organizerName
        ticketModel.ticketBookDate = Date()
        ticketModel.userId = UserModel.data!.uid
        ticketModel.eventImage = event!.eventImage1
        ticketModel.organizerUid = event!.eventOrganizerUid
        ticketModel.userEmail = organizerEmail
        ticketModel.ticketName = event!.ticketName
        ticketModel.latitude = event!.latitude
        ticketModel.longitude = event!.longitude
        if let isFree = event!.isFree, isFree {
            ticketModel.isFree = true
        }
        else {
            ticketModel.isFree = false
            ticketModel.ticketPrice = event!.ticketPrice ?? 0
        }
        self.performSegue(withIdentifier: "ticketSuccessSeg", sender: ticketModel)
    }

    
    @objc func addEventToCalendar(){
        
        let eventStore = EKEventStore()

        eventStore.requestAccess(to: .event, completion: { (granted, error) in
            DispatchQueue.main.async {
                if (granted) && (error == nil) {
                    let cevent = EKEvent(eventStore: eventStore)
                    cevent.title = self.event!.eventTitle ?? "myMINK Event"
                    cevent.startDate = self.event!.eventStartDate ?? Date()
                    cevent.endDate = self.event!.eventEndDate ?? Date()
                    cevent.notes = self.event!.eventDescription ?? "myMINK Description"
                    cevent.calendar = eventStore.defaultCalendarForNewEvents
                    do {
                        try eventStore.save(cevent, span: .thisEvent)
                        DispatchQueue.main.async {
                            self.showSnack(messages: "This event has been added to your calendar.")
                        }
                      
                    } catch let e as NSError {
                        self.showError(e.localizedDescription)
                        return
                    }
                  
                } else {
                    self.showMessage(title: "Permission Denied", message: "Please allow calendar access permission from devic settings")
                }
            }
        
        })
    }

    
    
    func showMapOptions(latitude: Double, longitude: Double) {
        let alertController = UIAlertController(title: "Open Location", message: "Choose a Maps App", preferredStyle: .actionSheet)

        // Google Maps Option
        let googleMapsAction = UIAlertAction(title: "Google Maps", style: .default) { (action) in
            if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) {
                let googleMapsURL = URL(string: "comgooglemaps://?q=\(latitude),\(longitude)")!
                UIApplication.shared.open(googleMapsURL, options: [:], completionHandler: nil)
            } else {
                self.showSnack(messages: "Google Maps is not installed.")
            }
        }

        // Apple Maps Option
        let appleMapsAction = UIAlertAction(title: "Apple Maps", style: .default) { (action) in
            let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
            mapItem.name = "Target Location" // Optional
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
        }

        // Cancel Option
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        // Add actions to the alert controller
        alertController.addAction(googleMapsAction)
        alertController.addAction(appleMapsAction)
        alertController.addAction(cancelAction)

        // Present the alert controller
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func changeImage() {
      
      if counter < imgArr.count {
          let index = IndexPath.init(item: counter, section: 0)
          self.headerCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
          myPageView.currentPage = counter
          counter += 1
      } else {
          counter = 0
          let index = IndexPath.init(item: counter, section: 0)
          self.headerCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
         myPageView.currentPage = counter
          counter = 1
      }
          
      }
    
    @objc func backClicked(){
        self.dismiss(animated: true, completion: nil)
    }

    
  
}



extension ShowEventViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
      
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
      
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == headerCollectionView {
            let size = headerCollectionView.frame.size
            return CGSize(width: size.width, height: size.height)
        }
        else {
            let size = tagsCollectionView.frame.size
            return CGSize(width: size.width, height: size.height)
        }
       
    
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
   
}

extension ShowEventViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    
  
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
      if collectionView == tagsCollectionView {
            return tags.count
        }
        return imgArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      
        if  collectionView == tagsCollectionView {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagcell", for: indexPath) as? TagCell {
                
                let tag = "#\(tags[indexPath.row])"
              
                cell.tagBtn.setTitle(tag, for: .normal)
                cell.tagBtn.layer.cornerRadius = 8
                return cell
            }
            return TagCell()
        }
        else {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "headercell", for: indexPath) as? HeaderViewCell {
              
                let mImage = SDAnimatedImageView()
                let placeholder1 = SDAnimatedImage(named: "imageload.gif")
                mImage.image = placeholder1
                
                let img = imgArr[indexPath.row]
                cell.mImage.sd_setImage(with: URL(string: img), placeholderImage: placeholder1) { _, _, _, _ in
                    mImage.stopAnimating()
                }
                return cell
                
            }
            return HeaderViewCell()
           
        }
    
    }
    
    
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        let visibleIndex = Int(targetContentOffset.pointee.x / headerCollectionView.frame.width)
        myPageView.currentPage = visibleIndex
        counter = visibleIndex
    }
    
    
    
    
    
}
extension ShowEventViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation {
            self.showMapOptions(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
            
        }
        
    }
}
