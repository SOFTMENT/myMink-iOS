// Copyright © 2023 SOFTMENT. All rights reserved.

import UIKit

class MembershipDetailsViewController: UIViewController {
    @IBOutlet var topView: UIView!
    @IBOutlet var mView: UIView!
    @IBOutlet var backView: UIView!
    @IBOutlet var membershipPrice: UILabel!
    @IBOutlet var status: UILabel!
    @IBOutlet var unsubscribeBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureMembershipDetails()
    }

    private func setupUI() {
        mView.clipsToBounds = true
        mView.layer.cornerRadius = 20
        mView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        unsubscribeBtn.layer.cornerRadius = 8

        backView.isUserInteractionEnabled = true
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(backViewClicked)
        ))

        topView.isUserInteractionEnabled = true
        topView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
    }

    private func configureMembershipDetails() {
        guard let userModel = UserModel.data else { return }

        switch userModel.activeEntitlement {
        case PriceID.month.rawValue:
            membershipPrice.text = "$14.99/month"
        case PriceID.year.rawValue:
            membershipPrice.text = "$26.99/year"
        default:
            membershipPrice.text = ""
        }

        status.text = userModel.entitlementStatus?.capitalized ?? "INACTIVE"

        if userModel.entitlementStatus == "active" ||  userModel.entitlementStatus == "trialing"{
            status.textColor = UIColor(red: 92 / 255, green: 184 / 255, blue: 92 / 255, alpha: 1)
          
        } else {
            status.textColor = .red
           
        }
    }

    @objc private func backViewClicked() {
        dismiss(animated: true)
    }

    @IBAction private func unsubscribeBtnClicked(_: Any) {
        
        self.showCancelSubscriptionAlert()
      
    }
    
    
    func showCancelSubscriptionAlert() {
        let alertController = UIAlertController(title: "Manage Subscription", message: "You will be redirected to the App Store where you can manage or cancel your subscription.", preferredStyle: .alert)

        // Add the action to open the App Store subscription page
        let manageAction = UIAlertAction(title: "Continue", style: .default) { _ in
            self.openAppStoreSubscriptionManagement()
        }
        
        // Add a cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // Add the actions to the alert controller
        alertController.addAction(manageAction)
        alertController.addAction(cancelAction)
        
        // Present the alert to the user
        self.present(alertController, animated: true)
    }

    func openAppStoreSubscriptionManagement() {
        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                print("Can't open App Store subscriptions page.")
            }
        }
    }
}
