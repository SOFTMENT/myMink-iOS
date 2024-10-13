import UIKit
import CropViewController
import Firebase
import FirebaseFirestoreSwift
import FirebaseAuth
import IQKeyboardManagerSwift

class UpdateEventMainEventImage: UIViewController {
    
    // MARK: - Outlets
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
  
    @IBOutlet weak var backView: UIView!
    
    // MARK: - Properties
    var event: Event?
    var isImage1Selected = false
    var isImage2Selected = false
    var isImage3Selected = false
    var isImage4Selected = false
    var isFree = false
    var mUser: User!

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let event = event else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        guard let user = Auth.auth().currentUser else {
            self.logoutPlease()
            return
        }
        mUser = user
        
        setupUI(event: event)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = true
    }
    
    // MARK: - Setup Methods
    private func setupUI(event : Event) {
        backView.dropShadow()
        backView.layer.cornerRadius = 8
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        setupImageViews()
        setupButtons()
        setupEventDescription()
        setupTextFields()
        
        if let image1 = event.eventImage1, !image1.isEmpty {
            imgStack1.isHidden = false
            imgView1.isHidden = true
            img1.isHidden = false
            img1.setImage(imageKey: image1, placeholder: "", width: 600, height: 360, shouldShowAnimationPlaceholder: true)
            
        }
        if let image2 = event.eventImage2, !image2.isEmpty {
            imgStack2.isHidden = false
            imgView2.isHidden = true
            img2.isHidden = false
            img2.setImage(imageKey: image2, placeholder: "", width: 600, height: 360, shouldShowAnimationPlaceholder: true)
        }
        if let image3 = event.eventImage3, !image3.isEmpty {
            imgStack3.isHidden = false
            imgView3.isHidden = true
            img3.isHidden = false
            img3.setImage(imageKey: image3, placeholder: "", width: 600, height: 360, shouldShowAnimationPlaceholder: true)
        }
        if let image4 = event.eventImage4, !image4.isEmpty {
            imgStack4.isHidden = false
            imgView4.isHidden = true
            img4.isHidden = false
            img4.setImage(imageKey: image4, placeholder: "", width: 600, height: 360, shouldShowAnimationPlaceholder: true)
        }
        
        
        
        if let free = event.isFree, free {
          
                isFree = true
                price.text = "Free".localized()
                price.isEnabled = false
                updatePaidButtonAppearance(selected: false)
                updateFreeButtonAppearance(selected: true)
         
           
        }
        else {
            isFree = false
            price.text = String(event.ticketPrice ?? 0)
            price.isEnabled = true
            updatePaidButtonAppearance(selected: true)
            updateFreeButtonAppearance(selected: false)
          
        }
        
        name.text = event.ticketName ?? ""
        availableQuantity.text = String(event.ticketQuantity ?? 0)
      
        
    }
    
    private func setupImageViews() {
        [imgStack1, imgStack2, imgStack3, imgStack4].forEach {
            $0?.dropShadow()
        }
        
        [imgView1, imgView2, imgView3, imgView4].forEach {
            $0?.layer.cornerRadius = 8
            $0?.isUserInteractionEnabled = true
        }
        
        [img1, img2, img3, img4].forEach {
            $0?.layer.cornerRadius = 8
            $0?.isHidden = true
            $0?.isUserInteractionEnabled = true
        }
        
        imgStack1.isHidden = false
        imgStack2.isHidden = true
        imgStack3.isHidden = true
        imgStack4.isHidden = true
        
        imgView1.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageView1Clicked)))
        imgView2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageView2Clicked)))
        imgView3.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageView3Clicked)))
        imgView4.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageView4Clicked)))
        
        img1.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageView1Clicked)))
        img2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageView2Clicked)))
        img3.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageView3Clicked)))
        img4.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageView4Clicked)))
        
        addImageBtn.layer.cornerRadius = 8
        addImageBtn.layer.borderWidth = 1
        addImageBtn.layer.borderColor = UIColor(red: 67/255, green: 67/255, blue: 67/255, alpha: 1).cgColor
    }
    
    private func setupButtons() {
        [paid, free].forEach {
            $0?.layer.cornerRadius = 8
            $0?.layer.borderWidth = 1
        }
        
        updatePaidButtonAppearance(selected: true)
        updateFreeButtonAppearance(selected: false)
        
        paid.addTarget(self, action: #selector(paidBtnClicked), for: .touchUpInside)
        free.addTarget(self, action: #selector(freeBtnClicked), for: .touchUpInside)
    }
    
    private func updatePaidButtonAppearance(selected: Bool) {
        paid.backgroundColor = selected ? UIColor(red: 210/255, green: 0/255, blue: 1/255, alpha: 0.1) : .clear
        paid.setTitleColor(selected ? UIColor(red: 210/255, green: 0/255, blue: 1/255, alpha: 1) : UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1), for: .normal)
        paid.layer.borderColor = selected ? UIColor(red: 210/255, green: 0/255, blue: 1/255, alpha: 1).cgColor : UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1).cgColor
    }
    
    private func updateFreeButtonAppearance(selected: Bool) {
        free.backgroundColor = selected ? UIColor(red: 210/255, green: 0/255, blue: 1/255, alpha: 0.1) : .clear
        free.setTitleColor(selected ? UIColor(red: 210/255, green: 0/255, blue: 1/255, alpha: 1) : UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1), for: .normal)
        free.layer.borderColor = selected ? UIColor(red: 210/255, green: 0/255, blue: 1/255, alpha: 1).cgColor : UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1).cgColor
    }
    
    private func setupEventDescription() {
        eventDescription.text = event!.eventDescription ?? "Summary*".localized()
        eventDescription.layer.borderColor = UIColor.lightGray.cgColor
        eventDescription.layer.borderWidth = 0.8
        eventDescription.layer.cornerRadius = 8
        eventDescription.delegate = self
        eventDescription.contentInset = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
        
        continueBtn.layer.cornerRadius = 8
    }
    
    private func setupTextFields() {
        [name, availableQuantity, price].forEach {
            $0?.layer.cornerRadius = 8
            $0?.delegate = self
        }
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    // MARK: - Actions
    @objc private func backViewClicked() {
        self.dismiss(animated: true)
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func imageView1Clicked() {
        chooseImageFromPhotoLibrary(title: "Event Image 1")
    }
    
    @objc private func imageView2Clicked() {
        chooseImageFromPhotoLibrary(title: "Event Image 2")
    }
    
    @objc private func imageView3Clicked() {
        chooseImageFromPhotoLibrary(title: "Event Image 3")
    }
    
    @objc private func imageView4Clicked() {
        chooseImageFromPhotoLibrary(title: "Event Image 4")
    }
    
    private func chooseImageFromPhotoLibrary(title: String) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.title = title
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true)
    }
    
    @IBAction func paidBtnClicked(_ sender: Any) {
        isFree = false
        price.text = ""
        price.isEnabled = true
        updatePaidButtonAppearance(selected: true)
        updateFreeButtonAppearance(selected: false)
    }
    
    @IBAction func freeBtnClicked(_ sender: Any) {
        isFree = true
        price.text = "Free".localized()
        price.isEnabled = false
        updatePaidButtonAppearance(selected: false)
        updateFreeButtonAppearance(selected: true)
    }
    
    
    @IBAction private func addMoreImageBtnClicked(_ sender: Any) {
        if imgStack2.isHidden {
            imgStack2.isHidden = false
        } else if imgStack3.isHidden {
            imgStack3.isHidden = false
        } else if imgStack4.isHidden {
            imgStack4.isHidden = false
            addImageBtn.isHidden = true
        }
    }
    
    @IBAction private func continueBtnClicked(_ sender: Any) {
        
        guard let sName = name.text?.trimmingCharacters(in: .whitespacesAndNewlines), !sName.isEmpty else {
            self.showSnack(messages: "Please fill in the name".localized())
            return
        }

        guard let sQuantity = availableQuantity.text?.trimmingCharacters(in: .whitespacesAndNewlines), !sQuantity.isEmpty else {
            self.showSnack(messages: "Please fill in the available quantity".localized())
            return
        }

     
            guard let priceText = price.text?.trimmingCharacters(in: .whitespacesAndNewlines), !priceText.isEmpty else {
                self.showSnack(messages: "Please fill in the price".localized())
                return
            }
         
            
        

        guard let sDescription = eventDescription.text?.trimmingCharacters(in: .whitespacesAndNewlines), !sDescription.isEmpty else {
            self.showSnack(messages: "Please fill in the description".localized())
            return
        }
        
        if let isFree = event!.isFree, isFree {
            // Proceed with the rest of your code since all fields are valid.
            updateEventDetails(sName: sName, sQuantity: sQuantity, sPrice: priceText, sDescription: sDescription)
        }
        else {
            guard Int(sQuantity) ?? 0 > 0 else {
                self.showSnack(messages: "Enter a valid quantity".localized())
                return
            }
    
            
            // Proceed with the rest of your code since all fields are valid.
            updateEventDetails(sName: sName, sQuantity: sQuantity, sPrice: priceText, sDescription: sDescription)
        }
      

        
    }
    
    private func updateEventDetails(sName: String, sQuantity: String, sPrice: String, sDescription: String) {
        guard let event = event else { return }
        
        event.eventDescription = sDescription
        event.isFree = isFree
        event.ticketName = sName
        event.ticketQuantity = Int(sQuantity) ?? 1
        event.ticketPrice = Int(sPrice) ?? 1
      
        self.ProgressHUDShow(text: "Updating...".localized())
        
        let batch = FirebaseStoreManager.db.batch()
        let docRef = FirebaseStoreManager.db.collection(Collections.events.rawValue).document(event.eventId!)
        
        do {
            try batch.setData(from: event, forDocument: docRef)
        } catch {
            self.ProgressHUDHide()
            self.showError(error.localizedDescription)
            return
        }
        
        batch.commit { error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error.localizedDescription)
            } else {
                self.showSnack(messages: "Event Updated".localized())
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                    self.beRootScreen(storyBoardName: StoryBoard.event, mIdentifier: Identifier.organizerDashboardController)
                }
            }
        }
    }
}

