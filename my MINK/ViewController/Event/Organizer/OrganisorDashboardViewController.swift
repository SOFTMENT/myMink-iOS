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

class OrganisorDashboardViewController: UIViewController {

    @IBOutlet weak var switchUser: UIButton!
    @IBOutlet weak var pastContainer: UIView!
    @IBOutlet weak var upcomingContainer: UIView!
    @IBOutlet weak var createEvent: UIButton!
    @IBOutlet weak var bottomNavigation: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var dateAndTime: UILabel!

    var isProfilePicChanged = false
    var downloadURL: String = ""
    var upcomingOrganizer: OrganisorUpcomingDashboard?
    var pastOrganizer: OrganisorPastDashboard?
    var mUser: User!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        validateUser()
        getMyEvents()
    }

    private func setupUI() {
        createEvent.layer.cornerRadius = 8
        bottomNavigation.installBlurEffect(isTop: false)
        pastContainer.isHidden = true
        switchUser.layer.cornerRadius = 6
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
    }

    private func validateUser() {
        guard let organizer = UserModel.data else {
            dismiss(animated: true, completion: nil)
            return
        }
        guard let user = Auth.auth().currentUser else {
            logoutPlease()
            return
        }
        mUser = user
        name.text = String(format: "Hi, %@".localized(), organizer.fullName ?? "User")

        dateAndTime.text = convertDateForHomePage(Date())
    }

    @IBAction func switchUserClicked(_ sender: Any) {
        dismissOrShowFailure()
    }

    private func dismissOrShowFailure() {
        if presentingViewController != nil {
            dismiss(animated: true) {
                if self.presentingViewController != nil {
                    self.onDismissFailed()
                }
            }
        } else {
            onDismissFailed()
        }
    }

    private func onDismissFailed() {
        Constants.fromEventCreate = true
        Constants.selectedTabBarPosition = 6
        beRootScreen(storyBoardName: .tabBar, mIdentifier: .tabBarViewController)
    }

    private func getMyEvents() {
        ProgressHUDShow(text: "")
        Firestore.firestore().collection(Collections.events.rawValue).order(by: "eventStartDate", descending: true).whereField("eventOrganizerUid", isEqualTo: mUser.uid).addSnapshotListener { snapshot, error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error.localizedDescription)
                return
            }
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
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let upcomingVC = segue.destination as? OrganisorUpcomingDashboard {
            self.upcomingOrganizer = upcomingVC
        }
        if let pastVC = segue.destination as? OrganisorPastDashboard {
            self.pastOrganizer = pastVC
        }
    }

    @IBAction func createEventBtnClicked(_ sender: Any) {
        performSegue(withIdentifier: "createeventseg", sender: nil)
    }

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        pastContainer.isHidden = sender.selectedSegmentIndex != 1
        upcomingContainer.isHidden = sender.selectedSegmentIndex != 0
    }
}
