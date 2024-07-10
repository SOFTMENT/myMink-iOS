//
//  DashboardTicketTableViewCell.swift
//  my MINK
//
//  Created by Vijay Rathore on 19/05/24.
//

import UIKit
import SDWebImage

class DashboardTicketTableViewCell : UITableViewCell {
    
   
    @IBOutlet weak var event_image: SDAnimatedImageView!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventLocation: UILabel!
   
    @IBOutlet weak var mView: UIView!
   
    
    override func prepareForReuse() {
        super.prepareForReuse()
        event_image.image = UIImage(named: "placeholder")
    }
    override class func awakeFromNib() {
        
    }
}
