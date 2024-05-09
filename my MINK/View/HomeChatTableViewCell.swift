// Copyright © 2023 SOFTMENT. All rights reserved.

import SDWebImage
import UIKit

class HomeChatTableViewCell: UITableViewCell {
    @IBOutlet var mImage: SDAnimatedImageView!
    @IBOutlet var mTitle: UILabel!
    @IBOutlet var mLastMessage: UILabel!
    @IBOutlet var mTime: UILabel!
    @IBOutlet var mView: UIView!

    override func prepareForReuse() {
        self.mImage.image = nil
    }
}
