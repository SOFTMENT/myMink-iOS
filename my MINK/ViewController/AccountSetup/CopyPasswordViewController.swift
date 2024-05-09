// Copyright © 2023 SOFTMENT. All rights reserved.

import UIKit

class CopyPasswordViewController: UIViewController {
    @IBOutlet var mEmail: UILabel!

    @IBOutlet var mPassword: UILabel!

    @IBOutlet var mCopy: UIImageView!

    @IBOutlet var mView: UIView!

    @IBOutlet var loginScreenBtn: UIButton!

    var email: String?
    var password: String?

    override func viewDidLoad() {
        guard let email = email, let password = password else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }

        self.mEmail.text = email
        self.mPassword.text = password
        self.mView.layer.cornerRadius = 8

        self.loginScreenBtn.layer.cornerRadius = 8

        self.mCopy.isUserInteractionEnabled = true
        self.mCopy.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.copyBtnClicked)))
    }

    @objc func copyBtnClicked() {
        showSnack(messages: "Copied")
        UIPasteboard.general.string = "Email - \(self.email ?? "")\n\nPassword - \(self.password ?? "")"
    }

    @IBAction func loginScreenClicked(_: Any) {
        beRootScreen(storyBoardName: .AccountSetup, mIdentifier: .ENTRYVIEWCONTROLLER)
    }
}
