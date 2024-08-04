//
//  AddToDoViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 06/02/24.
//

import UIKit

class AddToDoViewController: UIViewController {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var addTaskBtn: UIButton!
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var calendarView: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        addTaskBtn.layer.cornerRadius = 8
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        calendarView.minimumDate = Date()
    }
    
    @IBAction func addTaskClicked(_ sender: Any) {
        guard let sTitle = titleTF.text, !sTitle.isEmpty else {
            self.showSnack(messages: "Enter Title")
            return
        }
        
        guard let currentUser = FirebaseStoreManager.auth.currentUser else {
            self.showSnack(messages: "User not logged in")
            return
        }
        
        let todoModel = ToDoModel()
        todoModel.id = FirebaseStoreManager.db.collection(Collections.tasks.rawValue).document().documentID
        todoModel.title = sTitle
        todoModel.date = calendarView.date
        todoModel.isFinished = false
        todoModel.uid = currentUser.uid
        
        ProgressHUDShow(text: "Adding Task...")
        try? FirebaseStoreManager.db.collection(Collections.tasks.rawValue).document(todoModel.id!).setData(from: todoModel, completion: { error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error.localizedDescription)
            } else {
                self.showSnack(messages: "Task Added")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.dismiss(animated: true)
                }
            }
        })
    }
    
    @objc func backViewClicked() {
        self.dismiss(animated: true)
    }
}
