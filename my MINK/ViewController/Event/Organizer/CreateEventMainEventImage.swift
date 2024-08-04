//
//  CreateEventMainEventImage.swift
//  my MINK
//
//  Created by Vijay Rathore on 19/05/24.
//

import UIKit
import CropViewController
import Firebase
import FirebaseFirestoreSwift
import FirebaseAuth
import IQKeyboardManagerSwift

class CreateEventMainEventImage: UIViewController {
    
    @IBOutlet weak var paid: UIButton!
    @IBOutlet weak var free: UIButton!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var nameCounter: UILabel!
    @IBOutlet weak var availableQuantity: UITextField!
    @IBOutlet weak var price: UITextField!
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
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var discard: UILabel!
    @IBOutlet weak var backView: UIView!
    
    var isFree = false
    var isImage1Selected = false
    var isImage2Selected = false
    var isImage3Selected = false
    var isImage4Selected = false
    var event: Event?
    var mUser: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if event == nil {
            self.dismiss(animated: true, completion: nil)
        }
        
        guard let user = Auth.auth().currentUser else {
            self.logoutPlease()
            return
        }
        mUser = user
        
        setupViews()
        setupDelegates()
        setupGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = true
    }
    
    @IBAction func paidBtnClicked(_ sender: Any) {
        setEventType(isFree: false)
    }
    
    @IBAction func freeBtnClicked(_ sender: Any) {
        setEventType(isFree: true)
    }
    
    @objc func backViewClicked() {
        self.dismiss(animated: true)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc func discardBtnClicked() {
        self.beRootScreen(storyBoardName: StoryBoard.event, mIdentifier: Identifier.organizerDashboardController)
    }
    
    @objc func imageView1Clicked() {
        chooseImageFromPhotoLibrary(title: "Event Image 1")
    }
    
    @objc func imageView2Clicked() {
        chooseImageFromPhotoLibrary(title: "Event Image 2")
    }
    
    @objc func imageView3Clicked() {
        chooseImageFromPhotoLibrary(title: "Event Image 3")
    }
    
    @objc func imageView4Clicked() {
        chooseImageFromPhotoLibrary(title: "Event Image 4")
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
    
    @IBAction func continueBtnClicked(_ sender: Any) {
        let sName = name.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let sQuantity = availableQuantity.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let sPrice = price.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let sDescription = eventDescription.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard validateInputs(sName: sName, sQuantity: sQuantity, sPrice: sPrice, sDescription: sDescription) else { return }
        
        event!.eventDescription = sDescription
        event!.isFree = isFree
        event!.ticketName = sName
        event!.ticketQuantity = Int(sQuantity) ?? 1
        event!.ticketPrice = isFree ? 0 : Int(sPrice) ?? 0
        event!.isActive = true
        event!.eventCreateDate = Date()
        
        
        saveEvent()
    }
    
    private func validateInputs(sName: String, sQuantity: String, sPrice: String, sDescription: String) -> Bool {
        if !isImage1Selected {
            showSnack(messages: "Select at least 1 event image")
            return false
        } else if sDescription.isEmpty {
            showSnack(messages: "Enter Description")
            return false
        } else if sName.isEmpty {
            showSnack(messages: "Enter Name")
            return false
        } else if sQuantity.isEmpty {
            showSnack(messages: "Enter Available Quantity")
            return false
        } else if !isFree && sPrice.isEmpty {
            showSnack(messages: "Enter Price")
            return false
        } else if Int(sQuantity) ?? 0 <= 0 {
            showSnack(messages: "Enter Quantity more than 0")
            return false
        } else if !isFree && Int(sPrice) ?? 0 <= 0 {
            showSnack(messages: "Enter price more than US$ 0")
            return false
        }
        return true
    }
    
    private func saveEvent() {
        ProgressHUDShow(text: "Publishing...")
        let batch = FirebaseStoreManager.db.batch()
        let documentRef = FirebaseStoreManager.db.collection(Collections.events.rawValue).document()
        event!.eventId = documentRef.documentID
        event!.eventOrganizerUid = Auth.auth().currentUser!.uid
        
        createDeepLinkForEvent(event: event!) { url, error in
            DispatchQueue.main.async {
                do {
                    
                    self.event!.eventURL = url
                    try batch.setData(from: self.event!, forDocument: documentRef)
                    batch.commit { error in
                        self.ProgressHUDHide()
                        if error == nil {
                            let alert = UIAlertController(title: "Published", message: "Congrats! Your event has been published", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
                                self.beRootScreen(storyBoardName: StoryBoard.event, mIdentifier: Identifier.organizerDashboardController)
                            }
                            alert.addAction(okAction)
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            self.showError(error!.localizedDescription)
                        }
                    }
                } catch {
                    self.ProgressHUDHide()
                    self.showError(error.localizedDescription)
                }
            }
        
        }
        
      
    }
    
    private func setupViews() {
        backView.layer.cornerRadius = 8
        backView.dropShadow()
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
        eventDescription.layer.borderColor = UIColor.lightGray.cgColor
        eventDescription.layer.borderWidth = 0.8
        eventDescription.layer.cornerRadius = 8
        continueBtn.layer.cornerRadius = 8
        paid.layer.cornerRadius = 8
        free.layer.cornerRadius = 8
        paid.layer.borderWidth = 1
        free.layer.borderWidth = 1
        discard.layer.cornerRadius = 8
        
        setEventType(isFree: false)
        
        eventDescription.text = "Summary*"
        eventDescription.textColor = .lightGray
    }
    
    private func setupDelegates() {
        eventDescription.delegate = self
        name.delegate = self
        availableQuantity.delegate = self
        price.delegate = self
    }
    
    private func setupGestures() {
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        imgView1.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageView1Clicked)))
        imgView2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageView2Clicked)))
        imgView3.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageView3Clicked)))
        imgView4.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageView4Clicked)))
        img1.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageView1Clicked)))
        img2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageView2Clicked)))
        img3.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageView3Clicked)))
        img4.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageView4Clicked)))
        discard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(discardBtnClicked)))
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    private func setEventType(isFree: Bool) {
        self.isFree = isFree
        if isFree {
            price.text = "Free"
            price.isEnabled = false
            setButtonStyle(button: free, isSelected: true)
            setButtonStyle(button: paid, isSelected: false)
        } else {
            price.text = ""
            price.isEnabled = true
            setButtonStyle(button: paid, isSelected: true)
            setButtonStyle(button: free, isSelected: false)
        }
    }
    
    private func setButtonStyle(button: UIButton, isSelected: Bool) {
        if isSelected {
            button.backgroundColor = UIColor(red: 210/255, green: 0/255, blue: 1/255, alpha: 0.1)
            button.setTitleColor(UIColor(red: 210/255, green: 0/255, blue: 1/255, alpha: 1), for: .normal)
            button.layer.borderColor = UIColor(red: 210/255, green: 0/255, blue: 1/255, alpha: 1).cgColor
        } else {
            button.backgroundColor = .clear
            button.setTitleColor(UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1), for: .normal)
            button.layer.borderColor = UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1).cgColor
        }
    }
    
    private func chooseImageFromPhotoLibrary(title: String) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.title = title
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true)
    }
}

