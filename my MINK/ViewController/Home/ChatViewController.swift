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
    var useLastMessages = [LastMessageModel]()
    @IBOutlet var filter: UIStackView!
    @IBOutlet var backView: UIView!
    @IBOutlet var filterLabel: UILabel!
    var businessModel: BusinessModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard  FirebaseStoreManager.auth.currentUser != nil,  let _ = UserModel.data else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }

        setupViews()
        getAllLastMessages()
    }

    private func setupViews() {
        searchTF.delegate = self
        searchTF.layer.cornerRadius = 8
        searchTF.setLeftPaddingPoints(16)
        searchTF.setRightPaddingPoints(10)
        searchTF.setLeftIcons(icon: UIImage(systemName: "magnifyingglass")!)

        tableView.delegate = self
        tableView.dataSource = self

        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(keyboardHide)))

        backView.dropShadow()
        backView.layer.cornerRadius = 8
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))

        filter.layer.cornerRadius = 8
        filter.isUserInteractionEnabled = true
        filter.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(filterClicked)))
    }

    @objc private func filterClicked() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "All".localized(), style: .default, handler: { _ in
            self.filterLabel.text = "All".localized()
        }))
        alert.addAction(UIAlertAction(title: "Unread".localized(), style: .default, handler: { _ in
            self.filterLabel.text = "Unread".localized()
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        present(alert, animated: true)
    }

    @objc private func backViewClicked() {
        dismiss(animated: true)
    }

    @objc private func lastMessageBtnClicked(value: MyGesture) {
        let lastmessage = self.useLastMessages[value.index]
        
        performSegue(withIdentifier: "chatHome_ChatScreenSeg", sender: lastmessage)
    }

    @objc private func keyboardHide() {
        view.endEditing(true)
    }

    private func getAllLastMessages() {
        guard var uid = FirebaseStoreManager.auth.currentUser?.uid else { return }
        if let businessModel = businessModel {
            guard let businessID = businessModel.businessId else { return }
            uid = businessID
        }

        FirebaseStoreManager.db.collection(Collections.chats.rawValue).document(uid)
            .collection(Collections.lastMessage.rawValue).order(by: "date", descending: true).addSnapshotListener { snapshot, error in
                self.ProgressHUDHide()
                if error == nil {
                    self.lastMessages.removeAll()
                    self.useLastMessages.removeAll()
                    if let snapshot = snapshot, !snapshot.isEmpty {
                        for qds in snapshot.documents {
                            if let lastMessage = try? qds.data(as: LastMessageModel.self) {
                                self.lastMessages.append(lastMessage)
                                self.useLastMessages.append(lastMessage)
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
        no_chats_available.isHidden = !useLastMessages.isEmpty
        return useLastMessages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "homechat", for: indexPath) as? HomeChatTableViewCell else {
            return HomeChatTableViewCell()
        }

        let lastMessage = useLastMessages[indexPath.row]

        cell.mImage.makeRounded()
        cell.mImage.layer.borderWidth = 1
        cell.mImage.layer.borderColor = UIColor.lightGray.cgColor
        cell.mView.layer.borderWidth = 1
        cell.mView.layer.cornerRadius = 8
        cell.mView.layer.borderColor = (lastMessage.isRead ?? false) ? UIColor.lightGray.cgColor : UIColor(red: 189 / 255, green: 25 / 255, blue: 30 / 255, alpha: 1).cgColor

        if lastMessage.isBusiness == true {
            guard let senderUid = lastMessage.senderUid else { return cell }
            getBusinesses(by: senderUid) { businessModel, _ in
                self.configureCell(cell, with: businessModel, lastMessage: lastMessage)
            }
        } else {
            guard let senderUid = lastMessage.senderUid else { return cell }
            getUserDataByID(uid: senderUid) { userModel, _ in
                self.configureCell(cell, with: userModel, lastMessage: lastMessage)
            }
        }

        cell.mLastMessage.text = lastMessage.message
        cell.mTime.text = lastMessage.date?.timeAgoSinceDate()

        cell.mView.isUserInteractionEnabled = true
        let lastMessageTap = MyGesture(target: self, action: #selector(lastMessageBtnClicked(value:)))
        lastMessageTap.index = indexPath.row
        cell.mView.addGestureRecognizer(lastMessageTap)

        return cell
    }

    private func configureCell(_ cell: HomeChatTableViewCell, with model: Any?, lastMessage: LastMessageModel) {
        guard let senderUid = lastMessage.senderUid else { return }

        if let businessModel = model as? BusinessModel {
            if let index = useLastMessages.firstIndex(of: lastMessage) {
                useLastMessages[index].senderDeviceToken = businessModel.deviceToken
            }
            if let image = businessModel.profilePicture, !image.isEmpty {
                cell.mImage.setImage(imageKey: image, placeholder: "profile-placeholder", width: 80, height: 80, shouldShowAnimationPlaceholder: true)
            } else {
                cell.mImage.image = UIImage(named: "profile-placeholder")
            }
            cell.mTitle.text = businessModel.name ?? "Something went wrong".localized()
        } else if let userModel = model as? UserModel {
            if let index = useLastMessages.firstIndex(of: lastMessage) {
               useLastMessages[index].senderDeviceToken = userModel.deviceToken
            }
            if let image = userModel.profilePic, !image.isEmpty {
                cell.mImage.setImage(imageKey: image, placeholder: "profile-placeholder", width: 80, height: 80, shouldShowAnimationPlaceholder: true)
            } else {
                cell.mImage.image = UIImage(named: "profile-placeholder")
            }
            cell.mTitle.text = userModel.fullName ?? "Something went wrong".localized()
        } else {
            deleteLastMessage(uid: FirebaseStoreManager.auth.currentUser!.uid, otherUid: senderUid)
        }
    }
}
// MARK: - UITextFieldDelegate

extension ChatViewController : UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let searchText = textField.text?.lowercased(), !searchText.isEmpty else {
            useLastMessages = lastMessages
            tableView.reloadData()
            return
        }

        useLastMessages = lastMessages.filter { message in
            let nameMatches = message.senderName?.lowercased().contains(searchText) ?? false
       
            return nameMatches
        }
        tableView.reloadData()
    }
}
