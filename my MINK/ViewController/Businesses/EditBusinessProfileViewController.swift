//
//  EditBusinessProfileViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 06/06/24.
//

import UIKit
import CropViewController
import SDWebImage

class EditBusinessProfileViewController: UIViewController {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var coverPhoto: SDAnimatedImageView!
    @IBOutlet weak var profilePic: SDAnimatedImageView!
    @IBOutlet weak var businessType: UITextField!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIView!
    @IBOutlet weak var uploadBtn: UIButton!
    @IBOutlet weak var businessNameTF: UITextField!
    @IBOutlet weak var websiteURLTF: UITextField!
    @IBOutlet weak var descriptionTF: UITextView!
    
    let businessTypePicker = UIPickerView()
    var delegate: ReloadTableViewDelegate?
    var businessModel: BusinessModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let businessModel = businessModel else {
            dismiss(animated: true)
            return
        }
        
        setupUI()
        populateBusinessData(businessModel)
    }
    
    private func setupUI() {
        setupBackView()
        setupDescriptionTextView()
        setupButtons()
        setupBusinessTypePicker()
        setupImageViews()
    }
    
    private func setupBackView() {
        backView.dropShadow()
        backView.layer.cornerRadius = 8
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
    }
    
    private func setupDescriptionTextView() {
        descriptionTF.layer.cornerRadius = 8
        descriptionTF.layer.borderWidth = 1
        descriptionTF.layer.borderColor = UIColor(red: 221 / 255, green: 221 / 255, blue: 221 / 255, alpha: 1).cgColor
        descriptionTF.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    private func setupButtons() {
        addBtn.layer.cornerRadius = 8
        uploadBtn.layer.cornerRadius = 8
        deleteBtn.layer.cornerRadius = 8
        deleteBtn.dropShadow()
        deleteBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deleteBtnClicked)))
    }
    
    private func setupBusinessTypePicker() {
        businessType.delegate = self
        businessTypePicker.delegate = self
        businessTypePicker.dataSource = self
        
        let selectCategoryBar = UIToolbar()
        selectCategoryBar.setupToolBar(with: self, doneAction: #selector(businessTypePickerDoneClicked), cancelAction: #selector(businessTypePickerCancelClicked))
        
        businessType.inputAccessoryView = selectCategoryBar
        businessType.inputView = businessTypePicker
    }
    
    private func setupImageViews() {
        profilePic.layer.cornerRadius = 8
        coverPhoto.isUserInteractionEnabled = true
        coverPhoto.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(coverPhotoUpload)))
    }
    
    private func populateBusinessData(_ businessModel: BusinessModel) {
        profilePic.setImage(imageKey: businessModel.profilePicture, placeholder: "profile-placeholder", width: 400, height: 400)
        coverPhoto.setImage(imageKey: businessModel.coverPicture, placeholder: "cover-placeholder", width: 800, height: 500)
        businessNameTF.text = businessModel.name
        websiteURLTF.text = businessModel.website
        businessType.text = businessModel.businessCategory
        descriptionTF.text = businessModel.aboutBusiness
    }
    
    @objc private func deleteBtnClicked() {
        let alert = UIAlertController(title: "Delete".localized(), message: "Are you sure you want to delete this business?".localized(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete".localized(), style: .destructive) { _ in
            self.ProgressHUDShow(text: "Deleting...".localized())
            self.deleteBusiness(bId: self.businessModel!.businessId ?? "123") { error in
                self.ProgressHUDHide()
                self.showSnack(messages: "Business Deleted".localized())
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    self.delegate?.reloadTableView()
                    self.dismiss(animated: true)
                }
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        present(alert, animated: true)
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
        showImageUploadOptions(title: "Upload Business Cover", pickerTitle: "Cover Picture")
    }
    
    @objc private func backViewClicked() {
        dismiss(animated: true)
    }
    
    @IBAction private func addBtnClicked(_ sender: Any) {
        guard let sTitle = businessNameTF.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let sWebsite = websiteURLTF.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let sDescription = descriptionTF.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let sType = businessType.text, !sTitle.isEmpty, !sWebsite.isEmpty, !sDescription.isEmpty, !sType.isEmpty else {
            showSnack(messages: "All fields are required")
            return
        }
        
        businessModel?.name = sTitle
        businessModel?.website = sWebsite
        businessModel?.aboutBusiness = sDescription
        businessModel?.businessCategory = Constants.businessTypes[businessTypePicker.selectedRow(inComponent: 0)]
        
        updateBusiness(businessModel: businessModel!)
    }
    
    private func updateBusiness(businessModel: BusinessModel) {
        ProgressHUDShow(text: "")
        try? FirebaseStoreManager.db.collection(Collections.businesses.rawValue).document(businessModel.businessId!).setData(from: businessModel, merge: true) { error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error.localizedDescription)
            } else {
                self.showSnack(messages: "Business Updated")
                self.delegate?.reloadTableView()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
    @IBAction private func uploadBtnClicked(_ sender: Any) {
        showImageUploadOptions(title: "Upload Business Picture", pickerTitle: "Profile Picture")
    }
    
    private func showImageUploadOptions(title: String, pickerTitle: String) {
        let alert = UIAlertController(title: title.localized(), message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Using Camera".localized(), style: .default) { _ in
            self.presentImagePicker(sourceType: .camera, title: pickerTitle)
        })
        alert.addAction(UIAlertAction(title: "From Photo Library".localized(), style: .default) { _ in
            self.presentImagePicker(sourceType: .photoLibrary, title: pickerTitle)
        })
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        present(alert, animated: true)
    }
    
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType, title: String) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        imagePicker.title = title
        present(imagePicker, animated: true)
    }
}

