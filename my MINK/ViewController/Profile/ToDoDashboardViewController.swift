//
//  ToDoDashboardViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 06/02/24.
//

import UIKit

class ToDoDashboardViewController: UIViewController {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var addView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noTasksAvailable: UILabel!
    
    var todoModels = [ToDoModel]()
    var fromOnBoard = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchData()
    }
    
    private func setupUI() {
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
    }
    
    private func fetchData() {
        guard let currentUser = FirebaseStoreManager.auth.currentUser else {
            return
        }
        
        ProgressHUDShow(text: "")
        getMyToDo(uid: currentUser.uid) { [weak self] todoModels, error in
            guard let self = self else { return }
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error)
            } else {
                self.todoModels = todoModels ?? []
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func addViewClicked() {
        performSegue(withIdentifier: "addTaskSeg", sender: nil)
    }
    
    @objc func backViewClicked() {
        if fromOnBoard {
            Constants.selectedTabBarPosition = 6
            self.beRootScreen(storyBoardName: StoryBoard.tabBar, mIdentifier: Identifier.tabBarViewController)
        } else {
            dismiss(animated: true)
        }
    }
    
    @objc func todoCheckClicked(value: MyGesture) {
        guard let todoModel = todoModels[safe: value.index] else { return }
        value.todoCell.todoCheck.isSelected.toggle()
        
        FirebaseStoreManager.db.collection(Collections.tasks.rawValue)
            .document(todoModel.id ?? "")
            .setData(["isFinished": value.todoCell.todoCheck.isSelected], merge: true)
        
        if value.todoCell.todoCheck.isSelected {
            applyStrikethroughEffect(to: value.todoCell.todoTitle)
            value.todoCell.todoDue.isHidden = true
        } else {
            removeStrikethroughEffect(from: value.todoCell.todoTitle)
            value.todoCell.todoDue.isHidden = false
        }
    }
    
    @objc func cellClicked(value: MyGesture) {
        guard let todoModel = todoModels[safe: value.index] else { return }
        performSegue(withIdentifier: "updateTaskSeg", sender: todoModel)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "updateTaskSeg",
           let VC = segue.destination as? UpdateToDoViewController,
           let todoModel = sender as? ToDoModel {
            VC.todoModel = todoModel
        }
    }
}

extension ToDoDashboardViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noTasksAvailable.isHidden = !todoModels.isEmpty
        return todoModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath) as? TodoTableViewCell,
              let todoModel = todoModels[safe: indexPath.row] else {
            return TodoTableViewCell()
        }
        
        cell.todoView.dropShadow()
        cell.todoView.layer.cornerRadius = 8
        
        cell.todoTitle.text = todoModel.title ?? ""
        cell.todoTime.text = convertDateIntoTime(todoModel.date ?? Date())
        cell.todoDue.text = dueDateString(for: todoModel.date ?? Date())
        cell.todoCheck.isSelected = todoModel.isFinished ?? false
        
        if let isFinished = todoModel.isFinished, isFinished {
            applyStrikethroughEffect(to: cell.todoTitle)
            cell.todoDue.isHidden = true
        } else {
            removeStrikethroughEffect(from: cell.todoTitle)
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
}
