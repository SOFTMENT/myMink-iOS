//
//  ShowTicketTableViewCell.swift
//  my MINK
//
//  Created by Vijay Rathore on 19/05/24.
//

import UIKit

class ShowTicketTableViewCell : UITableViewCell {
    @IBOutlet weak var venueView: UIView!
    @IBOutlet weak var qrCodeView: UIView!
    @IBOutlet weak var onlineInstructionView: UIView!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var ticketCountView: UIView!
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var ticketCount: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var ticketName: UILabel!
    @IBOutlet weak var eventStartEndDate: UILabel!
    @IBOutlet weak var eventTime: UILabel!
    @IBOutlet weak var addToCalendar: UILabel!
    @IBOutlet weak var addressName: UILabel!
    @IBOutlet weak var viewMap: UILabel!
    @IBOutlet weak var orderNumber: UILabel!
    @IBOutlet weak var eventSummary: UILabel!
    @IBOutlet weak var viewEventListing: UILabel!
    @IBOutlet weak var organizerName: UILabel!
    @IBOutlet weak var saveTicketAsImageBtn: UIButton!
    
    @IBOutlet weak var mainView: UIView!
    override class func awakeFromNib() {
        
    }
}
