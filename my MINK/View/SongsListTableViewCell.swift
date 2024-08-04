// Copyright © 2023 SOFTMENT. All rights reserved.

import UIKit
import SDWebImage

class SongsListTableViewCell: UITableViewCell {
    @IBOutlet var mView: UIView!
 
    @IBOutlet weak var mImage: SDAnimatedImageView!
    @IBOutlet var mTitle: UILabel!
    @IBOutlet var mArtist: UILabel!
    @IBOutlet var mExplicitIcon: UIImageView!

    override class func awakeFromNib() {}
}
