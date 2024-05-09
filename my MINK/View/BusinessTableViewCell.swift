//
//  BusinessTableViewCell.swift
//  my MINK
//
//  Created by Vijay Rathore on 05/06/24.
//

import UIKit
import SDWebImage

class BusinessTableViewCell : UITableViewCell {
    
    
    @IBOutlet weak var mImage: SDAnimatedImageView!
    @IBOutlet weak var mCategory: UILabel!
    @IBOutlet weak var mName: UILabel!
    @IBOutlet weak var mWebsite: UILabel!
    @IBOutlet weak var mShare: UIImageView!
    @IBOutlet weak var mView: UIView!
    
    
    override class func awakeFromNib() {
        
    }

    
}
