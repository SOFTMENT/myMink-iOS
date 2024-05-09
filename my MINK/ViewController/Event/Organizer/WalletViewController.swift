//
//  WalletViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 19/05/24.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class WalletViewController: UIViewController {

    @IBOutlet weak var no_transaction_available: UILabel!
  
    @IBOutlet weak var walletView: UIView!
    @IBOutlet weak var totalBalance: UILabel!
    @IBOutlet weak var withdrawBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var currentDate : Date = Date()
    var transactions : [Transactions] = []
    @IBOutlet weak var backView: UIView!
    
    override func viewDidLoad() {
        
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        
        walletView.layer.cornerRadius = 12
        withdrawBtn.layer.cornerRadius = 8
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 34
        tableView.rowHeight = UITableView.automaticDimension
        
        
        guard let organiser = UserModel.data else {
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
            return
        }
        
        self.getTransactions(by: FirebaseStoreManager.auth.currentUser!.uid)
    
    }
    
    @objc func backViewClicked(){
        self.dismiss(animated: true)
    }
    
    func getTransactions(by uid : String) {
        ProgressHUDShow(text: "")
        Firestore.firestore().collection("Users").document(uid).collection("Transactions").getDocuments { snapshot, error in
            self.ProgressHUDHide()
            if error == nil {
                self.transactions.removeAll()
                if let snapshot = snapshot, !snapshot.isEmpty {
                    for qdr  in snapshot.documents {
                        if let trans = try? qdr.data(as: Transactions.self) {
                            self.transactions.append(trans)
                        }
                    }
                }
                self.tableView.reloadData()
            }
            else {
                self.showError(error!.localizedDescription)
            }
            
            
        }
    }
    
    @IBAction func withdrawBtnClicked(_ sender: Any) {
    
    }
    @IBAction func backBtnClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

extension WalletViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "walletCell", for: indexPath) as? WalletTableViewCell {
            
            cell.imgBackView.layer.cornerRadius = cell.imgBackView.bounds.height / 2
           
            let tran = transactions[indexPath.row]
            
            if tran.type == "deposit" {
//                if cur {
//                    <#code#>
//                }
            }
            return cell
        }
        return WalletTableViewCell()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if transactions.count > 0 {
            no_transaction_available.isHidden = true
        }
        else{
            no_transaction_available.isHidden = false
        }
        
        return transactions.count
    }
    
    
}
