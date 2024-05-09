// Copyright © 2023 SOFTMENT. All rights reserved.

import SDWebImage
import UIKit

class LiveChatTableViewCell: UITableViewCell {
    @IBOutlet var mMessage: UILabel!
    @IBOutlet var mName: UILabel!
    @IBOutlet var mProfile: SDAnimatedImageView!

    override class func awakeFromNib() {}
}
