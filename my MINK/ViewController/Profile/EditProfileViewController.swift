// Copyright © 2023 SOFTMENT. All rights reserved.


import CropViewController
import Firebase
import UIKit

// MARK: - EditProfileDelegate

protocol EditProfileDelegate {
    func refreshUI()
}

// MARK: - EditProfileViewController

class EditProfileViewController: UIViewController {
    @IBOutlet var scrollView: UIScrollView!

    @IBOutlet var address: UITextField!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableViewHeight: NSLayoutConstraint!

    let selectGenderPicker = UIPickerView()
    @IBOutlet var backView: UIView!
    @IBOutlet var mProfile: UIImageView!
    @IBOutlet var uploadProfileBtn: UIButton!
    @IBOutlet var website: UITextField!

    @IBOutlet var bioGraphyTV: UITextView!

    @IBOutlet var fullName: UITextField!

    @IBOutlet var changePasswordStack: UIStackView!
    @IBOutlet var continueBtn: UIButton!
    var isImageSelected = false
    var delegate: EditProfileDelegate?

    @IBOutlet var oldPassword: UITextField!
    @IBOutlet var newPassword: UITextField!
    @IBOutlet var confirmPassword: UITextField!
    @IBOutlet var changePasswordBtn: UIButton!

    var places: [Place] = []

