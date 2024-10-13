import Firebase
import IQKeyboardManagerSwift
import UIKit

// MARK: - CommentViewController

class CommentViewController: UIViewController, UITextViewDelegate {

    // MARK: - Outlets
    @IBOutlet var sendBtn: UIButton!
    @IBOutlet var chatTF: UITextView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var bottomCons: NSLayoutConstraint!
    @IBOutlet var backView: UIView!
    @IBOutlet var no_comments_available: UILabel!

    // MARK: - Properties
    var postModel: PostModel?
    var commentModels = [CommentModel]()

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        configurePostModel()
        registerKeyboardNotifications()
        setupGestures()
        getAllComments()
    }

    // MARK: - Setup Methods
    private func setupViews() {
        backView.dropShadow()
        backView.layer.cornerRadius = 8
        chatTF.sizeToFit()
        chatTF.isScrollEnabled = false
        chatTF.layer.cornerRadius = 8
        chatTF.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func configurePostModel() {
        guard postModel != nil else {
            dismiss(animated: true)
            return
        }
    }

    private func setupGestures() {
        setupGesture(for: backView, action: #selector(backViewClicked))
        setupGesture(for: sendBtn, action: #selector(sendBtnClicked))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }

    private func setupGesture(for view: UIView, action: Selector) {
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: action))
    }

    // MARK: - Action Methods
    @objc private func sendBtnClicked() {
        guard let sComment = chatTF.text, !sComment.isEmpty else { return }
        guard let postID = postModel?.postID, let currentUserID = FirebaseStoreManager.auth.currentUser?.uid else { return }

        let commentModel = CommentModel()
        let commentID = FirebaseStoreManager.db.collection(Collections.posts.rawValue).document(postID)
            .collection(Collections.comments.rawValue).document().documentID
        commentModel.uid = currentUserID
        commentModel.id = commentID
        commentModel.commentDate = Date()
        commentModel.comment = sComment
        chatTF.text = ""
        
        do {
            try FirebaseStoreManager.db.collection(Collections.posts.rawValue).document(postID)
                .collection(Collections.comments.rawValue).document(commentID).setData(from: commentModel) { error in
                    CommentManager.shared.reloadComment(for: postID)
                }
        } catch {
            showError(error.localizedDescription)
        }

        if currentUserID != postModel?.uid {
            
            self.addNotification(to: postModel!.postID!, userId: postModel!.uid ?? "123", comment: sComment, type: Notifications.comment.rawValue)
            
            PushNotificationSender().sendPushNotification(
                title: "Comment",
                body: "\(UserModel.data?.fullName ?? "") commented on your post.",
                topic: postModel?.notificationToken ?? ""
            )
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Keyboard Handling
    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(notify:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(notify:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func keyboardWillShow(notify: NSNotification) {
        if let keyboardSize = (notify.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            bottomCons.constant = keyboardSize.height - view.safeAreaInsets.bottom
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc private func keyboardWillHide(notify: NSNotification) {
        bottomCons.constant = 0
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func backViewClicked() {
        dismiss(animated: true)
    }

    // MARK: - Helper Methods
    private func getAllComments() {
        guard let postID = postModel?.postID else { return }
        ProgressHUDShow(text: "")
        FirebaseStoreManager.db.collection(Collections.posts.rawValue).document(postID)
            .collection(Collections.comments.rawValue)
            .order(by: "commentDate", descending: true)
            .addSnapshotListener { snapshot, error in
                self.ProgressHUDHide()
                if let error = error {
                    self.showError(error.localizedDescription)
                } else {
                    self.commentModels.removeAll()
                    if let snapshot = snapshot, !snapshot.isEmpty {
                        for document in snapshot.documents {
                            if let commentModel = try? document.data(as: CommentModel.self) {
                                self.commentModels.append(commentModel)
                            }
                        }
                    }
                    self.tableView.reloadData()
                }
            }
    }

    private func alertWithTF(commentID: String) {
        let alertController = UIAlertController(
            title: "Report".localized(),
            message: "\n\n\n\n\n",
            preferredStyle: .alert
        )

        let textView = UITextView(frame: CGRect.zero)
        textView.backgroundColor = UIColor.white
        textView.layer.cornerRadius = 8
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)

        alertController.view.addSubview(textView)

        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .default, handler: nil)
        alertController.addAction(cancelAction)

        let saveAction = UIAlertAction(title: "Submit".localized(), style: .default) { _ in
            let enteredText = textView.text ?? ""
            if !enteredText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                self.reportComment(reason: enteredText, commentID: commentID, postId: self.postModel?.postID ?? "") { message in
                    self.showSnack(messages: message)
                }
            } else {
                self.showSnack(messages: "Please enter a reason for reporting.".localized())
            }
        }
        alertController.addAction(saveAction)

        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: alertController.view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: alertController.view.trailingAnchor, constant: -16),
            textView.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 50),
            textView.heightAnchor.constraint(equalToConstant: 80)
        ])

        present(alertController, animated: true, completion: nil)
    }

    private func editComment(comment: String, commentID: String) {
        let alertController = UIAlertController(
            title: "Edit".localized(),
            message: "\n\n\n\n\n",
            preferredStyle: .alert
        )

        let textView = UITextView(frame: CGRect.zero)
        textView.backgroundColor = UIColor.white
        textView.layer.cornerRadius = 8
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
        textView.text = comment
        alertController.view.addSubview(textView)

        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .default, handler: nil)
        alertController.addAction(cancelAction)

        let saveAction = UIAlertAction(title: "Edit".localized(), style: .default) { _ in
            let enteredText = textView.text ?? ""
            if !enteredText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                guard let postID = self.postModel?.postID else { return }
                FirebaseStoreManager.db.collection(Collections.posts.rawValue).document(postID)
                    .collection(Collections.comments.rawValue).document(commentID).setData(["comment": enteredText], merge: true)
                self.showSnack(messages: "Comment Updated".localized())
            } else {
                self.showSnack(messages: "Please enter a valid comment.".localized())
            }
        }
        alertController.addAction(saveAction)

        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: alertController.view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: alertController.view.trailingAnchor, constant: -16),
            textView.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 50),
            textView.heightAnchor.constraint(equalToConstant: 80)
        ])

        present(alertController, animated: true, completion: nil)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "commentViewUserProfileSeg", let vc = segue.destination as? ViewUserProfileController, let user = sender as? UserModel {
            vc.user = user
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension CommentViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        no_comments_available.isHidden = !commentModels.isEmpty
        return commentModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as? CommentTableViewCell {
            configureCell(cell, at: indexPath)
            return cell
        }
        return CommentTableViewCell()
    }

    private func configureCell(_ cell: CommentTableViewCell, at indexPath: IndexPath) {
        cell.profilePic.layer.cornerRadius = cell.profilePic.bounds.height / 2
        cell.mView.layer.cornerRadius = 6
        let commentModel = commentModels[indexPath.row]
        cell.comment.text = commentModel.comment ?? ""

        var uiMenuElement = [UIMenuElement]()
        let delete = UIAction(title: "Delete".localized(), image: UIImage(systemName: "trash.fill")) { _ in
            self.deleteComment(postId: self.postModel?.postID ?? "", commentId: commentModel.id ?? "") { _ in
                CommentManager.shared.reloadComment(for: self.postModel?.postID ?? "")
            }
        }
        let edit = UIAction(title: "Edit".localized(), image: UIImage(systemName: "pencil.circle.fill")) { _ in
            self.editComment(comment: commentModel.comment ?? "", commentID: commentModel.id ?? "")
        }
        if FirebaseStoreManager.auth.currentUser?.uid == commentModel.uid {
            uiMenuElement.append(edit)
            uiMenuElement.append(delete)
        }
        let report = UIAction(title: "Report".localized(), image: UIImage(systemName: "exclamationmark.triangle.fill")) { _ in
            self.alertWithTF(commentID: commentModel.id ?? "")
        }
        uiMenuElement.append(report)

        if let caption = commentModel.comment, !caption.isEmpty {
            let translate = UIAction(title: "Translate".localized(), image: UIImage(systemName: "translate")) { _ in
                self.ProgressHUDShow(text: "Translating...".localized())
                TranslationService.shared.translateText(text: caption) { translate in
                    DispatchQueue.main.async {
                        self.ProgressHUDHide()
                        cell.comment.text = translate.removingPercentEncoding ?? ""
                    }
                }
            }
            uiMenuElement.append(translate)
        }

        cell.moreBtn.isUserInteractionEnabled = true
        cell.moreBtn.showsMenuAsPrimaryAction = true
        cell.moreBtn.menu = UIMenu(title: "", children: uiMenuElement)

        cell.profilePic.setImage(imageKey: "", placeholder: "profile-placeholder",shouldShowAnimationPlaceholder: true)
        getUserDataByID(uid: commentModel.uid ?? "") { friendModel, _ in
            if let friendModel = friendModel {
                if friendModel.uid != FirebaseStoreManager.auth.currentUser?.uid {
                    self.setupProfileGesture(cell, user: friendModel)
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
                cell.name.text = friendModel.fullName ?? "ERROR".localized()
                cell.commentDate.text = (commentModel.commentDate ?? Date()).timeAgoSinceDate()
            } else {
                self.deleteComment(postId: self.postModel?.postID ?? "", commentId: commentModel.id ?? "") { error in
                    // Handle Error Here
                }
            }
        }
    }

    private func setupProfileGesture(_ cell: CommentTableViewCell, user: UserModel) {
        let userGest = MyGesture(target: self, action: #selector(showUserProfile(_:)))
        userGest.userModel = user
        cell.nameAndDateStack.isUserInteractionEnabled = true
        cell.nameAndDateStack.addGestureRecognizer(userGest)

        let userGest1 = MyGesture(target: self, action: #selector(showUserProfile(_:)))
        userGest1.userModel = user
        cell.profilePic.isUserInteractionEnabled = true
        cell.profilePic.addGestureRecognizer(userGest1)
    }

    @objc private func showUserProfile(_ gesture: MyGesture) {
        if let userModel = gesture.userModel {
            performSegue(withIdentifier: "commentViewUserProfileSeg", sender: userModel)
        }
    }
}
