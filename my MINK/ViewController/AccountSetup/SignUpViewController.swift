// Copyright © 2023 SOFTMENT. All rights reserved.

import AuthenticationServices
import CryptoKit
import Firebase
import UIKit

private var currentNonce: String?

// MARK: - SignUpViewController

class SignUpViewController: UIViewController {
    // MARK: Internal

    @IBOutlet var gmailBtn: UIView!
    @IBOutlet var appleBtn: UIView!
    @IBOutlet var phoneBtn: UIView!

    @IBOutlet var signUpBtn: UIButton!

    @IBOutlet var signInBtn: UILabel!

    @IBOutlet var backView: UIView!
    @IBOutlet var lastName: UITextField!
    @IBOutlet var firstName: UITextField!

    @IBOutlet var passwordTF: UITextField!
    @IBOutlet var emailTF: UITextField!
    var email: String = ""
    var userModel: UserModel!
    var randomNumber: String = ""

    override func viewDidLoad() {
        self.firstName.layer.cornerRadius = 12
        self.firstName.setLeftPaddingPoints(16)
        self.firstName.setRightPaddingPoints(10)
        self.firstName.setLeftView(image: UIImage(named: "user")!)
        self.firstName.delegate = self

        self.lastName.layer.cornerRadius = 12
        self.lastName.setLeftPaddingPoints(16)
        self.lastName.setRightPaddingPoints(10)
        self.lastName.setLeftView(image: UIImage(named: "user")!)
        self.lastName.delegate = self

        self.emailTF.layer.cornerRadius = 12
        self.emailTF.setLeftPaddingPoints(16)
        self.emailTF.setRightPaddingPoints(10)
        self.emailTF.setLeftView(image: UIImage(named: "email")!)
        self.emailTF.delegate = self

        self.passwordTF.layer.cornerRadius = 12
        self.passwordTF.setLeftPaddingPoints(16)
        self.passwordTF.setRightPaddingPoints(10)
        self.passwordTF.setLeftView(image: UIImage(named: "lock")!)
        self.passwordTF.delegate = self

        self.passwordTF.rightViewMode = .always
        let imageView = UIImageView(frame: CGRect(x: 0, y: 13, width: 20, height: 20))
        let image = UIImage(named: "hide")
        imageView.image = image
        let iconContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 45))
        iconContainerView.addSubview(imageView)
        self.passwordTF.rightView = iconContainerView
        self.passwordTF.rightView?.isUserInteractionEnabled = true
        self.passwordTF.rightView?.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.passwordEyeClicked)
        ))

        self.backView.isUserInteractionEnabled = true
        self.backView.dropShadow()
        self.backView.layer.cornerRadius = 8
        self.backView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.backViewClicked)
        ))

        self.signInBtn.isUserInteractionEnabled = true
        self.signInBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.signInClicked)))

        self.signUpBtn.layer.cornerRadius = 8
        self.gmailBtn.layer.cornerRadius = 12
        self.appleBtn.layer.cornerRadius = 12
        self.phoneBtn.layer.cornerRadius = 12

        // PhoneClicked
        self.phoneBtn.isUserInteractionEnabled = true
        self.phoneBtn.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.phoneNumberViewClicked)
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

        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.hidekeyboard)))
    }

    @objc func phoneNumberViewClicked() {
        performSegue(withIdentifier: "phoneNumberSignUpSeg", sender: nil)
    }

    @objc func passwordEyeClicked() {
        if self.passwordTF.isSecureTextEntry {
            self.passwordTF.isSecureTextEntry = false
            let imageView = UIImageView(frame: CGRect(x: 0, y: 13, width: 20, height: 20))
            let image = UIImage(named: "view")
            imageView.image = image
            let iconContainerView: UIView = .init(frame: CGRect(x: 0, y: 0, width: 35, height: 45))
            iconContainerView.addSubview(imageView)
            self.passwordTF.rightView = iconContainerView
            self.passwordTF.rightView?.isUserInteractionEnabled = true
            self.passwordTF.rightView?.addGestureRecognizer(UITapGestureRecognizer(
                target: self,
                action: #selector(self.passwordEyeClicked)
            ))
        } else {
            self.passwordTF.isSecureTextEntry = true
            let imageView = UIImageView(frame: CGRect(x: 0, y: 13, width: 20, height: 20))
            let image = UIImage(named: "hide")
            imageView.image = image
            let iconContainerView: UIView = .init(frame: CGRect(x: 0, y: 0, width: 35, height: 45))
            iconContainerView.addSubview(imageView)
            self.passwordTF.rightView = iconContainerView
            self.passwordTF.rightView?.isUserInteractionEnabled = true
            self.passwordTF.rightView?.addGestureRecognizer(UITapGestureRecognizer(
                target: self,
                action: #selector(self.passwordEyeClicked)
            ))
        }
    }

    @objc func signInClicked() {
        performSegue(withIdentifier: "signInSeg", sender: nil)
    }

    @objc func hidekeyboard() {
        view.endEditing(true)
    }

    @objc func backViewClicked() {
        dismiss(animated: true)
    }

    func gotoEmailVerificationPage(email: String, randonNumber: String, userModel: UserModel) {
        self.email = email
        self.userModel = userModel
        self.randomNumber = randonNumber
        performSegue(withIdentifier: "signUpEmailVerificationSeg", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "signUpEmailVerificationSeg" {
            if let VC = segue.destination as? EmailVerificationController {
                VC.email = self.email
                VC.userModel = self.userModel
                VC.verificationCode = self.randomNumber
                VC.type = .EMAIL_VERIFICATION
            }
        } else if segue.identifier == "signUpPhoneVerificationSeg" {
            if let VC = segue.destination as? PhoneNumberVerificationController {
                if let value = sender as? String {
                    VC.verificationID = FirebaseStoreManager.auth.currentUser!.uid
                    VC.phoneNumber  = value
                    
                }
            }
        }
    }

    @IBAction func signUpClicked(_: Any) {
        let sFirstName = self.firstName.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let sLastName = self.lastName.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let sEmail = self.emailTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let sPassword = self.passwordTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)

        if sFirstName == "" {
            showSnack(messages: "Enter First Name")
        } else if sLastName == "" {
            showSnack(messages: "Enter Last Name")
        } else if sEmail == "" {
            showSnack(messages: "Enter Email")
        } else if sPassword == "" {
            showSnack(messages: "Enter Password")
        } else {
            let userData = UserModel()
            userData.isBlocked = false
            userData.fullName = "\(sFirstName!) \(sLastName!)"
            userData.encryptKey = try! generateEncryptionKey(withPassword: sPassword!)
            userData.encryptPassword = try! encryptMessage(message: sPassword!, encryptionKey: userData.encryptKey!)
            userData.email = sEmail
            userData.registredAt = Date()
            userData.regiType = "custom"

            FirebaseStoreManager.db.collection("Users").whereField("email", isEqualTo: sEmail ?? "123")
                .getDocuments { snapshot, error in
                    if let snapshot = snapshot {
                        if snapshot.isEmpty {
                            let n = Int.random(in: 10000 ... 99999)
                            self.sendVerificationMail(
                                randomNumber: String(n),
                                email: sEmail ?? "123",
                                userModel: userData
                            )
                        } else {
                            self.showError("Account with email : \(sEmail ?? "") already exist.")
                        }
                    } else {
                        self.showError(error!.localizedDescription)
                    }
                }
        }
    }

    func sendVerificationMail(randomNumber: String, email: String, userModel: UserModel) {
        ProgressHUDShow(text: "")
        let passwordResetHTMLTemplate = getEmailVerificationTemplate(randomNumber: randomNumber)

        sendMail(
            to_name: "my MINK",
            to_email: email,
            subject: "Email Verification",
            body: passwordResetHTMLTemplate
        ) { error in
            DispatchQueue.main.async {
                self.ProgressHUDHide()
                if error == "" {
                    self.gotoEmailVerificationPage(email: email, randonNumber: randomNumber, userModel: userModel)
                } else {
                    self.showError(error)
                }
            }
        }
    }

    @objc func loginWithGoogleBtnClicked() {
        loginWithGoogle(from: "signUp")
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

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_: UITextField) -> Bool {
        self.hidekeyboard()
        return true
    }
}

// MARK: ASAuthorizationControllerDelegate

extension SignUpViewController: ASAuthorizationControllerDelegate {
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
                from: "signUp",
                credential: credential,
                phoneNumber: nil,
                type: "apple",
                displayName: displayName
            )
        }
    }

    func authorizationController(controller _: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.

        print("Sign in with Apple errored: \(error)")
    }
}
