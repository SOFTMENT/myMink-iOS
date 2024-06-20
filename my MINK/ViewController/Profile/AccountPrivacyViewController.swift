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
        self.mView.clipsToBounds = true
        self.mView.layer.cornerRadius = 20
        self.mView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        self.topView.isUserInteractionEnabled = true
        self.topView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backViewClicked)))

        self.backView.layer.cornerRadius = 8
        self.backView.dropShadow()
        self.backView.isUserInteractionEnabled = true
        self.backView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.backViewClicked)
        ))

        // DELETE ACCOUNT
        self.deleteAccount.isUserInteractionEnabled = true
        self.deleteAccount.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.deleteAccountClicked)
        ))
        
        // DEACTIVATE ACCOUNT
        self.deactivateAccount.isUserInteractionEnabled = true
        self.deactivateAccount.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.deactivateAccountClicked)
        ))

        // WHOCANSEE
        self.whoCanSeeView.isUserInteractionEnabled = true
        self.whoCanSeeView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.whoCanSeeClicked)
        ))

        // 2FA
        if checkAuthProvider() == "phone" || checkAuthProvider() == "other" {
            self.Manage2FAView.isHidden = true
        } else {
            if self.checkIfUserHas2FAEnabled() {
                self.manage2FALbl.text = "Disable 2FA"
            } else {
                self.manage2FALbl.text = "Enable 2FA"
            }

            self.Manage2FAView.isUserInteractionEnabled = true
            self.Manage2FAView.addGestureRecognizer(UITapGestureRecognizer(
                target: self,
                action: #selector(self.manage2FAClicked)
            ))
        }
    }

    @objc func manage2FAClicked() {
        if self.checkIfUserHas2FAEnabled() {
            let alert = UIAlertController(
                title: "Disable 2FA",
                message: "Are you sure you want to disable 2FA?",
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                self.ProgressHUDShow(text: "")
                FirebaseStoreManager.db.collection(Collections.USERS.rawValue).document(FirebaseStoreManager.auth.currentUser!.uid)
                    .setData(["is2FAActive": false, "phoneNumber2FA": ""], merge: true) { error in
                        self.ProgressHUDHide()
                        if let error = error {
                            self.showError(error.localizedDescription)
                        } else {
                            UserModel.data?.is2FAActive = false
                            self.showSnack(messages: "2FA has been removed")
                        }
                    }

            }))

            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
        } else {
            self.performSegue(withIdentifier: "phoneLoginSeg", sender: true)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "phoneLoginSeg" {
            if let VC = segue.destination as? SignInPhoneNumberViewController {
                VC.for2FA = true
            }
        }
    }

    func checkIfUserHas2FAEnabled() -> Bool {
        guard let data = UserModel.data else {
            print("No user is currently signed in")
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
        dismiss(animated: true)

        let alert = UIAlertController(
            title: "DEACTIVATE ACCOUNT",
            message: "Are you sure you want to deactivate your account?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Deactivate", style: .destructive, handler: { _ in

            if let user = FirebaseStoreManager.auth.currentUser {
                self.ProgressHUDShow(text: "Account Deactivating...")
               
                self.deactivateUserAccount(userId: user.uid) { error in
                    self.ProgressHUDHide()
                    if let error = error {
                        self.showError(error)
                    }
                    else {
                        self.showSnack(messages: "Account Deactivated")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            self.logoutPlease()
                        }
                    }
                }
         
            }
        }))
        present(alert, animated: true)
    }
    
    @objc func deleteAccountClicked() {
        dismiss(animated: true)

        let alert = UIAlertController(
            title: "DELETE ACCOUNT",
            message: "Are you sure you want to delete your account?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in

            if let user = FirebaseStoreManager.auth.currentUser {
                self.ProgressHUDShow(text: "Account Deleting...")
               
                self.deleteUserAccount(userId: user.uid, username: UserModel.data!.username ?? "") { error in
                    self.ProgressHUDHide()
                    if let error = error {
                        self.showError(error)
                    }
                    else {
                        self.showSnack(messages: "Account Deleted")
                    }
                }
         
            }
        }))
        present(alert, animated: true)
    }

