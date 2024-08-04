//
//  AddBusinessProfile.swift
//  my MINK
//
//  Created by Vijay Rathore on 05/06/24.
//

import UIKit
import CropViewController

class AddBusinessProfileViewController: UIViewController {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var businessType: UITextField!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var coverPhoto: UIImageView!
    @IBOutlet weak var uploadBtn: UIButton!
    @IBOutlet weak var businessNameTF: UITextField!
    @IBOutlet weak var websiteURLTF: UITextField!
    @IBOutlet weak var descriptionTF: UITextView!
    
    var isImageSelected = false
    var isCoverPhotoSelected = false
    var delegate: ReloadTableViewDelegate?
    let businessTypePicker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPicker()
        setupTextView()
        setupImageViewGestures()
    }
    
    private func setupUI() {
        backView.isUserInteractionEnabled = true
        backView.dropShadow()
        backView.layer.cornerRadius = 8
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        profilePic.layer.cornerRadius = 8
        uploadBtn.layer.cornerRadius = 8
        addBtn.layer.cornerRadius = 8
    }
    
    private func setupPicker() {
        businessType.delegate = self
        businessTypePicker.delegate = self
        businessTypePicker.dataSource = self
        
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.tintColor = .link
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(businessTypePickerDoneClicked))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(businessTypePickerCancelClicked))
        
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        businessType.inputAccessoryView = toolbar
        businessType.inputView = businessTypePicker
    }
    
    private func setupTextView() {
        descriptionTF.layer.cornerRadius = 8
        descriptionTF.layer.borderWidth = 1
        descriptionTF.layer.borderColor = UIColor(red: 221/255, green: 221/255, blue: 221/255, alpha: 1).cgColor
        descriptionTF.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    private func setupImageViewGestures() {
        coverPhoto.isUserInteractionEnabled = true
        coverPhoto.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(coverPhotoUpload)))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked)))
    }
    
    @objc private func businessTypePickerDoneClicked() {
        businessType.resignFirstResponder()
        let row = businessTypePicker.selectedRow(inComponent: 0)
        businessType.text = Constants.businessTypes[row]
    }
    
    @objc private func businessTypePickerCancelClicked() {
        view.endEditing(true)
    }
    
    @objc private func viewClicked() {
        view.endEditing(true)
    }
    
    @objc private func coverPhotoUpload() {
        presentImagePicker(title: "Cover Picture")
    }
    
    @objc private func backViewClicked() {
        dismiss(animated: true)
    }
    
    @IBAction private func addBtnClicked(_ sender: Any) {
        guard validateInputs() else { return }
        let businessModel = createBusinessModel()
        
        ProgressHUDShow(text: "Uploading Pictures")
        let group = DispatchGroup()
        
        group.enter()
        uploadImage(image: profilePic.image!, folder: "BusinessProfilePictures") { url in
            businessModel.profilePicture = url
            group.leave()
        }
        
        group.enter()
        uploadImage(image: coverPhoto.image!, folder: "BusinessCoverPictures") { url in
            businessModel.coverPicture = url
            group.leave()
        }
        
        group.notify(queue: .main) {
            self.ProgressHUDHide()
            self.saveBusiness(businessModel: businessModel)
        }
    }
    
    private func validateInputs() -> Bool {
        guard isImageSelected else {
            showSnack(messages: "Upload Profile Picture")
            return false
        }
        guard isCoverPhotoSelected else {
            showSnack(messages: "Upload Cover Picture")
            return false
        }
        guard let title = businessNameTF.text?.trimmingCharacters(in: .whitespacesAndNewlines), !title.isEmpty else {
            showSnack(messages: "Enter Business Name")
            return false
        }
        guard let website = websiteURLTF.text?.trimmingCharacters(in: .whitespacesAndNewlines), !website.isEmpty else {
            showSnack(messages: "Enter Website")
            return false
        }
        guard let type = businessType.text, !type.isEmpty else {
            showSnack(messages: "Select Business Type")
            return false
        }
        guard let description = descriptionTF.text?.trimmingCharacters(in: .whitespacesAndNewlines), !description.isEmpty else {
            showSnack(messages: "Enter Description")
            return false
        }
        return true
    }
    
    private func createBusinessModel() -> BusinessModel {
        let businessModel = BusinessModel()
        businessModel.businessId = FirebaseStoreManager.db.collection(Collections.businesses.rawValue).document().documentID
        businessModel.createdAt = Date()
        businessModel.isActive = true
        businessModel.name = businessNameTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        businessModel.website = websiteURLTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        businessModel.aboutBusiness = descriptionTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        businessModel.businessCategory = Constants.businessTypes[businessTypePicker.selectedRow(inComponent: 0)]
        businessModel.uid = FirebaseStoreManager.auth.currentUser!.uid
        businessModel.deviceToken = UserModel.data!.deviceToken
        businessModel.notificationToken = UserModel.data!.notificationToken
        return businessModel
    }
    
    private func uploadImage(image: UIImage, folder: String, completion: @escaping (String) -> Void) {
        uploadFilesOnAWS(photo: image, folderName: folder, postType: .image) { downloadURL in
            completion(downloadURL ?? "")
        }
    }
    
    private func saveBusiness(businessModel: BusinessModel) {
        ProgressHUDShow(text: "")
        createDeepLinkForBusiness(businessModel: businessModel) { url, error in
            guard let url = url else {
                self.showError(error!.localizedDescription)
                return
            }
            businessModel.shareLink = url
            try? FirebaseStoreManager.db.collection(Collections.businesses.rawValue).document(businessModel.businessId!).setData(from: businessModel, merge: true) { error in
                self.ProgressHUDHide()
                if let error = error {
                    self.showError(error.localizedDescription)
                } else {
                    self.showSnack(messages: "Business Added")
                    self.delegate?.reloadTableView()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self.dismiss(animated: true)
                    }
                }
            }
        }
    }
    
    @IBAction private func uploadBtnClicked(_ sender: Any) {
        presentImagePicker(title: "Profile Picture")
    }
    
    private func presentImagePicker(title: String) {
        let alert = UIAlertController(title: "Upload \(title)", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Using Camera", style: .default) { _ in
            self.showImagePicker(sourceType: .camera, title: title)
        })
        alert.addAction(UIAlertAction(title: "From Photo Library", style: .default) { _ in
            self.showImagePicker(sourceType: .photoLibrary, title: title)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showImagePicker(sourceType: UIImagePickerController.SourceType, title: String) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.title = title
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true)
    }
}

extension AddBusinessProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let editedImage = info[.originalImage] as? UIImage else { return }
        dismiss(animated: true) {
            let cropViewController = CropViewController(image: editedImage)
            cropViewController.title = picker.title
            cropViewController.delegate = self
            if picker.title == "Profile Picture" {
                cropViewController.customAspectRatio = CGSize(width: 1, height: 1)
            } else {
                cropViewController.customAspectRatio = CGSize(width: 414, height: 220)
            }
            cropViewController.aspectRatioLockEnabled = true
            cropViewController.aspectRatioPickerButtonHidden = true
            self.present(cropViewController, animated: true)
        }
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        if cropViewController.title == "Profile Picture" {
            isImageSelected = true
            profilePic.image = image
        } else {
            isCoverPhotoSelected = true
            coverPhoto.image = image
        }
        dismiss(animated: true)
    }
}

extension AddBusinessProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

extension AddBusinessProfileViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Constants.businessTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Constants.businessTypes[row]
    }
}
