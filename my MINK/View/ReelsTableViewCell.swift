// Copyright © 2023 SOFTMENT. All rights reserved.

import AVFoundation
import SDWebImage
import UIKit

class ReelsTableViewCell: UITableViewCell {
    
    @IBOutlet var nameAndDateStack: UIStackView!

    @IBOutlet var videoMainView: UIView!

    @IBOutlet var videoImage: SDAnimatedImageView!

    @IBOutlet var videoRatio: NSLayoutConstraint!
    @IBOutlet var enjoyImage: UIImageView!
    @IBOutlet var enjoyCount: UILabel!

    @IBOutlet var commentView: UIImageView!
    @IBOutlet var commentCount: UILabel!

    @IBOutlet var shareView: UIView!

    @IBOutlet weak var saveImage: UIImageView!
    @IBOutlet weak var saveCount: UILabel!
    
    @IBOutlet var userProfile: UIImageView!


    @IBOutlet var userName: UILabel!
    @IBOutlet var date: UILabel!

    @IBOutlet var caption: UILabel!

    @IBOutlet weak var repostStack: UIView!
    @IBOutlet var moreBtn: UIButton!
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var returnPlayerDelegate: ReturnPlayerDelegate?
    @IBOutlet var watchCount: UILabel!

    override class func awakeFromNib() {}

    override func prepareForReuse() {
        super.prepareForReuse()

        self.playerLayer?.removeFromSuperlayer()
        if let player = player {
            self.returnPlayerDelegate?.returnPlayer(player: player)
        }

        player = nil
        self.playerLayer = nil

        self.videoImage.startAnimating()
        self.userProfile.imageURL = nil
    }
    
    private var postModel : PostModel?
    private var vc : UIViewController?
 
    
    func configure(with post: PostModel, vc : UIViewController) {
        self.postModel = post
        self.vc = vc
        
        updateFavoriteButton(isFromCell: true)
        updateSavedButton(isFromCell: true)
        updateCommentCount(postID: postModel?.postID ?? "123")
    }
    
    func updateFavoriteButton(isFromCell : Bool) {
        guard let postID = postModel!.postID else { return }
        let isFavorite = FavoritesManager.shared.isFavorite(postID)
       
        
        if isFavorite {
            
            enjoyImage.image = UIImage(named: "happy")
            
            if !isFromCell {
               
                self.enjoyCount.text = String(((Int(self.enjoyCount.text!) ?? 0) + 1))
                
            }
            else {
               
                self.updateLikeCount(postID: self.postModel!.postID ?? "123")
            }
            
        }
        else {
          
            enjoyImage.image = UIImage(named: "unhappy")
            
            if !isFromCell {
                self.enjoyCount.text = String(((Int(self.enjoyCount.text!) ?? 0) - 1))
                
            }
            else {
              
                self.updateLikeCount(postID: self.postModel!.postID ?? "123")
            }
        }
    }
    
    func updateSavedButton(isFromCell : Bool) {
        
        guard let postID = postModel!.postID else { return }
        let isSave = SavedManager.shared.isSave(postID)
       
        
        if isSave {
            
            saveImage.image = UIImage(named: "save-fill")
            
            if !isFromCell {
               
                self.saveCount.text = String(((Int(self.saveCount.text!) ?? 0) + 1))
                
            }
            else {
               
                self.updateSaveCount(postID: self.postModel!.postID ?? "123")
            }
            
        }
        else {
          
            saveImage.image = UIImage(named: "save")
            
            if !isFromCell {
                self.saveCount.text = String(((Int(self.saveCount.text!) ?? 0) - 1))
                
            }
            else {
              
                self.updateSaveCount(postID: self.postModel!.postID ?? "123")
            }
        }
    }
    
    func updateLikeCount(postID : String){
        self.vc?.getCount(for: postID, countType: "Likes") { count, error in
            if let count = count {
             
                self.enjoyCount.text = "\(count)"
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
