// Copyright © 2023 SOFTMENT. All rights reserved.

import UIKit

// MARK: - ResetPasswordViewController

class ResetPasswordViewController: UIViewController {
    @IBOutlet var backView: UIView!
    @IBOutlet var emailAddressTF: UITextField!
    @IBOutlet var getLinkBtn: UIButton!
    var email: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupGestures()
    }

    private func setupViews() {
        emailAddressTF.delegate = self
        getLinkBtn.layer.cornerRadius = 8
        backView.layer.cornerRadius = 8
        backView.dropShadow()
    }

    private func setupGestures() {
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

    @IBAction func getLinkClicked(_: Any) {
        guard let sEmail = emailAddressTF.text, !sEmail.isEmpty else {
            showSnack(messages: "Enter email address")
            return
        }
        ProgressHUDShow(text: "Retrieving Password...")

        FirebaseStoreManager.db.collection(Collections.users.rawValue).whereField("email", isEqualTo: sEmail)
            .whereField("regiType", isEqualTo: "custom").getDocuments { snapshot, _ in

                if let snapshot = snapshot, !snapshot.isEmpty {
                    let n = Int.random(in: 10000...99999)
                    self.sendResetMail(randomNumber: String(n), email: sEmail)
                } else {
                    self.ProgressHUDHide()
                    self.showError("Account not registered with this mail address.")
                }
            }
    }

    private func sendResetMail(randomNumber: String, email: String) {
        self.email = email
        let passwordResetHTMLTemplate = getPasswordResetTemplate(randomNumber: randomNumber)
        sendMail(
            to_name: "my MINK",
            to_email: email,
            subject: "Retrieve Password",
            body: passwordResetHTMLTemplate
        ) { error in
            DispatchQueue.main.async {
                self.ProgressHUDHide()
                if error == "" {
                    self.performSegue(withIdentifier: "emailVerificationSeg", sender: randomNumber)
                } else {
                    self.showError(error)
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "emailVerificationSeg",
           let VC = segue.destination as? EmailVerificationController,
           let random = sender as? String {
            VC.verificationCode = random
            VC.email = self.email
            VC.type = .RESET_PASSWORD
        }
    }
}

// MARK: UITextFieldDelegate

extension ResetPasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
