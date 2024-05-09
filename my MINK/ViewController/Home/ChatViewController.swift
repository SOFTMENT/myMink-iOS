// Copyright © 2023 SOFTMENT. All rights reserved.

import UIKit

// MARK: - ChatFilter

enum ChatFilter {
    case ALL
    case UNREAD
}

// MARK: - ChatViewController

class ChatViewController: UIViewController {
    @IBOutlet var searchTF: UITextField!
    @IBOutlet var no_chats_available: UILabel!
    @IBOutlet var tableView: UITableView!
    var lastMessages = [LastMessageModel]()
    @IBOutlet var filter: UIStackView!
    @IBOutlet var backView: UIView!
    @IBOutlet var filterLabel: UILabel!
    var businessModel : BusinessModel?
    override func viewDidLoad() {
        guard FirebaseStoreManager.auth.currentUser != nil && UserModel.data != nil else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        self.searchTF.layer.cornerRadius = 8
        self.searchTF.setLeftPaddingPoints(16)
        self.searchTF.setRightPaddingPoints(10)
        self.searchTF.setLeftIcons(icon: UIImage(systemName: "magnifyingglass")!)

        self.tableView.delegate = self
        self.tableView.dataSource = self

        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.keyboardHide)))

        // getAllLastMessages
        self.getAllLastMessages()

        // BackView
        self.backView.dropShadow()
        self.backView.layer.cornerRadius = 8
        self.backView.isUserInteractionEnabled = true
        self.backView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.backViewClicked)
        ))

        // FilterClicked
        self.filter.layer.cornerRadius = 8
        self.filter.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.filterClicked)))
    }

    @objc func filterClicked() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "All", style: .default, handler: { _ in
            self.filterLabel.text = "All"
        }))

        alert.addAction(UIAlertAction(title: "Unread", style: .default, handler: { _ in
            self.filterLabel.text = "Unread"
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    @objc func backViewClicked() {
        dismiss(animated: true)
    }

    @objc func lastMessageBtnClicked(value: MyGesture) {
        let lastmessage = self.lastMessages[value.index]
        performSegue(withIdentifier: "chatHome_ChatScreenSeg", sender: lastmessage)
    }

    @objc func keyboardHide() {
        view.endEditing(true)
    }

  

    func getAllLastMessages() {
        
        var uid = FirebaseStoreManager.auth.currentUser!.uid
        
        if let businessModel = businessModel {
            uid = businessModel.businessId ?? "123"
        }
        
        FirebaseStoreManager.db.collection("Chats").document(uid)
            .collection("LastMessage").order(by: "date", descending: true).addSnapshotListener { snapshot, error in
                self.ProgressHUDHide()
                if error == nil {
                    self.lastMessages.removeAll()
                    if let snapshot = snapshot, !snapshot.isEmpty {
                        for qds in snapshot.documents {
                            if let lastMessage = try? qds.data(as: LastMessageModel.self) {
                                self.lastMessages.append(lastMessage)
                            }
                        }
                    }
                    self.tableView.reloadData()
                }
            }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chatHome_ChatScreenSeg" {
            if let destinationVC = segue.destination as? ShowChatViewController {
                if let lastMessage = sender as? LastMessageModel {
                    destinationVC.lastMessage = lastMessage
                    destinationVC.businessModel = businessModel
                }
            }
        }
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        if !self.lastMessages.isEmpty {
            self.no_chats_available.isHidden = true
        } else {
            self.no_chats_available.isHidden = false
        }
        return self.lastMessages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(
            withIdentifier: "homechat",
            for: indexPath
        ) as? HomeChatTableViewCell {
            let lastMessage = self.lastMessages[indexPath.row]

            cell.mImage.makeRounded()
            cell.mImage.image = nil
            cell.mImage.layer.borderWidth = 1
            cell.mImage.layer.borderColor = UIColor.lightGray.cgColor
            if lastMessage.isRead ?? false {
                cell.mView.layer.borderWidth = 1
                cell.mView.layer.borderColor = UIColor.lightGray.cgColor
            } else {
                cell.mView.layer.borderWidth = 1
                cell.mView.layer.borderColor = UIColor(red: 189 / 255, green: 25 / 255, blue: 30 / 255, alpha: 1)
                    .cgColor
            }

            cell.mView.layer.cornerRadius = 8

            if let isBusiness = lastMessage.isBusiness, isBusiness {
                getBusinesses(by: lastMessage.senderUid ?? "123") { businessModel, error in
                    if let businessModel = businessModel {
                        if let index = self.lastMessages.firstIndex(of: lastMessage) {
                            self.lastMessages[index].senderDeviceToken = businessModel.deviceToken
                        }
                        if let image = businessModel.profilePicture {
                            if image != "" {
                                cell.mImage.setImage(
                                    imageKey: image,
                                    placeholder: "profile-placeholder",
                                    width: 80,
                                    height: 80,
                                    shouldShowAnimationPlaceholder: true
                                )
                            } else {
                                cell.mImage.image = UIImage(named: "profile-placeholder")
                            }
                        } else {
                            cell.mImage.image = UIImage(named: "profile-placeholder")
                        }

                        cell.mTitle.text = businessModel.name ?? "Something went wrong"
                    } else {
                        self.deleteLastMessage(uid: lastMessage.senderUid ?? "123", otherUid: lastMessage.senderUid ?? "123")
                    }
                    
                    
                }
            }
            else {
                getUserDataByID(uid: lastMessage.senderUid ?? "123") { userModel, _ in
                    if let userModel = userModel {
                        if let index = self.lastMessages.firstIndex(of: lastMessage) {
                            self.lastMessages[index].senderDeviceToken = userModel.deviceToken
                        }

                        if let image = userModel.profilePic {
                            if image != "" {
                                cell.mImage.setImage(
                                    imageKey: image,
                                    placeholder: "profile-placeholder",
                                    width: 80,
                                    height: 80,
                                    shouldShowAnimationPlaceholder: true
                                )
                            } else {
                                cell.mImage.image = UIImage(named: "profile-placeholder")
                            }
                        } else {
                            cell.mImage.image = UIImage(named: "profile-placeholder")
                        }

                        cell.mTitle.text = userModel.fullName ?? "Something went wrong"
                    } else {
                        self.deleteLastMessage(uid: FirebaseStoreManager.auth.currentUser!.uid, otherUid: lastMessage.senderUid ?? "123")
                    }
                }
            }
            

            cell.mLastMessage.text = lastMessage.message
            if let time = lastMessage.date {
                cell.mTime.text = time.timeAgoSinceDate()
            }

            cell.mView.isUserInteractionEnabled = true

            let lastMessageTap = MyGesture(target: self, action: #selector(self.lastMessageBtnClicked(value:)))
            lastMessageTap.index = indexPath.row
            cell.mView.addGestureRecognizer(lastMessageTap)

            return cell
        }

        return HomeChatTableViewCell()
    }
}
