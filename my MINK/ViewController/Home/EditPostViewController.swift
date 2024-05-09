// Copyright © 2023 SOFTMENT. All rights reserved.

import Amplify
import ATGMediaBrowser
import AVKit
import Combine
import CropViewController
import DSPhotoEditorSDK
import MobileCoreServices
import UIKit

class EditPostViewController: UIViewController {
    @IBOutlet var topView: UIView!
    @IBOutlet var mView: UIView!
    @IBOutlet var captionTV: UITextView!
    @IBOutlet var backView: UIView!
    @IBOutlet var editPostBtn: UIButton!
    var postModel: PostModel?
    var row: Int?
    var updatePostDelegate: UpdatePostDelegate?

    override func viewDidLoad() {
        guard let postModel = postModel else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }

        self.mView.clipsToBounds = true
        self.mView.layer.cornerRadius = 20
        self.mView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        self.topView.isUserInteractionEnabled = true
        self.topView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backBtnClicked)))

        self.captionTV.layer.cornerRadius = 8
        self.captionTV.layer.borderWidth = 1
        self.captionTV.layer.borderColor = UIColor(red: 221 / 255, green: 221 / 255, blue: 221 / 255, alpha: 1).cgColor
        self.captionTV.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.captionTV.text = "Write a caption here"
        self.captionTV.textColor = UIColor.lightGray

        self.captionTV.text = postModel.caption ?? ""

        self.backView.layer.cornerRadius = 8
        self.backView.dropShadow()
        self.backView.isUserInteractionEnabled = true
        self.backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backBtnClicked)))

        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard)))

        self.editPostBtn.layer.cornerRadius = 8
    }

    @IBAction func editPostClicked(_: Any) {
        ProgressHUDShow(text: "")
        FirebaseStoreManager.db.collection("Posts").document(self.postModel!.postID ?? "123")
            .setData(["caption": self.captionTV.text!], merge: true) { error in
                self.ProgressHUDHide()
                if let error = error {
                    self.showError(error.localizedDescription)
                } else {
                    self.postModel!.caption = self.captionTV.text
                    self.updatePostDelegate?.updatePost(postModel: self.postModel!)
                    self.dismiss(animated: true)
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
