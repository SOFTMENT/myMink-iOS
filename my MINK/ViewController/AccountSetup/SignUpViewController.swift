// Copyright © 2023 SOFTMENT. All rights reserved.

import AuthenticationServices
import CryptoKit
import Firebase
import UIKit

private var currentNonce: String?

// MARK: - SignUpViewController

class SignUpViewController: UIViewController {
    
    // MARK: - Outlets

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

    // MARK: - Properties

    var email: String = ""
    var userModel: UserModel!
    var randomNumber: String = ""

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        configureGestureRecognizers()
    }

    // MARK: - Setup Methods

    private func setupViews() {
        configureTextField(firstName, imageName: "user")
        configureTextField(lastName, imageName: "user")
        configureTextField(emailTF, imageName: "email")
        configureTextField(passwordTF, imageName: "lock")
        configurePasswordField()

        [gmailBtn, appleBtn, phoneBtn, signUpBtn].forEach {
            $0?.layer.cornerRadius = 12
        }

        backView.isUserInteractionEnabled = true
        backView.dropShadow()
        backView.layer.cornerRadius = 8
    }

    private func configureTextField(_ textField: UITextField, imageName: String) {
        textField.layer.cornerRadius = 12
        textField.setLeftPaddingPoints(16)
        textField.setRightPaddingPoints(10)
        if let image = UIImage(named: imageName) {
            textField.setLeftView(image: image)
        }
        textField.delegate = self
    }

    private func configurePasswordField() {
        passwordTF.rightViewMode = .always
        updatePasswordRightView(imageName: "hide")
    }

    private func updatePasswordRightView(imageName: String) {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 13, width: 20, height: 20))
        imageView.image = UIImage(named: imageName)
        let iconContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 45))
        iconContainerView.addSubview(imageView)
        passwordTF.rightView = iconContainerView
        passwordTF.rightView?.isUserInteractionEnabled = true
        passwordTF.rightView?.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(passwordEyeClicked)
        ))
    }

    private func configureGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hidekeyboard))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGesture)

        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        signInBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(signInClicked)))
        phoneBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(phoneNumberViewClicked)))
        gmailBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loginWithGoogleBtnClicked)))
        appleBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loginWithAppleBtnClicked)))
    }

    // MARK: - Actions

    @objc private func phoneNumberViewClicked() {
        performSegue(withIdentifier: "phoneNumberSignUpSeg", sender: nil)
    }

    @objc private func passwordEyeClicked() {
        let isSecure = passwordTF.isSecureTextEntry
        passwordTF.isSecureTextEntry = !isSecure
        let imageName = isSecure ? "view" : "hide"
        updatePasswordRightView(imageName: imageName)
    }

    @objc private func signInClicked() {
        performSegue(withIdentifier: "signInSeg", sender: nil)
    }

    @objc private func hidekeyboard() {
        view.endEditing(true)
    }

    @objc private func backViewClicked() {
        dismiss(animated: true)
    }

    @IBAction private func signUpClicked(_ sender: Any) {
        guard let sFirstName = firstName.text?.trimmingCharacters(in: .whitespacesAndNewlines), !sFirstName.isEmpty else {
            showSnack(messages: "Enter First Name")
            return
        }
        guard let sLastName = lastName.text?.trimmingCharacters(in: .whitespacesAndNewlines), !sLastName.isEmpty else {
            showSnack(messages: "Enter Last Name")
            return
        }
        guard let sEmail = emailTF.text?.trimmingCharacters(in: .whitespacesAndNewlines), !sEmail.isEmpty else {
            showSnack(messages: "Enter Email")
            return
        }
        guard let sPassword = passwordTF.text?.trimmingCharacters(in: .whitespacesAndNewlines), !sPassword.isEmpty else {
            showSnack(messages: "Enter Password")
            return
        }

        let userData = UserModel()
        userData.isBlocked = false
        userData.fullName = "\(sFirstName) \(sLastName)"
        userData.encryptKey = try? generateEncryptionKey(withPassword: sPassword)
        userData.encryptPassword = try? encryptMessage(message: sPassword, encryptionKey: userData.encryptKey ?? "")
        userData.email = sEmail
        userData.registredAt = Date()
        userData.regiType = "custom"

        FirebaseStoreManager.db.collection(Collections.users.rawValue).whereField("email", isEqualTo: sEmail).getDocuments { snapshot, error in
            if let snapshot = snapshot, snapshot.isEmpty {
                let n = Int.random(in: 10000 ... 99999)
                self.sendVerificationMail(randomNumber: String(n), email: sEmail, userModel: userData)
            } else if let error = error {
                self.showError(error.localizedDescription)
            } else {
                self.showError("Account with email : \(sEmail) already exist.")
            }
        }
    }

    private func sendVerificationMail(randomNumber: String, email: String, userModel: UserModel) {
        ProgressHUDShow(text: "")
        let passwordResetHTMLTemplate = getEmailVerificationTemplate(randomNumber: randomNumber)
        sendMail(to_name: "my MINK", to_email: email, subject: "Email Verification", body: passwordResetHTMLTemplate) { error in
            DispatchQueue.main.async {
                self.ProgressHUDHide()
                if error.isEmpty {
                    self.gotoEmailVerificationPage(email: email, randonNumber: randomNumber, userModel: userModel)
                } else {
                    self.showError(error)
                }
            }
        }
    }

    @objc private func loginWithGoogleBtnClicked() {
        loginWithGoogle(from: "signUp")
    }

    @objc private func loginWithAppleBtnClicked() {
        startSignInWithAppleFlow()
    }

    private func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }

    // MARK: - Private Methods

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
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
                if remainingLength == 0 { return }
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
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }

    private func gotoEmailVerificationPage(email: String, randonNumber: String, userModel: UserModel) {
        self.email = email
        self.userModel = userModel
        self.randomNumber = randonNumber
        performSegue(withIdentifier: "signUpEmailVerificationSeg", sender: nil)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "signUpEmailVerificationSeg", let VC = segue.destination as? EmailVerificationController {
            VC.email = email
            VC.userModel = userModel
            VC.verificationCode = randomNumber
            VC.type = .EMAIL_VERIFICATION
        } else if segue.identifier == "signUpPhoneVerificationSeg", let VC = segue.destination as? PhoneNumberVerificationController {
            if let value = sender as? String {
                VC.verificationID = FirebaseStoreManager.auth.currentUser!.uid
                VC.phoneNumber  = value
            }
        }
    }
}

// MARK: - UITextFieldDelegate

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hidekeyboard()
        return true
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension SignUpViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
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
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            var displayName = "my MINK"
            if let fullName = appleIDCredential.fullName {
                if let firstName = fullName.givenName {
                    displayName = firstName
                }
                if let lastName = fullName.familyName {
                    displayName = "\(displayName) \(lastName)"
                }
            }
            authWithFirebase(from: "signUp", credential: credential, phoneNumber: nil, type: "apple", displayName: displayName)
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple errored: \(error)")
    }
}
