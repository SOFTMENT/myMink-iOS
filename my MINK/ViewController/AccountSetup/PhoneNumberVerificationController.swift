// Copyright © 2023 SOFTMENT. All rights reserved.

import Firebase
import FirebaseAuth
import UIKit

// MARK: - PhoneNumberVerificationController

class PhoneNumberVerificationController: UIViewController {
    @IBOutlet var backView: UIView!
    @IBOutlet var codeTF: UITextField!
    @IBOutlet var getLinkBtn: UIButton!
    var verificationID: String?
    var fullName: String?
    var phoneNumber: String?
    @IBOutlet var resendCode: UILabel!
    var countdownTimer: Timer?
    var totalTime = 59
    var for2FA = false

    override func viewDidLoad() {
        guard self.verificationID != nil else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
 
            return
        }

        if self.for2FA {
            self.getLinkBtn.setTitle("Enable 2FA", for: .normal)
        }

        self.codeTF.delegate = self

        self.getLinkBtn.layer.cornerRadius = 8

        self.backView.isUserInteractionEnabled = true
        self.backView.layer.cornerRadius = 8
        self.backView.dropShadow()
        self.backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backBtnClicked)))

        self.startTimer()
        self.resendCode.isUserInteractionEnabled = true
        self.resendCode.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.resendCodeBtnClicked)
        ))

        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard)))
    }

    func startTimer() {
        self.totalTime = 59
        self.countdownTimer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(self.updateTime),
            userInfo: nil,
            repeats: true
        )
    }

    @objc func updateTime() {
        self.resendCode.text = "\(self.totalTime) seconds remaining"

        if self.totalTime != 0 {
            self.totalTime -= 1
        } else {
            self.endTimer()
        }
    }

    func endTimer() {
        self.countdownTimer?.invalidate()
        self.countdownTimer = nil
        self.resendCode.text = "Resend Code"
    }

    @objc func resendCodeBtnClicked() {
        if self.resendCode.text == "Resend Code" {
            self.ProgressHUDShow(text: "")

            self.codeTF.text = ""
            self.sendTwilioVerification(to: self.verificationID!) { error in
                DispatchQueue.main.async {
                    self.ProgressHUDHide()
                    if let error = error {
                        self.showError(error)
                    } else {
                        self.showSnack(messages: "Code has been sent")
                    }
                }
            }
        }
    }

    @objc func backBtnClicked() {
        self.logoutPlease()
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }

    @IBAction func getLinkClicked(_: Any) {
        let sCode = self.codeTF.text
        if sCode == "" {
            showSnack(messages: "Enter Verification Code")
        } else {
            self.ProgressHUDShow(text: "Verifying...")
            self.verifyTwilioCode(phoneNumber: self.phoneNumber!, code: sCode!) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.ProgressHUDHide()
                        self.showError(error)
                    } else {
                        if self.for2FA {
                            FirebaseStoreManager.db.collection("Users")
                                .document(FirebaseStoreManager.auth.currentUser!.uid)
                                .setData(
                                    ["is2FAActive": true, "phoneNumber2FA": self.phoneNumber ?? ""],
                                    merge: true
                                ) { error in
                                    self.ProgressHUDHide()
                                    if let error = error {
                                        self.showError(error.localizedDescription)
                                    } else {
                                        UserModel.data?.is2FAActive = true
                                        UserModel.data?.phoneNumber2FA = self.phoneNumber
                                        let alert = UIAlertController(
                                            title: "Activated",
                                            message: "We have enabled 2FA for your account.",
                                            preferredStyle: .alert
                                        )
                                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                                            self.beRootScreen(
                                                storyBoardName: StoryBoard.Tabbar,
                                                mIdentifier: Identifier.TABBARVIEWCONTROLLER
                                            )
                                        }))
                                        self.present(alert, animated: true)
                                    }
                                }
                        } else {
                            self.createCustomToken(userId: self.verificationID!) { token, error in
                                if let error = error {
                                    self.ProgressHUDHide()
                                    self.showError("Custom Token : \(error)")
                                } else {
                                        
                                      
                                    
                                        FirebaseStoreManager.auth.signIn(withCustomToken: token!) { auth, error in
                                            self.ProgressHUDHide()
                                            if let error = error {
                                                self.showError("Sign Up : \(error.localizedDescription)")
                                            } else {
                                                if let fullName = self.fullName {
                                                    let userData = UserModel()
                                                    userData.isBlocked = false
                                                    userData.fullName = fullName
                                                    userData.uid = self.verificationID!
                                                    userData.registredAt = auth!.user.metadata.creationDate ?? Date()
                                                    userData.regiType = "phone"
                                                    userData.phoneNumber = self.phoneNumber
                                                    self.addUserData(userData: userData)
                                                } else {
                                                    self.getUserData(uid: self.verificationID!, showProgress: true)
                                                }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: UITextFieldDelegate

extension PhoneNumberVerificationController: UITextFieldDelegate {
    func textFieldShouldReturn(_: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
