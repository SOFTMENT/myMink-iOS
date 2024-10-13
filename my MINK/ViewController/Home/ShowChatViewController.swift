// Copyright © 2023 SOFTMENT. All rights reserved.

import Firebase
import IQKeyboardManagerSwift
import UIKit
import SDWebImage

class ShowChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    @IBOutlet var userImageAndName: UIStackView!
    @IBOutlet var videoCallBtn: UIView!
    @IBOutlet var bottomConst: NSLayoutConstraint!
    @IBOutlet var backView: UIView!
    @IBOutlet weak var mProfile: SDAnimatedImageView!
    
    @IBOutlet var mName: UILabel!
    @IBOutlet var myTextField: UITextView!
    @IBOutlet var tableView: UITableView!
    var messages = [AllMessageModel]()
    var lastMessage: LastMessageModel?
    var callUUID = ""
    var mInfo = [String : String]()
    var businessModel : BusinessModel?
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        guard let lastMessage = lastMessage else {
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
            return
        }

        guard UserModel.data != nil else {
            DispatchQueue.main.async {
                self.logoutPlease()
            }
            return
        }

        self.mProfile.makeRounded()

        self.mProfile.setImage(
            imageKey: lastMessage.senderImage,
            placeholder: "profile-placeholder",
            width: 100,
            height: 100,
            shouldShowAnimationPlaceholder: true
        )

        self.mName.text = lastMessage.senderName ?? "Error".localized()

        self.videoCallBtn.layer.cornerRadius = 8
        self.videoCallBtn.dropShadow()
        self.videoCallBtn.isUserInteractionEnabled = true
        self.videoCallBtn.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.videoCallBtnClicked)
        ))

        self.backView.layer.cornerRadius = 8
        self.backView.dropShadow()
        self.backView.isUserInteractionEnabled = true
        self.backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backBtnPressed)))


        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 300
        self.tableView.showsVerticalScrollIndicator = false
        
        self.myTextField.sizeToFit()
        self.myTextField.isScrollEnabled = false
        self.myTextField.delegate = self
        self.myTextField.layer.cornerRadius = 8

        self.myTextField.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        self.userImageAndName.isUserInteractionEnabled = true
        self.userImageAndName.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.userProfileClikced)
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
        
        if let businessModel = businessModel {
            mInfo["fullName"] = businessModel.name
            mInfo["profilePic"] = businessModel.profilePicture
            mInfo["deviceToken"] = businessModel.deviceToken
            mInfo["uid"] = businessModel.businessId
            mInfo["isBusiness"] = "true"
           
        }
        else {
            mInfo["fullName"] = UserModel.data!.fullName
            mInfo["profilePic"] = UserModel.data!.profilePic
            mInfo["deviceToken"] = UserModel.data!.deviceToken
            mInfo["uid"] = FirebaseStoreManager.auth.currentUser!.uid
            mInfo["isBusiness"] = "false"
            
          
        }
        self.loadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            self.moveToBottom()
        }
    }

    @objc func userProfileClikced() {
        self.viewUserProfile()
    }

    @objc func videoCallBtnClicked() {
        ProgressHUDShow(text: "")
        generateAgoraToken(friendUid: self.lastMessage!.senderUid ?? "123") { token in

            DispatchQueue.main.async {
                self.ProgressHUDHide()
                self.callUUID = UUID().uuidString
                self.sendVOIPNotification(
                    deviceToken: self.lastMessage!.senderDeviceToken ?? "123",
                    name: self.mInfo["fullName"] ?? "123",
                    channelName: self.lastMessage!.senderUid ?? "",
                    token: token,
                    callEnd: false,
                    callUUID: self.callUUID
                ) { _, error in
                    if let error = error {
                        print(error)
                    }
                }
                self.sendMessage(sMessage: "📞 VIDEO CALL")
                self.performSegue(withIdentifier: "videoCallSeg", sender: token)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "videoCallSeg" {
            if let VC = segue.destination as? VideoCallViewController {
                if let token = sender as? String {
                    VC.token = token
                    VC.callUUID = self.callUUID
                    VC.admin = true
                    VC.deviceToken = self.lastMessage!.senderDeviceToken
                    VC.channelName = self.lastMessage!.senderUid ?? "123"
                }
            }
        } else if segue.identifier == "chatViewUserProfileSeg" {
            if let VC = segue.destination as? ViewUserProfileController {
                if let user = sender as? UserModel {
                    VC.user = user
                }
            }
        }
        else if segue.identifier == "businessProfileSeg" {
            if let VC = segue.destination as? ShowBusinessProfileViewController {
                if let businessModel = sender as? BusinessModel {
                    VC.businessModel = businessModel
                }
            }
        }
    }

    @objc func moreBtnClicked() {
        var alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if UIDevice.current.userInterfaceIdiom == .pad {
            alert = UIAlertController(
                title: "Do you want to report & block this user?".localized(),
                message: nil,
                preferredStyle: .alert
            )
        }

        alert.addAction(UIAlertAction(title: "Block this user".localized(), style: .default, handler: { _ in
            self.showSnack(messages: "User has been blocked.".localized())
        }))

        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
    }

    func sendMessage(sMessage: String) {
        let messageID = FirebaseStoreManager.db.collection(Collections.chats.rawValue).document().documentID

        FirebaseStoreManager.db.collection(Collections.chats.rawValue).document(self.mInfo["uid"]!)
            .collection(self.lastMessage!.senderUid!).document(messageID)
            .setData([
                "message": sMessage,
                "senderUid": self.mInfo["uid"]!,
                "messageId": messageID,
                "isBusiness": self.mInfo["isBusiness"]! == "true" ? true : false,
                "date": FieldValue.serverTimestamp()
                
                
                
            ]) { error in

                if let error = error {
                    self.showError(error.localizedDescription)
                } else {
                    FirebaseStoreManager.db.collection(Collections.chats.rawValue).document(self.lastMessage!.senderUid!)
                        .collection(self.mInfo["uid"]!).document(messageID)
                        .setData([
                            "message": sMessage,
                            "senderUid": self.mInfo["uid"]!,
                            "messageId": messageID,
                            "isBusiness": self.mInfo["isBusiness"]! == "true" ? true : false,
                            "date": FieldValue.serverTimestamp()
                        ])

                    FirebaseStoreManager.db.collection(Collections.chats.rawValue).document(self.mInfo["uid"]!)
                        .collection(Collections.lastMessage.rawValue).document(self.lastMessage!.senderUid!)
                        .setData([
                            "message": sMessage,
                            "senderUid": self.lastMessage!.senderUid!,
                            "isRead": true,
                            "isBusiness": self.lastMessage!.isBusiness ?? false,
                            "senderImage": self.lastMessage!.senderImage ?? "",
                            "senderName": self.lastMessage!.senderName!,
                            "date": FieldValue.serverTimestamp(),
                            "senderDeviceToken": self.lastMessage!.senderDeviceToken ?? ""
                        ])

                    FirebaseStoreManager.db.collection(Collections.chats.rawValue).document(self.lastMessage!.senderUid!)
                        .collection(Collections.lastMessage.rawValue).document(self.mInfo["uid"]!)
                        .setData([
                            "message": sMessage,
                            "senderUid": self.mInfo["uid"]!,
                            "isRead": false,
                            "senderName": self.mInfo["fullName"] ?? "Error",
                            "date": FieldValue.serverTimestamp(),
                            "senderImage": self.mInfo["profilePic"] ?? "",
                            "isBusiness": self.mInfo["isBusiness"]! == "true" ? true : false,
                            "senderDeviceToken": self.mInfo["deviceToken"] ?? ""
                        ])

                    if !sMessage.contains("📞 VIDEO CALL") {
                        PushNotificationSender().sendPushNotification(
                            title:self.mInfo["fullName"] ?? "Error",
                            body: sMessage,
                            topic: self.lastMessage!.senderToken ?? ""
                        )
                    }
                }
            }
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func moveToBottom() {
        if !self.messages.isEmpty {
            let indexPath = IndexPath(row: messages.count - 1, section: 0)

            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }

    @objc func keyboardWillShow(notify: NSNotification) {
        if let keyboardSize = (notify.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.bottomConst.constant = keyboardSize.height - view.safeAreaFrame
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc func keyboardWillHide(notify _: NSNotification) {
        self.bottomConst.constant = 0
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }

        self.moveToBottom()
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc func backBtnPressed() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func sendMessageClick(_: Any) {
        let mMessage = self.myTextField.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if mMessage != "" {
            self.myTextField.text = ""
            self.sendMessage(sMessage: mMessage)
        }
    }

    @objc func cellImageClicked() {
        self.viewUserProfile()
    }

    func viewUserProfile() {
        ProgressHUDShow(text: "")
        if let isBusiness = self.lastMessage!.isBusiness, isBusiness {
            getBusinesses(by: self.lastMessage!.senderUid ?? "123") { businessModel, error in
                self.ProgressHUDHide()
                if let businessModel = businessModel {
                    self.performSegue(withIdentifier: "businessProfileSeg", sender: businessModel)
                }
            }
        }
        else {
            getUserDataByID(uid: self.lastMessage!.senderUid ?? "123") { userModel, _ in
                self.ProgressHUDHide()
                if let userModel = userModel {
                    self.performSegue(withIdentifier: "chatViewUserProfileSeg", sender: userModel)
                }
            }
        }
    }

    func loadData() {
        ProgressHUDShow(text: "Loading...".localized())
        guard let friendUid = lastMessage!.senderUid else {
            dismiss(animated: true, completion: nil)
            return
        }
        FirebaseStoreManager.db.collection(Collections.chats.rawValue).document(self.mInfo["uid"]!)
            .collection(friendUid).order(by: "date").addSnapshotListener { snapshot, error in
                self.ProgressHUDHide()
                if error == nil {
                    self.messages.removeAll()
                    if let snapshot = snapshot {
                        for snap in snapshot.documents {
                            if let message = try? snap.data(as: AllMessageModel.self) {
                                self.messages.append(message)
                            }
                        }
                    }
                    self.tableView.reloadData()
                    self.moveToBottom()
                } else {
                    self.showError(error!.localizedDescription)
                }
            }
    }

    func tableView(_: UITableView, estimatedHeightForRowAt _: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        self.messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "messagecell", for: indexPath) as? MessagesCell {
            let message = self.messages[indexPath.row]
            cell.config(
                message: message,
                senderName: self.lastMessage!.senderName ?? "123",
                uid: self.mInfo["uid"]!,
                image: self.lastMessage!.senderImage ?? ""
            )

            cell.myimage.isUserInteractionEnabled = true
            cell.myimage.addGestureRecognizer(UITapGestureRecognizer(
                target: self,
                action: #selector(self.cellImageClicked)
            ))
            return cell
        }

        return MessagesCell()
    }

    override func viewWillAppear(_: Bool) {
        IQKeyboardManager.shared.enable = false
    }

    override func viewWillDisappear(_: Bool) {
        IQKeyboardManager.shared.enable = true
    }
}
