//
//  ToDoDashboardViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 06/02/24.
//

import UIKit

class ToDoDashboardViewController : UIViewController {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var addView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var noTasksAvailable: UILabel!
    var todoModels = Array<ToDoModel>()
    var fromOnBoard = false
    override func viewDidLoad() {
        
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        addView.layer.cornerRadius = 8
        addView.dropShadow()
        addView.isUserInteractionEnabled = true
        addView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addViewClicked)))
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.ProgressHUDShow(text: "")
        getMyToDo(uid: FirebaseStoreManager.auth.currentUser!.uid) { todoModels, error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error)
            }
            else {
                self.todoModels.removeAll()
                self.todoModels.append(contentsOf: todoModels ?? [])
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func addViewClicked(){
        performSegue(withIdentifier: "addTaskSeg", sender: nil)
    }
    
    @objc func backViewClicked(){
        if fromOnBoard {
            Constants.selectedTabbarPosition = 6
            self.beRootScreen(storyBoardName: StoryBoard.Tabbar, mIdentifier: Identifier.TABBARVIEWCONTROLLER)
        }
        else {
            self.dismiss(animated: true)
        }
    }
    
    @objc func todoCheckClicked(value : MyGesture){
        value.todoCell.todoCheck.isSelected = !value.todoCell.todoCheck.isSelected
        let todoModel = todoModels[value.index]
        FirebaseStoreManager.db.collection(Collections.TASKS.rawValue).document(todoModel.id!).setData(["isFinished" : value.todoCell.todoCheck.isSelected],merge: true)
       
        if value.todoCell.isSelected {
            applyStrikethroughEffect(to: value.todoCell.todoTitle)
            value.todoCell.todoDue.isHidden = true
        }
        else {
            removeStrikethroughEffect(from: value.todoCell.todoTitle)
            value.todoCell.todoDue.isHidden = false
        }
    }
    
    @objc func cellClicked(value : MyGesture){
        performSegue(withIdentifier: "updateTaskSeg", sender: todoModels[value.index])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "updateTaskSeg" {
            if let VC = segue.destination as? UpdateToDoViewController {
                if let todoModel = sender as? ToDoModel {
                    VC.todoModel = todoModel
                }
            }
        }
    }
    
}

extension ToDoDashboardViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noTasksAvailable.isHidden  = self.todoModels.count > 0 ? true : false
        return todoModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath) as? TodoTableViewCell {
            
            cell.todoView.dropShadow()
            cell.todoView.layer.cornerRadius = 8
            
            let todoModel = todoModels[indexPath.row]
            cell.todoTitle.text = todoModel.title ?? ""
            cell.todoTime.text = self.convertDateIntoTime(todoModel.date ?? Date())
            cell.todoDue.text = self.dueDateString(for: todoModel.date ?? Date())
            cell.todoCheck.isSelected = todoModel.isFinished ?? false
            if let isFinished = todoModel.isFinished, isFinished {
                applyStrikethroughEffect(to: cell.todoTitle)
                cell.todoDue.isHidden = true
            }
            else {
                removeStrikethroughEffect(from: cell.todoTime)
                cell.todoDue.isHidden = false
            }
            
            cell.todoCheck.isUserInteractionEnabled = true
            let checkGest = MyGesture(target: self, action: #selector(todoCheckClicked))
            checkGest.index = indexPath.row
            checkGest.todoCell = cell
            cell.todoCheck.addGestureRecognizer(checkGest)
            
            cell.todoView.isUserInteractionEnabled = true
            let cellGest = MyGesture(target: self, action: #selector(cellClicked(value:)))
            cellGest.index = indexPath.row
            cell.addGestureRecognizer(cellGest)
            
            
            
            return cell
        }
        
        return TodoTableViewCell()
    }
    
    
    
}
