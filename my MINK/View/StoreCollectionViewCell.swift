//
//  StoreTableViewCell.swift
//  my MINK
//
//  Created by Vijay Rathore on 09/04/24.
//

import UIKit
import SDWebImage

class StoreCollectionViewCell : UICollectionViewCell {
    
    @IBOutlet weak var cost: UILabel!
    
    @IBOutlet weak var storeName: UILabel!
    @IBOutlet weak var mView: UIView!

    @IBOutlet weak var storeImage: SDAnimatedImageView!
    @IBOutlet weak var storeCategory: UILabel!
    

    override func awakeFromNib() {
        
    }
}
