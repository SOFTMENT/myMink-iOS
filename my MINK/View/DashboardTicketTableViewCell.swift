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
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var soldView: UIView!
    @IBOutlet weak var totalView: UIView!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var sold: UILabel!
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var mView: UIView!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var progressBar: UIProgressView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        event_image.image = UIImage(named: "placeholder")
    }
    override class func awakeFromNib() {
        
    }
}
