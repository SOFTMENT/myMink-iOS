// Copyright © 2023 SOFTMENT. All rights reserved.

import ActiveLabel
import AVFoundation
import SDWebImage
import UIKit

class PostTableViewCell: UITableViewCell {
    @IBOutlet var mView: UIView!

    @IBOutlet var profilePic: SDAnimatedImageView!

    @IBOutlet var moreBtn: UIButton!

    @IBOutlet var userName: UILabel!

    @IBOutlet var createDate: UILabel!

    @IBOutlet var createTime: UILabel!
    
    @IBOutlet weak var sponsoredStack: UIStackView!
    
    @IBOutlet var postDesc: ActiveLabel!

    @IBOutlet var muteUnmuteBtn: UIImageView!

    @IBOutlet weak var saveView: UIView!
    @IBOutlet weak var saveCount: UILabel!
    @IBOutlet weak var saveImage: UIImageView!
    
    @IBOutlet var imageStack: UIStackView!

    @IBOutlet var image1: SDAnimatedImageView!
    @IBOutlet var image2: SDAnimatedImageView!
    @IBOutlet var image3: SDAnimatedImageView!
    @IBOutlet var image4: SDAnimatedImageView!

    @IBOutlet var videoImage: SDAnimatedImageView!

    @IBOutlet var videoMainView: UIView!

    @IBOutlet var likeCount: UILabel!
    @IBOutlet var likeImage: UIImageView!
    @IBOutlet var likeView: UIView!
    @IBOutlet var commentView: UIView!
    @IBOutlet var commentCount: UILabel!

    @IBOutlet var nameAndDateStack: UIStackView!

    @IBOutlet var shareCount: UILabel!
    @IBOutlet var shareView: UIView!

    @IBOutlet var image1Ratio: NSLayoutConstraint!
    @IBOutlet var image2Ratio: NSLayoutConstraint!
    @IBOutlet var image3Ratio: NSLayoutConstraint!
    @IBOutlet var image4Ratio: NSLayoutConstraint!

    @IBOutlet var videoRatio: NSLayoutConstraint!

    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    var returnPlayerDelegate: ReturnPlayerDelegate?
    var isViewCounted = false
    var playbackObserverToken: Any?
    override class func awakeFromNib() {}

    override func layoutSubviews() {
        super.layoutSubviews()

        // Update AVPlayerLayer frame in layoutSubviews
        self.playerLayer?.frame = self.videoImage.bounds
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.playerLayer?.removeFromSuperlayer()
        if let player = player {
            self.returnPlayerDelegate?.returnPlayer(player: player)
        }
        player = nil
        self.playerLayer = nil

        self.videoImage.imageURL = nil
        self.videoImage.image = nil
        self.image1.imageURL = nil
        self.image2.imageURL = nil
        self.image3.imageURL = nil
        self.image4.imageURL = nil
        self.profilePic.imageURL = nil
        self.isViewCounted = false
        if let token = playbackObserverToken {
            player?.removeTimeObserver(token)
            self.playbackObserverToken = nil
        }
    }
    
    private var vc : UIViewController?
 
    func configure(with post: PostModel, vc : UIViewController) {
       
        self.vc = vc
        
        updateFavoriteButton(isFromCell: true, postModel: post)
        updateSavedButton(isFromCell: true, postModel: post)
        updateCommentCount(postID: post.postID ?? "123")
    }
    
    func updateSavedButton(isFromCell : Bool, postModel : PostModel) {
        guard let postID = postModel.postID else { return }
        let isSave = SavedManager.shared.isSave(postID)
       
        
        if isSave {
            
            saveImage.image = UIImage(systemName: "bookmark.fill")
            saveImage.tintColor = UIColor(red: 154/255, green: 154/255, blue: 154/255, alpha: 1)
            if !isFromCell {
               
                self.saveCount.text = String(((Int(self.saveCount.text!) ?? 0) + 1))
                
            }
            else {
               
                self.updateSaveCount(postID: postModel.postID ?? "123")
            }
            
        }
        else {
          
            saveImage.image = UIImage(systemName: "bookmark")
            saveImage.tintColor = UIColor(red: 154/255, green: 154/255, blue: 154/255, alpha: 1)
            
            if !isFromCell {
                self.saveCount.text = String(((Int(self.saveCount.text!) ?? 0) - 1))
                
            }
            else {
              
                self.updateSaveCount(postID: postModel.postID ?? "123")
            }
        }
    }
    
    func updateFavoriteButton(isFromCell : Bool,postModel : PostModel) {
        guard let postID = postModel.postID else { return }
        let isFavorite = FavoritesManager.shared.isFavorite(postID)
        
        if isFavorite {
            
            likeImage.image = UIImage(named: "smiling-face")
            
            if !isFromCell {
               
                self.likeCount.text = String(((Int(self.likeCount.text!) ?? 0) + 1))
                
            }
            else {
               
                self.updateLikeCount(postID: postModel.postID ?? "123")
            }
            
        }
        else {
          
            likeImage.image = UIImage(named: "happy-5")
            
            if !isFromCell {
                self.likeCount.text = String(((Int(self.likeCount.text!) ?? 0) - 1))
                
            }
            else {
              
                self.updateLikeCount(postID: postModel.postID ?? "123")
            }
        }
    }
    
    func updateLikeCount(postID : String){
        self.vc?.getCount(for: postID, countType: "Likes") { count, error in
            if let count = count {
             
                self.likeCount.text = "\(count)"
            }
        }
    }
    
    func updateCommentCount(postID : String){
        self.vc?.getCount(for: postID, countType: "Comments") { count, error in
            if let count = count {
             
                self.commentCount.text = "\(count)"
            }
        }
    }
    
    func updateSaveCount(postID : String){
        self.vc?.getCount(for: postID, countType: "SavePosts") { count, error in
            if let count = count {
             
                self.saveCount.text = "\(count)"
            }
        }
    }
}
