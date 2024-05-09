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

class MyMinkBotViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
   
    @IBOutlet var bottomConst: NSLayoutConstraint!
    @IBOutlet var backView: UIView!
    @IBOutlet var myTextField: UITextView!
    @IBOutlet var tableView: UITableView!
    var messages = [AllMessageModel]()
    var lastMessage: LastMessageModel?
   
    override func viewDidLoad() {
        super.viewDidLoad()

     

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

       

        self.loadData()

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

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            self.moveToBottom()
        }
    }

 

    func sendMessage(sMessage: String) {
        let messageID = FirebaseStoreManager.db.collection("Chats").document().documentID

        self.ProgressHUDShow(text: "")
        self.getResponseFromChatbot(question: sMessage) { chatCompletion, error in
           
            DispatchQueue.main.async {
                if let error = error {
                    self.ProgressHUDHide()
                    self.showError(error)
                }
                else {
                    FirebaseStoreManager.db.collection("Chats").document(FirebaseStoreManager.auth.currentUser!.uid)
                        .collection("bot").document(chatCompletion!.id)
                        .setData([
                            "message": chatCompletion!.choices.first!.message.content,
                            "senderUid": "bot",
                            "messageId": chatCompletion!.id,
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
        
        FirebaseStoreManager.db.collection("Chats").document(FirebaseStoreManager.auth.currentUser!.uid)
            .collection("bot").document(messageID)
            .setData([
                "message": sMessage,
                "senderUid": FirebaseStoreManager.auth.currentUser!.uid,
                "messageId": messageID,
                "date": FieldValue.serverTimestamp()
            ]) { error in

                if let error = error {
                    self.showError(error.localizedDescription)
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

  

  
    func loadData() {
        ProgressHUDShow(text: "Loading...")
      
        FirebaseStoreManager.db.collection("Chats").document(FirebaseStoreManager.auth.currentUser!.uid)
            .collection("bot").order(by: "date").addSnapshotListener { snapshot, error in
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
