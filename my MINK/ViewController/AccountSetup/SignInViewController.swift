// Copyright © 2023 SOFTMENT. All rights reserved.

import AuthenticationServices
import CryptoKit
import Firebase
import UIKit

private var currentNonce: String?

// MARK: - SignInViewController

class SignInViewController: UIViewController {
    // MARK: Internal

    @IBOutlet var phoneBtn: UIView!

    @IBOutlet var backView: UIView!
    @IBOutlet var emailAddress: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var forgotPassword: UILabel!
    @IBOutlet var loginBtn: UIButton!
    @IBOutlet var gmailBtn: UIView!
    @IBOutlet var appleBtn: UIView!
    @IBOutlet var registerNowBtn: UILabel!
    @IBOutlet var remeberMeCheck: UIButton!
    var email: String = ""
    var randomNumber: String = ""

    override func viewDidLoad() {
        self.emailAddress.layer.cornerRadius = 12
        self.emailAddress.setLeftPaddingPoints(16)
        self.emailAddress.setRightPaddingPoints(10)
        self.emailAddress.setLeftView(image: UIImage(named: "email")!)
        self.emailAddress.delegate = self

        self.password.layer.cornerRadius = 12
        self.password.setLeftPaddingPoints(16)
        self.password.setRightPaddingPoints(10)
        self.password.setLeftView(image: UIImage(named: "lock")!)
        self.password.delegate = self

        self.password.rightViewMode = .always
        let imageView = UIImageView(frame: CGRect(x: 0, y: 13, width: 20, height: 20))
        let image = UIImage(named: "hide")
        imageView.image = image
        let iconContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 45))
        iconContainerView.addSubview(imageView)
        self.password.rightView = iconContainerView
        self.password.rightView?.isUserInteractionEnabled = true
        self.password.rightView?.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.passwordEyeClicked)
        ))

        self.loginBtn.layer.cornerRadius = 12
        self.gmailBtn.layer.cornerRadius = 12
        self.appleBtn.layer.cornerRadius = 12
        self.phoneBtn.layer.cornerRadius = 12

        // RESET PASSWORD
        self.forgotPassword.isUserInteractionEnabled = true
        self.forgotPassword.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.forgotPasswordClicked)
        ))

        // RegisterNow
        self.registerNowBtn.isUserInteractionEnabled = true
        self.registerNowBtn.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.registerBtnClicked)
        ))

        // GoogleClicked
        self.gmailBtn.isUserInteractionEnabled = true
        self.gmailBtn.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.loginWithGoogleBtnClicked)
        ))

        // AppleClicked
        self.appleBtn.isUserInteractionEnabled = true
        self.appleBtn.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.loginWithAppleBtnClicked)
        ))

        // PhoneClicked
        self.phoneBtn.isUserInteractionEnabled = true
        self.phoneBtn.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.phoneVerificationClicked)
        ))

        self.backView.isUserInteractionEnabled = true
        self.backView.dropShadow()
        self.backView.layer.cornerRadius = 8
        self.backView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.backViewClicked)
        ))

        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.hidekeyboard)))

        let rememberMeFlag = UserDefaults.standard.bool(forKey: "REMEMBER_USER")
        self.remeberMeCheck.isSelected = rememberMeFlag
        if rememberMeFlag {
            self.emailAddress.text = UserDefaults.standard.string(forKey: "USER_EMAIL")
            self.password.text = UserDefaults.standard.string(forKey: "PASSWORD")
        }
    }

    @objc func phoneVerificationClicked() {
        performSegue(withIdentifier: "phoneNumberSignInSeg", sender: nil)
    }

    @objc func passwordEyeClicked() {
        if self.password.isSecureTextEntry {
            self.password.isSecureTextEntry = false
            let imageView = UIImageView(frame: CGRect(x: 0, y: 13, width: 20, height: 20))
            let image = UIImage(named: "view")
            imageView.image = image
            let iconContainerView: UIView = .init(frame: CGRect(x: 0, y: 0, width: 35, height: 45))
            iconContainerView.addSubview(imageView)
            self.password.rightView = iconContainerView
            self.password.rightView?.isUserInteractionEnabled = true
            self.password.rightView?.addGestureRecognizer(UITapGestureRecognizer(
                target: self,
                action: #selector(self.passwordEyeClicked)
            ))
        } else {
            self.password.isSecureTextEntry = true
            let imageView = UIImageView(frame: CGRect(x: 0, y: 13, width: 20, height: 20))
            let image = UIImage(named: "hide")
            imageView.image = image
            let iconContainerView: UIView = .init(frame: CGRect(x: 0, y: 0, width: 35, height: 45))
            iconContainerView.addSubview(imageView)
            self.password.rightView = iconContainerView
            self.password.rightView?.isUserInteractionEnabled = true
            self.password.rightView?.addGestureRecognizer(UITapGestureRecognizer(
                target: self,
                action: #selector(self.passwordEyeClicked)
            ))
        }
    }

    @objc func backViewClicked() {
        dismiss(animated: true)
    }

    @IBAction func remeberMeClicked(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
        } else {
            sender.isSelected = true
        }
    }

    @objc func registerBtnClicked() {
        performSegue(withIdentifier: "signUpSeg", sender: nil)
    }

    @objc func forgotPasswordClicked() {
        performSegue(withIdentifier: "resetPasswordSeg", sender: nil)
    }

    @IBAction func loginBtnClicked(_: Any) {
        let sEmail = self.emailAddress.text?.trimmingCharacters(in: .nonBaseCharacters)
        let sPassword = self.password.text?.trimmingCharacters(in: .whitespacesAndNewlines)

        if sEmail == "" {
            showSnack(messages: "Enter Email Address")
        } else if sPassword == "" {
            showSnack(messages: "Enter Password")
        } else {
            if self.remeberMeCheck.isSelected {
                UserDefaults.standard.set(true, forKey: "REMEMBER_USER")
                UserDefaults.standard.set(sEmail, forKey: "USER_EMAIL")
                UserDefaults.standard.set(sPassword, forKey: "PASSWORD")
            } else {
                UserDefaults.standard.set(false, forKey: "REMEMBER_USER")
                UserDefaults.standard.removeObject(forKey: "USER_EMAIL")
                UserDefaults.standard.removeObject(forKey: "PASSWORD")
            }

            let credentials = EmailAuthProvider.credential(withEmail: sEmail!, password: sPassword!)
            authWithFirebase(
                from: "signIn",
                credential: credentials,
                phoneNumber: "",
                type: "password",
                displayName: ""
            )
        }
    }

    @objc func hidekeyboard() {
        view.endEditing(true)
    }

    @objc func loginWithGoogleBtnClicked() {
        loginWithGoogle(from: "signIn")
    }

    @objc func loginWithAppleBtnClicked() {
        self.startSignInWithAppleFlow()
    }

    func startSignInWithAppleFlow() {
        let nonce = self.randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = self.sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        // authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    // MARK: Private

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }
}

// MARK: UITextFieldDelegate

extension SignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_: UITextField) -> Bool {
        self.hidekeyboard()
        return true
    }
}

// MARK: ASAuthorizationControllerDelegate

extension SignInViewController: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller _: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(
                withProviderID: "apple.com",
                idToken: idTokenString,
                rawNonce: nonce
            )

            var displayName = "my MINK"

            if let fullName = appleIDCredential.fullName {
                if let firstName = fullName.givenName {
                    displayName = firstName
                }
                if let lastName = fullName.familyName {
                    displayName = "\(displayName) \(lastName)"
                }
            }

            authWithFirebase(
                from: "signIn",
                credential: credential,
                phoneNumber: nil,
                type: "apple",
                displayName: displayName
            )
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "signInPhoneVerificationSeg" {
            if let VC = segue.destination as? PhoneNumberVerificationController {
                if let value = sender as? String {
                    VC.verificationID = FirebaseStoreManager.auth.currentUser!.uid
                    VC.phoneNumber  = value
                  
                }
            }
        }
    }

    func authorizationController(controller _: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.

        print("Sign in with Apple errored: \(error)")
    }
}
