//
//  AttendeeDetails.swift
//  my MINK
//
//  Created by Vijay Rathore on 19/05/24.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class AttendeeDetails: UIViewController {
    
    @IBOutlet weak var checkedInView: UIView!
    @IBOutlet weak var checkInText: UILabel!
    @IBOutlet weak var checkInImg: UIImageView!
    @IBOutlet weak var checkInBtn: UIView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var checkedInTime: UILabel!
    @IBOutlet weak var ticketName: UILabel!
    @IBOutlet weak var orderNo: UILabel!
    var ticket : TicketModel?
    override func viewDidLoad() {
        
        guard let ticket = ticket else {
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
            return
        }
        checkedInView.isHidden = true
        
        userName.text = ticket.userName ?? "Something Went Wrong"
        userEmail.text = ticket.userEmail ?? "Something Went Wrong"
        orderNo.text = "#\(ticket.orderNumber ?? "Something Went Wrong")"
        ticketName.text = ticket.ticketName ?? "Something Went Wrong"
        
      
        
        
        
        checkInBtn.layer.cornerRadius = 8
        checkInBtn.isUserInteractionEnabled = true
        checkInBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(checkInBtnClicked)))

        if let isCheckedIn = ticket.isCheckedIn, isCheckedIn {
            checkInText.text = "Checked In"
            checkInImg.isHidden = false
            checkedInTime.text = self.convertDateForTicket(ticket.checkedInTime ?? Date())
            checkedInView.isHidden = false
        }
    }
    
    @objc func checkInBtnClicked(){
      
        if let isCheckedIn = ticket!.isCheckedIn, isCheckedIn {
            
            return
        }
        
        ProgressHUDShow(text: "")
        Firestore.firestore().collection(Collections.TICKETS.rawValue).document(ticket!.ticketId!).getDocument { snashot, error in
            if error == nil {
                if let snapshot = snashot, snapshot.exists{
                    if let ticket = try? snashot?.data(as: TicketModel.self) {
                        
                        if let isCheckedIn = ticket.isCheckedIn, isCheckedIn {
                            self.ProgressHUDHide()
                            let time = self.convertDateAndTimeFormater(ticket.checkedInTime ?? Date())
                            let messageString = "This ticket has already checked in at"
                            let alert = UIAlertController(title: "Duplicate Entry", message: "\(messageString)\n\(time)", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            
                            
                        }
                        else {
                            Firestore.firestore().collection(Collections.TICKETS.rawValue).document(ticket.ticketId!).setData(["isCheckedIn" : true, "checkedInTime" : FieldValue.serverTimestamp()],merge: true) { error in
                                self.ProgressHUDHide()
                                if error == nil {
                                    self.showSnack(messages: "Checked In")
                                    self.checkInText.text = "Checked In"
                                    self.checkInImg.isHidden = false
                                    self.checkedInTime.text = self.convertDateForTicket(Date())
                                    self.checkedInView.isHidden = false
                                    self.ticket?.isCheckedIn = true
                                    self.ticket?.checkedInTime = Date()
                                }
                                else {
                                    self.showSnack(messages: error!.localizedDescription)
                                    
                                }
                            }
                        }
                    }
                    
                }
                else {
                    self.ProgressHUDHide()
                    self.showSnack(messages: "No ticket available")
                    
                }
            }
            else {
                self.ProgressHUDHide()
                self.showError(error!.localizedDescription)
             
                
                
            }
        }
        
        
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
