// Copyright © 2023 SOFTMENT. All rights reserved.

import AuthenticationServices
import CryptoKit
import Firebase
import UIKit
import FirebaseCrashlytics

private var currentNonce: String?

// MARK: - SignInViewController

class SignInViewController: UIViewController {
    // MARK: - Outlets

    @IBOutlet var phoneBtn: UIView!
    @IBOutlet var backView: UIView!
    @IBOutlet var emailAddress: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var forgotPassword: UILabel!
    @IBOutlet var loginBtn: UIButton!
    @IBOutlet var gmailBtn: UIView!
    @IBOutlet var appleBtn: UIView!
    @IBOutlet var registerNowBtn: UILabel!
    @IBOutlet var rememberMeCheck: UIButton!

    // MARK: - Properties

    var email: String = ""
    var randomNumber: String = ""

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureGestureRecognizers()
        configureRememberMe()
        configurePasswordField()
      
    }

    // MARK: - UI Setup

    private func setupUI() {
        if let emailIcon = UIImage(named: "email") {
            emailAddress.configureTextField(placeholderImage: emailIcon)
        }
        if let lockIcon = UIImage(named: "lock") {
            password.configureTextField(placeholderImage: lockIcon)
        }

      

        [loginBtn, gmailBtn, appleBtn, phoneBtn].forEach {
            $0?.layer.cornerRadius = 12
        }

        backView.layer.cornerRadius = 8
        backView.dropShadow()
    }

    // MARK: - Gesture Recognizers

    private func configureGestureRecognizers() {
        forgotPassword.isUserInteractionEnabled = true
        forgotPassword.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(forgotPasswordClicked)))
        registerNowBtn.isUserInteractionEnabled = true
        registerNowBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(registerBtnClicked)))
        gmailBtn.isUserInteractionEnabled = true
        gmailBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loginWithGoogleBtnClicked)))
        appleBtn.isUserInteractionEnabled = true
        appleBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loginWithAppleBtnClicked)))
        phoneBtn.isUserInteractionEnabled = true
        phoneBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(phoneVerificationClicked)))
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }

    // MARK: - Remember Me

    private func configureRememberMe() {
        let rememberMeFlag = UserDefaults.standard.bool(forKey: "REMEMBER_USER")
        rememberMeCheck.isSelected = rememberMeFlag
        if rememberMeFlag {
            emailAddress.text = UserDefaults.standard.string(forKey: "USER_EMAIL")
            password.text = UserDefaults.standard.string(forKey: "PASSWORD")
        }
    }

    // MARK: - Actions

    @objc private func phoneVerificationClicked() {
        performSegue(withIdentifier: "phoneNumberSignInSeg", sender: nil)
    }

    private func configurePasswordField() {
        password.rightViewMode = .always
        updatePasswordRightView(imageName: "hide")
    }

    private func updatePasswordRightView(imageName: String) {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 13, width: 20, height: 20))
        imageView.image = UIImage(named: imageName)
        let iconContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 45))
        iconContainerView.addSubview(imageView)
        password.rightView = iconContainerView
        password.rightView?.isUserInteractionEnabled = true
        password.rightView?.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(passwordEyeClicked)
        ))
    }

    @objc private func passwordEyeClicked() {
        let isSecure = password.isSecureTextEntry
        password.isSecureTextEntry = !isSecure
        let imageName = isSecure ? "view" : "hide"
        updatePasswordRightView(imageName: imageName)
    }
    
    @objc private func backViewClicked() {
        dismiss(animated: true)
    }

    @IBAction private func rememberMeClicked(_ sender: UIButton) {
        sender.isSelected.toggle()
    }

    @objc private func registerBtnClicked() {
        performSegue(withIdentifier: "signUpSeg", sender: nil)
    }

    @objc private func forgotPasswordClicked() {
        performSegue(withIdentifier: "resetPasswordSeg", sender: nil)
    }

    @IBAction private func loginBtnClicked(_: Any) {
        guard let sEmail = emailAddress.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let sPassword = password.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !sEmail.isEmpty, !sPassword.isEmpty else {
            showSnack(messages: "Enter Email Address and Password".localized())
            return
        }

        if rememberMeCheck.isSelected {
            UserDefaults.standard.set(true, forKey: "REMEMBER_USER")
            UserDefaults.standard.set(sEmail, forKey: "USER_EMAIL")
            UserDefaults.standard.set(sPassword, forKey: "PASSWORD")
        } else {
            UserDefaults.standard.set(false, forKey: "REMEMBER_USER")
            UserDefaults.standard.removeObject(forKey: "USER_EMAIL")
            UserDefaults.standard.removeObject(forKey: "PASSWORD")
        }

        let credentials = EmailAuthProvider.credential(withEmail: sEmail, password: sPassword)
        authWithFirebase(from: "signIn", credential: credentials, phoneNumber: "", type: "password", displayName: "")
    }

    @objc private func hideKeyboard() {
        view.endEditing(true)
    }

    @objc private func loginWithGoogleBtnClicked() {
        loginWithGoogle(from: "signIn")
    }

    @objc private func loginWithAppleBtnClicked() {
        startSignInWithAppleFlow()
    }

    // MARK: - Apple Sign-In

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

    // MARK: - Helpers

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
        let hashString = hashedData.compactMap { String(format: "%02x", $0) }.joined()

        return hashString
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "signInPhoneVerificationSeg", let VC = segue.destination as? PhoneNumberVerificationController, let value = sender as? String {
            VC.verificationID = FirebaseStoreManager.auth.currentUser!.uid
            VC.phoneNumber = value
        }
    }
}

// MARK: - UITextFieldDelegate

extension SignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_: UITextField) -> Bool {
        hideKeyboard()
        return true
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension SignInViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller _: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let nonce = currentNonce,
              let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            fatalError("Invalid state: A login callback was received, but no login request was sent or token is invalid.")
        }

        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
        let displayName = [appleIDCredential.fullName?.givenName, appleIDCredential.fullName?.familyName].compactMap { $0 }.joined(separator: " ")

        authWithFirebase(from: "signIn", credential: credential, phoneNumber: nil, type: "apple", displayName: displayName)
    }

    func authorizationController(controller _: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple errored: \(error)")
    }
}

// MARK: - UITextField Extension

private extension UITextField {
    func configureTextField(placeholderImage: UIImage) {
        layer.cornerRadius = 12
        setLeftPaddingPoints(16)
        setRightPaddingPoints(10)
        setLeftView(image: placeholderImage)
        delegate = self as? UITextFieldDelegate
    }

   
}
