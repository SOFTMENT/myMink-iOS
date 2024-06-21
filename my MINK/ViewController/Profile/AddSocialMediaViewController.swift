//
//  AddSocialMediaViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 21/06/24.
//

import UIKit


class AddSocialMediaViewController : UIViewController {
    @IBOutlet var topView: UIView!

    @IBOutlet var mView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var profileLinkTF: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    override func viewDidLoad() {
      
        nameTF.delegate = self
        profileLinkTF.delegate = self
        
        self.mView.clipsToBounds = true
        self.mView.layer.cornerRadius = 20
        self.mView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        self.topView.isUserInteractionEnabled = true
        self.topView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.doneBtnClicked)))
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(doneBtnClicked)))
        
        nameTF.isUserInteractionEnabled = true
        nameTF.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(mediaNameClicked)))
        
        saveBtn.layer.cornerRadius = 8
    }
    
   
    @objc func mediaNameClicked(){
        let alert = UIAlertController(title: "Select Media", message: nil, preferredStyle: .actionSheet)
     
        alert.addAction(UIAlertAction(title: SocialMedia.Discord.rawValue , style: .default, handler: { action in
            self.nameTF.text = SocialMedia.Discord.rawValue
        }))
        alert.addAction(UIAlertAction(title: SocialMedia.Etsy.rawValue , style: .default, handler: { action in
            self.nameTF.text = SocialMedia.Etsy.rawValue
        }))
        alert.addAction(UIAlertAction(title: SocialMedia.Facebook.rawValue, style: .default, handler: { action in
            self.nameTF.text = SocialMedia.Facebook.rawValue
        }))
     
        alert.addAction(UIAlertAction(title: SocialMedia.Instagram.rawValue, style: .default, handler: { action in
            self.nameTF.text = SocialMedia.Instagram.rawValue
        }))
        alert.addAction(UIAlertAction(title: SocialMedia.LinkedIn.rawValue, style: .default, handler: { action in
            self.nameTF.text = SocialMedia.LinkedIn.rawValue
        }))
        alert.addAction(UIAlertAction(title: SocialMedia.Mastodon.rawValue, style: .default, handler: { action in
            self.nameTF.text = SocialMedia.Mastodon.rawValue
        }))
        alert.addAction(UIAlertAction(title: SocialMedia.Pinterest.rawValue, style: .default, handler: { action in
            self.nameTF.text = SocialMedia.Pinterest.rawValue
        }))
        alert.addAction(UIAlertAction(title: SocialMedia.Reddit.rawValue, style: .default, handler: { action in
            self.nameTF.text = SocialMedia.Reddit.rawValue
        }))
        alert.addAction(UIAlertAction(title: SocialMedia.Rumble.rawValue, style: .default, handler: { action in
            self.nameTF.text = SocialMedia.Rumble.rawValue
        }))
  
        alert.addAction(UIAlertAction(title: SocialMedia.Telegram.rawValue, style: .default, handler: { action in
            self.nameTF.text = SocialMedia.Telegram.rawValue
        }))
        alert.addAction(UIAlertAction(title: SocialMedia.TikTok.rawValue, style: .default, handler: { action in
            self.nameTF.text = SocialMedia.TikTok.rawValue
        }))
      
        alert.addAction(UIAlertAction(title: SocialMedia.Tumblr.rawValue, style: .default, handler: { action in
            self.nameTF.text = SocialMedia.Tumblr.rawValue
        }))
        alert.addAction(UIAlertAction(title: SocialMedia.Twitch.rawValue, style: .default, handler: { action in
            self.nameTF.text = SocialMedia.Twitch.rawValue
        }))
        alert.addAction(UIAlertAction(title: SocialMedia.Twitter.rawValue, style: .default, handler: { action in
            self.nameTF.text = SocialMedia.Twitter.rawValue
        }))
        alert.addAction(UIAlertAction(title: SocialMedia.YouTube.rawValue, style: .default, handler: { action in
            self.nameTF.text = SocialMedia.YouTube.rawValue
        }))
        alert.addAction(UIAlertAction(title: SocialMedia.Whatsapp.rawValue, style: .default, handler: { action in
            self.nameTF.text = SocialMedia.Whatsapp.rawValue
        }))
      
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
        
    }
    
    @objc func doneBtnClicked(){
        self.dismiss(animated: true)
    }
    
    @objc func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    @IBAction func saveBtnClicked(_ sender: Any) {
        let sName = nameTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let sUrl = profileLinkTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if sName == "" {
            self.showSnack(messages: "Select Media")
        }
        else if sUrl == "" {
            self.showSnack(messages: "Enter URL")
        }
        else {
            ProgressHUDShow(text: "")
            let socialMediaModel = SocialMediaModel()
            socialMediaModel.link = sUrl
            socialMediaModel.name = sName
            let id = FirebaseStoreManager.db.collection(Collections.USERS.rawValue).document(UserModel.data!.uid ?? "123").collection(Collections.SOCIALMEDIA.rawValue).document().documentID
            socialMediaModel.id = id
            try? FirebaseStoreManager.db.collection(Collections.USERS.rawValue).document(UserModel.data!.uid ?? "123").collection(Collections.SOCIALMEDIA.rawValue).document(id).setData(from: socialMediaModel,merge : true, completion: { error in
                self.ProgressHUDHide()
                if let error = error {
                    self.showSnack(messages: error.localizedDescription)
                }
                else {
                    self.showSnack(messages: "Added")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                        self.dismiss(animated: true)
                    }
                }
            })
        }
    }
    
}

extension AddSocialMediaViewController : UITextFieldDelegate {
    
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
