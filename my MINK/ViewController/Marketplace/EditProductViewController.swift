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

// MARK: - CreatePostViewController

class EditProductViewController : UIViewController {
    
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
    var photoArray = [UIImage]()
    let categoryPicker = UIPickerView()
    @IBOutlet weak var productDescriptionTV: UITextView!
    
    var photoURL = [String]()
    var images = [UIImage]()
    var delegate : ProductDelegate?
    @IBOutlet weak var postBtn: UIButton!
    var product : MarketplaceModel?
    var position : Int?

    override func viewDidLoad() {
       
        guard let product = product else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }

        if let images = product.productImages {
            var i = 0
            for image in images {
                if i == 0 {
                    self.imageView1.isHidden = false
                    self.image1.setImage(imageKey: image, placeholder: "placeholder",width: 500,height: 500,shouldShowAnimationPlaceholder: true)
                    self.images.append(image1.image!)
                }
                else if i == 1 {
                    self.imageView2.isHidden = false
                    self.image2.setImage(imageKey: image, placeholder: "placeholder",width: 500,height: 500,shouldShowAnimationPlaceholder: true)
                    self.images.append(image2.image!)
                }
                else if i == 2 {
                    self.imageView3.isHidden = false
                    self.image3.setImage(imageKey: image, placeholder: "placeholder",width: 500,height: 500,shouldShowAnimationPlaceholder: true)
                    self.images.append(image3.image!)
                }
                else if i == 3 {
                    self.imageView4.isHidden = false
                    self.image4.setImage(imageKey: image, placeholder: "placeholder",width: 500,height: 500,shouldShowAnimationPlaceholder: true)
                    self.images.append(image4.image!)
                }
                i = i + 1
            }
        }
        
        selectCategoryTV.text = product.categoryName
        titleTV.text = product.title
        priceTV.text = product.cost
        productDescriptionTV.text = product.about

        selectCategoryTV.delegate = self
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        
        
