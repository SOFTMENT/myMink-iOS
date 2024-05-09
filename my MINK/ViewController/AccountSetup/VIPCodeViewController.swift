// Copyright © 2023 SOFTMENT. All rights reserved.

//
//  VIPCodeViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 05/06/23.
//
import UIKit

// MARK: - VIPCodeViewController

class VIPCodeViewController: UIViewController {
    @IBOutlet var codeTF: UITextField!

    @IBOutlet var backView: UIView!

    @IBOutlet var getLinkBtn: UIButton!

    override func viewDidLoad() {
        self.getLinkBtn.layer.cornerRadius = 8

        self.backView.isUserInteractionEnabled = true
        self.backView.layer.cornerRadius = 8
        self.backView.dropShadow()
        self.backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backBtnClicked)))

        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard)))
    }

    @objc func backBtnClicked() {
        dismiss(animated: true)
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }

    @IBAction func getLinkClicked(_: Any) {
        let sCode = self.codeTF.text
        if sCode == "" {
            showSnack(messages: "Enter VIP Code")
        } else {
            ProgressHUDShow(text: "Verifying")
            getCouponModelBy(couponId: sCode ?? "") { couponModel in
            
                if let couponCode = couponModel {
                    UserModel.data!.planID = PriceID.LIFETIME.rawValue
                    UserModel.data?.daysLeft = 3
                    UserModel.data?.status = "active"
                    UserModel.data?.isAccountActive = true
                    FirebaseStoreManager.db.collection("Users").document(FirebaseStoreManager.auth.currentUser!.uid).setData(["planID" : PriceID.LIFETIME.rawValue,"status" : "active","isAccountActive" : true],merge: true) { error in
                        self.ProgressHUDHide()
                        if let error = error {
                            self.showError(error.localizedDescription)
                        }
                        else {
                        
                            self.deleteCoupon(sCode: sCode ?? "123")
                         
                            self.performSegue(withIdentifier: "successSeg", sender: nil)
                         
                        }
                    }
                }
                else {
                    self.showError("Invalid Coupon Code.")
                    self.ProgressHUDHide()
                }
            }
        }
    }
}

// MARK: UITextFieldDelegate

extension VIPCodeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
