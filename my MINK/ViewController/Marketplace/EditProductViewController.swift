//
//  EditProductViewController.swift
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

class EditProductViewController: UIViewController {
    
    @IBOutlet weak var deleteBtn: UIView!
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var imageView1: UIView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var imageView2: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView3: UIView!
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var image4: UIImageView!
    @IBOutlet weak var imageView4: UIView!
    @IBOutlet weak var selectCategoryTV: UITextField!
    @IBOutlet weak var titleTV: UITextField!
    @IBOutlet weak var priceTV: UITextField!
    @IBOutlet weak var productDescriptionTV: UITextView!
    @IBOutlet weak var postBtn: UIButton!
    
    var photoArray = [UIImage]()
    let categoryPicker = UIPickerView()
    var photoURL = [String]()
    var images = [UIImage]()

    var product: MarketplaceModel?
    var position: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupCategoryPicker()
        populateProductDetails()
        setupGestures()
        registerKeyboardNotifications()
    }
    
    private func setupViews() {
        [image1, image2, image3, image4].forEach { $0?.layer.cornerRadius = 8 }
        [imageView1, imageView2, imageView3, imageView4].forEach { $0?.isHidden = true }
        
        productDescriptionTV.layer.cornerRadius = 8
        productDescriptionTV.layer.borderWidth = 1
        productDescriptionTV.layer.borderColor = UIColor(red: 221 / 255, green: 221 / 255, blue: 221 / 255, alpha: 1).cgColor
        productDescriptionTV.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        productDescriptionTV.textColor = .lightGray
        
        postBtn.layer.cornerRadius = 8
        
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        
        deleteBtn.layer.cornerRadius = 8
        deleteBtn.dropShadow()
        deleteBtn.isUserInteractionEnabled = true
        deleteBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deleteBtnClicked)))
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
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
    
    private func populateProductDetails() {
        guard let product = product else {
            dismiss(animated: true)
            return
        }
        
        if let productImages = product.productImages {
            for (index, image) in productImages.enumerated() {
                switch index {
                case 0:
                    imageView1.isHidden = false
                    image1.setImage(imageKey: image, placeholder: "placeholder", width: 500, height: 500, shouldShowAnimationPlaceholder: true)
                    images.append(image1.image!)
                case 1:
                    imageView2.isHidden = false
                    image2.setImage(imageKey: image, placeholder: "placeholder", width: 500, height: 500, shouldShowAnimationPlaceholder: true)
                    images.append(image2.image!)
                case 2:
                    imageView3.isHidden = false
                    image3.setImage(imageKey: image, placeholder: "placeholder", width: 500, height: 500, shouldShowAnimationPlaceholder: true)
                    images.append(image3.image!)
                case 3:
                    imageView4.isHidden = false
                    image4.setImage(imageKey: image, placeholder: "placeholder", width: 500, height: 500, shouldShowAnimationPlaceholder: true)
                    images.append(image4.image!)
                default:
                    break
                }
            }
        }
        
        selectCategoryTV.text = product.categoryName
        titleTV.text = product.title
        priceTV.text = product.cost
        productDescriptionTV.text = product.about
    }
    
    private func setupGestures() {
        let gestures = [
            MyGesture(target: self, action: #selector(postImageClicked)),
            MyGesture(target: self, action: #selector(postImageClicked)),
            MyGesture(target: self, action: #selector(postImageClicked)),
            MyGesture(target: self, action: #selector(postImageClicked))
        ]
        
        [image1, image2, image3, image4].enumerated().forEach { index, imageView in
            guard let imageView = imageView else { return }
            gestures[index].index = index
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(gestures[index])
        }
    }
    
    @objc func deleteBtnClicked() {
        let alert = UIAlertController(title: "Delete".localized(), message: "Are you sure you want to delete this product?".localized(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete".localized(), style: .destructive) { _ in
            self.ProgressHUDShow(text: "Deleting...".localized())
            self.deleteProduct(productId: self.product?.id ?? "123", images: self.product?.productImages ?? []) { error in
                self.ProgressHUDHide()
                if let error = error {
                    self.showError(error)
                } else {
                    self.showSnack(messages: "Product Deleted".localized())
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                       
                        self.dismiss(animated: true)
                    }
                }
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        present(alert, animated: true)
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
        guard let title = titleTV.text, !title.isEmpty,
              let category = selectCategoryTV.text, !category.isEmpty,
              let price = priceTV.text, !price.isEmpty,
              let description = productDescriptionTV.text, !description.isEmpty else {
            showSnack(messages: "All fields are required".localized())
            return
        }
        
        product?.title = title
        product?.cost = price
        product?.about = description
        product?.categoryName = category
        
        uploadImages(for: product!)
    }
    
    private func uploadImages(for product: MarketplaceModel) {
        photoURL.removeAll()
        let fetchGroup = DispatchGroup()
        
        let loading = DownloadProgressHUDShow(text: "Image 1 Uploading...".localized())
        for (index, photo) in images.enumerated() {
            fetchGroup.enter()
            uploadFilesOnAWS(photo: photo, folderName: "ProductImages", postType: .image, shouldHideProgress: true) { downloadURL in
                if let downloadURL = downloadURL {
                    self.photoURL.append(downloadURL)
                    self.DownloadProgressHUDUpdate(loading: loading, text: String(format: "Image %d Uploading...".localized(), index + 2))

                    loading.label.layoutIfNeeded()
                }
                fetchGroup.leave()
            }
        }
        
        fetchGroup.notify(queue: .main) {
            self.DownloadProgressHUDUpdate(loading: loading, text: "")
            loading.label.layoutIfNeeded()
            self.photoURL.sort(by: <)
            Constants.imageIndex = 0
            product.productImages = self.photoURL
            self.productAdd(productModel: product)
        }
    }
    
    private func productAdd(productModel: MarketplaceModel) {
        addProduct(marketModel: productModel) { error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error)
            } else {
                self.showSnack(messages: "Product Updated".localized())
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
    
    @objc func postImageClicked(value: MyGesture) {
        let mediaBrowser = MediaBrowserViewController(index: value.index, dataSource: self)
        present(mediaBrowser, animated: true, completion: nil)
    }
}

// MARK: - MediaBrowserViewControllerDataSource
extension EditProductViewController: MediaBrowserViewControllerDataSource {
    func mediaBrowser(_: ATGMediaBrowser.MediaBrowserViewController, imageAt index: Int, completion: @escaping CompletionBlock) {
        let images = [image1, image2, image3, image4]
        guard let imageView = images[index] else { return }
        completion(index, imageView.image!, .default, nil)
    }
    
    func numberOfItems(in _: MediaBrowserViewController) -> Int {
        images.count
    }
}

// MARK: - Keyboard Notifications
extension EditProductViewController {
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

// MARK: - UITextFieldDelegate
extension EditProductViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

// MARK: - UIPickerViewDelegate & UIPickerViewDataSource
extension EditProductViewController: UIPickerViewDelegate, UIPickerViewDataSource {
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
