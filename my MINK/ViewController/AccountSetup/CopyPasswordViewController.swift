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
        super.viewDidLoad()
        setupViews()
        populateFields()
    }

    private func setupViews() {
        mView.layer.cornerRadius = 8
        loginScreenBtn.layer.cornerRadius = 8
        mCopy.isUserInteractionEnabled = true
        mCopy.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(copyBtnClicked)))
    }

    private func populateFields() {
        guard let email = email, let password = password else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }

        mEmail.text = email
        mPassword.text = password
    }

    @objc private func copyBtnClicked() {
        showSnack(messages: "Copied".localized())
        UIPasteboard.general.string = String(format: "Email - %@\n\nPassword - %@".localized(), email ?? "", password ?? "")

    }

    @IBAction private func loginScreenClicked(_: Any) {
        beRootScreen(storyBoardName: .accountSetup, mIdentifier: .entryViewController)
    }
}
