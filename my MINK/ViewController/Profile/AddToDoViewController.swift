//
//  AddToDoViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 06/02/24.
//

import UIKit

class AddToDoViewController : UIViewController {
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var addTaskBtn: UIButton!
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var calendarView: UIDatePicker!
    override func viewDidLoad() {
        
        addTaskBtn.layer.cornerRadius = 8
        
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        calendarView.minimumDate = Date()
    }
    
    @IBAction func addTaskClicked(_ sender: Any) {
        let sTitle = titleTF.text
        if sTitle == "" {
            self.showSnack(messages: "Enter Title")
        }
        else {
            let todoModel = ToDoModel()
            todoModel.id = FirebaseStoreManager.db.collection(Collections.TASKS.rawValue).document().documentID
            
            todoModel.title = sTitle
            todoModel.date = calendarView.date
            todoModel.isFinished = false
            todoModel.uid = FirebaseStoreManager.auth.currentUser!.uid
            
            ProgressHUDShow(text: "Adding Task...")
            try? FirebaseStoreManager.db.collection(Collections.TASKS.rawValue).document(todoModel.id!).setData(from: todoModel,completion: { error in
                self.ProgressHUDHide()
                if let error = error {
                    self.showError(error.localizedDescription)
                }
                else {
                    
                    self.showSnack(messages: "Task Added")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
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
