// Copyright © 2023 SOFTMENT. All rights reserved.


import CropViewController
import Firebase
import UIKit

// MARK: - CompleteProfileViewController

class CompleteProfileViewController: UIViewController {
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

    @IBOutlet var usernameTF: UITextField!
    @IBOutlet var continueBtn: UIButton!
    var isImageSelected = false
    var isLocationSelected: Bool = false

    var places: [Place] = []

    override func viewDidLoad() {
        if UserModel.data == nil {
            DispatchQueue.main.async {
                self.logoutPlease()
            }
        }

        self.scrollView.contentInsetAdjustmentBehavior = .never

        self.usernameTF.layer.cornerRadius = 12
        self.usernameTF.setLeftPaddingPoints(16)
        self.usernameTF.setRightPaddingPoints(10)
        self.usernameTF.setLeftView(image: UIImage(named: "at")!)
        self.usernameTF.delegate = self

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

        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.hidekeyboard)))
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
        logoutPlease()
    }

    @IBAction func continueBtnClicked(_: Any) {
        let sWeb = self.website.text
        let sBio = self.bioGraphyTV.text
        let sUsername = self.usernameTF.text
        if !self.isImageSelected {
            showSnack(messages: "Upload Profile Picture")
        } else if sUsername == "" {
            showSnack(messages: "Enter Username")
        } else if !self.isLocationSelected {
            showSnack(messages: "Enter Location")
        } else if sBio == "" {
            showSnack(messages: "Enter Biography")
        } else {
            UserModel.data!.biography = sBio
            UserModel.data!.website = sWeb
            UserModel.data!.location = self.address.text

            ProgressHUDShow(text: "")

            FirebaseStoreManager.db.collection("Users").whereField("username", isEqualTo: sUsername ?? "")
                .getDocuments { snapshot, error in
                    self.ProgressHUDHide()
                    if error != nil {
                        self.showSnack(messages: "Username is already in use.")
                    } else {
                        if let snapshot = snapshot, snapshot.isEmpty {
                            UserModel.data!.username = sUsername
                            self.uploadFilesOnAWS(
                                photo: self.mProfile.image!,
                                previousKey: UserModel.data!.profilePic,
                                folderName: "ProfilePictures",
                                postType: .IMAGE
                            ) { downloadURL in
                                UserModel.data!.profilePic = downloadURL

                                self.createDeepLinkForUserProfile(
                                    userModel: UserModel.data!,
                                    completion: { url, error in
                                        if let url = url {
                                            UserModel.data!.profileURL = url
                                        }

                                        self.ProgressHUDShow(text: "")
                                        try? FirebaseStoreManager.db.collection("Users")
                                            .document(FirebaseStoreManager.auth.currentUser!.uid)
                                            .setData(from: UserModel.data!, merge: true, completion: { error in

                                                if let error = error {
                                                    self.ProgressHUDHide()
                                                    self.showError(error.localizedDescription)
                                                } else {
                                                    self.beRootScreen(
                                                        storyBoardName: .Tabbar,
                                                        mIdentifier: .TABBARVIEWCONTROLLER
                                                    )
                                                }
                                            })
                                    }
                                )
                            }
                        } else {
                            self.ProgressHUDHide()
                            self.showSnack(messages: "Username is not available")
                        }
                    }
                }
        }
    }

    @objc func locationCellClicked(myGesture: MyGesture) {
        self.tableView.isHidden = true
        view.endEditing(true)

        let place = self.places[myGesture.index]
        self.address.text = place.name ?? ""

        self.isLocationSelected = true

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

extension CompleteProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_: UITextField) -> Bool {
        self.hidekeyboard()
        return true
    }
}

// MARK: UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate

extension CompleteProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate,
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

extension CompleteProfileViewController: UITableViewDelegate, UITableViewDataSource {
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