        // ToolBar
        let selectCategoryBar = UIToolbar()
        selectCategoryBar.barStyle = .default
        selectCategoryBar.isTranslucent = true
        selectCategoryBar.tintColor = .link
        selectCategoryBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(categoryPickerDoneClicked))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(categoryPickerCancelClicked))
        selectCategoryBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        selectCategoryBar.isUserInteractionEnabled = true
        selectCategoryTV.inputAccessoryView = selectCategoryBar
        selectCategoryTV.inputView = categoryPicker
        
        self.productDescriptionTV.layer.cornerRadius = 8
        self.productDescriptionTV.layer.borderWidth = 1
        self.productDescriptionTV.layer.borderColor = UIColor(red: 221 / 255, green: 221 / 255, blue: 221 / 255, alpha: 1).cgColor
        self.productDescriptionTV.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
       
        self.productDescriptionTV.textColor = UIColor.lightGray
       

        self.image1.layer.cornerRadius = 8
        self.image2.layer.cornerRadius = 8
        self.image3.layer.cornerRadius = 8
        self.image4.layer.cornerRadius = 8

        let myGest1 = MyGesture(target: self, action: #selector(self.postImageClicked))
        self.image1.isUserInteractionEnabled = true
        myGest1.index = 0
        self.image1.addGestureRecognizer(myGest1)

        let myGest2 = MyGesture(target: self, action: #selector(self.postImageClicked))
        self.image2.isUserInteractionEnabled = true
        myGest2.index = 1
        self.image2.addGestureRecognizer(myGest2)

        let myGest3 = MyGesture(target: self, action: #selector(self.postImageClicked))
        self.image3.isUserInteractionEnabled = true
        myGest3.index = 2
        self.image3.addGestureRecognizer(myGest3)

        let myGest4 = MyGesture(target: self, action: #selector(self.postImageClicked))
        self.image4.isUserInteractionEnabled = true
        myGest4.index = 3
        self.image4.addGestureRecognizer(myGest4)

       

        self.postBtn.layer.cornerRadius = 8

       
        self.backView.layer.cornerRadius = 8
        self.backView.dropShadow()
        self.backView.isUserInteractionEnabled = true
        self.backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backBtnClicked)))

        self.deleteBtn.layer.cornerRadius = 8
        self.deleteBtn.dropShadow()
        self.deleteBtn.isUserInteractionEnabled = true
        self.deleteBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deleteBtnClicked)))
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard)))
    }

    @objc func deleteBtnClicked(){
        let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this product?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            self.ProgressHUDShow(text: "Deleting...")
            
            self.deleteProduct(productId: self.product!.id ?? "123", images: self.product!.productImages ?? []) { error in
                self.ProgressHUDHide()
                if let error = error {
                    self.showError(error)
                }
                else {
                    self.showSnack(messages: "Product Deleted")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        self.delegate?.removeProduct(productModel: self.product!)
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
                    
    }
    
    @objc func categoryPickerDoneClicked(){
        selectCategoryTV.resignFirstResponder()
        let row = categoryPicker.selectedRow(inComponent: 0)
        selectCategoryTV.text = Constants.product_categories[row]
    
    }
    
    @objc func categoryPickerCancelClicked(){
        self.view.endEditing(true)
    }




   

    @IBAction func addProductClicked(_ sender: Any) {
        
        let sTitle = self.titleTV.text
        let sCategory = self.selectCategoryTV.text
        let sPrice = self.priceTV.text
        let sProductDescription = self.productDescriptionTV.text
        
        if sCategory == "" {
            self.showSnack(messages: "Select Category")
        }
        else if sTitle == "" {
            self.showSnack(messages: "Enter Title")
        }
        else if sPrice == "" {
            self.showSnack(messages: "Enter Price")
        }
        else if sProductDescription == "" {
            self.showSnack(messages: "Enter Product Description")
        }
        else {
         
           
          
            self.product!.title = sTitle
            self.product!.cost = sPrice
            self.product!.about = sProductDescription
            self.product!.categoryName = sCategory
 
                self.photoURL.removeAll()
                let fetchGroup = DispatchGroup()

                var i = 1
                let loading = DownloadProgressHUDShow(text: "Image 1 Uploading...")
                for photo in self.images {
                    fetchGroup.enter()
                    uploadFilesOnAWS(
                        photo: photo,
                      
                        folderName: "ProductImages",
                        postType: .IMAGE,
                        shouldHideProgress: true
                    ) { downloadURL in
                        if let downloadURL = downloadURL {
                            self.photoURL.append(downloadURL)
                            i = i + 1
                            self.DownloadProgressHUDUpdate(loading: loading, text: "Image \(i) Uploading...")
                            loading.label.layoutIfNeeded()
                        }

                        fetchGroup.leave()
                    }
                }

                fetchGroup.notify(queue: DispatchQueue.main) {
                    self.DownloadProgressHUDUpdate(loading: loading, text: "")
                    loading.label.layoutIfNeeded()
                    self.photoURL.sort { url1, url2 in
                        if url1.split(separator: "/").last! < url2.split(separator: "/").last! {
                            return true
                        }
                        return false
                    }
                    Constants.imageIndex = 0
                    self.product!.productImages = self.photoURL

                    self.productAdd(productModel: self.product!)
                    
                }
        }

    }

    func productAdd(productModel : MarketplaceModel) {
      
        self.addProduct(marketModel: productModel) { error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error)
            } else {
                self.showSnack(messages: "Product Updated")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    self.delegate?.updateProduct(productModel: productModel, position: self.position!)
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


// MARK: MediaBrowserViewControllerDataSource

extension EditProductViewController : MediaBrowserViewControllerDataSource {
    func mediaBrowser(
        _: ATGMediaBrowser.MediaBrowserViewController,
        imageAt index: Int,
        completion: @escaping CompletionBlock
    ) {
        if index == 0 {
            completion(index, self.image1.image!, ZoomScale.default, nil)
        } else if index == 1 {
            completion(index, self.image2.image!, ZoomScale.default, nil)
        } else if index == 2 {
            completion(index, self.image3.image!, ZoomScale.default, nil)
        } else {
            completion(index, self.image4.image!, ZoomScale.default, nil)
        }
    }

    func numberOfItems(in _: ATGMediaBrowser.MediaBrowserViewController) -> Int {
        self.images.count
    }
}



extension EditProductViewController {
    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillShow(_:)),
            name: UIControl.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillHide(_:)),
            name: UIControl.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrameValue = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue
        else {
            return
        }
        let keyboardFrame = view.convert(keyboardFrameValue.cgRectValue, from: nil)
        self.scrollView.contentOffset = CGPoint(x: 0, y: keyboardFrame.size.height)
    }

    @objc func keyboardWillHide(_: Notification) {
        self.scrollView.contentOffset = .zero
    }
}

// MARK: UITextFieldDelegate

extension EditProductViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}




extension EditProductViewController : UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Constants.product_categories.count

    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        
        return Constants.product_categories[row]
        

    }

}
