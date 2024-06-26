//
//  OrganisorDashboardViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 19/05/24.
//

import UIKit
import SDWebImage
import Firebase
import FirebaseFirestoreSwift
import CropViewController

class OrganisorDashboardViewController : UIViewController {
    
    @IBOutlet weak var switchUser: UIButton!
    
    @IBOutlet weak var pastContainer: UIView!
    @IBOutlet weak var upcomingContainer: UIView!
    @IBOutlet weak var createEvent: UIButton!
    @IBOutlet weak var bottomNavigation: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var dateAndTime: UILabel!
    @IBOutlet weak var settingsView: UIView!

    var isProfilePicChanged = false
    var downloadURL : String = ""
    var upcomingOrganizer : OrganisorUpcomingDashboard?
    var pastOrganizer : OrganisorPastDashboard?
    
    var mUser : User!
    override func viewDidLoad() {
        
        guard let organizer = UserModel.data else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        guard let user = Auth.auth().currentUser else {
            self.logoutPlease()
            return
        }
        mUser = user
        
      
        let hi = "Hi"
        name.text = "\(hi), \(organizer.fullName ?? "User")"
        dateAndTime.text = self.convertDateForHomePage(Date())
        
       
        settingsView.layer.cornerRadius = 12
        createEvent.layer.cornerRadius = 8
        bottomNavigation.installBlurEffect(isTop: false)
        pastContainer.isHidden  = true
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        settingsView.isUserInteractionEnabled = true
        settingsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(settingsViewClicked)))
   
        switchUser.layer.cornerRadius = 6
        
        //GET MY EVENTS
        getMyEvents()
    }
     
    @IBAction func switchUserClicked(_ sender: Any) {
        if self.presentingViewController != nil {
                   self.dismiss(animated: true) {
                       // Check if the view controller is actually dismissed
                       if self.presentingViewController != nil {
                           self.onDismissFailed()
                       }
                   }
               } else {
                   self.onDismissFailed()
               }
    }
    
    func onDismissFailed() {
        Constants.FROM_EVENT_CREATE = true
        Constants.selectedTabbarPosition = 6
        self.beRootScreen(storyBoardName: .Tabbar, mIdentifier: .TABBARVIEWCONTROLLER)
    }
    
    public func getMyEvents(){
        ProgressHUDShow(text: "")
        
        
        Firestore.firestore().collection(Collections.EVENTS.rawValue).order(by: "eventStartDate",descending: true).whereField("eventOrganizerUid", isEqualTo: mUser.uid).addSnapshotListener { snapshot, error in
            self.ProgressHUDHide()
            if error == nil {
                Event.datas.removeAll()
                if let snap = snapshot, !snap.isEmpty {
                    for qds in snap.documents {
                       
                            if let event = try? qds.data(as: Event.self) {
                                Event.datas.append(event)
                             
                            }
                        
                    }
                    
                    self.upcomingOrganizer?.notifyAdapter()
                    self.pastOrganizer?.notifyAdapter()
                    
                }
               
            }
            else {
                self.showError(error!.localizedDescription)
            }
        }
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let upcomingVC = segue.destination as? OrganisorUpcomingDashboard {
            self.upcomingOrganizer = upcomingVC
        }
        if let pastVC = segue.destination as? OrganisorPastDashboard {
            self.pastOrganizer = pastVC
        }
    }
    
    @objc func settingsViewClicked() {
        performSegue(withIdentifier: "walletSeg", sender: nil)
    }
    
    
    @IBAction func createEventBtnClicked(_ sender: Any) {
        performSegue(withIdentifier: "createeventseg", sender: nil)
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        pastContainer.isHidden = true
        upcomingContainer.isHidden = true
        
        if sender.selectedSegmentIndex == 0 {
            upcomingContainer.isHidden = false
            
        }
        else {
            pastContainer.isHidden = false
            
        }
    }
    
    
}