extension EditBusinessProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let editedImage = info[.originalImage] as? UIImage {
            dismiss(animated: true) {
                self.presentCropViewController(image: editedImage, title: picker.title)
            }
        }
        dismiss(animated: true)
    }
    
    private func presentCropViewController(image: UIImage, title: String?) {
        let cropViewController = CropViewController(image: image)
        cropViewController.title = title
        cropViewController.delegate = self
        
        if title == "Profile Picture" {
            cropViewController.customAspectRatio = CGSize(width: 1, height: 1)
        } else {
            cropViewController.customAspectRatio = CGSize(width: 414, height: 220)
        }
        
        cropViewController.aspectRatioLockEnabled = true
        cropViewController.aspectRatioPickerButtonHidden = true
        present(cropViewController, animated: true)
    }
    
    func cropViewController(_ cropView: CropViewController, didCropToImage image: UIImage, withRect _: CGRect, angle _: Int) {
        if cropView.title == "Profile Picture" {
            profilePic.image = image
            uploadBusinessImage(image: image, previousKey: businessModel?.profilePicture, folderName: "BusinessProfilePictures") { downloadURL in
                self.businessModel?.profilePicture = downloadURL
            }
        } else {
            coverPhoto.image = image
            uploadBusinessImage(image: image, previousKey: businessModel?.coverPicture, folderName: "BusinessCoverPictures") { downloadURL in
                self.businessModel?.coverPicture = downloadURL
            }
        }
        dismiss(animated: true)
    }
    
    private func uploadBusinessImage(image: UIImage, previousKey: String?, folderName: String, completion: @escaping (String) -> Void) {
        uploadFilesOnAWS(photo: image, previousKey: previousKey, folderName: folderName, postType: .image) { downloadURL in
            completion(downloadURL ?? "")
        }
    }
}

extension EditBusinessProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

extension EditBusinessProfileViewController: UIPickerViewDelegate, UIPickerViewDataSource {
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

extension UIToolbar {
    func setupToolBar(with target: Any, doneAction: Selector, cancelAction: Selector) {
        self.barStyle = .default
        self.isTranslucent = true
        self.tintColor = .link
        self.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done".localized(), style: .plain, target: target, action: doneAction)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel".localized(), style: .plain, target: target, action: cancelAction)
        self.setItems([cancelButton, spaceButton, doneButton], animated: false)
        self.isUserInteractionEnabled = true
    }
}


