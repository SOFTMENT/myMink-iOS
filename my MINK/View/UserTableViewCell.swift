// Copyright © 2023 SOFTMENT. All rights reserved.

import SDWebImage
import UIKit

class UserTableViewCell: UITableViewCell {
    @IBOutlet var mProfile: SDAnimatedImageView!

    @IBOutlet var mView: UIView!
    @IBOutlet var fullName: UILabel!
    @IBOutlet var username: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    
    override class func awakeFromNib() {}

    override func prepareForReuse() {
        super.prepareForReuse()

        self.mProfile.imageURL = nil
    }
}
