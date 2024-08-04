//
//  UpdateToDoViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 08/02/24.
//

import UIKit

class UpdateToDoViewController: UIViewController {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var deleteBtn: UIView!
    @IBOutlet weak var addTaskBtn: UIButton!
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var calendarView: UIDatePicker!
    
    var todoModel: ToDoModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let todoModel = todoModel else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        setupUI(todoModel: todoModel)
    }
    
    private func setupUI(todoModel: ToDoModel) {
        deleteBtn.isUserInteractionEnabled = true
        deleteBtn.dropShadow()
        deleteBtn.layer.cornerRadius = 8
        deleteBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deleteBtnClicked)))
        
        addTaskBtn.layer.cornerRadius = 8
        
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        calendarView.minimumDate = Date()
        calendarView.date = todoModel.date ?? Date()
        titleTF.text = todoModel.title ?? ""
    }
    
    @objc func deleteBtnClicked() {
        let alert = UIAlertController(title: "DELETE", message: "Are you sure you want to delete this task.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "DELETE", style: .destructive, handler: { action in
            self.ProgressHUDShow(text: "Deleting...")
            guard let todoId = self.todoModel?.id else {
                self.ProgressHUDHide()
                self.showError("Task ID not found.")
                return
            }
            FirebaseStoreManager.db.collection(Collections.tasks.rawValue).document(todoId).delete { error in
                self.ProgressHUDHide()
                if let error = error {
                    self.showError(error.localizedDescription)
                } else {
                    self.showSnack(messages: "Deleted")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self.dismiss(animated: true)
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @IBAction func addTaskClicked(_ sender: Any) {
        guard let sTitle = titleTF.text, !sTitle.isEmpty else {
            self.showSnack(messages: "Enter Title")
            return
        }
        
        guard var todoModel = todoModel else {
            self.showSnack(messages: "Task model not found")
            return
        }
        
        todoModel.title = sTitle
        todoModel.date = calendarView.date
        
        ProgressHUDShow(text: "Updating Task...")
        guard let todoId = todoModel.id else {
            self.ProgressHUDHide()
            self.showError("Task ID not found.")
            return
        }
        
        try? FirebaseStoreManager.db.collection(Collections.tasks.rawValue).document(todoId).setData(from: todoModel, merge: true, completion: { error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error.localizedDescription)
            } else {
                self.showSnack(messages: "Task Updated")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.dismiss(animated: true)
                }
            }
        })
    }
    
    @objc func backViewClicked() {
        self.dismiss(animated: true)
    }
}
