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
    var sCode: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupCountryPicker()
    }

    private func setupViews() {
        setupTextField(firstName, image: UIImage(named: "user"))
        setupTextField(lastName, image: UIImage(named: "user"))
        setupTextField(phoneTF)
        
        backView.isUserInteractionEnabled = true
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))

        signUpBtn.layer.cornerRadius = 8

        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hidekeyboard)))
    }

    private func setupTextField(_ textField: UITextField, image: UIImage? = nil) {
        textField.layer.cornerRadius = 12
        textField.setLeftPaddingPoints(16)
        textField.setRightPaddingPoints(10)
        if let image = image {
            textField.setLeftView(image: image)
        }
        textField.delegate = self
    }

    private func setupCountryPicker() {
        let country = Country(isoCode: getCountryCode().uppercased())
        sCode = country.phoneCode
        codeTF.text = country.isoCode.getFlag() + " " + country.phoneCode
        codeTF.delegate = self
        codeTF.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(countryCodeClicked)))
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
        guard let sFirstName = firstName.text?.trimmingCharacters(in: .whitespacesAndNewlines), !sFirstName.isEmpty else {
            showSnack(messages: "Enter First Name".localized())
            return
        }

        guard let sLastName = lastName.text?.trimmingCharacters(in: .whitespacesAndNewlines), !sLastName.isEmpty else {
            showSnack(messages: "Enter Last Name".localized())
            return
        }

        guard !sCode.isEmpty else {
            showSnack(messages: "Select Phone Code".localized())
            return
        }

        guard let sPhone = phoneTF.text, !sPhone.isEmpty else {
            showSnack(messages: "Enter Phone Number".localized())
            return
        }

        fullName = "\(sFirstName) \(sLastName)"
        phoneNumber = "+\(sCode)\(sPhone)"

        ProgressHUDShow(text: "Creating Account...".localized())

        FirebaseStoreManager.db.collection(Collections.users.rawValue).whereField("phoneNumber", isEqualTo: phoneNumber)
            .getDocuments { snapshot, error in
                self.ProgressHUDHide()
                if let snapshot = snapshot, !snapshot.isEmpty {
                    self.showMessage(
                        title: "Account Exist".localized(),
                        message: "There is an account already available with the same phone number. Please Sign In.".localized()
                    )
                } else {
                    self.sendTwilioVerification(to: self.phoneNumber) { error in
                        DispatchQueue.main.async {
                            if let error = error {
                                self.showError(error)
                            } else {
                                self.performSegue(withIdentifier: "phoneVerificationSeg", sender: nil)
                            }
                        }
                    }
                }
            }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "phoneVerificationSeg",
           let VC = segue.destination as? PhoneNumberVerificationController {
            VC.verificationID = UUID().uuidString
            VC.fullName = fullName
            VC.phoneNumber = phoneNumber
        }
    }

    private func showCountryPicker() {
        let countryPicker = CountryPickerViewController()
        countryPicker.selectedCountry = getCountryCode().uppercased()
        countryPicker.delegate = self
        present(countryPicker, animated: true)
    }
}

// MARK: UITextFieldDelegate

extension SignUpPhoneNumberViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hidekeyboard()
        return true
    }
}

// MARK: CountryPickerDelegate

extension SignUpPhoneNumberViewController: CountryPickerDelegate {
    func countryPicker(didSelect country: Country) {
        sCode = country.phoneCode
        codeTF.text = country.isoCode.getFlag() + " " + country.phoneCode
    }
}
