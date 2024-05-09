//
//  CustomPostCollectionViewCell.swift
//  my MINK
//
//  Created by Vijay Rathore on 28/02/24.
//

import ActiveLabel
import AVFoundation
import SDWebImage
import UIKit

class CustomPostCollectionViewCell : UICollectionViewCell {
 

    @IBOutlet weak var videoMainView: UIView!
    @IBOutlet weak var image: SDAnimatedImageView!
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    var returnPlayerDelegate: ReturnPlayerDelegate?
    override class func awakeFromNib() {}

    override func layoutSubviews() {
        super.layoutSubviews()

        // Update AVPlayerLayer frame in layoutSubviews
        self.playerLayer?.frame = self.image.bounds
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.playerLayer?.removeFromSuperlayer()
        if let player = player {
            self.returnPlayerDelegate?.returnPlayer(player: player)
        }
        player = nil
        self.playerLayer = nil
        self.image.imageURL = nil
       
      
    }
}
