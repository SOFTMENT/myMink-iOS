// Copyright © 2023 SOFTMENT. All rights reserved.

import AuthenticationServices
import Firebase
import GoogleSignIn
import UIKit
import CountryPicker

// MARK: - SignInPhoneNumberViewController

class SignInPhoneNumberViewController: UIViewController {
    @IBOutlet var codeTF: UITextField!
    @IBOutlet var phoneTF: UITextField!
    @IBOutlet var signUpBtn: UIButton!
    @IBOutlet var backView: UIView!
    var phoneNumber: String?
    var for2FA: Bool = false
    var sCode = ""
    
    @IBOutlet weak var loginTitle: UILabel!
    
    override func viewDidLoad() {
        setupViews()
        setupCountryPicker()
    }

    private func setupViews() {
        
        backView.isUserInteractionEnabled = true
        backView.dropShadow()
        backView.layer.cornerRadius = 8
        backView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.backViewClicked)
        ))

        codeTF.delegate = self
        codeTF.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(countryCodeClicked)))
        signUpBtn.layer.cornerRadius = 8
        
        if for2FA {
            loginTitle.text = "2FA".localized()
            signUpBtn.setTitle("Enable 2FA".localized(), for: .normal)
        }
       
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.hidekeyboard)))
    }

    private func setupCountryPicker() {
        let country = Country(isoCode: getCountryCode().uppercased())
        sCode = country.phoneCode
        codeTF.text = country.isoCode.getFlag() + " " + country.phoneCode
    }

    @objc func countryCodeClicked() {
        showCountryPicker()
    }

    @objc func hidekeyboard() {
        view.endEditing(true)
    }

    @objc func backViewClicked() {
        dismiss(animated: true)
    }

    @IBAction func signUpClicked(_: Any) {
        guard !sCode.isEmpty else {
            showSnack(messages: "Select Phone Code".localized())
            return
        }

        guard let sPhone = phoneTF.text, !sPhone.isEmpty else {
            showSnack(messages: "Enter Phone Number".localized())
            return
        }

        phoneNumber = "+\(sCode)\(sPhone)"

        if for2FA, let user = FirebaseStoreManager.auth.currentUser {
            ProgressHUDShow(text: "Retrieving activation code for 2FA...".localized())
            self.verifyPhoneNumber(phoneNumber: self.phoneNumber!, uid: user.uid, session: nil)
        } else {
            ProgressHUDShow(text: "Signing in...".localized())
            FirebaseStoreManager.db.collection(Collections.users.rawValue).whereField("phoneNumber", isEqualTo: phoneNumber!)
                .getDocuments { snapshot, error in
                    if let snapshot = snapshot, !snapshot.documents.isEmpty,
                       let userModel = try? snapshot.documents.first?.data(as: UserModel.self),
                       let uid = userModel.uid {
                        self.verifyPhoneNumber(phoneNumber: self.phoneNumber!, uid: uid, session: nil)
                    } else {
                        self.ProgressHUDHide()
                        self.showMessage(
                            title: "Account Not Found.".localized(),
                            message: "There is no account linked with this phone number. Please sign up for a new account first.".localized()
                        )
                    }
                }
        }
      
    }

    func verifyPhoneNumber(phoneNumber: String, uid: String, session: MultiFactorSession?) {
        self.sendTwilioVerification(to: phoneNumber) { error in
            DispatchQueue.main.async {
                self.ProgressHUDHide()
                if let error = error {
                    self.showError(error)
                } else {
                    self.performSegue(
                        withIdentifier: "signInPhoneVerificationSeg",
                        sender: uid
                    )
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "signInPhoneVerificationSeg",
           let VC = segue.destination as? PhoneNumberVerificationController,
           let code = sender as? String {
            VC.verificationID = code
            VC.phoneNumber = self.phoneNumber
            VC.for2FA = self.for2FA
        }
    }

    func showCountryPicker() {
        let countryPicker = CountryPickerViewController()
    
        countryPicker.selectedCountry = getCountryCode().uppercased()
        countryPicker.delegate = self
        self.present(countryPicker, animated: true)
    }
}

// MARK: UITextFieldDelegate

extension SignInPhoneNumberViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_: UITextField) -> Bool {
        self.hidekeyboard()
        return true
    }
}

// MARK: CountryPickerDelegate

extension SignInPhoneNumberViewController: CountryPickerDelegate {
    func countryPicker(didSelect country: Country) {
        sCode = country.phoneCode
        codeTF.text = country.isoCode.getFlag() + " " + country.phoneCode
    }
}
