// Copyright © 2023 SOFTMENT. All rights reserved.

import AuthenticationServices
import Firebase
import FirebaseAuth
import FirebaseFunctions
import GoogleSignIn
import UIKit

class AccountPrivacyViewController: UIViewController {
    @IBOutlet var backView: UIView!
    @IBOutlet var topView: UIView!
    @IBOutlet var mView: UIView!
    @IBOutlet var deactivateAccount: UIView!
    @IBOutlet var deleteAccount: UIView!
    @IBOutlet var whoCanSeeView: UIView!
    @IBOutlet var Manage2FAView: UIView!
    @IBOutlet var manage2FALbl: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        self.setupGestures()
        self.setup2FA()
    }

    private func configureView() {
        self.mView.clipsToBounds = true
        self.mView.layer.cornerRadius = 20
        self.mView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        self.backView.layer.cornerRadius = 8
        self.backView.dropShadow()
    }

    private func setupGestures() {
        self.topView.isUserInteractionEnabled = true
        self.topView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backViewClicked)))

        self.backView.isUserInteractionEnabled = true
        self.backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backViewClicked)))

        self.deleteAccount.isUserInteractionEnabled = true
        self.deleteAccount.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.deleteAccountClicked)))

        self.deactivateAccount.isUserInteractionEnabled = true
        self.deactivateAccount.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.deactivateAccountClicked)))

        self.whoCanSeeView.isUserInteractionEnabled = true
        self.whoCanSeeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.whoCanSeeClicked)))
    }

    private func setup2FA() {
        if checkAuthProvider() == "phone" || checkAuthProvider() == "other" {
            self.Manage2FAView.isHidden = true
        } else {
            if self.checkIfUserHas2FAEnabled() {
                self.manage2FALbl.text = "Disable 2FA".localized()
            } else {
                self.manage2FALbl.text = "Enable 2FA".localized()
            }

            self.Manage2FAView.isUserInteractionEnabled = true
            self.Manage2FAView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.manage2FAClicked)))
        }
    }

    @objc func manage2FAClicked() {
        if self.checkIfUserHas2FAEnabled() {
            self.showDisable2FAAlert()
        } else {
            self.performSegue(withIdentifier: "phoneLoginSeg", sender: true)
        }
    }

    private func showDisable2FAAlert() {
        let alert = UIAlertController(
            title: "Disable 2FA".localized(),
            message: "Are you sure you want to disable 2FA?".localized(),
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Yes".localized(), style: .default, handler: { _ in
            self.disable2FA()
        }))

        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        present(alert, animated: true)
    }

    private func disable2FA() {
        self.ProgressHUDShow(text: "")
        guard let userId = FirebaseStoreManager.auth.currentUser?.uid else { return }
        FirebaseStoreManager.db.collection(Collections.users.rawValue).document(userId)
            .setData(["is2FAActive": false, "phoneNumber2FA": ""], merge: true) { error in
                self.ProgressHUDHide()
                if let error = error {
                    self.showError(error.localizedDescription)
                } else {
                    UserModel.data?.is2FAActive = false
                    self.showSnack(messages: "2FA has been removed".localized())
                }
            }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "phoneLoginSeg", let VC = segue.destination as? SignInPhoneNumberViewController {
            VC.for2FA = true
        }
    }

    func checkIfUserHas2FAEnabled() -> Bool {
        guard let data = UserModel.data else {
            print("No user is currently signed in".localized())
            return false
        }
        return data.is2FAActive ?? false
    }

    @objc func whoCanSeeClicked() {
        performSegue(withIdentifier: "privateSettingsSeg", sender: nil)
    }

    @objc func backViewClicked() {
        dismiss(animated: true)
    }

    @objc func deactivateAccountClicked() {
        self.showDeactivateAccountAlert()
    }

    private func showDeactivateAccountAlert() {
        let alert = UIAlertController(
            title: "DEACTIVATE ACCOUNT".localized(),
            message: "Are you sure you want to deactivate your account?".localized(),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        alert.addAction(UIAlertAction(title: "Deactivate".localized(), style: .destructive, handler: { _ in
            self.deactivateAccountContinue()
        }))
        present(alert, animated: true)
    }

    private func deactivateAccountContinue() {
        guard let user = FirebaseStoreManager.auth.currentUser else { return }
        self.ProgressHUDShow(text: "Account Deactivating...".localized())
        self.deactivateUserAccount(userId: user.uid) { error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error)
            } else {
                self.showSnack(messages: "Account Deactivated".localized())
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    self.logoutPlease()
                }
            }
        }
    }

    @objc func deleteAccountClicked() {
        self.showDeleteAccountAlert()
    }

    private func showDeleteAccountAlert() {
        let alert = UIAlertController(
            title: "DELETE ACCOUNT".localized(),
            message: "Are you sure you want to delete your account?".localized(),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete".localized(), style: .destructive, handler: { _ in
            self.deleteAccountContinue()
        }))
        present(alert, animated: true)
    }

    private func deleteAccountContinue() {
        guard let user = FirebaseStoreManager.auth.currentUser, let username = UserModel.data?.username else { return }
        self.ProgressHUDShow(text: "Account Deleting...".localized())
        self.deleteUserAccount(userId: user.uid, username: username) { error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error)
            } else {
                self.showSnack(messages: "Account Deleted".localized())
            }
        }
    }
}
