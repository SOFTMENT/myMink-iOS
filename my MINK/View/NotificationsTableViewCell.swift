//
//  NotificationsTableViewCell.swift
//  my MINK
//
//  Created by Vijay Rathore on 05/08/24.
//

import UIKit
import SDWebImage

class NotificationsTableViewCell : UITableViewCell {
    
    @IBOutlet weak var mView: UIView!
    @IBOutlet weak var mProfile: SDAnimatedImageView!
    @IBOutlet weak var mName: UILabel!
    @IBOutlet weak var mMessage: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var postImg: SDAnimatedImageView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var comment: UILabel!
    
    override class func awakeFromNib() {
        
    }
    
    
}