// MARK: - UITextViewDelegate
extension UpdateEventMainEventImage: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Summary*".localized()
            textView.textColor = .lightGray
        }
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate
extension UpdateEventMainEventImage: UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let editedImage = info[.originalImage] as? UIImage {
            self.dismiss(animated: true) {
                let cropViewController = CropViewController(image: editedImage)
                cropViewController.title = picker.title
                cropViewController.delegate = self
                cropViewController.customAspectRatio = CGSize(width: 9, height: 5)
                cropViewController.aspectRatioLockEnabled = true
                cropViewController.aspectRatioPickerButtonHidden = true
                self.present(cropViewController, animated: true)
            }
        }
        self.dismiss(animated: true)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        guard let title = cropViewController.title else { return }
        
        self.ProgressHUDShow(text: "Updating...".localized())
        
        switch title {
        case "Event Image 1":
            img1.image = image
            img1.isHidden = false
            imgView1.isHidden = true
            uploadImage(image: image, imageNo: 1) { downloadURL in
                self.isImage1Selected = true
                self.event?.eventImage1 = downloadURL
            }
        case "Event Image 2":
            img2.image = image
            img2.isHidden = false
            imgView2.isHidden = true
            uploadImage(image: image, imageNo: 2) { downloadURL in
                self.isImage2Selected = true
                self.event?.eventImage2 = downloadURL
            }
        case "Event Image 3":
            img3.image = image
            img3.isHidden = false
            imgView3.isHidden = true
            uploadImage(image: image, imageNo: 3) { downloadURL in
                self.isImage3Selected = true
                self.event?.eventImage3 = downloadURL
            }
        case "Event Image 4":
            img4.image = image
            img4.isHidden = false
            imgView4.isHidden = true
            uploadImage(image: image, imageNo: 4) { downloadURL in
                self.isImage4Selected = true
                self.event?.eventImage4 = downloadURL
            }
        default:
            break
        }
        
        self.dismiss(animated: true)
    }
    
    private func uploadImage(image: UIImage, imageNo: Int, completion: @escaping (String) -> Void) {
        uploadFilesOnAWS(photo: image, folderName: "EventImages", postType: .image) { downloadURL in
            self.ProgressHUDHide()
            completion(downloadURL ?? "")
        }
    }
}

// MARK: - UITextFieldDelegate
extension UpdateEventMainEventImage: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == name {
            let maxLength = 50
            let currentString: NSString = (textField.text ?? "") as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            nameCounter.text = "\(newString.length) / \(maxLength)"
            return newString.length <= maxLength
        }
        return true
    }
}
