// Copyright © 2023 SOFTMENT. All rights reserved.

import Amplify
import ATGMediaBrowser
import AVKit
import Combine
import CropViewController
import MobileCoreServices
import UIKit

class EditPostViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet var topView: UIView!
    @IBOutlet var mView: UIView!
    @IBOutlet var captionTV: UITextView!
    @IBOutlet var backView: UIView!
    @IBOutlet var editPostBtn: UIButton!

    // MARK: - Properties
    var postModel: PostModel?
    var row: Int?
    var updatePostDelegate: UpdatePostDelegate?

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        configurePostModel()
        setupGestures()
    }

    // MARK: - Setup Methods
    private func setupViews() {
        mView.clipsToBounds = true
        mView.layer.cornerRadius = 20
        mView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        captionTV.layer.cornerRadius = 8
        captionTV.layer.borderWidth = 1
        captionTV.layer.borderColor = UIColor(red: 221 / 255, green: 221 / 255, blue: 221 / 255, alpha: 1).cgColor
        captionTV.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        captionTV.text = "Write a caption here".localized()
        captionTV.textColor = UIColor.lightGray

        backView.layer.cornerRadius = 8
        backView.dropShadow()

        editPostBtn.layer.cornerRadius = 8
    }

    private func configurePostModel() {
        guard let postModel = postModel else {
            dismiss(animated: true)
            return
        }
        captionTV.text = postModel.caption ?? ""
    }

    private func setupGestures() {
        setupGesture(for: topView, action: #selector(backBtnClicked))
        setupGesture(for: backView, action: #selector(backBtnClicked))

        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }

    private func setupGesture(for view: UIView, action: Selector) {
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: action))
    }

    // MARK: - Action Methods
    @IBAction func editPostClicked(_: Any) {
        ProgressHUDShow(text: "")
        guard let postID = postModel?.postID else { return }
        FirebaseStoreManager.db.collection(Collections.posts.rawValue).document(postID)
            .setData(["caption": captionTV.text!], merge: true) { error in
                self.ProgressHUDHide()
                if let error = error {
                    self.showError(error.localizedDescription)
                } else {
                    self.postModel?.caption = self.captionTV.text
                    self.updatePostDelegate?.updatePost(postModel: self.postModel!)
                    self.dismiss(animated: true)
                }
            }
    }

    @objc private func hideKeyboard() {
        view.endEditing(true)
    }

    @objc private func backBtnClicked() {
        dismiss(animated: true)
    }
}
