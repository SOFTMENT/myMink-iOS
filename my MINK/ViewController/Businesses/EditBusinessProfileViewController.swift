//
//  EditBusinessProfileViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 06/06/24.
//


import UIKit
import CropViewController
import SDWebImage

class EditBusinessProfileViewController : UIViewController {
    
    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var coverPhoto: SDAnimatedImageView!
    @IBOutlet weak var profilePic: SDAnimatedImageView!
    
    
    @IBOutlet weak var businessType: UITextField!
    @IBOutlet weak var addBtn: UIButton!
  
   
  
    @IBOutlet weak var uploadBtn: UIButton!
    @IBOutlet weak var businessNameTF: UITextField!
    @IBOutlet weak var websiteURLTF: UITextField!
    @IBOutlet weak var descriptionTF: UITextView!
    let businessTypePicker = UIPickerView()
    var delegate : ReloadTableViewDelegate?
    
    var businessModel : BusinessModel?
    
    override func viewDidLoad() {
        
        guard let businessModel = businessModel else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        if let sProfilepicture = businessModel.profilePicture, !sProfilepicture.isEmpty {
            profilePic.setImage(imageKey: sProfilepicture, placeholder: "profile-placeholder",width: 400, height: 400,shouldShowAnimationPlaceholder: true)
        }
        
        
        if let sCoverpicture = businessModel.coverPicture, !sCoverpicture.isEmpty {
            coverPhoto.setImage(imageKey: sCoverpicture, placeholder: "cover-placeholder",width: 800, height: 500,shouldShowAnimationPlaceholder: true)
        }
        
        
        businessNameTF.text = businessModel.name ?? ""
        websiteURLTF.text = businessModel.website ?? ""
        businessType.text = businessModel.businessCategory ?? ""
        descriptionTF.text = businessModel.aboutBusiness ?? ""
        
        backView.isUserInteractionEnabled = true
        backView.dropShadow()
        backView.layer.cornerRadius = 8
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewCliced)))
        
        self.descriptionTF.layer.cornerRadius = 8
        self.descriptionTF.layer.borderWidth = 1
        self.descriptionTF.layer.borderColor = UIColor(red: 221 / 255, green: 221 / 255, blue: 221 / 255, alpha: 1)
            .cgColor
        self.descriptionTF.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        uploadBtn.layer.cornerRadius = 8
        addBtn.layer.cornerRadius = 8
        
        self.profilePic.layer.cornerRadius = 8
        
        businessType.delegate = self
        businessTypePicker.delegate = self
        businessTypePicker.dataSource = self
        
        businessNameTF.delegate = self
        websiteURLTF.delegate = self
        
        coverPhoto.isUserInteractionEnabled = true
        coverPhoto.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(coverPhotoUpload)))
        
        // ToolBar
        let selectCategoryBar = UIToolbar()
        selectCategoryBar.barStyle = .default
        selectCategoryBar.isTranslucent = true
        selectCategoryBar.tintColor = .link
        selectCategoryBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(businessTypePickerDoneClicked))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(businessTypePickerCancelClicked))
        selectCategoryBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        selectCategoryBar.isUserInteractionEnabled = true
        businessType.inputAccessoryView = selectCategoryBar
        businessType.inputView = businessTypePicker
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClicked)))
    }
    
    @objc func businessTypePickerDoneClicked(){
       businessType.resignFirstResponder()
        let row = businessTypePicker.selectedRow(inComponent: 0)
        businessType.text = Constants.BUSINESS_TYPE[row]
    
    }
    
    @objc func businessTypePickerCancelClicked(){
        self.view.endEditing(true)
    }
    
    @objc func viewClicked(){
        self.view.endEditing(true)
    }
    
    @objc func coverPhotoUpload(){
        let alert = UIAlertController(title: "Upload Business Cover", message: "", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Using Camera", style: .default) { _ in

            let image = UIImagePickerController()
            image.title = "Cover Picture"
            image.delegate = self
            image.sourceType = .camera
            self.present(image, animated: true)
        }

        let action2 = UIAlertAction(title: "From Photo Library", style: .default) { _ in

            let image = UIImagePickerController()
            image.delegate = self
            image.title = "Cover Picture"
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
    
    @objc func backViewCliced() {
        self.dismiss(animated: true)
    }
    
    @IBAction func addBtnClicked(_ sender: Any) {
        let sTitle = businessNameTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let sWebsite = websiteURLTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let sDescription = descriptionTF.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let sType = businessType.text
        
        if sTitle == "" {
            self.showSnack(messages: "Enter Business Name")
            return
        }
        if sWebsite == "" {
            self.showSnack(messages: "Enter Website")
            return
        }
        if sType == "" {
            self.showSnack(messages: "Select Business Type")
            return
        }
        if sDescription == "" {
            self.showSnack(messages: "Enter Description")
            return
        }
        
       
        self.businessModel!.name = sTitle
        self.businessModel!.website = sWebsite
        self.businessModel!.aboutBusiness = sDescription
        self.businessModel!.businessCategory = Constants.BUSINESS_TYPE[businessTypePicker.selectedRow(inComponent: 0)]
       
        self.updateBusiness(businessModel: self.businessModel!)
    }
    
    func updateBusiness(businessModel : BusinessModel) {
        self.ProgressHUDShow(text: "")
        try? FirebaseStoreManager.db.collection("Businesses").document(businessModel.businessId!).setData(from: businessModel,merge: true, completion: { error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error.localizedDescription)
            }
            else {
                self.showSnack(messages: "Business Updated")
                self.delegate?.reloadTableView()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.dismiss(animated: true)
                }
            }
        })
        
    }
    
    @IBAction func uplaodBtnClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Upload Business Picture", message: "", preferredStyle: .alert)
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


extension EditBusinessProfileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate,
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
                    if picker.title == "Profile Picture" {
                       
                       
                        cropViewController.customAspectRatio = CGSize(width: 1, height: 1)
                        cropViewController.aspectRatioLockEnabled = true
                        cropViewController.aspectRatioPickerButtonHidden = true
                        self.present(cropViewController, animated: true, completion: nil)
                    }
                    else {
                       
                        cropViewController.customAspectRatio = CGSize(width: 414, height: 220)
                        cropViewController.aspectRatioLockEnabled = true
                        cropViewController.aspectRatioPickerButtonHidden = true
                        self.present(cropViewController, animated: true, completion: nil)
                    }
            }
        }
       
        

        dismiss(animated: true, completion: nil)
    }

    func cropViewController(_ cropView : CropViewController, didCropToImage image: UIImage, withRect _: CGRect, angle _: Int) {
        
        if cropView.title == "Profile Picture" {
            self.profilePic.image = image
            uploadFilesOnAWS(
                photo: self.profilePic.image!,
                previousKey: self.businessModel!.profilePicture,
                folderName: "BusinessProfilePictures",
                postType: .IMAGE
            ) { downloadURL in
                self.businessModel!.profilePicture = downloadURL
               
            }
           
        }
        else {
            self.coverPhoto.image =  image
            uploadFilesOnAWS(
                photo: self.coverPhoto.image!,
                previousKey: self.businessModel!.coverPicture,
                folderName: "BusinessCoverPictures",
                postType: .IMAGE
            ) { downloadURL in
                self.businessModel!.coverPicture = downloadURL
             
            }
           
        }
     
        dismiss(animated: true, completion: nil)
    }
}
extension EditBusinessProfileViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}




extension EditBusinessProfileViewController : UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Constants.BUSINESS_TYPE.count

    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        
        return Constants.BUSINESS_TYPE[row]
        

    }

}
