// Copyright © 2023 SOFTMENT. All rights reserved.

import Firebase
import UIKit

class TabbarViewController: UIViewController {
    // Outlets for tab bar buttons and images
    @IBOutlet var pageView: UIView!
    @IBOutlet var homeBtn: UIView!
    @IBOutlet var searchBtn: UIView!
    @IBOutlet var liveBtn: UIView!
    @IBOutlet var cameraBtn: UIView!
    @IBOutlet var reelBtn: UIView!
    @IBOutlet var notificationBtn: UIView!
    @IBOutlet var userBtn: UIView!

    @IBOutlet var homeImage: UIImageView!
    @IBOutlet var searchImage: UIImageView!
    @IBOutlet var liveImage: UIImageView!
    @IBOutlet var cameraImage: UIImageView!
    @IBOutlet var reelImage: UIImageView!
    @IBOutlet var notificationImage: UIImageView!
    @IBOutlet var userImage: UIImageView!
    @IBOutlet weak var notificationCountView: UIView!
    @IBOutlet weak var notificationCount: UILabel!
    let badgeCountKey = "badgeCountKey"
    // Page view controller for managing child view controllers
    var pageViewController: UIPageViewController!

    // Lazy loading of view controllers
    lazy var viewControllers: [UIViewController] = {
        let homeVC = UIStoryboard.load(.home, .homeViewController) as! HomeViewController
        homeVC.performDynamicLinkSegue()
        
        let searchVC = UIStoryboard.load(.search, .searchViewController) as! SearchViewController
        let liveVC = UIStoryboard.load(.liveStream, .liveStreamViewController) as! LiveViewController
        let cameraVC = UIStoryboard.load(.home, .cameraViewController) as! CameraViewController
        let reelVC = UIStoryboard.load(.reels, .reelsViewController) as! ReelViewController
        reelVC.getAllPosts(isManual: false)
        
        let notificationVC = UIStoryboard.load(.notification, .notificationController) as! NotificationViewController
        let profileVC = UIStoryboard.load(.profile, .profileViewController) as! ProfileViewController

        return [homeVC, searchVC, liveVC, cameraVC, reelVC, notificationVC, profileVC]
    }()

    override var prefersStatusBarHidden: Bool {
        true
    }
   

    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        FirebaseStoreManager.messaging.subscribe(toTopic: "all")

        // Check if the user is authenticated
        guard FirebaseStoreManager.auth.currentUser != nil else {
            DispatchQueue.main.async {
                self.logoutPlease()
            }
            return
        }
        
        notificationCountView.layer.cornerRadius = notificationCountView.bounds.height / 2

        
        updateNotificationCounts()
        
        observeUserStatus()
        updateFCMToken()

        // Initialize and configure the page view controller
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        pageViewController.setViewControllers([viewControllers[0]], direction: .forward, animated: true)
        pageView.addSubview(pageViewController.view)
        pageViewController.view.frame = pageView.frame
        pageViewController.didMove(toParent: self)

        // Set up gesture recognizers for tab bar buttons
        setupGestureRecognizers()

