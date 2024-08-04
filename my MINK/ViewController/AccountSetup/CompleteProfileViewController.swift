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
    @IBOutlet var backView: UIView!
    @IBOutlet var mProfile: UIImageView!
    @IBOutlet var uploadProfileBtn: UIButton!
    @IBOutlet var website: UITextField!
    @IBOutlet var bioGraphyTV: UITextView!
    @IBOutlet var usernameTF: UITextField!
    @IBOutlet var continueBtn: UIButton!

    var isImageSelected = false
    var isLocationSelected = false
    var places: [Place] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        guard UserModel.data != nil else {
            DispatchQueue.main.async {
                self.logoutPlease()
            }
            return
        }

        setupViews()
        setupTableView()
    }

    private func setupViews() {
        scrollView.contentInsetAdjustmentBehavior = .never

        setupTextField(usernameTF, placeholderImage: UIImage(named: "at"))
        setupTextField(address, placeholderImage: nil)
        address.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        setupTextField(website, placeholderImage: nil)

        mProfile.layer.cornerRadius = 8
        uploadProfileBtn.layer.cornerRadius = 6

        bioGraphyTV.layer.cornerRadius = 8
        bioGraphyTV.layer.borderWidth = 1
        bioGraphyTV.layer.borderColor = UIColor(red: 221 / 255, green: 221 / 255, blue: 221 / 255, alpha: 1).cgColor
        bioGraphyTV.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        continueBtn.layer.cornerRadius = 8

        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))

        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }

    private func setupTextField(_ textField: UITextField, placeholderImage: UIImage?) {
        textField.layer.cornerRadius = 12
        textField.setLeftPaddingPoints(16)
        textField.setRightPaddingPoints(10)
        if let image = placeholderImage {
            textField.setLeftView(image: image)
        }
        textField.delegate = self
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
    }

    @objc private func textFieldDidChange(textField: UITextField) {
        guard let query = textField.text, !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            places.removeAll()
            tableView.reloadData()
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

    @objc private func hideKeyboard() {
        view.endEditing(true)
    }

    @objc private func backViewClicked() {
        logoutPlease()
    }

    @IBAction private func continueBtnClicked(_: Any) {
        guard isImageSelected else {
            showSnack(messages: "Upload Profile Picture")
            return
        }
        guard let sUsername = usernameTF.text, !sUsername.isEmpty else {
            showSnack(messages: "Enter Username")
            return
        }
        guard isLocationSelected else {
            showSnack(messages: "Enter Location")
            return
        }
        guard let sBio = bioGraphyTV.text, !sBio.isEmpty else {
            showSnack(messages: "Enter Biography")
            return
        }

        UserModel.data!.biography = sBio
        UserModel.data!.website = website.text
        UserModel.data!.location = address.text

        ProgressHUDShow(text: "")

        FirebaseStoreManager.db.collection(Collections.users.rawValue).whereField("username", isEqualTo: sUsername)
            .getDocuments { snapshot, error in
                self.ProgressHUDHide()
                if let error = error {
                    self.showSnack(messages: error.localizedDescription)
                } else if let snapshot = snapshot, snapshot.isEmpty {
                    self.updateUserProfile(username: sUsername)
                } else {
                    self.showSnack(messages: "Username is not available")
                }
            }
    }

    private func updateUserProfile(username: String) {
        UserModel.data!.username = username
        guard let profileImage = mProfile.image else { return }

        uploadFilesOnAWS(photo: profileImage, previousKey: UserModel.data!.profilePic, folderName: "ProfilePictures", postType: .image) { downloadURL in
            UserModel.data!.profilePic = downloadURL

            self.createDeepLinkForUserProfile(userModel: UserModel.data!) { url, error in
                if let url = url {
                    UserModel.data!.profileURL = url
                }

                self.ProgressHUDShow(text: "")
                try? FirebaseStoreManager.db.collection(Collections.users.rawValue)
                    .document(FirebaseStoreManager.auth.currentUser!.uid)
                    .setData(from: UserModel.data!, merge: true) { error in
                        self.ProgressHUDHide()
                        if let error = error {
                            self.showError(error.localizedDescription)
                        } else {
                            self.beRootScreen(storyBoardName: .tabBar, mIdentifier: .tabBarViewController)
                        }
                    }
            }
        }
    }

    @objc private func locationCellClicked(myGesture: MyGesture) {
        tableView.isHidden = true
        view.endEditing(true)

        let place = places[myGesture.index]
        address.text = place.name
        isLocationSelected = true

        GooglePlacesManager.shared.resolveLocation(for: place) { result in
            if case .failure(let error) = result {
                print(error)
            }
        }
    }

    private func updateTableViewHeight() {
        tableViewHeight.constant = tableView.contentSize.height
        tableView.layoutIfNeeded()
    }

    @IBAction private func uploadProfileClick(_: Any) {
        let alert = UIAlertController(title: "Upload Profile Picture", message: "", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Using Camera", style: .default) { _ in
            self.presentImagePicker(sourceType: .camera)
        }
        let action2 = UIAlertAction(title: "From Photo Library", style: .default) { _ in
            self.presentImagePicker(sourceType: .photoLibrary)
        }
        let action3 = UIAlertAction(title: "Cancel", style: .cancel)

        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(action3)

        present(alert, animated: true)
    }

    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.title = "Profile Picture"
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension CompleteProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyboard()
        return true
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate

extension CompleteProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let editedImage = info[.originalImage] as? UIImage {
            dismiss(animated: true) {
                let cropViewController = CropViewController(image: editedImage)
                cropViewController.title = picker.title
                cropViewController.delegate = self
                cropViewController.customAspectRatio = CGSize(width: 1, height: 1)
                cropViewController.aspectRatioLockEnabled = true
                cropViewController.aspectRatioPickerButtonHidden = true
                self.present(cropViewController, animated: true)
            }
        } else {
            dismiss(animated: true)
        }
    }

    func cropViewController(_: CropViewController, didCropToImage image: UIImage, withRect _: CGRect, angle _: Int) {
        isImageSelected = true
        mProfile.image = image
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension CompleteProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection _: Int) -> Int {
        tableView.isHidden = places.isEmpty
        return places.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "placescell", for: indexPath) as? GooglePlacesCell else {
            return GooglePlacesCell()
        }

        cell.name.text = places[indexPath.row].name
        cell.mView.isUserInteractionEnabled = true

        let myGesture = MyGesture(target: self, action: #selector(locationCellClicked))
        myGesture.index = indexPath.row
        cell.mView.addGestureRecognizer(myGesture)

        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            DispatchQueue.main.async {
                self.updateTableViewHeight()
            }
        }
        return cell
    }
}
