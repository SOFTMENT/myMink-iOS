//
//  EditSocialMediaViewContoller.swift
//  my MINK
//
//  Created by Vijay Rathore on 21/06/24.
//


import UIKit


class EditSocialMediaViewContoller : UIViewController {
    
    @IBOutlet var topView: UIView!
    @IBOutlet var mView: UIView!
    
    
    @IBOutlet weak var deleteBtn: UIView!
    @IBOutlet weak var backBtn: UIView!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var profileLinkTF: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    var socialMediaModel : SocialMediaModel?
    
    override func viewDidLoad() {
        
        guard let socialMediaModel = socialMediaModel else {
            
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        self.mView.clipsToBounds = true
        self.mView.layer.cornerRadius = 20
        self.mView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        self.topView.isUserInteractionEnabled = true
        self.topView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.doneBtnClicked)))
      
        nameTF.delegate = self
        profileLinkTF.delegate = self
        
        nameTF.text = socialMediaModel.name ?? ""
        profileLinkTF.text = socialMediaModel.link ?? ""
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        deleteBtn.dropShadow()
        deleteBtn.layer.cornerRadius = 8
        deleteBtn.isUserInteractionEnabled = true
        deleteBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deleteSocialClicked)))
        
        backBtn.dropShadow()
        backBtn.layer.cornerRadius = 8
        backBtn.isUserInteractionEnabled = true
        backBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(doneBtnClicked)))
    
        saveBtn.layer.cornerRadius = 8
    }
    @objc func deleteSocialClicked(){
        ProgressHUDShow(text: "Deleting...")
        FirebaseStoreManager.db.collection(Collections.USERS.rawValue).document(UserModel.data!.uid ?? "123").collection(Collections.SOCIALMEDIA.rawValue).document(self.socialMediaModel!.id ?? "123").delete { error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error.localizedDescription)
            }
            else {
                self.showSnack(messages: "Deleted")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                    self.dismiss(animated: true)
                }
            }
        }
    }
    

    @objc func doneBtnClicked(){
        self.dismiss(animated: true)
    }
    
    @objc func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    @IBAction func saveBtnClicked(_ sender: Any) {
       
        let sUrl = profileLinkTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if sUrl == "" {
            self.showSnack(messages: "Enter URL")
        }
        else {
            ProgressHUDShow(text: "")
          
            self.socialMediaModel!.link = sUrl
          
            try? FirebaseStoreManager.db.collection(Collections.USERS.rawValue).document(UserModel.data!.uid ?? "123").collection(Collections.SOCIALMEDIA.rawValue).document(self.socialMediaModel!.id ?? "123").setData(from: socialMediaModel,merge : true, completion: { error in
                self.ProgressHUDHide()
                if let error = error {
                    self.showSnack(messages: error.localizedDescription)
                }
                else {
                    self.showSnack(messages: "Updated")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                        self.dismiss(animated: true)
                    }
                }
            })
        }
    }
    
}

extension EditSocialMediaViewContoller : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == nameTF {
            return false;
        }
        return true
    }
}
