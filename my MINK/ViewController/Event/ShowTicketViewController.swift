//
//  ShowTicketViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 18/05/24.
//


import UIKit
import SDWebImage
import Lottie
import EventKitUI
import Firebase
import FirebaseFirestoreSwift
import MapKit


public enum ClipCorner:Int {
    case top
    case center
    case bottom
    case all
}
public enum Views:Int {
    case topView
    case bottomView
}

class ShowTicketViewController: UIViewController {
  
    

    
    var orderNumber : String?
    var tickets : [TicketModel]?
    var willGoBack : Bool = false
    @IBOutlet weak var tableView: UITableView!
    var clips = [ClipCorner]()
    var path = UIBezierPath()

    @IBOutlet weak var backgroundImage: UIImageView!
    
    override func viewDidLoad() {
      
        
        updateUI(tickets: tickets)

    }
    
    
    func updateUI(tickets : [TicketModel]?){
       
        

        self.tickets = tickets
        if self.tickets == nil {
            self.tickets = []
            
            guard let orderNumber = orderNumber, orderNumber != "" else {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
                return
            }
            
            getTickets(by: self.orderNumber!)
            
           
        }
     
        tableView.delegate = self
        tableView.dataSource  = self
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    
    func getTickets(by orderNumber  : String) {
        self.ProgressHUDShow(text: "")
        Firestore.firestore().collection(Collections.TICKETS.rawValue).order(by: "ticketBookDate").whereField("orderNumber", isEqualTo: orderNumber).addSnapshotListener { snapshot, error in

            self.ProgressHUDHide()
            if error == nil {

                self.tickets!.removeAll()
                if let snap = snapshot, !snap.isEmpty {
                    for qdr in snap.documents {
                        if let ticket = try? qdr.data(as: TicketModel.self) {
                            self.tickets!.append(ticket)
                        }
                    }

                    self.tableView.reloadData()
                }
            }
            else {
                self.showError(error!.localizedDescription)
            }
        }
    }
    
    public func addClips(mView : UIView,to view:Views, corner clips:[ClipCorner]) {
        let viewFrames:CGRect
        if view == .bottomView {
            path = UIBezierPath(rect: mView.bounds)
            viewFrames = mView.bounds
        } else if view == .topView {
            path = UIBezierPath(rect: mView.frame)
            viewFrames = mView.frame
        } else {
            return
        }
        if clips.contains(.all) {
            overLay(points: CGPoint(x: viewFrames.origin.x - 15, y: viewFrames.origin.y - 15), view: view, mView: mView)
            overLay(points: CGPoint(x: viewFrames.origin.x + viewFrames.width - 15, y: viewFrames.origin.y - 15), view: view, mView: mView)
            overLay(points: CGPoint(x: viewFrames.origin.x - 15, y: viewFrames.origin.y + viewFrames.height - 15), view: view, mView: mView)
            overLay(points: CGPoint(x: viewFrames.origin.x + viewFrames.width - 15, y: viewFrames.origin.y + viewFrames.height - 15), view: view, mView: mView)
            overLay(points: CGPoint(x: viewFrames.origin.x - 15 , y:  (viewFrames.height/2) - 15), view: view, mView: mView)
            overLay(points:  CGPoint(x: viewFrames.origin.x + viewFrames.width - 15, y: (viewFrames.height/2) - 15), view: view, mView: mView)
        } else if clips.contains(.bottom) && clips.contains(.top) && clips.contains(.center){
            overLay(points: CGPoint(x: viewFrames.origin.x - 15, y: viewFrames.origin.y - 15), view: view, mView: mView)
            overLay(points: CGPoint(x: viewFrames.origin.x + viewFrames.width - 15, y: viewFrames.origin.y - 15), view: view, mView: mView)
            overLay(points: CGPoint(x: viewFrames.origin.x - 15, y: viewFrames.origin.y + viewFrames.height - 15), view: view, mView: mView)
            overLay(points: CGPoint(x: viewFrames.origin.x + viewFrames.width - 15, y: viewFrames.origin.y + viewFrames.height - 15), view: view, mView: mView)
            overLay(points: CGPoint(x: viewFrames.origin.x - 15 , y:  (viewFrames.height/2) - 15), view: view, mView: mView)
            overLay(points:  CGPoint(x: viewFrames.origin.x + viewFrames.width - 15, y: (viewFrames.height/2) - 15), view: view, mView: mView)
        } else if clips.contains(.bottom) && clips.contains(.top){
            overLay(points: CGPoint(x: viewFrames.origin.x - 15, y: viewFrames.origin.y - 15), view: view, mView: mView)
            overLay(points: CGPoint(x: viewFrames.origin.x + viewFrames.width - 15, y: viewFrames.origin.y - 15), view: view, mView: mView)
            overLay(points: CGPoint(x: viewFrames.origin.x - 15, y: viewFrames.origin.y + viewFrames.height - 15), view: view, mView: mView)
            overLay(points: CGPoint(x: viewFrames.origin.x + viewFrames.width - 15, y: viewFrames.origin.y + viewFrames.height - 15), view: view, mView: mView)
        } else if clips.contains(.bottom) && clips.contains(.center){
            overLay(points: CGPoint(x: viewFrames.origin.x - 15, y: viewFrames.origin.y + viewFrames.height - 15), view: view, mView: mView)
            overLay(points: CGPoint(x: viewFrames.origin.x + viewFrames.width - 15, y: viewFrames.origin.y + viewFrames.height - 15), view: view, mView: mView)
            overLay(points: CGPoint(x: viewFrames.origin.x - 15 , y:  (viewFrames.height/2) - 15), view: view, mView: mView)
            overLay(points:  CGPoint(x: viewFrames.origin.x + viewFrames.width - 15, y: (viewFrames.height/2) - 15), view: view, mView: mView)
        } else if clips.contains(.top) && clips.contains(.center){
            overLay(points: CGPoint(x: viewFrames.origin.x - 15, y: viewFrames.origin.y - 15), view: view, mView: mView)
            overLay(points: CGPoint(x: viewFrames.origin.x + viewFrames.width - 15, y: viewFrames.origin.y - 15), view: view, mView: mView)
            overLay(points: CGPoint(x: viewFrames.origin.x - 15 , y:  (viewFrames.height/2) - 15), view: view, mView: mView)
            overLay(points:  CGPoint(x: viewFrames.origin.x + viewFrames.width - 15, y: (viewFrames.height/2) - 15), view: view, mView: mView)
        } else if clips.contains(.center){
            overLay(points: CGPoint(x: viewFrames.origin.x - 15 , y:  (viewFrames.height/2) - 15), view: view, mView: mView)
            overLay(points:  CGPoint(x: viewFrames.origin.x + viewFrames.width - 15, y: (viewFrames.height/2) - 15), view: view, mView: mView)
        } else if clips.contains(.top) {
            overLay(points: CGPoint(x: viewFrames.origin.x - 15, y: viewFrames.origin.y - 15), view: view, mView: mView)
            overLay(points: CGPoint(x: viewFrames.origin.x + viewFrames.width - 15, y: viewFrames.origin.y - 15), view: view, mView: mView)
        } else if clips.contains(.bottom) {
            overLay(points: CGPoint(x: viewFrames.origin.x - 15, y: viewFrames.origin.y + viewFrames.height - 15), view: view, mView: mView)
            overLay(points: CGPoint(x: viewFrames.origin.x + viewFrames.width - 15, y: viewFrames.origin.y + viewFrames.height - 15), view: view, mView: mView)
        }
    }
    private func overLay(points: CGPoint,view:Views, mView : UIView) {
        let sizes = CGSize(width: 30, height: 30)
        let circlePath = UIBezierPath(ovalIn: CGRect(origin: points, size: sizes))
        path.append(circlePath)
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd
        if view == .topView {
            mView.layer.mask = maskLayer
        } else if view == .bottomView {
            mView.layer.mask = maskLayer
        }
    }
    
    // MARK: - Actions
    @objc func imageWasSaved(_ image: UIImage, error: Error?, context: UnsafeMutableRawPointer) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
      //  print("Image was saved in the photo gallery")
        self.showSnack(messages: "Image was saved in the photo gallery")
    }
    
