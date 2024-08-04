//
//  MyMinkBotViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 22/02/24.
//

import Firebase
import IQKeyboardManagerSwift
import UIKit
import FirebaseFirestore

class MyMinkBotViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
   
    @IBOutlet var bottomConst: NSLayoutConstraint!
    @IBOutlet var backView: UIView!
    @IBOutlet var myTextField: UITextView!
    @IBOutlet var tableView: UITableView!
    
    var messages = [AllMessageModel]()
    var lastMessage: LastMessageModel?
   
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupObservers()
        loadData()

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            self.moveToBottom()
        }
    }

    private func setupUI() {
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnPressed)))

        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
        tableView.showsVerticalScrollIndicator = false

        myTextField.sizeToFit()
        myTextField.isScrollEnabled = false
        myTextField.delegate = self
        myTextField.layer.cornerRadius = 8
        myTextField.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }

    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    private func loadData() {
        ProgressHUDShow(text: "Loading...")

        guard let currentUserUID = FirebaseStoreManager.auth.currentUser?.uid else {
            self.ProgressHUDHide()
            self.showError("User not logged in.")
            return
        }

        FirebaseStoreManager.db.collection(Collections.chats.rawValue).document(currentUserUID)
            .collection(Collections.bot.rawValue).order(by: "date").addSnapshotListener { snapshot, error in
                self.ProgressHUDHide()
                if let error = error {
                    self.showError(error.localizedDescription)
                } else {
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
                }
            }
    }

    private func sendMessage(sMessage: String) {
        guard let currentUserUID = FirebaseStoreManager.auth.currentUser?.uid else {
            self.showError("User not logged in.")
            return
        }

        let messageID = FirebaseStoreManager.db.collection(Collections.chats.rawValue).document().documentID

        self.ProgressHUDShow(text: "")
        self.getResponseFromChatbot(question: sMessage) { chatCompletion, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.ProgressHUDHide()
                    self.showError(error)
                } else {
                    guard let chatCompletion = chatCompletion, let chatMessage = chatCompletion.choices.first?.message.content else {
                        self.ProgressHUDHide()
                        self.showError("Failed to get chat response.")
                        return
                    }

                    FirebaseStoreManager.db.collection(Collections.chats.rawValue).document(currentUserUID)
                        .collection(Collections.bot.rawValue).document(chatCompletion.id)
                        .setData([
                            "message": chatMessage,
                            "senderUid": "bot",
                            "messageId": chatCompletion.id,
                            "date": FieldValue.serverTimestamp()
                        ]) { error in
                            self.ProgressHUDHide()
                            if let error = error {
                                self.showError(error.localizedDescription)
                            }
                        }
                }
            }
        }

        FirebaseStoreManager.db.collection(Collections.chats.rawValue).document(currentUserUID)
            .collection(Collections.bot.rawValue).document(messageID)
            .setData([
                "message": sMessage,
                "senderUid": currentUserUID,
                "messageId": messageID,
                "date": FieldValue.serverTimestamp()
            ]) { error in
                if let error = error {
                    self.showError(error.localizedDescription)
                }
            }
    }

    private func moveToBottom() {
        if !messages.isEmpty {
            let indexPath = IndexPath(row: messages.count - 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }

    @objc private func keyboardWillShow(notify: NSNotification) {
        if let keyboardSize = (notify.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            bottomConst.constant = keyboardSize.height - view.safeAreaInsets.bottom
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc private func keyboardWillHide(notify _: NSNotification) {
        bottomConst.constant = 0
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        moveToBottom()
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func backBtnPressed() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func sendMessageClick(_: Any) {
        let mMessage = myTextField.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if !mMessage.isEmpty {
            myTextField.text = ""
            sendMessage(sMessage: mMessage)
        }
    }

    func tableView(_: UITableView, estimatedHeightForRowAt _: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "messagecell", for: indexPath) as? MessagesCell {
            let message = messages[indexPath.row]
            cell.config(
                message: message,
                senderName: "my MINK Chatbot",
                uid: FirebaseStoreManager.auth.currentUser!.uid,
                image: ""
            )
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
