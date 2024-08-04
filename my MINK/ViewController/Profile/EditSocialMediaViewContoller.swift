//
//  EditSocialMediaViewContoller.swift
//  my MINK
//
//  Created by Vijay Rathore on 21/06/24.
//

import UIKit

class EditSocialMediaViewContoller: UIViewController {
    
    @IBOutlet var topView: UIView!
    @IBOutlet var mView: UIView!
    @IBOutlet weak var deleteBtn: UIView!
    @IBOutlet weak var backBtn: UIView!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var profileLinkTF: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    var socialMediaModel: SocialMediaModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let socialMediaModel = socialMediaModel else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        setupUI(socialMediaModel: socialMediaModel)
    }
    
    private func setupUI(socialMediaModel: SocialMediaModel) {
        mView.clipsToBounds = true
        mView.layer.cornerRadius = 20
        mView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        topView.isUserInteractionEnabled = true
        topView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(doneBtnClicked)))
        
        nameTF.delegate = self
        profileLinkTF.delegate = self
        
        nameTF.text = socialMediaModel.name
        profileLinkTF.text = socialMediaModel.link
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        configureButton(deleteBtn, action: #selector(deleteSocialClicked))
        configureButton(backBtn, action: #selector(doneBtnClicked))
        
        saveBtn.layer.cornerRadius = 8
    }
    
    private func configureButton(_ button: UIView, action: Selector) {
        button.dropShadow()
        button.layer.cornerRadius = 8
        button.isUserInteractionEnabled = true
        button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: action))
    }
    
    @objc private func deleteSocialClicked() {
        ProgressHUDShow(text: "Deleting...")
        
        guard let userId = UserModel.data?.uid, let socialMediaId = socialMediaModel?.id else {
            ProgressHUDHide()
            showError("Failed to delete: Invalid user or social media ID")
            return
        }
        
        FirebaseStoreManager.db.collection(Collections.users.rawValue).document(userId).collection(Collections.socialMedia.rawValue).document(socialMediaId).delete { error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error.localizedDescription)
            } else {
                self.showSnack(messages: "Deleted")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
    @objc private func doneBtnClicked() {
        dismiss(animated: true)
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction private func saveBtnClicked(_ sender: Any) {
        guard let sUrl = profileLinkTF.text?.trimmingCharacters(in: .whitespacesAndNewlines), !sUrl.isEmpty else {
            showSnack(messages: "Enter URL")
            return
        }
        
        guard let socialMediaModel = socialMediaModel else {
            showError("Failed to save: Social media model is missing")
            return
        }
        
        socialMediaModel.link = sUrl
        updateSocialMedia(socialMediaModel: socialMediaModel)
    }
    
    private func updateSocialMedia(socialMediaModel: SocialMediaModel) {
        ProgressHUDShow(text: "Updating...")
        
        guard let userId = UserModel.data?.uid, let socialMediaId = socialMediaModel.id else {
            ProgressHUDHide()
            showError("Failed to update: Invalid user or social media ID")
            return
        }
        
        try? FirebaseStoreManager.db.collection(Collections.users.rawValue).document(userId).collection(Collections.socialMedia.rawValue).document(socialMediaId).setData(from: socialMediaModel, merge: true) { error in
            self.ProgressHUDHide()
            if let error = error {
                self.showSnack(messages: error.localizedDescription)
            } else {
                self.showSnack(messages: "Updated")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                    self.dismiss(animated: true)
                }
            }
        }
    }
}

extension EditSocialMediaViewContoller: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == nameTF {
            return false
        }
        return true
    }
}