    func takeScreenshot(of view: UIView) {
        UIGraphicsBeginImageContextWithOptions(
            CGSize(width: view.bounds.width, height: view.bounds.height),
            false,
            2
        )
        
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        UIImageWriteToSavedPhotosAlbum(screenshot, self, #selector(imageWasSaved), nil)
    }
    
    
    @IBAction func moreBtnClicked(_ sender: Any) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
     
        alert.addAction(UIAlertAction(title: "View Map", style: .default, handler: { action in
           
            if let tickets = self.tickets, tickets.count > 0 {
               
                    let myGestMap = MyGesture()
                    myGestMap.latitude = tickets[0].latitude ?? 0
                    myGestMap.longitude = tickets[0].longitude ?? 0
                    self.showOpenMapPopup(myGest: myGestMap)
                
            }

        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        
        present(alert, animated: true, completion: nil)
    }
    
    
 
    
    
    @IBAction func backBtnPressed(_ sender: Any) {
        if willGoBack {
            self.dismiss(animated: true, completion: nil)
        }
        else {
            self.beRootScreen(storyBoardName: StoryBoard.Tabbar, mIdentifier: Identifier.TABBARVIEWCONTROLLER)
        }
    }
    
    public func generateQrCode(code : String) -> UIImage? {
        
        let code = code.data(using: .ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(code, forKey: "inputMessage")
           
            let transform = CGAffineTransform(scaleX: 8, y: 8)
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
    
    @objc func showEvent(myGest : MyGesture){
        self.ProgressHUDShow(text: "")
        self.getEvent(by: myGest.id) { event in
            self.ProgressHUDHide()
            if let event = event {
                self.performSegue(withIdentifier: "eventseg", sender: event)
            }
            else {
                self.showSnack(messages: "Something Went Wrong")
            }
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "eventseg" {
            if let vc = segue.destination as? ShowEventViewController {
                if let event = sender as? Event {
                    vc.event = event
                }
            }
        }
    }
    
    @objc func addEventToCalendar(myGest : MyGesture){
        
        let eventStore = EKEventStore()
        
        eventStore.requestAccess(to: .event, completion: { (granted, error) in
            if (granted) && (error == nil) {
                let cevent = EKEvent(eventStore: eventStore)
                cevent.title = myGest.ticket!.eventName ?? "Something Went Wrong"
                cevent.startDate = myGest.ticket!.eventStartDate ?? Date()
                cevent.endDate =  myGest.ticket!.eventEndDate ?? Date()
                cevent.notes =  myGest.ticket!.eventSummary ?? "Something Went Wrong"
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
        })
    }
    
    @objc func showOpenMapPopup(myGest : MyGesture){
        let alert = UIAlertController(title: "", message: "Open in maps", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Apple Maps", style: .default, handler: { action in
            
            let coordinate = CLLocationCoordinate2DMake(myGest.latitude!,myGest.longitude!)
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
            mapItem.name = "Event Location"
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
        }))
        
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            
            alert.addAction(UIAlertAction(title: "Google Maps", style: .default, handler: { action in
                
                UIApplication.shared.open(URL(string:"comgooglemaps://?center=\(myGest.latitude!),\(myGest.longitude!)&zoom=14&views=traffic&q=\(myGest.latitude!),\(myGest.longitude!)")!, options: [:], completionHandler: nil)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func saveTicketAsImageClicked(myGest : MyGesture){
        takeScreenshot(of: myGest.mView!)
    }
    
    
}

extension ShowTicketViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tickets!.count > 0 {
            if let image = tickets![0].eventImage, image != "" {
           
                
                self.backgroundImage.sd_setImage(with: URL(string: image), completed: nil)
                
                
            }
        }
        return tickets!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "showticketcell", for: indexPath) as? ShowTicketTableViewCell {
            
            let ticket = tickets![indexPath.row]
        
            addClips(mView: cell.topView, to: .topView, corner: [.bottom])
            addClips(mView: cell.bottomView, to: .bottomView, corner: [.top])
            addClips(mView: cell.middleView, to: .bottomView, corner: [.top,.bottom])
            cell.saveTicketAsImageBtn.layer.borderWidth = 1.2
            cell.saveTicketAsImageBtn.layer.borderColor = UIColor.gray.cgColor
            cell.saveTicketAsImageBtn.layer.cornerRadius = 8
            cell.saveTicketAsImageBtn.isUserInteractionEnabled = true
            let viewGest = MyGesture(target: self, action: #selector(saveTicketAsImageClicked(myGest:)))
            viewGest.mView = cell.mainView
            cell.saveTicketAsImageBtn.addGestureRecognizer(viewGest)
          
            
                cell.onlineInstructionView.isHidden = true
                cell.qrCodeView.isHidden = false
                cell.qrCodeImageView.image = self.generateQrCode(code: ticket.ticketId!)
                cell.venueView.isHidden = false
           
            
            cell.userName.text = ticket.userName ?? "Error"
            cell.eventName.text = ticket.eventName ?? "Error"
            cell.ticketName.text = ticket.ticketName ?? "Error"
            cell.eventStartEndDate.text = self.convertDateForShowTicket(ticket.eventStartDate ?? Date(), endDate: ticket.eventEndDate ?? Date())
            cell.addressName.text = ticket.addressName ?? "Error"
            cell.orderNumber.text = "#\(ticket.orderNumber!)"
            cell.eventSummary.text = ticket.eventSummary ?? "Error"
            cell.organizerName.text = ticket.organizerName ?? "Error"
            cell.eventTime.text = "\(self.convertTimeFormater(ticket.eventStartDate ?? Date())) - \(self.convertTimeFormater(ticket.eventEndDate ?? Date()))"
            
            cell.addToCalendar.isUserInteractionEnabled = true
            let myGestForCalendar = MyGesture(target: self, action: #selector(addEventToCalendar(myGest:)))
            myGestForCalendar.ticket = ticket
            cell.addToCalendar.addGestureRecognizer(myGestForCalendar)
            
            cell.viewMap.isUserInteractionEnabled = true
            let myGestMap = MyGesture(target: self, action: #selector(showOpenMapPopup(myGest:)))
            myGestMap.latitude = ticket.latitude ?? 0
            myGestMap.longitude = ticket.longitude ?? 0
            cell.viewMap.addGestureRecognizer(myGestMap)
            
            cell.viewEventListing.isUserInteractionEnabled = true
            let myGestEvent = MyGesture(target: self, action: #selector(showEvent(myGest:)))
            myGestEvent.id = ticket.eventId!
            cell.viewEventListing.addGestureRecognizer(myGestEvent)
            
            let ofString = "of"
            cell.ticketCount.text = "\(indexPath.row + 1) \(ofString) \(ticket.quantity ?? 1)"
            return cell
        }
        
        return ShowTicketTableViewCell()
    }
    
    
}