extension CreateEventMainEventImage: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Summary*"
            textView.textColor = UIColor.lightGray
        }
    }
}

extension CreateEventMainEventImage: UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
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
        self.ProgressHUDShow(text: "Uploading...")
        let title = cropViewController.title!
        
        if title == "Event Image 1" {
            setImage(image: image, imageView: img1, imgView: imgView1, imageNo: 1)
        } else if title == "Event Image 2" {
            setImage(image: image, imageView: img2, imgView: imgView2, imageNo: 2)
        } else if title == "Event Image 3" {
            setImage(image: image, imageView: img3, imgView: imgView3, imageNo: 3)
        } else if title == "Event Image 4" {
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
                self.isImage1Selected = true
                self.event?.eventImage1 = downloadURL
            } else if imageNo == 2 {
                self.isImage2Selected = true
                self.event?.eventImage2 = downloadURL
            } else if imageNo == 3 {
                self.isImage3Selected = true
                self.event?.eventImage3 = downloadURL
            } else if imageNo == 4 {
                self.isImage4Selected = true
                self.event?.eventImage4 = downloadURL
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
        
        uploadFilesOnAWS(photo: image, folderName: "EventImages", postType: .image) { downloadURL in
            completion(downloadURL ?? "")
        }
    }
}

extension CreateEventMainEventImage: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == name {
            let maxLength = 50
            let currentString: NSString = (textField.text ?? "") as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            if newString.length <= maxLength {
                nameCounter.text = "\(newString.length) / \(maxLength)"
            }
            return newString.length <= maxLength
        }
        return true
    }
}
