//
//  OrganizerViewEventDetails.swift
//  my MINK
//
//  Created by Vijay Rathore on 19/05/24.
//
import UIKit
import Firebase
import FirebaseFirestoreSwift

class OrganizerViewEventDetails: UIViewController {

    @IBOutlet weak var topTitle: UILabel!
    @IBOutlet weak var topDate: UILabel!
    @IBOutlet weak var headView: UIView!
    @IBOutlet weak var checkInContainer: UIView!
    @IBOutlet weak var ordersContainer: UIView!
    var checkInVC : CheckInViewController?
    var ordersVC : OrdersViewController?
    var event : Event?
    var tickets : [TicketModel] = []
    
    override func viewDidLoad() {
        
        guard event != nil else {
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
            return
        }
 
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        ordersContainer.isHidden = true
        
        
        topTitle.text = event!.eventTitle ?? "Something Went Wrong"
        topDate.text = convertDateForTicket(event!.eventStartDate ?? Date())
        
        getOrders(by: event!.eventOrganizerUid!)
    }
    

    public func getOrders(by organizerId : String) {
        ProgressHUDShow(text: "")
        Firestore.firestore().collection("Tickets").order(by: "ticketBookDate",descending: true).whereField("eventId", isEqualTo: event!.eventId!).addSnapshotListener(includeMetadataChanges: true) { snapshot, error in
            
            self.ProgressHUDHide()
            if error == nil {
                self.tickets.removeAll()
                if let snapshot = snapshot, !snapshot.isEmpty {
                    for qdr in snapshot.documents {
                        if let ticket = try? qdr.data(as: TicketModel.self) {
                            self.tickets.append(ticket)
                        }
                    }
                }
                self.checkInVC?.notifyAdapter(checkInData: self.tickets)
                self.ordersVC?.notifyAdapter(ordersData: self.tickets)
            }
            else {
                print(error!.localizedDescription)
            }
        }
        
        
    }
    
    
    
    
    
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        
        checkInContainer.isHidden = true
        ordersContainer.isHidden = true
        
        if sender.selectedSegmentIndex == 0 {
            checkInContainer.isHidden = false
        }
        else {
            ordersContainer.isHidden = false
        }
        
    }
    
    @IBAction func backBtnClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let checkInVC = segue.destination as? CheckInViewController {
            self.checkInVC = checkInVC
        }
        if let ordersVC = segue.destination as? OrdersViewController {
            self.ordersVC = ordersVC
        }
    }
    
    
}
