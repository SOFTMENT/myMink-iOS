//
//  UpdateToDoViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 08/02/24.
//

import UIKit

class UpdateToDoViewController : UIViewController {
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var deleteBtn: UIView!
    @IBOutlet weak var addTaskBtn: UIButton!
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var calendarView: UIDatePicker!
    var todoModel : ToDoModel?
    override func viewDidLoad() {
 
        guard let todoModel = todoModel else {
            
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
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
    
    @objc func deleteBtnClicked(){
        let alert = UIAlertController(title: "DELETE", message: "Are you sure you want to delete this task.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "DELETE", style: .destructive, handler: { action in
            
            self.ProgressHUDShow(text: "Deleting...")
            FirebaseStoreManager.db.collection(Collections.TASKS.rawValue).document(self.todoModel!.id!).delete { error in
                self.ProgressHUDHide()
                if let error = error {
                    self.showError(error.localizedDescription)
                }
                else {
                
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
        let sTitle = titleTF.text
        if sTitle == "" {
            self.showSnack(messages: "Enter Title")
        }
        else {
          
         
            
            self.todoModel!.title = sTitle
            self.todoModel!.date = calendarView.date
            
            ProgressHUDShow(text: "Updating Task...")
            try? FirebaseStoreManager.db.collection(Collections.TASKS.rawValue).document(self.todoModel!.id!).setData(from: todoModel,merge : true,completion: { error in
                self.ProgressHUDHide()
                if let error = error {
                    self.showError(error.localizedDescription)
                }
                else {
                    
                    self.showSnack(messages: "Task Updated")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self.dismiss(animated: true)
                    }
                }
            })
        }
    }
    
    @objc func backViewClicked(){
        self.dismiss(animated: true)
    }
    
   
}
