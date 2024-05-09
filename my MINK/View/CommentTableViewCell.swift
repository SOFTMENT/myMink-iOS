// Copyright © 2023 SOFTMENT. All rights reserved.

import SDWebImage
import UIKit

class CommentTableViewCell: UITableViewCell {
    @IBOutlet var moreBtn: UIButton!
    @IBOutlet var mView: UIView!

    @IBOutlet var profilePic: SDAnimatedImageView!

    @IBOutlet var name: UILabel!

    @IBOutlet var commentDate: UILabel!

    @IBOutlet var comment: UILabel!

    @IBOutlet var nameAndDateStack: UIStackView!

    override class func awakeFromNib() {}
}
