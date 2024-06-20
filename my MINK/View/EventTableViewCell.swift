//
//  EventTableViewCell.swift
//  my MINK
//
//  Created by Vijay Rathore on 27/01/24.
//

import UIKit
import SDWebImage

class EventTableViewCell: UITableViewCell {
   
    
    @IBOutlet weak var eventView: UIView!
    @IBOutlet weak var eventShare: UIImageView!
    @IBOutlet weak var eventType: UILabel!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventImage: SDAnimatedImageView!
    @IBOutlet weak var eventDate: UILabel!
    
    
    override class func awakeFromNib() {
        
    }
}
