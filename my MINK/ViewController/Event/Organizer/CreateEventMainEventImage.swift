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
    var event : Event?
    var isImage1Selected = false
    var isImage2Selected = false
    var isImage3Selected = false
    var isImage4Selected = false
    var mUser : User!
    @IBOutlet weak var discard: UILabel!
    @IBOutlet weak var backView: UIView!
    
    
    override func viewDidLoad() {
        
        
        
        if event == nil {
            self.dismiss(animated: true, completion: nil)
        }
        
        guard let user = Auth.auth().currentUser else {
            self.logoutPlease()
            return
        }
        mUser = user
        
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        
        imgStack1.isHidden = false
        imgStack2.isHidden = true
        imgStack3.isHidden = true
        imgStack4.isHidden = true
        
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
        
        img1.isHidden = true
        img2.isHidden = true
        img3.isHidden = true
        img4.isHidden = true
        
        addImageBtn.layer.cornerRadius = 8
        addImageBtn.layer.borderWidth = 1
        addImageBtn.layer.borderColor = UIColor(red: 67/255, green: 67/255, blue: 67/255, alpha: 1).cgColor
        
   
        imgView1.isUserInteractionEnabled = true
        imgView2.isUserInteractionEnabled = true
        imgView3.isUserInteractionEnabled = true
        imgView4.isUserInteractionEnabled = true
        
        imgView1.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageView1Clicked)))
        imgView2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageView2Clicked)))
        imgView3.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageView3Clicked)))
        imgView4.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageView4Clicked)))
        
        img1.isUserInteractionEnabled = true
        img2.isUserInteractionEnabled = true
        img3.isUserInteractionEnabled = true
        img4.isUserInteractionEnabled = true
        
        img1.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageView1Clicked)))
        img2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageView2Clicked)))
        img3.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageView3Clicked)))
        img4.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageView4Clicked)))
        
        eventDescription.text = "Summary*"
        eventDescription.textColor = .lightGray
        eventDescription.layer.borderColor = UIColor.lightGray.cgColor
        eventDescription.layer.borderWidth = 0.8
        eventDescription.layer.cornerRadius = 8
        eventDescription.delegate = self
        eventDescription.contentInset = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
        
        continueBtn.layer.cornerRadius = 8
        
        discard.isUserInteractionEnabled = true
        discard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(discardBtnClicked)))
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    
    
    @objc func backViewClicked(){
        self.dismiss(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = true
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    @objc func discardBtnClicked(){
        self.beRootScreen(storyBoardName: StoryBoard.Event, mIdentifier: Identifier.ORGANIZERDASHBOARDCONTROLLER)
    }
    
    @objc func imageView1Clicked(){
        chooseImageFromPhotoLibrary(title: "Event Image 1")
    }
    @objc func imageView2Clicked(){
        chooseImageFromPhotoLibrary(title: "Event Image 2")
    }
    @objc func imageView3Clicked(){
        chooseImageFromPhotoLibrary(title: "Event Image 3")
    }
    
    @objc func imageView4Clicked(){
        chooseImageFromPhotoLibrary(title: "Event Image 4")
    }
    
    func chooseImageFromPhotoLibrary(title : String){
       
        let image = UIImagePickerController()
        image.delegate = self
        image.title = title
        image.sourceType = .photoLibrary
        self.present(image,animated: true)
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addMoreImageBtnClicked(_ sender: Any) {
        if imgStack2.isHidden {
            imgStack2.isHidden = false
        }
        else if imgStack3.isHidden {
            imgStack3.isHidden = false
        }
        else if imgStack4.isHidden {
            imgStack4.isHidden = false
            addImageBtn.isHidden = true
        }
    }
    
    @IBAction func continueBtnClicked(_ sender: Any) {
        
        let sDescription = eventDescription.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if !isImage1Selected {
            self.showSnack(messages: "Select atleast 1 event image")
        }
        else if sDescription == "" {
            self.showSnack(messages: "Enter Description")
        }
        else {
            event!.eventDescription = sDescription
            performSegue(withIdentifier: "addticketseg", sender: event)
            
        }
       
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addticketseg" {
            if let dest = segue.destination as? AddTicketsViewController {
                if let mEvent = sender as? Event {
                    dest.event = mEvent
                }
            }
        }
    }
}

extension CreateEventMainEventImage : UITextViewDelegate {
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

extension CreateEventMainEventImage : UIImagePickerControllerDelegate, UINavigationControllerDelegate,CropViewControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.originalImage] as? UIImage {
            
            
            
            self.dismiss(animated: true) {
                
                let cropViewController = CropViewController(image: editedImage)
                cropViewController.title = picker.title
                cropViewController.delegate = self
                cropViewController.customAspectRatio = CGSize(width: 9  , height: 5)
                cropViewController.aspectRatioLockEnabled = true
                cropViewController.aspectRatioPickerButtonHidden = true
                self.present(cropViewController, animated: true, completion: nil)
            }
            
            
           
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
       
        self.ProgressHUDShow(text: "Updating...")
        
        if cropViewController.title! == "Event Image 1" {
           
            img1.image = image
            img1.isHidden = false
            imgView1.isHidden = true
            
            uploadImageOnFirebase(imageNo: 1){ downloadURL in
               
                self.ProgressHUDHide()
                self.isImage1Selected = true
                self.event!.eventImage1 = downloadURL
             
                
            }
           
            
        }
        else if cropViewController.title! == "Event Image 2"  {
            self.isImage2Selected = true
            img2.image = image
            img2.isHidden = false
            imgView2.isHidden = true
            
            uploadImageOnFirebase(imageNo: 2){ downloadURL in
               
                self.ProgressHUDHide()
                self.event!.eventImage2 = downloadURL
             
                
            }
           
            
        }
        if cropViewController.title! == "Event Image 3"  {
            self.isImage3Selected = true
            img3.image = image
            img3.isHidden = false
            imgView3.isHidden = true
            
            uploadImageOnFirebase(imageNo: 3){ downloadURL in
               
                self.ProgressHUDHide()
                self.event!.eventImage3 = downloadURL
             
                
            }
           
            
        }
        if cropViewController.title! == "Event Image 4"  {
            self.isImage4Selected = true
            img4.image = image
            img4.isHidden = false
            imgView4.isHidden = true
            
            uploadImageOnFirebase(imageNo: 4){ downloadURL in
               
                self.ProgressHUDHide()
                self.event!.eventImage4 = downloadURL
             
                
            }
           
            
        }

        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func uploadImageOnFirebase(imageNo : Int,completion : @escaping (String) -> Void ) {
        
        let storage = Storage.storage().reference().child("EventImages").child(event!.eventId!).child("\(imageNo).png")
        var downloadUrl = ""
        
        var uploadData : Data!
    
        if imageNo == 1 {
            uploadData = (self.img1.image?.jpegData(compressionQuality: 0.4))!
        }
        else if imageNo == 2 {
            uploadData = (self.img2.image?.jpegData(compressionQuality: 0.4))!
        }
        else if imageNo == 3 {
            uploadData = (self.img3.image?.jpegData(compressionQuality: 0.4))!
        }
        else if imageNo == 4 {
            uploadData = (self.img4.image?.jpegData(compressionQuality: 0.4))!
        }
       
       
    
        
        storage.putData(uploadData, metadata: nil) { (metadata, error) in
            
            if error == nil {
                storage.downloadURL { (url, error) in
                    if error == nil {
                        downloadUrl = url!.absoluteString
                    }
                    completion(downloadUrl)
               
                }
            }
            else {
                completion(downloadUrl)
            }
            
        }
    }
}
