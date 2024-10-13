//
//  AddProductViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 15/04/24.
//

import Amplify
import ATGMediaBrowser
import AVKit
import Combine
import CropViewController
import MobileCoreServices
import UIKit
import BSImagePicker
import Photos

class AddProductViewController: UIViewController {
    @IBOutlet weak var imgStack1: UIStackView!
    @IBOutlet weak var imgStack2: UIStackView!
    @IBOutlet weak var imgStack3: UIStackView!
    @IBOutlet weak var imgStack4: UIStackView!
    @IBOutlet weak var imgView1: UIView!
    @IBOutlet weak var imgView2: UIView!
    @IBOutlet weak var imgView3: UIView!
    @IBOutlet weak var imgView4: UIView!
    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var img3: UIImageView!
    @IBOutlet weak var img4: UIImageView!
    @IBOutlet weak var addImageBtn: UIButton!
    
    var downloadURL1 : String?
    var downloadURL2 : String?
    var downloadURL3 : String?
    var downloadURL4 : String?
    
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var selectCategoryTV: UITextField!
    @IBOutlet weak var titleTV: UITextField!
    @IBOutlet weak var priceTV: UITextField!
    @IBOutlet weak var productDescriptionTV: UITextView!
    @IBOutlet weak var postBtn: UIButton!
    
    var photoArray = [UIImage]()
    let categoryPicker = UIPickerView()
    var photoURL = [String]()
    var images: [UIImage]?
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupCategoryPicker()
        setupGestures()
        registerKeyboardNotifications()
    }
    private func setupGestures() {
     
        imgView1.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageView1Clicked)))
        imgView2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageView2Clicked)))
        imgView3.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageView3Clicked)))
        imgView4.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageView4Clicked)))
        img1.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageView1Clicked)))
        img2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageView2Clicked)))
        img3.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageView3Clicked)))
        img4.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageView4Clicked)))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    @objc func imageView1Clicked() {
        chooseImageFromPhotoLibrary(title: "Image 1")
    }
    
    @objc func imageView2Clicked() {
        chooseImageFromPhotoLibrary(title: "Image 2")
    }
    
    @objc func imageView3Clicked() {
        chooseImageFromPhotoLibrary(title: "Image 3")
    }
    
    @objc func imageView4Clicked() {
        chooseImageFromPhotoLibrary(title: "Image 4")
    }
    
    private func chooseImageFromPhotoLibrary(title: String) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.title = title
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true)
    }
    
    @IBAction func addMoreImageBtnClicked(_ sender: Any) {
        if imgStack2.isHidden {
            imgStack2.isHidden = false
        } else if imgStack3.isHidden {
            imgStack3.isHidden = false
        } else if imgStack4.isHidden {
            imgStack4.isHidden = false
            addImageBtn.isHidden = true
        }
    }
    private func setupViews() {
        
        productDescriptionTV.layer.cornerRadius = 8
        productDescriptionTV.layer.borderWidth = 1
        productDescriptionTV.layer.borderColor = UIColor(red: 221 / 255, green: 221 / 255, blue: 221 / 255, alpha: 1).cgColor
        productDescriptionTV.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        productDescriptionTV.text = "Write a product description".localized()
        productDescriptionTV.textColor = .lightGray
        productDescriptionTV.delegate = self
        
        postBtn.layer.cornerRadius = 8
        
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        
        
        imgStack1.dropShadow()
        imgStack2.dropShadow()
        imgStack3.dropShadow()
        imgStack4.dropShadow()
        imgView1.layer.cornerRadius = 8
        imgView2.layer.cornerRadius = 8
        imgView3.layer.cornerRadius = 8
        imgView4.layer.cornerRadius = 8
        img1.layer.cornerRadius = 8
        img2.layer.cornerRadius = 8
        img3.layer.cornerRadius = 8
        img4.layer.cornerRadius = 8
        addImageBtn.layer.cornerRadius = 8
        addImageBtn.layer.borderWidth = 1
        addImageBtn.layer.borderColor = UIColor(red: 67/255, green: 67/255, blue: 67/255, alpha: 1).cgColor
      
        
       
    }
    
    private func setupCategoryPicker() {
        selectCategoryTV.delegate = self
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        
        let selectCategoryBar = UIToolbar()
        selectCategoryBar.barStyle = .default
        selectCategoryBar.isTranslucent = true
        selectCategoryBar.tintColor = .link
        selectCategoryBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done".localized(), style: .plain, target: self, action: #selector(categoryPickerDoneClicked))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel".localized(), style: .plain, target: self, action: #selector(categoryPickerCancelClicked))
        selectCategoryBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        selectCategoryBar.isUserInteractionEnabled = true
        selectCategoryTV.inputAccessoryView = selectCategoryBar
        selectCategoryTV.inputView = categoryPicker
    }
    

    
   
    
    @objc func categoryPickerDoneClicked() {
        selectCategoryTV.resignFirstResponder()
        let row = categoryPicker.selectedRow(inComponent: 0)
        selectCategoryTV.text = Constants.productCategories[row]
    }
    
    @objc func categoryPickerCancelClicked() {
        view.endEditing(true)
    }
    
    @IBAction func addProductClicked(_ sender: Any) {
             let title = titleTV.text
              let category = selectCategoryTV.text
              let price = priceTV.text
              let description = productDescriptionTV.text
           
        
        
        guard let  downloadURL = self.downloadURL1,  !downloadURL.isEmpty else {
            self.showSnack(messages: "Upload Product Image".localized())
            return
        }
        
        if title == "" {
            self.showSnack(messages: "Enter Title".localized())
            return
        }
        else if category == "" {
            self.showSnack(messages: "Select Category".localized())
            return
        }
        else if price == "" {
            self.showSnack(messages: "Enter Price".localized())
            return
        }
        else if description == "" {
            self.showSnack(messages: "Enter Description".localized())
            return
        }
        
        
        let marketModel = MarketplaceModel()
        let id = FirebaseStoreManager.db.collection(Collections.marketplace.rawValue).document().documentID
        marketModel.id = id
        marketModel.title = title
        marketModel.cost = price
        marketModel.about = description
        marketModel.categoryName = category
        marketModel.uid = FirebaseStoreManager.auth.currentUser!.uid
        marketModel.dateCreated = Date()
        marketModel.isActive = true
        marketModel.countryCode = getCountryCode()
        marketModel.productImages = Array()
        marketModel.productImages!.append(downloadURL)
        
        
        if let downloadURL2 = downloadURL2, !downloadURL2.isEmpty {
            marketModel.productImages!.append(downloadURL2)
        }
        if let downloadURL3 = downloadURL3, !downloadURL3.isEmpty {
            marketModel.productImages!.append(downloadURL3)
        }
        if let downloadURL4 = downloadURL4, !downloadURL4.isEmpty {
            marketModel.productImages!.append(downloadURL4)
        }
        
        self.ProgressHUDShow(text: "")
        createDeepLinkForProduct(productModel: marketModel) { url, error in
            if let url = url {
                marketModel.productUrl = url
            }
            self.productAdd(productModel: marketModel)
        }
        
    }
    
    
    private func productAdd(productModel: MarketplaceModel) {
     
        addProduct(marketModel: productModel) { error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error)
            } else {
                self.showSnack(messages: "Product Added".localized())
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                  
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc func backBtnClicked() {
        dismiss(animated: true)
    }
    
   
}

