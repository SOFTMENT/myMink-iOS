//
//  TodoTableViewCell.swift
//  my MINK
//
//  Created by Vijay Rathore on 06/02/24.
//

import UIKit

class TodoTableViewCell : UITableViewCell {
    
    @IBOutlet weak var todoCheck: UIButton!
    @IBOutlet weak var todoTitle: UILabel!
    @IBOutlet weak var todoTime: UILabel!
    @IBOutlet weak var todoDue: UILabel!
    @IBOutlet weak var todoView: UIView!
    
    override class func awakeFromNib() {
        
    }
    
}
