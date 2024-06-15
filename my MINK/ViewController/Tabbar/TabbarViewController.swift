// Copyright © 2023 SOFTMENT. All rights reserved.

import Firebase
import UIKit

class TabbarViewController: UIViewController {
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

    var pageViewController: UIPageViewController!
    
    lazy var viewControllers: [UIViewController] = {
        let homeVC = UIStoryboard.load(.Home, .HOMEVIEWCONTROLLER) as! HomeViewController
        homeVC.tabbar = self
        homeVC.performDynamicLinkSegue()
        let searchVC = UIStoryboard.load(.Search, .SEARCHVIEWCONTROLLER) as! SearchViewController
        let liveVC = UIStoryboard.load(.LiveStream, .LIVESTREAMVIEWCONTROLLER) as! LiveViewController
        let cameraVC = UIStoryboard.load(.Home, .CAMERAVIEWCONTROLLER) as! CameraViewController
        let reelVC = UIStoryboard.load(.Reels, .REELSVIEWCONTROLLER) as! ReelViewController
        reelVC.getAllPosts(isManual: false)
        let notificationVC = UIStoryboard.load(.Notification, .NOTIFICATIONCONTROLLER) as! NotificationViewController
        let profileVC = UIStoryboard.load(.Profile, .PROFILEVIEWCONTROLLER) as! ProfileViewController

        return [homeVC, searchVC, liveVC, cameraVC, reelVC, notificationVC, profileVC]
    }()

    override var prefersStatusBarHidden: Bool {
        true
    }

    override func viewDidLoad() {
    
        
        guard FirebaseStoreManager.auth.currentUser != nil else {
            DispatchQueue.main.async {
                self.logoutPlease()
            }
            return
        }
        
            self.observeUserStatus()
        
            self.updateFCMToken()

            self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
            self.pageViewController.setViewControllers([self.viewControllers[0]], direction: .forward, animated: true)
            self.pageView.addSubview(self.pageViewController.view)
            self.pageViewController.view.frame = self.pageView.frame
            self.pageViewController.didMove(toParent: self)

            self.homeBtn.isUserInteractionEnabled = true
            self.homeBtn.addGestureRecognizer(UITapGestureRecognizer(
                target: self,
                action: #selector(self.homeBtnClicked)
            ))

            self.searchBtn.isUserInteractionEnabled = true
            self.searchBtn.addGestureRecognizer(UITapGestureRecognizer(
                target: self,
                action: #selector(self.searchBtnClicked)
            ))

            self.liveBtn.isUserInteractionEnabled = true
            self.liveBtn.addGestureRecognizer(UITapGestureRecognizer(
                target: self,
                action: #selector(self.liveBtnClicked)
            ))

            self.cameraBtn.isUserInteractionEnabled = true
            self.cameraBtn.addGestureRecognizer(UITapGestureRecognizer(
                target: self,
                action: #selector(self.cameraBtnClicked)
            ))

            self.reelBtn.isUserInteractionEnabled = true
            self.reelBtn.addGestureRecognizer(UITapGestureRecognizer(
                target: self,
                action: #selector(self.reelBtnClicked)
            ))

            self.notificationBtn.isUserInteractionEnabled = true
            self.notificationBtn.addGestureRecognizer(UITapGestureRecognizer(
                target: self,
                action: #selector(self.notificationBtnClicked)
            ))

            self.userBtn.isUserInteractionEnabled = true
            self.userBtn.addGestureRecognizer(UITapGestureRecognizer(
                target: self,
                action: #selector(self.userBtnClicked)
            ))

            switch Constants.selectedTabbarPosition {
            case 0:
                self.homeBtnClicked()
            case 1:
                self.searchBtnClicked()
            case 3:
                self.cameraBtnClicked()
            case 6:
                self.userBtnClicked()
            default:
                self.homeBtnClicked()
            }
       
    }

    func updateFCMToken() {
        Messaging.messaging().token { token, error in
            if error != nil {
            } else if let token = token {
                if let currentUser = FirebaseStoreManager.auth.currentUser {
                    UserModel.data?.notificationToken = token
                    FirebaseStoreManager.db.collection(Collections.USERS.rawValue).document(currentUser.uid)
                        .setData(["notificationToken": token], merge: true)
                    
                    self.getBusinessesBy(currentUser.uid) { businessModel, error in
                        if let businessModel = businessModel {
                            FirebaseStoreManager.db.collection(Collections.BUSINESSES.rawValue).document(businessModel.businessId ?? "123")
                                .setData(["notificationToken": token], merge: true)
                        }
                    }
                }
                else {
                    self.logoutPlease()
                }
               
            }
        }
    }

