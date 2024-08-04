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

        switch userModel.planID {
        case PriceID.month.rawValue:
            membershipPrice.text = "$14.99/month"
        case PriceID.year.rawValue:
            membershipPrice.text = "$26.99/year"
        default:
            membershipPrice.text = ""
        }

        status.text = userModel.status?.capitalized

        if userModel.status == "active" {
            status.textColor = UIColor(red: 92 / 255, green: 184 / 255, blue: 92 / 255, alpha: 1)
            unsubscribeBtn.isHidden = false
        } else {
            status.textColor = .red
            unsubscribeBtn.isHidden = true
        }
    }

    @objc private func backViewClicked() {
        dismiss(animated: true)
    }

    @IBAction private func unsubscribeBtnClicked(_: Any) {
        guard let sub_id = UserModel.data?.subscriptionId else { return }

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
                    if let success = success, success {
                        self.unsubscribeBtn.isHidden = true
                        self.status.textColor = .red
                        self.status.text = "Cancelled"
                        UserModel.data?.status = "Cancelled"
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
