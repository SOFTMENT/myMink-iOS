//
//  WalletTableViewCell.swift
//  my MINK
//
//  Created by Vijay Rathore on 19/05/24.
//

import UIKit

class WalletTableViewCell : UITableViewCell {
    
    @IBOutlet weak var mTime: UILabel!
    @IBOutlet weak var imgBackView: UIView!
    @IBOutlet weak var mPrice: UILabel!
    @IBOutlet weak var mDescription: UILabel!
    @IBOutlet weak var mTitle: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var mDescriptionIcon: UIImageView!
    
    
    override class func awakeFromNib() {
        
    }

}
