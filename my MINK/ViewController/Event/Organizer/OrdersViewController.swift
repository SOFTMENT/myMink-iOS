//
//  OrdersViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 19/05/24.
//

import UIKit

class OrdersViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var no_orders_available: UILabel!
    var ordersData : [TicketModel] = []
    override func viewDidLoad() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    public func notifyAdapter(ordersData : [TicketModel]){
        self.ordersData.removeAll()
        self.ordersData = ordersData
        self.tableView.reloadData()
    }
}

extension OrdersViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ordersData.count > 0 {
            no_orders_available.isHidden = true
        }
        else {
            no_orders_available.isHidden = false
        }
        return ordersData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "orderscell", for: indexPath) as? OrdersTabbleViewCell {
            
            cell.mView.dropShadow()
            let order = ordersData[indexPath.row]
            cell.email.text = order.userEmail ?? "Something Went Wrong"
            cell.name.text = order.userName ?? "Something Went Wrong"
            cell.orderNo.text =  "Ticket No.:\(order.orderNumber ?? "Something Went Wrong")"
            cell.orderDate.text = self.convertDateFormaterWithSlash(order.ticketBookDate ?? Date())
            if let isFree = order.isFree, isFree {
                cell.price.text = "Free"
            }
            else{
                
                let tPrice =  Double(order.quantity ?? 1) * Double(order.ticketPrice ?? 1)
                cell.price.text  = String(format: "$ %.2f", tPrice)
            
            }
           
            return cell
        }
        
        return OrdersTabbleViewCell()
        
    }
    
    
    
}
