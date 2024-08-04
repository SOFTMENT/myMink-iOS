//
//  AddSocialMediaViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 21/06/24.
//

import UIKit

class AddSocialMediaViewController: UIViewController {
    @IBOutlet var topView: UIView!
    @IBOutlet var mView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var profileLinkTF: UITextField!
    @IBOutlet weak var saveBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        nameTF.delegate = self
        profileLinkTF.delegate = self

        mView.clipsToBounds = true
        mView.layer.cornerRadius = 20
        mView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        topView.isUserInteractionEnabled = true
        topView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(doneBtnClicked)))

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

    @objc private func mediaNameClicked() {
        let alert = UIAlertController(title: "Select Media", message: nil, preferredStyle: .actionSheet)
        let socialMedias: [SocialMedia] = [
            .discord, .etsy, .facebook, .instagram, .linkedin, .mastodon, .pinterest, .reddit, .rumble, .telegram,
            .tiktok, .tumblr, .twitch, .twitter, .youtube, .whatsapp
        ]

        socialMedias.forEach { media in
            alert.addAction(UIAlertAction(title: media.rawValue, style: .default, handler: { _ in
                self.nameTF.text = media.rawValue
            }))
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func doneBtnClicked() {
        dismiss(animated: true)
    }

    @objc private func hideKeyboard() {
        view.endEditing(true)
    }

    @IBAction private func saveBtnClicked(_ sender: Any) {
        let sName = nameTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let sUrl = profileLinkTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let name = sName, !name.isEmpty else {
            showSnack(messages: "Select Media")
            return
        }

        guard let url = sUrl, !url.isEmpty else {
            showSnack(messages: "Enter URL")
            return
        }

        saveSocialMedia(name: name, url: url)
    }

    private func saveSocialMedia(name: String, url: String) {
        ProgressHUDShow(text: "")
        let socialMediaModel = SocialMediaModel()
        socialMediaModel.link = url
        socialMediaModel.name = name

        guard let uid = UserModel.data?.uid else {
            ProgressHUDHide()
            showSnack(messages: "User ID not found")
            return
        }

        let id = FirebaseStoreManager.db.collection(Collections.users.rawValue).document(uid).collection(Collections.socialMedia.rawValue).document().documentID
        socialMediaModel.id = id

        try? FirebaseStoreManager.db.collection(Collections.users.rawValue).document(uid).collection(Collections.socialMedia.rawValue).document(id).setData(from: socialMediaModel, merge: true) { error in
            self.ProgressHUDHide()
            if let error = error {
                self.showSnack(messages: error.localizedDescription)
            } else {
                self.showSnack(messages: "Added")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                    self.dismiss(animated: true)
                }
            }
        }
    }
}

extension AddSocialMediaViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == nameTF {
            mediaNameClicked()
            return false
        }
        return true
    }
}