    func resetImageOfAllBtn() {
        self.homeImage.image = UIImage(named: "Home1F")
        self.searchImage.image = UIImage(named: "loupe-2")
        self.liveImage.image = UIImage(named: "signal")
        self.cameraImage.image = UIImage(named: "camera1F")
        self.reelImage.image = UIImage(named: "video1F")
        self.notificationImage.image = UIImage(named: "notification1F")
        self.userImage.image = UIImage(named: "user1F")
    }

    @objc func homeBtnClicked() {
        self.resetImageOfAllBtn()
        self.homeImage.image = UIImage(named: "home2F")

        if let homeVC = viewControllers[0] as? HomeViewController {
            if Constants.selectedTabbarPosition == 0 {
                homeVC.scrollToTop(animated: true)
            }
            self.pageViewController.setViewControllers([homeVC], direction:.reverse, animated: true)
        }
        
        Constants.selectedTabbarPosition = 0
    }

    @objc func searchBtnClicked() {
        self.searchStart(search: "")
        Constants.selectedTabbarPosition = 1
    }

    func searchStart(search: String) {
        
        if hasMembership() {
            self.resetImageOfAllBtn()
            self.searchImage.image = UIImage(named: "magnifying-glass-5")

            var direction = UIPageViewController.NavigationDirection.forward

            if Constants.selectedTabbarPosition > 1 {
                direction = .reverse
            }
            if search != "" {
                if let searchVC = viewControllers[1] as? SearchViewController {
                    searchVC.searchStart(searchText: search)
                    self.pageViewController.setViewControllers([searchVC], direction: direction, animated: true)
                }
            } else {
                self.pageViewController.setViewControllers([self.viewControllers[1]], direction: direction, animated: true)
            }

            Constants.selectedTabbarPosition = 1
        }
        else {
            performSegue(withIdentifier: "membershipSeg", sender: nil)
        }
        
     
    }

    @objc func liveBtnClicked() {
        if hasMembership() {
            self.resetImageOfAllBtn()
            self.liveImage.image = UIImage(named: "signal-stream")

            var direction = UIPageViewController.NavigationDirection.forward

            if Constants.selectedTabbarPosition > 2 {
                direction = .reverse
            }

            self.pageViewController.setViewControllers([self.viewControllers[2]], direction: direction, animated: true)

            Constants.selectedTabbarPosition = 2
        }
        else {
            performSegue(withIdentifier: "membershipSeg", sender: nil)
        }
        
        
    }

    @objc func cameraBtnClicked() {
        
        if hasMembership() {
            self.resetImageOfAllBtn()
            self.cameraImage.image = UIImage(named: "camera2F")
            var direction = UIPageViewController.NavigationDirection.forward

            if Constants.selectedTabbarPosition > 3 {
                direction = .reverse
            }

            self.pageViewController.setViewControllers([self.viewControllers[3]], direction: direction, animated: true)
            Constants.selectedTabbarPosition = 3
        }
        else {
            performSegue(withIdentifier: "membershipSeg", sender: nil)
        }
        
    }

    @objc func reelBtnClicked() {
        
        if hasMembership() {
            self.resetImageOfAllBtn()
            self.reelImage.image = UIImage(named: "video2F")

            var direction = UIPageViewController.NavigationDirection.forward

            if Constants.selectedTabbarPosition > 4 {
                direction = .reverse
            }
            
            
            if let reelVC = viewControllers[4] as? ReelViewController {
                if Constants.selectedTabbarPosition == 4 {
                    reelVC.scrollToTop(animated: true)
                }
                self.pageViewController.setViewControllers([reelVC], direction:direction, animated: true)
            }
            
          

            Constants.selectedTabbarPosition = 4
        }
        else {
            performSegue(withIdentifier: "membershipSeg", sender: nil)
        }
      
    }

    @objc func notificationBtnClicked() {
        
        if hasMembership() {
            self.resetImageOfAllBtn()
            self.notificationImage.image = UIImage(named: "notification2F")
            var direction = UIPageViewController.NavigationDirection.forward

            if Constants.selectedTabbarPosition > 5 {
                direction = .reverse
            }
            self.pageViewController.setViewControllers([self.viewControllers[5]], direction: direction, animated: true)

            Constants.selectedTabbarPosition = 5
        }
        else {
            performSegue(withIdentifier: "membershipSeg", sender: nil)
        }
        
      
    }

    @objc func userBtnClicked() {
        
        
        if let profileVC = viewControllers[6] as? ProfileViewController {
            if Constants.selectedTabbarPosition == 6 {
                profileVC.scrollToTop(animated: true)
            }
            self.pageViewController.setViewControllers([profileVC], direction:.forward, animated: true)
        }
        
        Constants.selectedTabbarPosition = 6
    
        self.resetImageOfAllBtn()
        self.userImage.image = UIImage(named: "user2F")
    }
}
