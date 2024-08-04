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

class ShowEventViewController: UIViewController {

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
    @IBOutlet weak var eventDescription: UILabel!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var ticketPrice: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var viewProfile: UIView!
    
    var event: Event?
    var imgArr: [String] = []
    var timer = Timer()
    var counter = 0
    var tags: [String] = []
    var userModel: UserModel?
    var organizerName: String?
    var organizerEmail: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI(event: event)
    }

    private func setupUI() {
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
        
        mapView.delegate = self
        
        topProfileImage.makeRounded()
        ticketBtn.layer.cornerRadius = 8
    }

    private func updateUI(event: Event?) {
        guard let event = event else {
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
            return
        }
        
        setupEventDetails(event: event)
        setupOrganizerDetails(event: event)
        setupMapView(event: event)
        setupImages(event: event)
    }

    private func setupEventDetails(event: Event) {
        eventTitle.text = event.eventTitle ?? "Something Went Wrong"
        navigationTitle.text = event.eventTitle ?? "Something Went Wrong"
        eventStartDate.text = convertDateForEvent(event.eventStartDate ?? Date())
        eventTime.text = "\(convertTimeFormater(event.eventStartDate ?? Date())) - \(convertTimeFormater(event.eventEndDate ?? Date()))"
        eventAddToCalendar.isUserInteractionEnabled = true
        eventAddToCalendar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addEventToCalendar)))
        eventDescription.text = event.eventDescription ?? "Something Went Wrong"
        addressName.text = event.addressName ?? ""
        fullAddress.text = event.address ?? ""
        if let tag = event.tags, !tag.isEmpty {
            tags = tag.components(separatedBy: ",")
            tagsCollectionView.reloadData()
        }
        
        if let isFree = event.isFree, isFree {
            ticketPrice.text = "Free!"
        } else {
            let price = event.ticketPrice ?? 0
            ticketPrice.text = "\(getCurrencyCode(forRegion: Locale.current.regionCode!) ?? "AU") \(String(format: "%.2f", Double(price)))"
        }
    }

    private func setupOrganizerDetails(event: Event) {
        getUserDataByID(uid: event.eventOrganizerUid!) { [weak self] userModel, error in
            guard let self = self else { return }
            if let userModel = userModel {
                self.userModel = userModel
                self.topOrganizerName.text = userModel.fullName ?? ""
                self.userName.text = "@\(userModel.username ?? "")"
                
                if let path = userModel.profilePic, !path.isEmpty {
                    self.topProfileImage.setImage(imageKey: path, placeholder: "profile-placeholder", shouldShowAnimationPlaceholder: true)
                }
                self.organizerName = userModel.fullName
                self.organizerEmail = userModel.email
            }
        }
    }

    private func setupMapView(event: Event) {
        let coordinates = CLLocationCoordinate2D(latitude: event.latitude ?? 0, longitude: event.longitude ?? 0)
        setCoordinatesOnMap(with: coordinates)
    }

    private func setupImages(event: Event) {
        if let img1 = event.eventImage1, !img1.isEmpty { imgArr.append(img1) }
        if let img2 = event.eventImage2, !img2.isEmpty { imgArr.append(img2) }
        if let img3 = event.eventImage3, !img3.isEmpty { imgArr.append(img3) }
        if let img4 = event.eventImage4, !img4.isEmpty { imgArr.append(img4) }
        headerCollectionView.reloadData()
        myPageView.numberOfPages = imgArr.count
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewProfileSeg", let VC = segue.destination as? ViewUserProfileController {
            VC.user = self.userModel
        }
    }

    @objc private func viewProfileClick() {
        performSegue(withIdentifier: "viewProfileSeg", sender: nil)
    }

    private func setCoordinatesOnMap(with coordinates: CLLocationCoordinate2D) {
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(pin)
        mapView.setRegion(MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)), animated: true)
        mapView.isScrollEnabled = false
    }

    @IBAction func ticketBtnClicked(_ sender: Any) {
            //Send Invites
    }

    @objc private func addEventToCalendar() {
        let eventStore = EKEventStore()
        eventStore.requestAccess(to: .event) { [weak self] granted, error in
            guard let self = self else { return }
            if granted && error == nil {
                let cevent = EKEvent(eventStore: eventStore)
                cevent.title = self.event?.eventTitle ?? "myMINK Event"
                cevent.startDate = self.event?.eventStartDate ?? Date()
                cevent.endDate = self.event?.eventEndDate ?? Date()
                cevent.notes = self.event?.eventDescription ?? "myMINK Description"
                cevent.calendar = eventStore.defaultCalendarForNewEvents
                do {
                    try eventStore.save(cevent, span: .thisEvent)
                    self.showSnack(messages: "This event has been added to your calendar.")
                } catch let e as NSError {
                    self.showError(e.localizedDescription)
                }
            } else {
                self.showMessage(title: "Permission Denied", message: "Please allow calendar access permission from device settings")
            }
        }
    }

    private func showMapOptions(latitude: Double, longitude: Double) {
        let alertController = UIAlertController(title: "Open Location", message: "Choose a Maps App", preferredStyle: .actionSheet)
        
        let googleMapsAction = UIAlertAction(title: "Google Maps", style: .default) { _ in
            if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) {
                let googleMapsURL = URL(string: "comgooglemaps://?q=\(latitude),\(longitude)")!
                UIApplication.shared.open(googleMapsURL, options: [:], completionHandler: nil)
            } else {
                self.showSnack(messages: "Google Maps is not installed.")
            }
        }
        
        let appleMapsAction = UIAlertAction(title: "Apple Maps", style: .default) { _ in
            let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary: nil))
            mapItem.name = "Target Location"
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(googleMapsAction)
        alertController.addAction(appleMapsAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }

    @objc private func changeImage() {
        if counter < imgArr.count {
            let index = IndexPath(item: counter, section: 0)
            headerCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
            myPageView.currentPage = counter
            counter += 1
        } else {
            counter = 0
            let index = IndexPath(item: counter, section: 0)
            headerCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
            myPageView.currentPage = counter
            counter = 1
        }
    }

    @objc private func backClicked() {
        dismiss(animated: true, completion: nil)
    }
}

extension ShowEventViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == headerCollectionView {
            return headerCollectionView.frame.size
        } else {
            return tagsCollectionView.frame.size
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}

extension ShowEventViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == tagsCollectionView {
            return tags.count
        }
        return imgArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == tagsCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagcell", for: indexPath) as? TagCell else {
                return TagCell()
            }
            cell.tagBtn.setTitle("#\(tags[indexPath.row])", for: .normal)
            cell.tagBtn.layer.cornerRadius = 8
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "headercell", for: indexPath) as? HeaderViewCell else {
                return HeaderViewCell()
            }
            let img = imgArr[indexPath.row]
            cell.mImage.setImage(imageKey: img, placeholder: "placeholder", width: 600, height: 400, shouldShowAnimationPlaceholder: true)
            return cell
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let visibleIndex = Int(targetContentOffset.pointee.x / headerCollectionView.frame.width)
        myPageView.currentPage = visibleIndex
        counter = visibleIndex
    }
}

extension ShowEventViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }
        showMapOptions(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
    }
}
