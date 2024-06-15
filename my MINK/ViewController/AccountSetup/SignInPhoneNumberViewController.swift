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
    override func viewDidLoad() {
        self.backView.isUserInteractionEnabled = true
        self.backView.dropShadow()
        self.backView.layer.cornerRadius = 8
        self.backView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.backViewClicked)
        ))

        codeTF.delegate = self
        codeTF.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(countryCodeClicked)))
        self.signUpBtn.layer.cornerRadius = 8
        
        if for2FA {
            signUpBtn.setTitle("Enable 2FA", for: .normal)
        }
       
        let country = Country(isoCode: getCountryCode().uppercased())
        sCode = country.phoneCode
        codeTF.text = country.isoCode.getFlag() + " " + country.phoneCode
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.hidekeyboard)))
    }
    
    @objc func countryCodeClicked(){
        showCountryPicker()
    }

    @objc func hidekeyboard() {
        view.endEditing(true)
    }

    @objc func backViewClicked() {
        dismiss(animated: true)
    }

    @IBAction func signUpClicked(_: Any) {
      
        let sPhone = self.phoneTF.text

        if self.sCode == "" {
            showSnack(messages: "Select Phone Code")
        } else if sPhone == "" {
            showSnack(messages: "Enter Phone Number")
        } else {
            let phoneNumber = "+\(self.sCode)\(sPhone!)"

            self.phoneNumber = phoneNumber

            if self.for2FA {
                ProgressHUDShow(text: "Retrieving activation code for 2FA...")
            } else {
                ProgressHUDShow(text: "Signing in...")
            }

            FirebaseStoreManager.db.collection(Collections.USERS.rawValue).whereField("phoneNumber", isEqualTo: phoneNumber)
                .getDocuments { snapshot, error in
                    if let snapshot = snapshot, !snapshot.isEmpty {
                        self.verifyPhoneNumber(phoneNumber: phoneNumber, session: nil)
                    } else {
                        self.ProgressHUDHide()
                        self.showMessage(
                            title: "Account Not Found.",
                            message: "There is no account link with this phone number. Please sign up new account first."
                        )
                    }
                }
        }
    }

    func verifyPhoneNumber(phoneNumber: String, session: MultiFactorSession?) {
        self.sendTwilioVerification(to: phoneNumber) { error in
            DispatchQueue.main.async {
                self.ProgressHUDHide()
                if let error = error {
                    self.showError(error)
                } else {
                    let uid = self.generateUniqueCode(using: phoneNumber)
                    self.performSegue(
                        withIdentifier: "signInPhoneVerificationSeg",
                        sender: uid
                    )
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "signInPhoneVerificationSeg" {
            if let VC = segue.destination as? PhoneNumberVerificationController {
                if let code = sender as? String {
                    VC.verificationID = code
                    VC.phoneNumber = self.phoneNumber
                    VC.for2FA = self.for2FA
                }
            }
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

extension SignInPhoneNumberViewController : CountryPickerDelegate {
    func countryPicker(didSelect country: Country) {
        sCode = country.phoneCode
        codeTF.text = country.isoCode.getFlag() + " " + country.phoneCode
    }
}
