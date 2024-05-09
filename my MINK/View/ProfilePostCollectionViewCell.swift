// Copyright © 2023 SOFTMENT. All rights reserved.

import SDWebImage
import UIKit

class ProfilePosCollectionViewCell: UICollectionViewCell {
    @IBOutlet var mImage: SDAnimatedImageView!
    @IBOutlet var captionView: UIView!
    @IBOutlet var captionLabel: UILabel!

    override class func awakeFromNib() {}

    override func prepareForReuse() {
        super.prepareForReuse()

        self.mImage.imageURL = nil
    }
}
