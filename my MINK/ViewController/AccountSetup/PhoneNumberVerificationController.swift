// Copyright © 2023 SOFTMENT. All rights reserved.

import Firebase
import FirebaseAuth
import UIKit

// MARK: - PhoneNumberVerificationController

class PhoneNumberVerificationController: UIViewController {
    @IBOutlet var backView: UIView!
    @IBOutlet var codeTF: UITextField!
    @IBOutlet var getLinkBtn: UIButton!
    @IBOutlet var resendCode: UILabel!

    var verificationID: String?
    var fullName: String?
    var phoneNumber: String?
    var countdownTimer: Timer?
    var totalTime = 59
    var for2FA = false

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let verificationID = verificationID else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }

        if for2FA {
            getLinkBtn.setTitle("Enable 2FA", for: .normal)
        }

        setupViews()
        startTimer()
    }

    private func setupViews() {
        codeTF.delegate = self
        getLinkBtn.layer.cornerRadius = 8

        backView.isUserInteractionEnabled = true
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))

        resendCode.isUserInteractionEnabled = true
        resendCode.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(resendCodeBtnClicked)))

        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }

    private func startTimer() {
        totalTime = 59
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }

    @objc private func updateTime() {
        resendCode.text = "\(totalTime) seconds remaining"
        totalTime -= 1

        if totalTime == 0 {
            endTimer()
        }
    }

    private func endTimer() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        resendCode.text = "Resend Code"
    }

    @objc private func resendCodeBtnClicked() {
        guard resendCode.text == "Resend Code" else { return }
        
        ProgressHUDShow(text: "")

        codeTF.text = ""
        sendTwilioVerification(to: verificationID!) { error in
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

    @objc private func backBtnClicked() {
        logoutPlease()
    }

    @objc private func hideKeyboard() {
        view.endEditing(true)
    }

    @IBAction private func getLinkClicked(_: Any) {
        guard let sCode = codeTF.text, !sCode.isEmpty else {
            showSnack(messages: "Enter Verification Code")
            return
        }

        ProgressHUDShow(text: "Verifying...")
        verifyTwilioCode(phoneNumber: phoneNumber!, code: sCode) { error in
            DispatchQueue.main.async {
                self.ProgressHUDHide()
                if let error = error {
                    self.showError(error)
                } else {
                    self.handleVerificationSuccess()
                }
            }
        }
    }

    private func handleVerificationSuccess() {
        if for2FA {
            enable2FA()
        } else {
            authenticateUser()
        }
    }

    private func enable2FA() {
        FirebaseStoreManager.db.collection(Collections.users.rawValue)
            .document(FirebaseStoreManager.auth.currentUser!.uid)
            .setData(["is2FAActive": true, "phoneNumber2FA": phoneNumber ?? ""], merge: true) { error in
                self.ProgressHUDHide()
                if let error = error {
                    self.showError(error.localizedDescription)
                } else {
                    UserModel.data?.is2FAActive = true
                    UserModel.data?.phoneNumber2FA = self.phoneNumber
                    self.show2FAActivationAlert()
                }
            }
    }

    private func show2FAActivationAlert() {
        let alert = UIAlertController(
            title: "Activated",
            message: "We have enabled 2FA for your account.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.beRootScreen(storyBoardName: StoryBoard.tabBar, mIdentifier: Identifier.tabBarViewController)
        })
        present(alert, animated: true)
    }

    private func authenticateUser() {
        createCustomToken(userId: verificationID!) { token, error in
            if let error = error {
                self.ProgressHUDHide()
                self.showError("Custom Token : \(error)")
            } else {
                self.signInWithCustomToken(token!)
            }
        }
    }

    private func signInWithCustomToken(_ token: String) {
        FirebaseStoreManager.auth.signIn(withCustomToken: token) { authResult, error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError("Sign Up : \(error.localizedDescription)")
            } else if let fullName = self.fullName {
                self.createUserModel(authResult: authResult, fullName: fullName)
            } else {
                self.getUserData(uid: self.verificationID!, showProgress: true)
            }
        }
    }

    private func createUserModel(authResult: AuthDataResult?, fullName: String) {
        let userData = UserModel()
        userData.isBlocked = false
        userData.fullName = fullName
        userData.uid = verificationID!
        userData.registredAt = authResult?.user.metadata.creationDate ?? Date()
        userData.regiType = "phone"
        userData.phoneNumber = phoneNumber
        addUserData(userData: userData)
    }
}

// MARK: - UITextFieldDelegate

extension PhoneNumberVerificationController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyboard()
        return true
    }
}
