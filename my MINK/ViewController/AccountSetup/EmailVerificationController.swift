// Copyright © 2023 SOFTMENT. All rights reserved.

import UIKit

// MARK: - EmailVerificationController

class EmailVerificationController: UIViewController {
    @IBOutlet var backView: UIView!
    @IBOutlet var codeTF: UITextField!
    @IBOutlet var verifyBtn: UIButton!

    var verificationCode: String?
    var type: EmailVerificationType?
    var email: String?
    var userModel: UserModel?
    @IBOutlet var resendCode: UILabel!
    var countdownTimer: Timer?
    var totalTime = 59
    override func viewDidLoad() {
        self.verifyBtn.layer.cornerRadius = 8
        self.codeTF.delegate = self

        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard)))

        self.backView.layer.cornerRadius = 8
        self.backView.dropShadow()
        self.backView.isUserInteractionEnabled = true
        self.backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backBtnClicked)))

        self.codeTF.becomeFirstResponder()

        self.startTimer()
        self.resendCode.isUserInteractionEnabled = true
        self.resendCode.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.resendCodeBtnClicked)
        ))
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

    @objc func resendCodeBtnClicked() {
        if self.resendCode.text == "Resend Code" {
            
        
            self.ProgressHUDShow(text: "")

            if self.type! == .EMAIL_VERIFICATION {
                self.sendVerificationMail(randomNumber: self.verificationCode!, email: self.email!)
            } else {
                self.sendResetMail(randomNumber: self.verificationCode!, email: self.email!)
            }
        }
    }

    func sendResetMail(randomNumber: String, email: String) {
        self.email = email

        sendMail(
            to_name: "my MINK",
            to_email: email,
            subject: "Retrieve Password",
            body: getPasswordResetTemplate(randomNumber: randomNumber)
        ) { error in
            DispatchQueue.main.async {
                self.ProgressHUDHide()
                if error == "" {
                    self.showSnack(messages: "Code has been sent")
                } else {
                    self.showError(error)
                }
            }
        }
    }

    func sendVerificationMail(randomNumber: String, email: String) {
        ProgressHUDShow(text: "")

        sendMail(
            to_name: "my MINK",
            to_email: email,
            subject: "Email Verification",
            body: getEmailVerificationTemplate(randomNumber: randomNumber)
        ) { error in
            DispatchQueue.main.async {
                self.ProgressHUDHide()
                if error == "" {
                    self.showSnack(messages: "Code has been sent")
                } else {
                    self.showError(error)
                }
            }
        }
    }

    func endTimer() {
        self.countdownTimer?.invalidate()
        self.countdownTimer = nil
        self.resendCode.text = "Resend Code"
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }

    @objc func backBtnClicked() {
        dismiss(animated: true)
    }

    @IBAction func verifyBtnClicked(_: Any) {
        let sCode = self.codeTF.text
        if sCode == "" {
            showSnack(messages: "Enter Code")
        } else if sCode! != self.verificationCode! {
            showSnack(messages: "Incorrect Code")
        } else {
            if self.type == .RESET_PASSWORD {
                ProgressHUDShow(text: "")
                FirebaseStoreManager.db.collection("Users").whereField("email", isEqualTo: self.email!)
                    .whereField("regiType", isEqualTo: "custom").getDocuments { snapshot, _ in
                        self.ProgressHUDHide()
                        if let snapshot = snapshot, !snapshot.isEmpty {
                            if let resetPasswordModel = try? snapshot.documents[0].data(as: ResetPasswordModel.self) {
                                let password = try! self.decryptMessage(
                                    encryptedMessage: resetPasswordModel.encryptPassword ?? "123",
                                    encryptionKey: resetPasswordModel.encryptKey ?? "123"
                                )
                                self.performSegue(withIdentifier: "copyPasswordSeg", sender: password)
                            }
                        } else {
                            self.showError("Account not registered with this mail address.")
                        }
                    }
            } else {
                let password = try? decryptMessage(
                    encryptedMessage: self.userModel!.encryptPassword ?? "123",
                    encryptionKey: self.userModel!.encryptKey ?? "key"
                )
                ProgressHUDShow(text: "Creating Account...")
                FirebaseStoreManager.auth.createUser(
                    withEmail: self.userModel!.email ?? "123",
                    password: password ?? "password"
                ) { _, error in
                    self.ProgressHUDHide()
                    if error == nil {
                        self.userModel?.uid = FirebaseStoreManager.auth.currentUser!.uid
                        self.addUserData(userData: self.userModel!)
                    } else {
                        self.showError(error!.localizedDescription)
                    }
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "copyPasswordSeg" {
            if let VC = segue.destination as? CopyPasswordViewController {
                if let password = sender as? String {
                    VC.password = password
                    VC.email = self.email
                }
            }
        }
    }
}

// MARK: UITextFieldDelegate

extension EmailVerificationController: UITextFieldDelegate {
    func textFieldShouldReturn(_: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

// MARK: - EmailVerificationType

enum EmailVerificationType {
    case RESET_PASSWORD
    case EMAIL_VERIFICATION
}