    override func viewDidLoad() {
        guard let user = UserModel.data, let _ = delegate else {
            DispatchQueue.main.async {
                self.logoutPlease()
            }
            return
        }

        if let profilePath = user.profilePic, !profilePath.isEmpty {
            self.mProfile.setImage(imageKey: profilePath, placeholder: "profile-placeholder", width: 400, height: 400)
        }

        self.fullName.text = user.fullName ?? ""
        self.address.text = user.location ?? ""
        self.website.text = user.website ?? ""
        self.bioGraphyTV.text = user.biography ?? ""

        self.scrollView.contentInsetAdjustmentBehavior = .never
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.isScrollEnabled = false
        self.tableView.contentInsetAdjustmentBehavior = .never

        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 44

        self.address.delegate = self
        self.address.addTarget(
            self,
            action: #selector(self.textFieldDidChange(textField:)),
            for: UIControl.Event.editingChanged
        )

        self.mProfile.layer.cornerRadius = 8
        self.uploadProfileBtn.layer.cornerRadius = 6

        self.website.delegate = self
        self.fullName.delegate = self

        self.bioGraphyTV.layer.cornerRadius = 8
        self.bioGraphyTV.layer.borderWidth = 1
        self.bioGraphyTV.layer.borderColor = UIColor(red: 221 / 255, green: 221 / 255, blue: 221 / 255, alpha: 1)
            .cgColor
        self.bioGraphyTV.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        self.continueBtn.layer.cornerRadius = 8

        self.backView.layer.cornerRadius = 8
        self.backView.dropShadow()
        self.backView.isUserInteractionEnabled = true
        self.backView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.backViewClicked)
        ))

        self.changePasswordBtn.layer.cornerRadius = 8

        self.newPassword.delegate = self
        self.newPassword.rightViewMode = .always
        let imageView = UIImageView(frame: CGRect(x: 0, y: 13, width: 20, height: 20))
        let image = UIImage(named: "hide")
        imageView.image = image
        let iconContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 45))
        iconContainerView.addSubview(imageView)
        self.newPassword.rightView = iconContainerView
        self.newPassword.rightView?.isUserInteractionEnabled = true
        self.newPassword.rightView?.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.passwordEyeClicked)
        ))

        self.oldPassword.delegate = self
        self.oldPassword.rightViewMode = .always
        let imageView1 = UIImageView(frame: CGRect(x: 0, y: 13, width: 20, height: 20))
        let image1 = UIImage(named: "hide")
        imageView1.image = image1
        let iconContainerView1 = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 45))
        iconContainerView1.addSubview(imageView1)
        self.oldPassword.rightView = iconContainerView1
        self.oldPassword.rightView?.isUserInteractionEnabled = true
        self.oldPassword.rightView?.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.oldpasswordEyeClicked)
        ))

        self.confirmPassword.delegate = self
        self.confirmPassword.rightViewMode = .always
        let imageView2 = UIImageView(frame: CGRect(x: 0, y: 13, width: 20, height: 20))
        let image2 = UIImage(named: "hide")
        imageView2.image = image2
        let iconContainerView2 = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 45))
        iconContainerView2.addSubview(imageView2)
        self.confirmPassword.rightView = iconContainerView2
        self.confirmPassword.rightView?.isUserInteractionEnabled = true
        self.confirmPassword.rightView?.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.confirmpasswordEyeClicked)
        ))

        if checkAuthProvider() != "password" {
            self.changePasswordStack.isHidden = true
        }

        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.hidekeyboard)))
    }

    @IBAction func changePasswordClicked(_ sender: Any) {
        let sOldPassword = self.oldPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let sNewPassword = self.newPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let sConfirmPassword = self.confirmPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines)

        if sOldPassword == "" {
            self.showSnack(messages: "Enter Current Password")
        } else if sNewPassword == "" {
            self.showSnack(messages: "Enter New Password")
        } else if sConfirmPassword == "" {
            self.showSnack(messages: "Enter Confirm Password")
        } else {
            let originalPassword = try! self.decryptMessage(
                encryptedMessage: UserModel.data!.encryptPassword ?? "123",
                encryptionKey: UserModel.data!.encryptKey ?? "123"
            )

            if originalPassword == sOldPassword {
                if sNewPassword == sConfirmPassword {
                    if sOldPassword == sNewPassword {
                        self.showError("Current password and new password must be different.")
                    } else {
                        let user = Auth.auth().currentUser
                        var credential: AuthCredential

                        // Prompt the user to re-provide their sign-in credentials
                        let email = UserModel.data!.email!
                        let password = originalPassword
                        credential = EmailAuthProvider.credential(withEmail: email, password: password)
                        self.ProgressHUDShow(text: "")
                        user?.reauthenticate(with: credential) { result, error in

                            if let error = error {
                                self.ProgressHUDHide()
                                self.showError(error.localizedDescription)
                            } else {
                                Auth.auth().currentUser?.updatePassword(to: sNewPassword!, completion: { error in
                                    self.ProgressHUDHide()
                                    if let error = error {
                                        self.showError(error.localizedDescription)
                                    } else {
                                        UserModel.data!.encryptPassword = try! self.encryptMessage(
                                            message: sNewPassword!,
                                            encryptionKey: UserModel.data!.encryptKey!
                                        )
                                        Firestore.firestore().collection(Collections.USERS.rawValue).document(user!.uid)
                                            .setData(
                                                ["encryptPassword": UserModel.data!.encryptPassword!], merge: true,
                                                completion: nil
                                            )

                                        self.newPassword.text = ""
                                        self.confirmPassword.text = ""
                                        self.oldPassword.text = ""
                                        self.showSnack(messages: "Password has been changed")
                                    }

                                })
                            }
                        }
                    }
                } else {
                    self.showSnack(messages: "New and confirm password mismatch")
                }
            } else {
                self.showSnack(messages: "Current password is incorrect")
            }
        }
    }

    @objc func passwordEyeClicked() {
        if self.newPassword.isSecureTextEntry {
            self.newPassword.isSecureTextEntry = false
            let imageView = UIImageView(frame: CGRect(x: 0, y: 13, width: 20, height: 20))
            let image = UIImage(named: "view")
            imageView.image = image
            let iconContainerView: UIView = .init(frame: CGRect(x: 0, y: 0, width: 35, height: 45))
            iconContainerView.addSubview(imageView)
            self.newPassword.rightView = iconContainerView
            self.newPassword.rightView?.isUserInteractionEnabled = true
            self.newPassword.rightView?.addGestureRecognizer(UITapGestureRecognizer(
                target: self,
                action: #selector(self.passwordEyeClicked)
            ))
        } else {
            self.newPassword.isSecureTextEntry = true
            let imageView = UIImageView(frame: CGRect(x: 0, y: 13, width: 20, height: 20))
            let image = UIImage(named: "hide")
            imageView.image = image
            let iconContainerView: UIView = .init(frame: CGRect(x: 0, y: 0, width: 35, height: 45))
            iconContainerView.addSubview(imageView)
            self.newPassword.rightView = iconContainerView
            self.newPassword.rightView?.isUserInteractionEnabled = true
            self.newPassword.rightView?.addGestureRecognizer(UITapGestureRecognizer(
                target: self,
                action: #selector(self.passwordEyeClicked)
            ))
        }
    }

    @objc func oldpasswordEyeClicked() {
        if self.oldPassword.isSecureTextEntry {
            self.oldPassword.isSecureTextEntry = false
            let imageView = UIImageView(frame: CGRect(x: 0, y: 13, width: 20, height: 20))
            let image = UIImage(named: "view")
            imageView.image = image
            let iconContainerView: UIView = .init(frame: CGRect(x: 0, y: 0, width: 35, height: 45))
            iconContainerView.addSubview(imageView)
            self.oldPassword.rightView = iconContainerView
            self.oldPassword.rightView?.isUserInteractionEnabled = true
            self.oldPassword.rightView?.addGestureRecognizer(UITapGestureRecognizer(
                target: self,
                action: #selector(self.passwordEyeClicked)
            ))
        } else {
            self.oldPassword.isSecureTextEntry = true
            let imageView = UIImageView(frame: CGRect(x: 0, y: 13, width: 20, height: 20))
            let image = UIImage(named: "hide")
            imageView.image = image
            let iconContainerView: UIView = .init(frame: CGRect(x: 0, y: 0, width: 35, height: 45))
            iconContainerView.addSubview(imageView)
            self.oldPassword.rightView = iconContainerView
            self.oldPassword.rightView?.isUserInteractionEnabled = true
            self.oldPassword.rightView?.addGestureRecognizer(UITapGestureRecognizer(
                target: self,
                action: #selector(self.passwordEyeClicked)
            ))
        }
    }

    @objc func confirmpasswordEyeClicked() {
        if self.confirmPassword.isSecureTextEntry {
            self.confirmPassword.isSecureTextEntry = false
            let imageView = UIImageView(frame: CGRect(x: 0, y: 13, width: 20, height: 20))
            let image = UIImage(named: "view")
            imageView.image = image
            let iconContainerView: UIView = .init(frame: CGRect(x: 0, y: 0, width: 35, height: 45))
            iconContainerView.addSubview(imageView)
            self.confirmPassword.rightView = iconContainerView
            self.confirmPassword.rightView?.isUserInteractionEnabled = true
            self.confirmPassword.rightView?.addGestureRecognizer(UITapGestureRecognizer(
                target: self,
                action: #selector(self.passwordEyeClicked)
            ))
        } else {
            self.confirmPassword.isSecureTextEntry = true
            let imageView = UIImageView(frame: CGRect(x: 0, y: 13, width: 20, height: 20))
            let image = UIImage(named: "hide")
            imageView.image = image
            let iconContainerView: UIView = .init(frame: CGRect(x: 0, y: 0, width: 35, height: 45))
            iconContainerView.addSubview(imageView)
            self.confirmPassword.rightView = iconContainerView
            self.confirmPassword.rightView?.isUserInteractionEnabled = true
            self.confirmPassword.rightView?.addGestureRecognizer(UITapGestureRecognizer(
                target: self,
                action: #selector(self.passwordEyeClicked)
            ))
        }
    }

    @objc func textFieldDidChange(textField: UITextField) {
        guard let query = textField.text, !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            self.places.removeAll()

            self.tableView.reloadData()
            return
        }

        GooglePlacesManager.shared.findPlaces(query: query) { result in
            switch result {
            case .success(let places):
                self.places = places

                self.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }

    @objc func hidekeyboard() {
        view.endEditing(true)
    }

    @objc func backViewClicked() {
        dismiss(animated: true)
    }

    @IBAction func continueBtnClicked(_: Any) {
        let sWeb = self.website.text
        let sBio = self.bioGraphyTV.text
        let sFullname = self.fullName.text
        let sAddress = self.address.text

        if sFullname == "" {
            showSnack(messages: "Enter Full Name")
        } else if sAddress == "" {
            showSnack(messages: "Enter Location")
        } else if sBio == "" {
            showSnack(messages: "Enter Biography")
        } else {
            UserModel.data!.biography = sBio
            UserModel.data!.website = sWeb
            UserModel.data!.location = sAddress
            UserModel.data!.fullName = sFullname

            if self.isImageSelected {
                uploadFilesOnAWS(
                    photo: self.mProfile.image!,
                    previousKey: UserModel.data!.profilePic,
                    folderName: "ProfilePictures",
                    postType: .IMAGE
                ) { downloadURL in
             
                 
                    UserModel.data!.profilePic = downloadURL
                    
                    self.updateProfile()
                }
            } else {
                self.updateProfile()
            }
        }
    }
    
    

    func updateProfile() {
        ProgressHUDShow(text: "")
        try? FirebaseStoreManager.db.collection(Collections.USERS.rawValue).document(FirebaseStoreManager.auth.currentUser!.uid)
            .setData(from: UserModel.data!, merge: true, completion: { error in
                self.ProgressHUDHide()
                if let error = error {
                    self.ProgressHUDHide()
                    self.showError(error.localizedDescription)
                } else {
                    self.delegate!.refreshUI()
                    self.showSnack(messages: "Profile Updated")
                }
            })
    }

    @objc func locationCellClicked(myGesture: MyGesture) {
        self.tableView.isHidden = true
        view.endEditing(true)

        let place = self.places[myGesture.index]
        self.address.text = place.name ?? ""

        GooglePlacesManager.shared.resolveLocation(for: place) { result in
            switch result {
            case .success:

                break
            case .failure(let error):
                print(error)
            }
        }
    }

    func updateTableViewHeight() {
        self.tableViewHeight.constant = self.tableView.contentSize.height
        self.tableView.layoutIfNeeded()
    }

    @IBAction func uploadProfileClick(_: Any) {
        let alert = UIAlertController(title: "Upload Profile Picture", message: "", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Using Camera", style: .default) { _ in

            let image = UIImagePickerController()
            image.title = "Profile Picture"
            image.delegate = self
            image.sourceType = .camera
            self.present(image, animated: true)
        }

        let action2 = UIAlertAction(title: "From Photo Library", style: .default) { _ in

            let image = UIImagePickerController()
            image.delegate = self
            image.title = "Profile Picture"
            image.sourceType = .photoLibrary

            self.present(image, animated: true)
        }

        let action3 = UIAlertAction(title: "Cancel", style: .cancel) { _ in

            alert.dismiss(animated: true, completion: nil)
        }

        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(action3)

        present(alert, animated: true, completion: nil)
    }
}