        // Handle initial selected tab based on Constants.selectedTabBarPosition
        switch Constants.selectedTabBarPosition {
        case 0:
            homeBtnClicked()
        case 1:
            searchBtnClicked()
        case 3:
            cameraBtnClicked()
        case 5:
            notificationBtnClicked()
        case 6:
            userBtnClicked()
        default:
            homeBtnClicked()
        }
    }
    
 
    func updateNotificationCounts() {
        
        self.notificationCountView.isHidden = true
        
        FirebaseStoreManager.db.collection(Collections.users.rawValue)
            .document(FirebaseStoreManager.auth.currentUser!.uid)
            .collection("UnreadNotifications")
            .document("doc")
            .addSnapshotListener { snapshot, error in
                
                if let error = error {
                    print("Error fetching unread notifications: \(error)")
                    return
                }
                
                // Check if the document exists and has data
                guard let data = snapshot?.data() else {
                    print("Document does not exist or has no data")
                    return
                }
               
                // Try to get the 'count' field from the document data
                if let count = data["count"] as? Int {
                 
                    if count > 0 {
                        self.notificationCountView.isHidden = false
                        self.notificationCount.text = String(count)
                    }
                    else {
                        self.notificationCountView.isHidden = true
                    }
                    
                    self.notificationCountView.layoutIfNeeded()
                    self.loadViewIfNeeded()
                }
            }

        
      
        
    }

    func resetBadgeNumber() {
            FirebaseStoreManager.db.collection(Collections.users.rawValue).document(FirebaseStoreManager.auth.currentUser!.uid).collection("UnreadNotifications")
            .document("doc").setData(["count":0])
            notificationCountView.isHidden = true
            notificationCount.text = ""
        }
    
    // Updates the FCM token for notifications
    func updateFCMToken() {
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM token: \(error)")
            } else if let token = token {
                self.updateUserNotificationToken(token)
            }
        }
    }

    // Helper function to update user and business notification tokens
    private func updateUserNotificationToken(_ token: String) {
        if let currentUser = FirebaseStoreManager.auth.currentUser {
            UserModel.data?.notificationToken = token
            FirebaseStoreManager.db.collection(Collections.users.rawValue).document(currentUser.uid)
                .setData(["notificationToken": token], merge: true)

            getBusinessesBy(currentUser.uid) { businessModel, error in
                if let businessModel = businessModel, let businessId = businessModel.businessId, !businessId.isEmpty {
                    FirebaseStoreManager.db.collection(Collections.businesses.rawValue).document(businessId)
                        .setData(["notificationToken": token], merge: true)
                }
            }
        } else {
            logoutPlease()
        }
    }

    // Resets images for all tab bar buttons to their default state
    func resetImageOfAllBtn() {
        homeImage.image = UIImage(named: "Home1F")
        searchImage.image = UIImage(named: "loupe-2")
        liveImage.image = UIImage(named: "signal")
        cameraImage.image = UIImage(named: "camera1F")
        reelImage.image = UIImage(named: "video1F")
        notificationImage.image = UIImage(named: "notification1F")
        userImage.image = UIImage(named: "user1F")
    }

    // Sets up gesture recognizers for tab bar buttons
    private func setupGestureRecognizers() {
        let buttons = [homeBtn, searchBtn, liveBtn, cameraBtn, reelBtn, notificationBtn, userBtn]
        let selectors: [Selector] = [
            #selector(homeBtnClicked),
            #selector(searchBtnClicked),
            #selector(liveBtnClicked),
            #selector(cameraBtnClicked),
            #selector(reelBtnClicked),
            #selector(notificationBtnClicked),
            #selector(userBtnClicked)
        ]

        for (button, selector) in zip(buttons, selectors) {
            button?.isUserInteractionEnabled = true
            button?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: selector))
        }
    }

    @objc func homeBtnClicked() {
        switchToViewController(at: 0, withImageName: "home2F", andResetOtherImages: true)
    }

    @objc func searchBtnClicked() {
        searchStart(search: "")
    }

    func searchStart(search: String) {
        if hasMembership() {
            switchToViewController(at: 1, withImageName: "magnifying-glass-5", andResetOtherImages: true, search: search)
        } else {
            performSegue(withIdentifier: "membershipSeg", sender: nil)
        }
    }

    @objc func liveBtnClicked() {
        if hasMembership() {
            switchToViewController(at: 2, withImageName: "signal-stream", andResetOtherImages: true)
        } else {
            performSegue(withIdentifier: "membershipSeg", sender: nil)
        }
    }

    @objc func cameraBtnClicked() {
        if hasMembership() {
            switchToViewController(at: 3, withImageName: "camera2F", andResetOtherImages: true)
        } else {
            performSegue(withIdentifier: "membershipSeg", sender: nil)
        }
    }

    @objc func reelBtnClicked() {
        if hasMembership() {
            switchToViewController(at: 4, withImageName: "video2F", andResetOtherImages: true)
        } else {
            performSegue(withIdentifier: "membershipSeg", sender: nil)
        }
    }

    @objc func notificationBtnClicked() {
        if hasMembership() {
            self.resetBadgeNumber()
            switchToViewController(at: 5, withImageName: "notification2F", andResetOtherImages: true)
        } else {
            performSegue(withIdentifier: "membershipSeg", sender: nil)
        }
    }

    @objc func userBtnClicked() {
        switchToViewController(at: 6, withImageName: "user2F", andResetOtherImages: true)
    }

    // Helper function to switch view controllers
    private func switchToViewController(at index: Int, withImageName imageName: String, andResetOtherImages reset: Bool, search: String = "") {
        if reset { resetImageOfAllBtn() }
        switch index {
        case 0:
            homeImage.image = UIImage(named: imageName)
            if let homeVC = viewControllers[0] as? HomeViewController, Constants.selectedTabBarPosition == 0 {
                homeVC.scrollToTop(animated: true)
            }
            pageViewController.setViewControllers([viewControllers[0]], direction: .reverse, animated: true)
        case 1:
            searchImage.image = UIImage(named: imageName)
            if search != "", let searchVC = viewControllers[1] as? SearchViewController {
                searchVC.searchStart(searchText: search)
                pageViewController.setViewControllers([searchVC], direction: Constants.selectedTabBarPosition > 1 ? .reverse : .forward, animated: true)
            } else {
                pageViewController.setViewControllers([viewControllers[1]], direction: Constants.selectedTabBarPosition > 1 ? .reverse : .forward, animated: true)
            }
        case 2:
            liveImage.image = UIImage(named: imageName)
            pageViewController.setViewControllers([viewControllers[2]], direction: Constants.selectedTabBarPosition > 2 ? .reverse : .forward, animated: true)
        case 3:
            cameraImage.image = UIImage(named: imageName)
            pageViewController.setViewControllers([viewControllers[3]], direction: Constants.selectedTabBarPosition > 3 ? .reverse : .forward, animated: true)
        case 4:
            reelImage.image = UIImage(named: imageName)
            if let reelVC = viewControllers[4] as? ReelViewController, Constants.selectedTabBarPosition == 4 {
                reelVC.scrollToTop(animated: true)
            }
            pageViewController.setViewControllers([viewControllers[4]], direction: .forward, animated: true)
        case 5:
            notificationImage.image = UIImage(named: imageName)
            pageViewController.setViewControllers([viewControllers[5]], direction: Constants.selectedTabBarPosition > 5 ? .reverse : .forward, animated: true)
        case 6:
            userImage.image = UIImage(named: imageName)
            if let profileVC = viewControllers[6] as? ProfileViewController, Constants.selectedTabBarPosition == 6 {
                profileVC.scrollToTop(animated: true)
            }
            pageViewController.setViewControllers([viewControllers[6]], direction: .forward, animated: true)
        default:
            break
        }
        Constants.selectedTabBarPosition = index
    }
}
