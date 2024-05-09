// Copyright © 2023 SOFTMENT. All rights reserved.

import Firebase
import IQKeyboardManagerSwift
import UIKit

// MARK: - ReloadTableViewDelegate

protocol ReloadTableViewDelegate: AnyObject {
    func reloadTableView()
}

// MARK: - CommentViewController

class CommentViewController: UIViewController, UITextViewDelegate {
    let textView = UITextView(frame: CGRect.zero)
    @IBOutlet var sendBtn: UIButton!
    @IBOutlet var chatTF: UITextView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var bottomCons: NSLayoutConstraint!
    @IBOutlet var backView: UIView!
    @IBOutlet var no_comments_available: UILabel!
    var postModel: PostModel?
    var commentModels = [CommentModel]()

  

    override func viewDidLoad() {
        if self.postModel == nil {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }

        self.backView.dropShadow()
        self.backView.layer.cornerRadius = 8
        self.backView.isUserInteractionEnabled = true
        self.backView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.backViewClicked)
        ))

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )

        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard)))

        self.chatTF.sizeToFit()
        self.chatTF.isScrollEnabled = false
        self.chatTF.delegate = self
        self.chatTF.layer.cornerRadius = 8
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.chatTF.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        self.sendBtn.isUserInteractionEnabled = true
        self.sendBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.sendBtnClicked)))

        self.chatTF.becomeFirstResponder()

        self.getAllComments()
    }

    func getAllComments() {
        ProgressHUDShow(text: "")
        FirebaseStoreManager.db.collection("Posts").document(self.postModel!.postID ?? "123").collection("Comments")
            .order(by: "commentDate", descending: true).addSnapshotListener { snapshot, error in
                self.ProgressHUDHide()
                if let error = error {
                    self.showError(error.localizedDescription)
                } else {
                    self.commentModels.removeAll()
                    if let snapshot = snapshot, !snapshot.isEmpty {
                        for qdr in snapshot.documents {
                            if let commentModel = try? qdr.data(as: CommentModel.self) {
                                self.commentModels.append(commentModel)
                            }
                        }
                    }

                    self.tableView.reloadData()
                }
            }
    }

    @objc func sendBtnClicked() {
        let sComment = self.chatTF.text
        if sComment != "" {
            
            let commentModel = CommentModel()
            let commentID = FirebaseStoreManager.db.collection("Posts").document(self.postModel!.postID ?? "123")
                .collection("Comments").document().documentID
            commentModel.uid = FirebaseStoreManager.auth.currentUser!.uid
            commentModel.id = commentID
            commentModel.commentDate = Date()
            commentModel.comment = sComment
            self.chatTF.text = ""
            try? FirebaseStoreManager.db.collection("Posts").document(self.postModel!.postID ?? "123")
                .collection("Comments").document(commentID).setData(from: commentModel, completion: { error in
                    CommentManager.shared.reloadComment(for: self.postModel?.postID ?? "123")
                })
                
            if FirebaseStoreManager.auth.currentUser!.uid != self.postModel!.uid {
                PushNotificationSender().sendPushNotification(
                    title: "Comment",
                    body: "\(UserModel.data!.fullName ?? "123") commented on your post.",
                    topic: self.postModel!.notificationToken ?? "123"
                )
            }
        }
    }

    override func viewWillAppear(_: Bool) {
        IQKeyboardManager.shared.enable = false
    }

    override func viewWillDisappear(_: Bool) {
        IQKeyboardManager.shared.enable = true
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc func keyboardWillShow(notify: NSNotification) {
        if let keyboardSize = (notify.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.bottomCons.constant = (keyboardSize.height - view.safeAreaFrame)
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc func keyboardWillHide(notify _: NSNotification) {
        self.bottomCons.constant = 0
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }

    @objc func showUserProfile(value: MyGesture) {
        if let userModel = value.userModel {
            performSegue(withIdentifier: "commentViewUserProfileSeg", sender: userModel)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "commentViewUserProfileSeg" {
            if let vc = segue.destination as? ViewUserProfileController {
                if let user = sender as? UserModel {
                    vc.user = user
                }
            }
        }
    }

    @objc func backViewClicked() {
       dismiss(animated: true)
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource

extension CommentViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        self.no_comments_available.isHidden = self.commentModels.count > 0 ? true : false
        return self.commentModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(
            withIdentifier: "commentCell",
            for: indexPath
        ) as? CommentTableViewCell {
            cell.profilePic.layer.cornerRadius = cell.profilePic.bounds.height / 2
            cell.mView.layer.cornerRadius = 6
            let commentModel = self.commentModels[indexPath.row]
            cell.comment.text = commentModel.comment ?? ""

            var uiMenuElement = [UIMenuElement]()
            let delete = UIAction(
                title: "Delete",
                image: UIImage(systemName: "trash.fill")
            ) { _ in
              
                self.deleteComment(postId: self.postModel!.postID ?? "123", commentId: commentModel.id ?? "") { error in
                    CommentManager.shared.reloadComment(for: self.postModel?.postID ?? "123")
                }
            }
            let edit = UIAction(
                title: "Edit",
                image: UIImage(systemName: "pencil.circle.fill")
            ) { _ in

                self.editComment(comment: commentModel.comment ?? "", commentID: commentModel.id ?? "123")
            }
            if FirebaseStoreManager.auth.currentUser!.uid == commentModel.uid {
                uiMenuElement.append(edit)
                uiMenuElement.append(delete)
            }
            let report = UIAction(
                title: "Report",
                image: UIImage(systemName: "exclamationmark.triangle.fill")
            ) { _ in

                self.alertWithTF(commentID: commentModel.id ?? "123")
            }
            uiMenuElement.append(report)
            
            if let caption = commentModel.comment, !caption.isEmpty {
                let transalte = UIAction(title: "Translate", image: UIImage(systemName: "translate")) { _ in
                    self.ProgressHUDShow(text: "Translating...")
                    TranslationService.shared.translateText(text: caption) { translate in
                        DispatchQueue.main.async {
                            self.ProgressHUDHide()
                            cell.comment.text = translate.removingPercentEncoding ?? ""
                        }
                    }
                }
                uiMenuElement.append(transalte)
            }

            cell.moreBtn.isUserInteractionEnabled = true
            cell.moreBtn.showsMenuAsPrimaryAction = true

            cell.moreBtn.menu = UIMenu(title: "", children: uiMenuElement)

            getUserDataByID(uid: commentModel.uid ?? "123") { friendModel, _ in
                if let friendModel = friendModel {
                    if friendModel.uid != FirebaseStoreManager.auth.currentUser!.uid {
                        cell.nameAndDateStack.isUserInteractionEnabled = true
                        let userGest = MyGesture(target: self, action: #selector(self.showUserProfile))
                        userGest.userModel = friendModel
                        cell.nameAndDateStack.addGestureRecognizer(userGest)

                        let userGest1 = MyGesture(target: self, action: #selector(self.showUserProfile))
                        userGest1.userModel = friendModel

                        cell.profilePic.isUserInteractionEnabled = true
                        cell.profilePic.addGestureRecognizer(userGest1)
                    }

                    if let image = friendModel.profilePic, !image.isEmpty {
                        cell.profilePic.setImage(
                            imageKey: image,
                            placeholder: "profile-placeholder",
                            width: 80,
                            height: 80,
                            shouldShowAnimationPlaceholder: true
                        )
                    }
                    cell.name.text = friendModel.fullName ?? "ERROR"
                    cell.commentDate.text = (commentModel.commentDate ?? Date()).timeAgoSinceDate()
                } else {
                    self.deleteComment(postId: self.postModel!.postID ?? "123", commentId: commentModel.id ?? "") { error in
                        //Handle Error Here
                    }
                }
            }
            return cell
        }
        return CommentTableViewCell()
    }

    func alertWithTF(commentID: String) {
        let alertController = UIAlertController(
            title: "Report",
            message: "\n\n\n\n\n",
            preferredStyle: .alert
        ) // Added extra newlines for textView space

        let textView = UITextView(frame: CGRect.zero)
        textView.backgroundColor = UIColor.white
        textView.layer.cornerRadius = 8
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)

        alertController.view.addSubview(textView)

        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)

        let saveAction = UIAlertAction(title: "Submit", style: .default) { _ in
            let enteredText = textView.text
            if enteredText != "" {
                self.reportComment(reason: enteredText ?? "", commentID: commentID, postId: self.postModel!.postID!) { message in
                    self.showSnack(messages: message)
                }
            }
        }
        alertController.addAction(saveAction)

        // Constraints for the textView (Positioning it within the UIAlertController)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: alertController.view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: alertController.view.trailingAnchor, constant: -16),
            textView.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 50),
            textView.heightAnchor.constraint(equalToConstant: 80)
        ])

        present(alertController, animated: true, completion: nil)
    }

    func editComment(comment: String, commentID: String) {
        let alertController = UIAlertController(
            title: "Edit",
            message: "\n\n\n\n\n",
            preferredStyle: .alert
        ) // Added extra newlines for textView space

        let textView = UITextView(frame: CGRect.zero)
        textView.backgroundColor = UIColor.white
        textView.layer.cornerRadius = 8
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
        textView.text = comment
        alertController.view.addSubview(textView)

        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)

        let saveAction = UIAlertAction(title: "Edit", style: .default) { _ in
            let enteredText = textView.text
            if enteredText != "" {
                FirebaseStoreManager.db.collection("Posts").document(self.postModel!.postID ?? "123")
                    .collection("Comments").document(commentID).setData(["comment": enteredText ?? ""], merge: true)
                self.showSnack(messages: "Comment Updated")
            }
        }
        alertController.addAction(saveAction)

        // Constraints for the textView (Positioning it within the UIAlertController)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: alertController.view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: alertController.view.trailingAnchor, constant: -16),
            textView.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 50),
            textView.heightAnchor.constraint(equalToConstant: 80)
        ])

        present(alertController, animated: true, completion: nil)
    }
}
