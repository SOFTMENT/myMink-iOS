//
//  HeaderViewCell.swift
//  my MINK
//
//  Created by Vijay Rathore on 27/01/24.
//

import UIKit
import SDWebImage

class HeaderViewCell: UICollectionViewCell {
    
    @IBOutlet weak var mImage: SDAnimatedImageView!
    
    override class func awakeFromNib() {
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        mImage.imageURL = nil
        mImage.image = nil
    }
    
    
}
