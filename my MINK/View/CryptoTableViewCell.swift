// Copyright © 2023 SOFTMENT. All rights reserved.

import UIKit

class CryptoTableViewCell: UITableViewCell {
    @IBOutlet var mImage: UIImageView!
    @IBOutlet var mView: UIView!
    @IBOutlet var mName: UILabel!
    @IBOutlet var mSymbol: UILabel!

    @IBOutlet var mRankView: UIView!

    @IBOutlet var mRank: UILabel!
    @IBOutlet var mMarketPrice: UILabel!

    @IBOutlet var mPrice: UILabel!

    @IBOutlet var change24Hours: UILabel!

    @IBOutlet var upDownIcon: UIImageView!

    override class func awakeFromNib() {}
}
