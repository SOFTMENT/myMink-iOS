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
        self.mView.clipsToBounds = true
        self.mView.layer.cornerRadius = 20
        self.mView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        if UserModel.data!.planID == PriceID.MONTH.rawValue {
            self.membershipPrice.text = "$14.99/month"
        } else if UserModel.data!.planID == PriceID.YEAR.rawValue {
            self.membershipPrice.text = "$26.99/year"
        }

        self.status.text = UserModel.data!.status?.capitalized

        if UserModel.data!.status == "active" {
            self.status.textColor = UIColor(red: 92 / 255, green: 184 / 255, blue: 92 / 255, alpha: 1)
            self.unsubscribeBtn.isHidden = false
        } else {
            self.status.textColor = .red
            self.unsubscribeBtn.isHidden = true
        }

        self.unsubscribeBtn.layer.cornerRadius = 8

        self.backView.isUserInteractionEnabled = true
        self.backView.layer.cornerRadius = 8
        self.backView.dropShadow()
        self.backView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.backViewClicked)
        ))

        self.topView.isUserInteractionEnabled = true
        self.topView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backViewClicked)))
    }

    @objc func backViewClicked() {
        dismiss(animated: true)
    }

    @IBAction func unsubscribeBtnClicked(_: Any) {
        if let sub_id = UserModel.data!.subscriptionId {
            let alert = UIAlertController(
                title: "UNSUBSCRIBE",
                message: "Are you sure you want to unsubscribe my MINK membership?",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Unsubscribe", style: .destructive, handler: { _ in
                self.ProgressHUDShow(text: "")
                self.callCancelSubscriptionFunction(subId: sub_id) { success, error in
                    DispatchQueue.main.async {
                        self.ProgressHUDHide()
                        if let sucess = success,sucess {
                            self.unsubscribeBtn.isHidden = true
                            self.status.textColor = .red
                            self.status.text = "Cancelled"
                        } else {
                            self.showError("Something went wrong. Please contact us.")
                        }
                    }
                }
            }))

            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
        }
    }
}
