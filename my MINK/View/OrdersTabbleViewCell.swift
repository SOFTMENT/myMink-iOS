//
//  OrdersTabbleViewCell.swift
//  my MINK
//
//  Created by Vijay Rathore on 19/05/24.
//

import UIKit

class OrdersTabbleViewCell : UITableViewCell {
    
    @IBOutlet weak var mView: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var orderNo: UILabel!
    @IBOutlet weak var orderDate: UILabel!
    @IBOutlet weak var price: UILabel!
    
    
    
    override class func awakeFromNib() {
        
    }
}