//    func reauthenticateWithPassword() {
//        let user = Auth.auth().currentUser
//        var credential: AuthCredential?
//
//        // Prompt the user to re-enter their email and password
//        let email = UserModel.data!.email ?? "123"
//
//        ProgressHUDShow(text: "")
//        FirebaseStoreManager.db.collection("Users").whereField("email", isEqualTo: email)
//            .whereField("regiType", isEqualTo: "custom").getDocuments { snapshot, _ in
//
//                if let snapshot = snapshot, !snapshot.isEmpty {
//                    if let resetPasswordModel = try? snapshot.documents[0].data(as: ResetPasswordModel.self) {
//                        let password = try! self.decryptMessage(
//                            encryptedMessage: resetPasswordModel.encryptPassword ?? "123",
//                            encryptionKey: resetPasswordModel.encryptKey ?? "123"
//                        )
//                        credential = EmailAuthProvider.credential(withEmail: email, password: password)
//
//                        user?.reauthenticate(with: credential!) { result, error in
//                            self.ProgressHUDHide()
//                            if let error = error {
//                                self.showError(error.localizedDescription)
//                            } else {
//                                self.performSegue(withIdentifier: "phoneLoginSeg", sender: true)
//                            }
//                        }
//                    }
//                } else {
//                    self.ProgressHUDHide()
//                    self.showError("Account not registered with this mail address.")
//                }
//            }
//    }
//
//    func reauthenticateWithApple() {
//        let provider = ASAuthorizationAppleIDProvider()
//        let request = provider.createRequest()
//        // Set requested scopes
//        request.requestedScopes = [.fullName, .email]
//
//        let controller = ASAuthorizationController(authorizationRequests: [request])
//        controller.delegate = self // Ensure that your class conforms to `ASAuthorizationControllerDelegate`
//        controller.performRequests()
//    }
//
//    func reauthenticateWithGoogle() {
//        guard let clientID = FirebaseApp.app()?.options.clientID else {
//            return
//        }
//
//        // Create Google Sign In configuration object.
//        let config = GIDConfiguration(clientID: clientID)
//        GIDSignIn.sharedInstance.configuration = config
//        // Start the sign in flow!
//        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
//
//            if let error = error {
//                self.showError(error.localizedDescription)
//                return
//            }
//
//            guard let user = result?.user,
//                  let idToken = user.idToken?.tokenString
//            else {
//                return
//            }
//
//            let credential = GoogleAuthProvider.credential(
//                withIDToken: idToken,
//                accessToken: user.accessToken.tokenString
//            )
//
//            Auth.auth().currentUser?.reauthenticate(with: credential) { _, error in
//                if let error = error {
//                    self.showError(error.localizedDescription)
//                } else {
//                    self.performSegue(withIdentifier: "phoneLoginSeg", sender: true)
//                }
//            }
//        }
//    }
}

// extension AccountPrivacyViewController: ASAuthorizationControllerDelegate {
//    // ASAuthorizationControllerDelegate method
//    func authorizationController(
//        controller: ASAuthorizationController,
//        didCompleteWithAuthorization authorization: ASAuthorization
//    ) {
//        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
//           let identityToken = appleIDCredential.identityToken,
//           let tokenString = String(data: identityToken, encoding: .utf8)
//        {
//            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenString, rawNonce:
//            nil)
//
//            Auth.auth().currentUser?.reauthenticate(with: credential) { authResult, error in
//                if let error = error {
//                    self.showError(error.localizedDescription)
//                } else {
//                    self.performSegue(withIdentifier: "phoneLoginSeg", sender: nil)
//                }
//            }
//        }
//    }
//
//    // ASAuthorizationControllerDelegate method
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
//        self.showError(error.localizedDescription)
//    }
// }
