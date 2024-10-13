// Copyright © 2023 SOFTMENT. All rights reserved.

import UIKit

// MARK: - EmailVerificationController

class EmailVerificationController: UIViewController {
    @IBOutlet var backView: UIView!
    @IBOutlet var codeTF: UITextField!
    @IBOutlet var verifyBtn: UIButton!
    @IBOutlet var resendCode: UILabel!

    var verificationCode: String?
    var type: EmailVerificationType?
    var email: String?
    var userModel: UserModel?
    var countdownTimer: Timer?
    var totalTime = 59

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        startTimer()
    }

    private func setupViews() {
        verifyBtn.layer.cornerRadius = 8
        codeTF.delegate = self

        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))

        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))

        codeTF.becomeFirstResponder()

        resendCode.isUserInteractionEnabled = true
        resendCode.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(resendCodeBtnClicked)))
    }

    private func startTimer() {
        totalTime = 59
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }

    @objc private func updateTime() {
        resendCode.text = String(format: "%d seconds remaining".localized(), totalTime)

        if totalTime != 0 {
            totalTime -= 1
        } else {
            endTimer()
        }
    }

    @objc private func resendCodeBtnClicked() {
        guard resendCode.text == "Resend Code" else { return }
        ProgressHUDShow(text: "")

        guard let verificationCode = verificationCode, let email = email else { return }

        if type == .EMAIL_VERIFICATION {
            sendVerificationMail(randomNumber: verificationCode, email: email)
        } else {
            sendResetMail(randomNumber: verificationCode, email: email)
        }
    }

    private func sendResetMail(randomNumber: String, email: String) {
        sendMail(
            to_name: "my MINK",
            to_email: email,
            subject: "Retrieve Password",
            body: getPasswordResetTemplate(randomNumber: randomNumber)
        ) { error in
            DispatchQueue.main.async {
                self.ProgressHUDHide()
                if error.isEmpty {
                    self.showSnack(messages: "Code has been sent".localized())
                } else {
                    self.showError(error)
                }
            }
        }
    }

    private func sendVerificationMail(randomNumber: String, email: String) {
        sendMail(
            to_name: "my MINK",
            to_email: email,
            subject: "Email Verification".localized(),
            body: getEmailVerificationTemplate(randomNumber: randomNumber)
        ) { error in
            DispatchQueue.main.async {
                self.ProgressHUDHide()
                if error.isEmpty {
                    self.showSnack(messages: "Code has been sent".localized())
                } else {
                    self.showError(error)
                }
            }
        }
    }

    private func endTimer() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        resendCode.text = "Resend Code".localized()
    }

    @objc private func hideKeyboard() {
        view.endEditing(true)
    }

    @objc private func backBtnClicked() {
        dismiss(animated: true)
    }

    @IBAction private func verifyBtnClicked(_: Any) {
        guard let sCode = codeTF.text, !sCode.isEmpty else {
            showSnack(messages: "Enter Code".localized())
            return
        }

        guard let verificationCode = verificationCode, sCode == verificationCode else {
            showSnack(messages: "Incorrect Code".localized())
            return
        }

        if type == .RESET_PASSWORD {
            handlePasswordReset()
        } else {
            handleEmailVerification()
        }
    }

    private func handlePasswordReset() {
        guard let email = email else { return }
        ProgressHUDShow(text: "")
        FirebaseStoreManager.db.collection(Collections.users.rawValue)
            .whereField("email", isEqualTo: email)
            .whereField("regiType", isEqualTo: "custom")
            .getDocuments { snapshot, error in
                self.ProgressHUDHide()
                if let snapshot = snapshot, !snapshot.isEmpty, let resetPasswordModel = try? snapshot.documents[0].data(as: ResetPasswordModel.self) {
                    let password = try! self.decryptMessage(encryptedMessage: resetPasswordModel.encryptPassword ?? "", encryptionKey: resetPasswordModel.encryptKey ?? "")
                    self.performSegue(withIdentifier: "copyPasswordSeg", sender: password)
                } else {
                    self.showError("Account not registered with this email address.".localized())
                }
            }
    }

    private func handleEmailVerification() {
        guard let userModel = userModel else { return }
        let password = try? decryptMessage(encryptedMessage: userModel.encryptPassword ?? "", encryptionKey: userModel.encryptKey ?? "")
        ProgressHUDShow(text: "Creating Account...".localized())
        FirebaseStoreManager.auth.createUser(withEmail: userModel.email ?? "", password: password ?? "") { _, error in
            self.ProgressHUDHide()
            if error == nil {
                userModel.uid = FirebaseStoreManager.auth.currentUser?.uid
                self.addUserData(userData: userModel)
            } else {
                self.showError(error!.localizedDescription)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "copyPasswordSeg", let VC = segue.destination as? CopyPasswordViewController, let password = sender as? String {
            VC.password = password
            VC.email = email
        }
    }
}

// MARK: - UITextFieldDelegate

extension EmailVerificationController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

// MARK: - EmailVerificationType

enum EmailVerificationType {
    case RESET_PASSWORD
    case EMAIL_VERIFICATION
}
