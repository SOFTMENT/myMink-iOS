// Copyright © 2023 SOFTMENT. All rights reserved.

import UIKit

// MARK: - VIPCodeViewController

class VIPCodeViewController: UIViewController {
    @IBOutlet var codeTF: UITextField!
    @IBOutlet var backView: UIView!
    @IBOutlet var getLinkBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    private func setupViews() {
        getLinkBtn.layer.cornerRadius = 8
        backView.layer.cornerRadius = 8
        backView.dropShadow()

        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))

        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }

    @objc private func backBtnClicked() {
        dismiss(animated: true)
    }

    @objc private func hideKeyboard() {
        view.endEditing(true)
    }

    @IBAction private func getLinkClicked(_: Any) {
        guard let sCode = codeTF.text, !sCode.isEmpty else {
            showSnack(messages: "Enter VIP Code".localized())
            return
        }
        
        ProgressHUDShow(text: "Verifying".localized())
        verifyCouponCode(sCode)
    }

    private func verifyCouponCode(_ sCode: String) {
        getCouponModelBy(couponId: sCode) { [weak self] couponModel in
            guard let self = self else { return }
            self.ProgressHUDHide()
            
            if let couponModel = couponModel {
            
                FirebaseStoreManager.db.collection("Coupons").document(couponModel.id!).delete()
                self.updateUserModel(for: sCode)
            
            } else {
                self.showError("Invalid Coupon Code or Redeemed.".localized())
            }
        }
    }

    private func updateUserModel(for sCode: String) {
        UserModel.data?.activeEntitlement = PriceID.lifetime.rawValue
        UserModel.data?.entitlementStatus = "active"
        UserModel.data?.isAccountActive = true

        let userUpdates: [String: Any] = [
            "status": "active",
            "isAccountActive": true,
            "activeEntitlement" : PriceID.lifetime.rawValue
        ]

        FirebaseStoreManager.db.collection(Collections.users.rawValue)
            .document(FirebaseStoreManager.auth.currentUser!.uid)
            .setData(userUpdates, merge: true) { [weak self] error in
                if let error = error {
                    self?.showError(error.localizedDescription)
                } else {
                    self?.deleteCoupon(sCode: sCode)
                    self?.performSegue(withIdentifier: "successSeg", sender: nil)
                }
            }
    }
}

// MARK: UITextFieldDelegate

extension VIPCodeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
