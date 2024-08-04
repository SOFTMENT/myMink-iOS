// Copyright © 2023 SOFTMENT. All rights reserved.

import StoreKit
import UIKit

// MARK: - SettingsPresentationController

class SettingsPresentationController: UIPresentationController {
    // MARK: Lifecycle

    init(
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?,
        profileVC: ProfileViewController
    ) {
        self.profileVC = profileVC

        self.blurEffectView = UIView()
        self.blurEffectView.backgroundColor = UIColor.clear

        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)

        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissController(r:)))

        self.blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.blurEffectView.isUserInteractionEnabled = true
        self.blurEffectView.tag = 2
        self.blurEffectView.addGestureRecognizer(self.tapGestureRecognizer)
    }

    // MARK: Internal

    let blurEffectView: UIView!
    let profileVC: ProfileViewController?
    var tapGestureRecognizer: UITapGestureRecognizer = .init()
    var isBlurBtnSelected = false

    override var frameOfPresentedViewInContainerView: CGRect {
        CGRect(
            origin: CGPoint(x: 0, y: self.containerView!.frame.height - 565),
            size: CGSize(width: self.containerView!.frame.width, height: 565)
        )
    }

    @objc func redirectToLegalAgreements() {
        self.dismissController(r: UITapGestureRecognizer())
        self.profileVC?.performSegue(withIdentifier: "legalAgreementSeg", sender: nil)
    }

    @objc func shareApp() {
        self.dismissController(r: UITapGestureRecognizer())
        if let name = URL(string: "https://itunes.apple.com/us/app/my-MINK/id6448769013?ls=1&mt=8"),
           !name.absoluteString.isEmpty
        {
            let objectsToShare = [name]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            self.profileVC!.present(activityVC, animated: true, completion: nil)
        }
    }

    @objc func rateUs() {
        self.dismissController(r: UITapGestureRecognizer())
        if #available(iOS 14.0, *) {
            if let scene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
            {
                SKStoreReviewController.requestReview(in: scene)
            }
        } else if let url = URL(string: "itms-apps://itunes.apple.com/app/" + "6448769013") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    @objc func contactUsClicked() {
        self.dismissController(r: UITapGestureRecognizer())
        guard let url = URL(string: "https://mymink.com.au/contact-us/") else {
            return
        }
        UIApplication.shared.open(url)
    }

    @objc func membershipViewClicked() {
        self.dismissController(r: UITapGestureRecognizer())
        self.profileVC?.performSegue(withIdentifier: "membershipDetailsSeg", sender: nil)
    }

    @objc func accountPrivacyClicked() {
        self.dismissController(r: UITapGestureRecognizer())
        self.profileVC?.performSegue(withIdentifier: "accountPrivacySeg", sender: nil)
    }

    @objc func editProfileClicked() {
        self.dismissController(r: UITapGestureRecognizer())
        self.profileVC?.performSegue(withIdentifier: "updateProfileSeg", sender: nil)
    }
    
    @objc func savedViewClicked() {
        self.dismissController(r: UITapGestureRecognizer())
        self.profileVC?.performSegue(withIdentifier: "savedSeg", sender: nil)
    }

    @objc func logoutME() {
        self.dismissController(r: UITapGestureRecognizer())

        let alert = UIAlertController(
            title: "Logout",
            message: "Are you sure you want to logout?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { _ in

            self.profileVC?.logoutPlease()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.profileVC?.present(alert, animated: true)
    }

    override func presentationTransitionWillBegin() {
        guard let profileVC = profileVC else { return }

        // LegalAgreements
        profileVC.settingsVC.legalAgreements.isUserInteractionEnabled = true
        profileVC.settingsVC.legalAgreements.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.redirectToLegalAgreements)
        ))

        // shareapp
        profileVC.settingsVC.shareApp.isUserInteractionEnabled = true
        profileVC.settingsVC.shareApp.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.shareApp)
        ))

        // RateUs
        profileVC.settingsVC.rateApp.isUserInteractionEnabled = true
        profileVC.settingsVC.rateApp.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.rateUs)
        ))

        // AccountPrivacy
        profileVC.settingsVC.accountPrivacy.isUserInteractionEnabled = true
        profileVC.settingsVC.accountPrivacy.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.accountPrivacyClicked)
        ))

        // Contact US
        profileVC.settingsVC.contactUs.isUserInteractionEnabled = true
        profileVC.settingsVC.contactUs.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.contactUsClicked)
        ))

        // EditProfile
        profileVC.settingsVC.editProfile.isUserInteractionEnabled = true
        profileVC.settingsVC.editProfile.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.editProfileClicked)
        ))
        
        //Saved
        profileVC.settingsVC.savedView.isUserInteractionEnabled = true
        profileVC.settingsVC.savedView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.savedViewClicked)
        ))

        // MembershipView
        profileVC.settingsVC.membershipView.layer.cornerRadius = 8

        if let profilePath = UserModel.data?.profilePic, !profilePath.isEmpty {
            profileVC.settingsVC.profilePic.setImage(
                imageKey: profilePath,
                placeholder: "profile-placeholder",
                width: 100,
                height: 100,
                shouldShowAnimationPlaceholder: true
            )
        }

        profileVC.settingsVC.name.text = UserModel.data?.fullName ?? ""
        profileVC.settingsVC.email.text = UserModel.data?.email ?? UserModel.data?.phoneNumber ?? ""

        profileVC.settingsVC.logoutBtn.isUserInteractionEnabled = true
        profileVC.settingsVC.logoutBtn.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.logoutME)
        ))

        if let daysLeft = UserModel.data?.daysLeft, daysLeft > 0 {
            if UserModel.data?.planID == PriceID.lifetime.rawValue {
                profileVC.settingsVC.membershipView.isHidden = true
            } else {
                if let isFree = UserModel.data?.isDuringTrial, isFree {
                    profileVC.settingsVC.timeLeft.text = "\(daysLeft) free \(daysLeft > 1 ? "days" : "day")"
                } else {
                    profileVC.settingsVC.timeLeft.text = "\(daysLeft) \((daysLeft) > 1 ? "days" : "day")"
                }

                profileVC.settingsVC.membershipView.isUserInteractionEnabled = true
                profileVC.settingsVC.membershipView.addGestureRecognizer(UITapGestureRecognizer(
                    target: self,
                    action: #selector(self.membershipViewClicked)
                ))
            }
        } else {
            profileVC.settingsVC.membershipView.isHidden = true
        }

        containerView?.addSubview(self.blurEffectView)
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
        }, completion: { _ in })
    }

    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
        }, completion: { _ in
            self.blurEffectView.removeFromSuperview()
            if !self.isBlurBtnSelected {
                self.dismissController(r: UITapGestureRecognizer())
            }
        })
    }

    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedView!.roundCorners([.topLeft, .topRight], radius: 50)
    }

    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        presentedView?.frame = self.frameOfPresentedViewInContainerView
        self.blurEffectView.frame = containerView!.bounds
    }

    @objc func dismissController(r: UITapGestureRecognizer) {
        if r.view?.tag == 2 {
            self.isBlurBtnSelected = true
        } else {
            self.isBlurBtnSelected = false
        }

        presentedViewController.dismiss(animated: true, completion: nil)
    }
}

extension UIView {
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