// MARK: UITextFieldDelegate

extension EditProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_: UITextField) -> Bool {
        self.hidekeyboard()
        return true
    }
}

// MARK: UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate,
    CropViewControllerDelegate
{
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        if let editedImage = info[.originalImage] as? UIImage {
            dismiss(animated: true) {
                let cropViewController = CropViewController(image: editedImage)
                cropViewController.title = picker.title
                cropViewController.delegate = self
                cropViewController.customAspectRatio = CGSize(width: 1, height: 1)
                cropViewController.aspectRatioLockEnabled = true
                cropViewController.aspectRatioPickerButtonHidden = true
                self.present(cropViewController, animated: true, completion: nil)
            }
        }

        dismiss(animated: true, completion: nil)
    }

    func cropViewController(_: CropViewController, didCropToImage image: UIImage, withRect _: CGRect, angle _: Int) {
        self.isImageSelected = true
        self.mProfile.image = image

        dismiss(animated: true, completion: nil)
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource

extension EditProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection _: Int) -> Int {
        if !self.places.isEmpty {
            tableView.isHidden = false
        } else {
            tableView.isHidden = true
        }
        return self.places.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "placescell", for: indexPath) as? GooglePlacesCell {
            cell.name.text = self.places[indexPath.row].name ?? ""
            cell.mView.isUserInteractionEnabled = true

            let myGesture = MyGesture(target: self, action: #selector(self.locationCellClicked(myGesture:)))
            myGesture.index = indexPath.row
            cell.mView.addGestureRecognizer(myGesture)

            let totalRow = tableView.numberOfRows(inSection: indexPath.section)
            if indexPath.row == totalRow - 1 {
                DispatchQueue.main.async {
                    self.updateTableViewHeight()
                }
            }
            return cell
        }

        return GooglePlacesCell()
    }
}
