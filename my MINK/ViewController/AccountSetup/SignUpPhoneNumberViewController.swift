// Copyright © 2023 SOFTMENT. All rights reserved.


import Firebase
import UIKit
import CountryPicker

// MARK: - SignUpPhoneNumberViewController

class SignUpPhoneNumberViewController: UIViewController {
    @IBOutlet var codeTF: UITextField!
    @IBOutlet var phoneTF: UITextField!
    @IBOutlet var signUpBtn: UIButton!
    @IBOutlet var backView: UIView!
    @IBOutlet var lastName: UITextField!
    @IBOutlet var firstName: UITextField!
    var fullName: String = ""
    var phoneNumber: String = ""
    var sCode = ""

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

        self.backView.isUserInteractionEnabled = true
        self.backView.dropShadow()
        self.backView.layer.cornerRadius = 8
        self.backView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.backViewClicked)
        ))

      
        codeTF.delegate = self
        codeTF.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(countryCodeClicked)))

        let country = Country(isoCode: getCountryCode().uppercased())
        sCode = country.phoneCode
        codeTF.text = country.isoCode.getFlag() + " " + country.phoneCode
        
        self.signUpBtn.layer.cornerRadius = 8

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
        let sFirstName = self.firstName.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let sLastName = self.lastName.text?.trimmingCharacters(in: .whitespacesAndNewlines)
     
        let sPhone = self.phoneTF.text

        if sFirstName == "" {
            showSnack(messages: "Enter First Name")
        } else if sLastName == "" {
            showSnack(messages: "Enter Last Name")
        } else if sCode == "" {
            showSnack(messages: "Select Phone Code")
        } else if sPhone == "" {
            showSnack(messages: "Enter Phone Number")
        } else {
            self.fullName = "\(sFirstName!) \(sLastName!)"
            let phoneNumber = "+\(self.sCode)\(sPhone!)"
            self.phoneNumber = phoneNumber
            ProgressHUDShow(text: "Creating Account...")

            FirebaseStoreManager.db.collection(Collections.USERS.rawValue).whereField("phoneNumber", isEqualTo: phoneNumber)
                .getDocuments { snapshot, error in
                    if let snapshot = snapshot, !snapshot.isEmpty {
                        self.ProgressHUDHide()
                        self.showMessage(
                            title: "Account Exist",
                            message: "There is a account already available with same phone number. Please Sign In."
                        )
                    } else {
                        let uid = self.generateUniqueCode(using: phoneNumber)

                        self.sendTwilioVerification(to: phoneNumber) { error in
                            DispatchQueue.main.async {
                                self.ProgressHUDHide()
                                if let error = error {
                                    self.showError(error)
                                } else {
                                    self.performSegue(
                                        withIdentifier: "phoneVerificationSeg",
                                        sender: uid
                                    )
                                }
                            }
                        }
                    }
                }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "phoneVerificationSeg" {
            if let VC = segue.destination as? PhoneNumberVerificationController {
                if let code = sender as? String {
                    VC.verificationID = code
                    VC.fullName = self.fullName
                    VC.phoneNumber = self.phoneNumber
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

extension SignUpPhoneNumberViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_: UITextField) -> Bool {
        self.hidekeyboard()
        return true
    }
}

// MARK: CountryPickerDelegate


extension SignUpPhoneNumberViewController : CountryPickerDelegate {
    func countryPicker(didSelect country: Country) {
        codeTF.text = country.isoCode.getFlag() + " " + country.phoneCode
    }
}