// MARK: UITextViewDelegate
extension AddProductViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Write a product description".localized()
            textView.textColor = .lightGray
        }
    }
}


extension AddProductViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let editedImage = info[.originalImage] as? UIImage {
            self.dismiss(animated: true) {
                let cropViewController = CropViewController(image: editedImage)
                cropViewController.title = picker.title
                cropViewController.delegate = self
                cropViewController.customAspectRatio = CGSize(width: 9, height: 5)
                cropViewController.aspectRatioLockEnabled = true
                cropViewController.aspectRatioPickerButtonHidden = true
                self.present(cropViewController, animated: true, completion: nil)
            }
        }
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.ProgressHUDShow(text: "Uploading...".localized())
        let title = cropViewController.title!
        
        if title == "Image 1" {
            setImage(image: image, imageView: img1, imgView: imgView1, imageNo: 1)
        } else if title == "Image 2" {
            setImage(image: image, imageView: img2, imgView: imgView2, imageNo: 2)
        } else if title == "Image 3" {
            setImage(image: image, imageView: img3, imgView: imgView3, imageNo: 3)
        } else if title == "Image 4" {
            setImage(image: image, imageView: img4, imgView: imgView4, imageNo: 4)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setImage(image: UIImage, imageView: UIImageView, imgView: UIView, imageNo: Int) {
        imageView.image = image
        imageView.isHidden = false
        imgView.isHidden = true
        
        uploadImageOnFirebase(imageNo: imageNo) { downloadURL in
            self.ProgressHUDHide()
       
            if imageNo == 1 {
               
                self.downloadURL1 = downloadURL
            } else if imageNo == 2 {
                self.downloadURL2 = downloadURL
            } else if imageNo == 3 {
                self.downloadURL3 = downloadURL
            } else if imageNo == 4 {
                self.downloadURL4 = downloadURL
            }
        }
    }
    
    private func uploadImageOnFirebase(imageNo: Int, completion: @escaping (String) -> Void) {
        let image: UIImage
        switch imageNo {
        case 1:
            image = self.img1.image!
        case 2:
            image = self.img2.image!
        case 3:
            image = self.img3.image!
        case 4:
            image = self.img4.image!
        default:
            return
        }
        
        uploadFilesOnAWS(photo: image, folderName: "ProductImages", postType: .image) { downloadURL in
            completion(downloadURL ?? "")
        }
    }
}

// MARK: Keyboard Notifications
extension AddProductViewController {
    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrameValue = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue else { return }
        let keyboardFrame = view.convert(keyboardFrameValue.cgRectValue, from: nil)
        scrollView.contentOffset = CGPoint(x: 0, y: keyboardFrame.size.height)
    }
    
    @objc func keyboardWillHide(_: Notification) {
        scrollView.contentOffset = .zero
    }
}

// MARK: UITextFieldDelegate
extension AddProductViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

// MARK: UIPickerViewDelegate & UIPickerViewDataSource
extension AddProductViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Constants.productCategories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Constants.productCategories[row]
    }
}
