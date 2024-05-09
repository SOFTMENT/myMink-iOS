// Copyright © 2023 SOFTMENT. All rights reserved.

import SDWebImage
import UIKit

class LiveStreamingCollectionViewCell: UICollectionViewCell {
    @IBOutlet var mView: UIView!
    @IBOutlet var mProfile: SDAnimatedImageView!
    @IBOutlet var fullNameView: UIView!
    @IBOutlet var fullName: UILabel!
    @IBOutlet var countView: UIView!
    @IBOutlet var count: UILabel!

    override class func awakeFromNib() {}
}
