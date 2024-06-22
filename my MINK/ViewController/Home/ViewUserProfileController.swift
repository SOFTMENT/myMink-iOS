// Copyright © 2023 SOFTMENT. All rights reserved.

import CropViewController
import SDWebImage
import UIKit
import Lottie

// MARK: - ViewUserProfileController

class ViewUserProfileController: UIViewController {
    @IBOutlet var chatFollowStack: UIStackView!
    @IBOutlet weak var topPostsLbl: UILabel!
    
    @IBOutlet weak var topViewsLbl: UILabel!
    @IBOutlet weak var topFollowersLbl: UILabel!
    @IBOutlet weak var verificationBadge: UIImageView!
    @IBOutlet var messageBtn: UIButton!
    @IBOutlet var followBtn: UIButton!

    @IBOutlet var userPersonalnfoView: UIView!
    @IBOutlet var userPostView: UIView!

    @IBOutlet var backView: UIImageView!
    @IBOutlet var dotsView: UIImageView!

    @IBOutlet var signView: UIView!

    @IBOutlet var followingView: UIView!
    @IBOutlet var followersView: UIView!
    @IBOutlet var followersCount: UILabel!
    @IBOutlet var followingCount: UILabel!
    @IBOutlet var topPostCount: UILabel!
    @IBOutlet var viewCount: UILabel!

    var postModels = [PostModel]()
    var usePostModels = [PostModel]()
    @IBOutlet var postCount: UILabel!
    @IBOutlet var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var address: UILabel!

    @IBOutlet var phoneNumberView: UIStackView!
    @IBOutlet var phoneNumber: UILabel!
    @IBOutlet var emailAddress: UILabel!
    @IBOutlet var emailAddressView: UIStackView!
    @IBOutlet var bioGraphy: UILabel!

    @IBOutlet var website: UILabel!
    @IBOutlet var websiteView: UIStackView!

    @IBOutlet var userProfile: SDAnimatedImageView!

    @IBOutlet var fullName: UILabel!
    @IBOutlet var username: UILabel!
    @IBOutlet var userstatsView: UIView!
    @IBOutlet var noPostsAvailable: UILabel!
    @IBOutlet var joiningDate: UILabel!

    @IBOutlet var signatureImage: UIImageView!

  
    @IBOutlet weak var filterBtn: UIButton!
    @IBOutlet var searchTF: UITextField!

    @IBOutlet weak var followerLoading: LottieAnimationView!
    @IBOutlet weak var followingLoading: LottieAnimationView!
    @IBOutlet weak var postsLoading: LottieAnimationView!
    @IBOutlet weak var viewsLoading: LottieAnimationView!
    
    
    var user: UserModel?
    
    
    @IBOutlet weak var twitterCircle: CircleView!
    @IBOutlet weak var instagramCircle: CircleView!
    @IBOutlet weak var tiktokCircle: CircleView!
    @IBOutlet weak var facebookCircle: CircleView!
    @IBOutlet weak var youtubeCircle: CircleView!
    @IBOutlet weak var rumCircle: CircleView!
    @IBOutlet weak var twitchCircle: CircleView!
    @IBOutlet weak var redditCircle: CircleView!
    
    @IBOutlet weak var tumblrCircle: CircleView!
    @IBOutlet weak var discordCircle: CircleView!
    @IBOutlet weak var telegramCircle: CircleView!
  
    @IBOutlet weak var mastodonCircle: CircleView!
    @IBOutlet weak var pintrestCircle: CircleView!
    @IBOutlet weak var etsyCircle: CircleView!
    @IBOutlet weak var linkedinCircle: CircleView!
    @IBOutlet weak var whatsAppCircle: CircleView!
    
    @IBOutlet weak var socialMediaView: UIView!
    
    @IBOutlet weak var twitterView: UIView!
    @IBOutlet weak var twitterNumber: UILabel!

    @IBOutlet weak var instagramView: UIView!
    @IBOutlet weak var instagramNumber: UILabel!
    
    @IBOutlet weak var tiktokView: UIView!
    @IBOutlet weak var tikTokNumber: UILabel!
    
    @IBOutlet weak var facebookView: UIView!
    @IBOutlet weak var facebookNumber: UILabel!
    
    @IBOutlet weak var youtubeView: UIView!
    @IBOutlet weak var youtubeNumber: UILabel!
    
    @IBOutlet weak var rumView: UIView!
    @IBOutlet weak var rumNumber: UILabel!
    
    @IBOutlet weak var twitchView: UIView!
    @IBOutlet weak var twitchNumber: UILabel!
    
    @IBOutlet weak var redditView: UIView!
    @IBOutlet weak var redditNumber: UILabel!
    
    @IBOutlet weak var tumblr: UIView!
    @IBOutlet weak var tumblrNumer: UILabel!
    
    @IBOutlet weak var discordView: UIView!
    @IBOutlet weak var discordNumber: UILabel!
    
    @IBOutlet weak var telegramView: UIView!
    @IBOutlet weak var telegramNumber: UILabel!
    
 
    @IBOutlet weak var mastodonView: UIView!
    @IBOutlet weak var mastodonNumber: UILabel!
    
    @IBOutlet weak var pintrestView: UIView!
    @IBOutlet weak var pintrestNumber: UILabel!
    
    @IBOutlet weak var etsyView: UIView!
    @IBOutlet weak var etsyNumber: UILabel!
    
    
    @IBOutlet weak var linkedinView: UIView!
    @IBOutlet weak var linkedinNumber: UILabel!
    
    @IBOutlet weak var whatsAppView: UIView!
    @IBOutlet weak var whatsAppNumber: UILabel!

    var socialMediaModels = Array<SocialMediaModel>()
    var amIFollowing : Bool = false
    

    override func viewDidLoad() {
   
        guard let user = user else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
            if let isPrivate = user.isAccountPrivate, isPrivate {
                self.shouldHideUserPersonalInfo(isHidden: true)
            }

            if UserModel.data?.uid == user.uid {
                self.chatFollowStack.isHidden = true
                self.shouldHideUserPersonalInfo(isHidden: false)
            }
            
            followerLoading.loopMode = .loop
            followerLoading.contentMode = .scaleAspectFill
            followerLoading.play()
            
            
            followingLoading.loopMode = .loop
            followingLoading.contentMode = .scaleAspectFill
            followingLoading.play()
            
            postsLoading.loopMode = .loop
            postsLoading.contentMode = .scaleAspectFill
            postsLoading.play()
            
            viewsLoading.loopMode = .loop
            viewsLoading.contentMode = .scaleAspectFill
            viewsLoading.play()
            
            

            // FollowersView
            self.followersView.isUserInteractionEnabled = true
            self.followersView.addGestureRecognizer(UITapGestureRecognizer(
                target: self,
                action: #selector(self.followersViewClicked)
            ))

            // FollowingView
            self.followingView.isUserInteractionEnabled = true
            self.followingView.addGestureRecognizer(UITapGestureRecognizer(
                target: self,
                action: #selector(self.followingViewClicked)
            ))

            // MessageBtn
            self.messageBtn.layer.cornerRadius = 8

            // FollowBtn
            self.followBtn.layer.cornerRadius = 8
            self.followBtn.isSelected = false
            // checkFollow
            FirebaseStoreManager.db.collection(Collections.USERS.rawValue).document(FirebaseStoreManager.auth.currentUser!.uid)
            .collection(Collections.FOLLOWING.rawValue).document(user.uid ?? "123").addSnapshotListener { snapshot, error in
                if error == nil {
                    if let snapshot = snapshot, snapshot.exists {
                        self.followBtn.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
                        self.followBtn.isSelected = true
                        self.followBtn.setTitleColor(.black, for: .selected)
                        self.followBtn.setTitle("Following", for: .normal)
                        self.amIFollowing = true
                        self.shouldHideUserPersonalInfo(isHidden: false)
                    }
                    else {
                        self.amIFollowing = false
                        if let isPrivate = user.isAccountPrivate, isPrivate {
                            self.shouldHideUserPersonalInfo(isHidden: true)
                        }

                    }
                }
            }

            self.userProfile.makeRounded()
            self.userstatsView.layer.cornerRadius = 8

            self.scrollView.contentInsetAdjustmentBehavior = .never

            if let autoGraphImage = user.autoGraphImage, !autoGraphImage.isEmpty {
                self.signatureImage.setImage(imageKey: autoGraphImage, placeholder: "", width: 100, height: 100)
                self.signatureImage.isHidden = false
                self.signView.isHidden = false

                view.layoutIfNeeded()
            } else {
                self.signatureImage.isHidden = true
                self.signView.isHidden = true

                view.layoutIfNeeded()
            }

            self.websiteView.isHidden = true
            self.websiteView.isUserInteractionEnabled = true
            self.websiteView.addGestureRecognizer(UITapGestureRecognizer(
                target: self,
                action: #selector(self.websiteClicked)
            ))

            self.filterBtn.layer.cornerRadius = 8
            self.searchTF.layer.cornerRadius = 8
            self.searchTF.setLeftPaddingPoints(16)
            self.searchTF.setRightPaddingPoints(10)
            self.searchTF.delegate = self
            self.searchTF.setLeftIcons(icon: UIImage(systemName: "magnifyingglass")!)

            if let path = user.profilePic, !path.isEmpty {
                self.userProfile.setImage(
                    imageKey: path,
                    placeholder: "profile-placeholder",
                    width: 250,
                    height: 250,
                    shouldShowAnimationPlaceholder: true
                )
            }
            self.fullName.text = user.fullName ?? "my MINK"
            self.username.text = "@\(user.username ?? "username")"

            if let swebsite = user.website, !swebsite.isEmpty {
                self.websiteView.isHidden = false
                self.website.text = swebsite
            }
            self.bioGraphy.text = user.biography ?? ""
            self.address.text = user.location ?? ""

            self.phoneNumberView.isHidden = true
            self.phoneNumberView.isUserInteractionEnabled = true
            self.phoneNumberView.addGestureRecognizer(UITapGestureRecognizer(
                target: self,
                action: #selector(self.phoneClicked)
            ))

            self.emailAddressView.isHidden = true
            self.emailAddressView.isUserInteractionEnabled = true
            self.emailAddressView.addGestureRecognizer(UITapGestureRecognizer(
                target: self,
                action: #selector(self.mailClicked)
            ))

            if let sphoneNumber = user.phoneNumber, !sphoneNumber.isEmpty {
                self.phoneNumberView.isHidden = false
                self.phoneNumber.text = sphoneNumber
            }
            if let semail = user.email, !semail.isEmpty {
                self.emailAddressView.isHidden = false
                self.emailAddress.text = semail
            }

            self.collectionView.delegate = self
            self.collectionView.dataSource = self
            let flowLayout = UICollectionViewFlowLayout()
            let width = self.collectionView.bounds.width
            flowLayout.itemSize = CGSize(width: (width / 3) - 5, height: (width / 3) - 5)
            flowLayout.scrollDirection = UICollectionView.ScrollDirection.vertical
            flowLayout.minimumInteritemSpacing = 0
            self.collectionView.collectionViewLayout = flowLayout

            self.joiningDate.text = "Joined on \(convertDateFormaterWithoutDash(user.registredAt ?? Date()))"

            getPostsBy(uid: user.uid ?? "123", accountType: .USER) { pModels, error in

                if let error = error {
                    self.showError(error)
                } else {
                    self.usePostModels.removeAll()
                    self.postModels.removeAll()
                    if let pModels = pModels, !pModels.isEmpty {
                        self.postModels.append(contentsOf: pModels)
                        self.usePostModels.append(contentsOf: pModels)
                    }
                    
                    self.topPostCount.isHidden = false
                    self.postsLoading.isHidden = true
                    
                    let count = self.postModels.count
                   
                    self.topPostsLbl.text = count > 1 ? "Posts" : "Post"
                    self.topPostCount.text = "\(count)"
                    self.collectionView.reloadData()
                }
            }
            
       

        self.backView.isUserInteractionEnabled = true
        self.backView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.backViewClicked)
        ))
        
        
        //IncreaseProfileView
        if FirebaseStoreManager.auth.currentUser!.uid != user.uid {
            increaseProfileView(mUid: FirebaseStoreManager.auth.currentUser!.uid, mFriendUid: user.uid ?? "")
        }
      
        
        getCount(for: user.uid ?? "123", countType: Collections.PROFILEVIEWS.rawValue) { count, error in
            self.viewsLoading.isHidden = true
            self.viewCount.isHidden = false
            self.topViewsLbl.text = (count ?? 0) > 1 ? "Views" : "View"
            self.viewCount.text = "\(count ?? 0)"
        }
        
        updateFollowersAndFollowingCount()
        
        
        twitterView.isUserInteractionEnabled = true
        let gest1 = MyGesture(target: self, action: #selector(socialViewClicked))
        gest1.socialType = .Twitter
        twitterView.addGestureRecognizer(gest1)
        
        instagramView.isUserInteractionEnabled = true
        let gest2 = MyGesture(target: self, action: #selector(socialViewClicked))
        gest2.socialType = .Instagram
        instagramView.addGestureRecognizer(gest2)
        
        tiktokView.isUserInteractionEnabled = true
        let gest3 = MyGesture(target: self, action: #selector(socialViewClicked))
        gest3.socialType = .TikTok
        tiktokView.addGestureRecognizer(gest3)
        
        facebookView.isUserInteractionEnabled = true
        let gest4 = MyGesture(target: self, action: #selector(socialViewClicked))
        gest4.socialType = .Facebook
        facebookView.addGestureRecognizer(gest4)
        
        youtubeView.isUserInteractionEnabled = true
        let gest5 = MyGesture(target: self, action: #selector(socialViewClicked))
        gest5.socialType = .YouTube
        youtubeView.addGestureRecognizer(gest5)
        
        rumView.isUserInteractionEnabled = true
        let gest6 = MyGesture(target: self, action: #selector(socialViewClicked))
        gest6.socialType = .Rumble
        rumView.addGestureRecognizer(gest6)
        
        twitchView.isUserInteractionEnabled = true
        let gest7 = MyGesture(target: self, action: #selector(socialViewClicked))
        gest7.socialType = .Twitch
        twitchView.addGestureRecognizer(gest7)
        
        redditView.isUserInteractionEnabled = true
        let gest8 = MyGesture(target: self, action: #selector(socialViewClicked))
        gest8.socialType = .Reddit
        redditView.addGestureRecognizer(gest8)
        
       
        tumblr.isUserInteractionEnabled = true
        let gest10 = MyGesture(target: self, action: #selector(socialViewClicked))
        gest10.socialType = .Tumblr
        tumblr.addGestureRecognizer(gest10)
        
        discordView.isUserInteractionEnabled = true
        let gest11 = MyGesture(target: self, action: #selector(socialViewClicked))
        gest11.socialType = .Discord
        discordView.addGestureRecognizer(gest11)
        
        telegramView.isUserInteractionEnabled = true
        let gest12 = MyGesture(target: self, action: #selector(socialViewClicked))
        gest12.socialType = .Telegram
        telegramView.addGestureRecognizer(gest12)
        
        
        
        mastodonView.isUserInteractionEnabled = true
        let gest14 = MyGesture(target: self, action: #selector(socialViewClicked))
        gest14.socialType = .Mastodon
        mastodonView.addGestureRecognizer(gest14)
        
        pintrestView.isUserInteractionEnabled = true
        let gest15 = MyGesture(target: self, action: #selector(socialViewClicked))
        gest15.socialType = .Pinterest
        pintrestView.addGestureRecognizer(gest15)
        
        etsyView.isUserInteractionEnabled = true
        let gest16 = MyGesture(target: self, action: #selector(socialViewClicked))
        gest16.socialType = .Etsy
        etsyView.addGestureRecognizer(gest16)
        
        linkedinView.isUserInteractionEnabled = true
        let gest17 = MyGesture(target: self, action: #selector(socialViewClicked))
        gest17.socialType = .LinkedIn
        linkedinView.addGestureRecognizer(gest17)
        
        whatsAppView.isUserInteractionEnabled = true
        let gest18 = MyGesture(target: self, action: #selector(socialViewClicked))
        gest18.socialType = .Whatsapp
        whatsAppView.addGestureRecognizer(gest18)
  
        
        getAllSocialMedia(uid: user.uid ?? "123") { socialMediaModels in
            self.hideAllSocialMedia()
        
            if let socialMediaModels = socialMediaModels {
                self.socialMediaModels.removeAll()
                self.socialMediaModels.append(contentsOf: socialMediaModels)
                self.socialMediaView.isHidden = self.socialMediaModels.count > 0 ? false : true
                for model in socialMediaModels {
                    if model.name == SocialMedia.Twitter.rawValue {
                      
                        self.twitterView.isHidden = false
                        self.twitterNumber.text = String((Int(self.twitterNumber.text ?? "1") ?? 1) + 1)
                       
                        if (Int(self.twitterNumber.text ?? "1") ?? 1) > 1 {
                            self.twitterCircle.isHidden = false
                        }
                    }
                    else if model.name == SocialMedia.Instagram.rawValue {
                        self.instagramView.isHidden = false
                        self.instagramNumber.text = String((Int(self.instagramNumber.text ?? "1") ?? 1) + 1)
                        
                        if (Int(self.instagramNumber.text ?? "1") ?? 1) > 1 {
                            self.instagramCircle.isHidden = false
                        }
                    }
                    else if model.name == SocialMedia.TikTok.rawValue {
                        self.tiktokView.isHidden = false
                        self.tikTokNumber.text = String((Int(self.tikTokNumber.text ?? "1") ?? 1) + 1)
                        
                        if (Int(self.tikTokNumber.text ?? "1") ?? 1) > 1 {
                            self.tiktokCircle.isHidden = false
                        }
                    }
                    else if model.name == SocialMedia.Facebook.rawValue {
                        self.facebookView.isHidden = false
                        self.facebookNumber.text = String((Int(self.facebookNumber.text ?? "1") ?? 1) + 1)
                        
                        if (Int(self.facebookNumber.text ?? "1") ?? 1) > 1 {
                            self.facebookCircle.isHidden = false
                        }
                    }
                    else if model.name == SocialMedia.YouTube.rawValue {
                        self.youtubeView.isHidden = false
                        self.youtubeNumber.text = String((Int(self.youtubeNumber.text ?? "1") ?? 1) + 1)
                        
                        if (Int(self.youtubeNumber.text ?? "1") ?? 1) > 1 {
                            self.youtubeCircle.isHidden = false
                        }
                    }
                    else if model.name == SocialMedia.Rumble.rawValue {
                        self.rumView.isHidden = false
                        self.rumNumber.text = String((Int(self.rumNumber.text ?? "1") ?? 1) + 1)
                        
                        if (Int(self.rumNumber.text ?? "1") ?? 1) > 1 {
                            self.rumCircle.isHidden = false
                        }
                    }
                    else if model.name == SocialMedia.Twitch.rawValue {
                        self.twitchView.isHidden = false
                        self.twitchNumber.text = String((Int(self.twitchNumber.text ?? "1") ?? 1) + 1)
                        
                        if (Int(self.twitchNumber.text ?? "1") ?? 1) > 1 {
                            self.twitchCircle.isHidden = false
                        }
                    }
                    else if model.name == SocialMedia.Reddit.rawValue {
                        self.redditView.isHidden = false
                        self.redditNumber.text = String((Int(self.redditNumber.text ?? "1") ?? 1) + 1)
                        
                        if (Int(self.redditNumber.text ?? "1") ?? 1) > 1 {
                            self.redditCircle.isHidden = false
                        }
                    }
                 
                    else if model.name == SocialMedia.Tumblr.rawValue {
                        self.tumblr.isHidden = false
                        self.tumblrNumer.text = String((Int(self.tumblrNumer.text ?? "1") ?? 1) + 1)
                        
                        if (Int(self.tumblrNumer.text ?? "1") ?? 1) > 1 {
                            self.tumblrCircle.isHidden = false
                        }
                    }
                    else if model.name == SocialMedia.Discord.rawValue {
                        self.discordView.isHidden = false
                        self.discordNumber.text = String((Int(self.discordNumber.text ?? "1") ?? 1) + 1)
                        
                        if (Int(self.discordNumber.text ?? "1") ?? 1) > 1 {
                            self.discordCircle.isHidden = false
                        }
                    }
                    else if model.name == SocialMedia.Telegram.rawValue {
                        self.telegramView.isHidden = false
                        self.telegramNumber.text = String((Int(self.telegramNumber.text ?? "1") ?? 1) + 1)
                        
                        if (Int(self.telegramNumber.text ?? "1") ?? 1) > 1 {
                            self.telegramCircle.isHidden = false
                        }
                    }
                  
                    else if model.name == SocialMedia.Mastodon.rawValue {
                        self.mastodonView.isHidden = false
                        self.mastodonNumber.text = String((Int(self.mastodonNumber.text ?? "1") ?? 1) + 1)
                        
                        if (Int(self.mastodonNumber.text ?? "1") ?? 1) > 1 {
                            self.mastodonCircle.isHidden = false
                        }
                    }
                    else if model.name == SocialMedia.Pinterest.rawValue {
                        self.pintrestView.isHidden = false
                        self.pintrestNumber.text = String((Int(self.pintrestNumber.text ?? "1") ?? 1) + 1)
                        
                        if (Int(self.pintrestNumber.text ?? "1") ?? 1) > 1 {
                            self.pintrestCircle.isHidden = false
                        }
                    }
                    else if model.name == SocialMedia.Etsy.rawValue {
                        self.etsyView.isHidden = false
                        self.etsyNumber.text = String((Int(self.etsyNumber.text ?? "1") ?? 1) + 1)
                        
                        if (Int(self.etsyNumber.text ?? "1") ?? 1) > 1 {
                            self.etsyCircle.isHidden = false
                        }
                    }
                    else if model.name == SocialMedia.LinkedIn.rawValue {
                        self.linkedinView.isHidden = false
                        self.linkedinNumber.text = String((Int(self.linkedinNumber.text ?? "1") ?? 1) + 1)
                        
                        if (Int(self.linkedinNumber.text ?? "1") ?? 1) > 1 {
                            self.linkedinCircle.isHidden = false
                        }
                    }
                    else if model.name == SocialMedia.Whatsapp.rawValue {
                        self.whatsAppView.isHidden = false
                        self.whatsAppNumber.text = String((Int(self.whatsAppNumber.text ?? "1") ?? 1) + 1)
                        
                        if (Int(self.whatsAppNumber.text ?? "1") ?? 1) > 1 {
                            self.whatsAppCircle.isHidden = false
                        }
                    }
                    
                }
            }
            
        }
        
        
    }
    @objc func socialViewClicked(value : MyGesture){
        
        let models = socialMediaModels.filter { model in
            if model.name == value.socialType!.rawValue {
                return true
            }
            return false
        }
        
        if models.count > 1 {
            self.showAlertForOpen(models: models)
        }
        else {
        
            guard let url = URL(string: makeValidURL(urlString: models.first!.link ?? "")) else { return}
            UIApplication.shared.open(url)
        }
           
        
    }
    func showAlertForOpen(models : Array<SocialMediaModel>){
        let alert = UIAlertController(title: nil, message: "Select Account", preferredStyle: .actionSheet)
        for model in models {
            alert.addAction(UIAlertAction(title: model.link ?? "NIL", style: .default,handler: { action in
                guard let url = URL(string: self.makeValidURL(urlString: model.link ?? "")) else { return}
                UIApplication.shared.open(url)
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
   }
    func hideAllSocialMedia(){
        twitterView.isHidden = true
        twitterNumber.text = "0"
        twitterCircle.isHidden = true
        
        instagramView.isHidden = true
        instagramNumber.text = "0"
        instagramCircle.isHidden = true
        
        tiktokView.isHidden = true
        tikTokNumber.text = "0"
        tiktokCircle.isHidden = true
        
        facebookView.isHidden = true
        facebookNumber.text = "0"
        facebookCircle.isHidden = true
        
        youtubeView.isHidden = true
        youtubeNumber.text = "0"
        youtubeCircle.isHidden = true
        
        rumView.isHidden = true
        rumNumber.text = "0"
        rumCircle.isHidden = true
        
        twitchView.isHidden = true
        twitchNumber.text = "0"
        twitchCircle.isHidden = true
        
        redditView.isHidden = true
        redditNumber.text = "0"
        redditCircle.isHidden = true
        
       
        
        tumblr.isHidden = true
        tumblrNumer.text = "0"
        tumblrCircle.isHidden = true
        
        discordView.isHidden = true
        discordNumber.text = "0"
        
        telegramView.isHidden = true
        telegramNumber.text = "0"
        telegramCircle.isHidden = true
        
        mastodonView.isHidden = true
        mastodonNumber.text = "0"
        mastodonCircle.isHidden = true
        
        pintrestView.isHidden = true
        pintrestNumber.text = "0"
        pintrestCircle.isHidden = true
        
        etsyView.isHidden = true
        etsyNumber.text = "0"
        etsyCircle.isHidden = true
        
        linkedinView.isHidden = true
        linkedinNumber.text = "0"
        linkedinCircle.isHidden = true
        
        whatsAppView.isHidden = true
        whatsAppNumber.text = "0"
        whatsAppCircle.isHidden = true
    }

    func updateFollowersAndFollowingCount() {
        getCount(for: user!.uid ?? "123", countType: Collections.FOLLOW.rawValue) { mcount, error in
            var count  = 0
            if let mcount = mcount {
               count = mcount
            }
            
            self.followerLoading.isHidden = true
            self.followersCount.isHidden = false
            
            self.topFollowersLbl.text = count > 1 ? "Followers" : "Follower"
            self.followersCount.text = "\(count)"
            
            if count > 2  && count < 10{
                self.verificationBadge.isHidden = false
                self.verificationBadge.image = UIImage(named: "verification")
            }
            else if count >= Constants.BLUE_TICK_REQUIREMENT {
                self.verificationBadge.isHidden = false
                self.verificationBadge.image = UIImage(named: "verified")
            }
            else {
                self.verificationBadge.isHidden = true
            }
        }
        
     
       
        getCount(for: user!.uid ?? "123", countType: Collections.FOLLOWING.rawValue) { count, error in
            
        
            
            self.followingLoading.isHidden = true
            self.followingCount.isHidden = false
            self.followingCount.text = "\(count ?? 0)"
  
        }
    }
    
    func searchBtnClicked(searchText : String){
        ProgressHUDShow(text: "Searching...")
        algoliaSearch(searchText: searchText, indexName: .POSTS, filters: "uid:\(self.user!.uid ?? "123")") { models in
            
            DispatchQueue.main.async {
                self.ProgressHUDHide()
                
                self.usePostModels.removeAll()
                self.usePostModels.append(contentsOf: models as? [PostModel] ?? [])
                self.collectionView.reloadData()
                
            }
            
            
        }
    }
    
    @IBAction func filterBtnClicked(_ sender: Any) {
        var uiMenuElements = [UIMenuElement]()

        filterBtn.isUserInteractionEnabled = true
        filterBtn.showsMenuAsPrimaryAction = true
     

        let image = UIAction(
            title: "Image",
            image: UIImage(systemName: "photo.circle.fill")
        ) { _ in

            self.performSegue(withIdentifier: "viewprofilePostViewSeg", sender: "image")
        }

        let video = UIAction(
            title: "Video",
            image: UIImage(systemName: "video.circle.fill")
        ) { _ in

            self.performSegue(withIdentifier: "viewprofilePostViewSeg", sender: "video")
        }
        
        let text = UIAction(
            title: "Text",
            image: UIImage(systemName: "text.quote")
        ) { _ in

            self.performSegue(withIdentifier: "viewprofilePostViewSeg", sender: "text")
        }
     
        uiMenuElements.append(image)
        uiMenuElements.append(video)
        uiMenuElements.append(text)

        filterBtn.menu = UIMenu(title: "", children: uiMenuElements)
    }
    
    func shouldHideUserPersonalInfo(isHidden: Bool) {
        self.userPersonalnfoView.isHidden = isHidden
        self.userPostView.isHidden = isHidden
    }
    

    @objc func followersViewClicked() {
        if let isPrivate = user!.isAccountPrivate, isPrivate,!amIFollowing {
            showMessage(
                title: "Private Account",
                message: "This account is private. Follow to see their followers, following & posts."
            )
        } else {
            
            self.ProgressHUDShow(text: "")
            self.getFollowersByUid(uid: user!.uid ?? "") { followModels in
                self.ProgressHUDHide()
                var usersIds = Array<String>()
                for followModel in followModels!  {
                    if let userId = followModel.uid {
                        usersIds.append(userId)
                    }
                   
                }
                
                let value = ["title" : "Followers" , "users" : usersIds]
                self.performSegue(withIdentifier: "usersListSeg", sender: value)
            }
     
        }
    }

    @objc func followingViewClicked() {
        if let isPrivate = user!.isAccountPrivate, isPrivate, !amIFollowing{
            showMessage(
                title: "Private Account",
                message: "This account is private. Follow to see their followers, following & posts."
            )
        } else {
            
            self.ProgressHUDShow(text: "")
            self.getFollowingByUid(uid: user!.uid ?? "") { followModels in
                self.ProgressHUDHide()
                var usersIds = Array<String>()
                for followModel in followModels!  {
                    if let userId = followModel.uid {
                        usersIds.append(userId)
                    }
                   
                }
                let value = ["title" : "Following" , "users" : usersIds]
                self.performSegue(withIdentifier: "usersListSeg", sender: value)
            }
        }
    }

    @IBAction func messageBtnClicked(_: Any) {
        performSegue(withIdentifier: "viewProfileChatSeg", sender: nil)
    }

    @IBAction func followBtnClicked(_: Any) {
        if !self.followBtn.isSelected {
            self.followBtn.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
            self.followBtn.isSelected = true
            self.followBtn.setTitleColor(.black, for: .selected)
            self.followBtn.setTitle("Following", for: .normal)
            addFollow(mUser: UserModel.data!, fUser: self.user!)
           
            PushNotificationSender().sendPushNotification(
                title: "Good News",
                body: "\(UserModel.data!.fullName ?? "123") is following you.",
                topic: self.user!.notificationToken ?? "123"
            )
        } else {
            self.followBtn.backgroundColor = UIColor(red: 210 / 255, green: 0, blue: 1 / 255, alpha: 1)
            self.followBtn.isSelected = false
            self.followBtn.setTitleColor(.white, for: .normal)
            self.followBtn.setTitle("Follow", for: .normal)
            
            self.deleteFollow(mainUserId: FirebaseStoreManager.auth.currentUser!.uid, followerUserId: self.user!.uid ?? "123") { error in
                if error != nil {
                    self.followBtn.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
                    self.followBtn.isSelected = true
                    self.followBtn.setTitleColor(.black, for: .selected)
                    self.followBtn.setTitle("Following", for: .normal)
                }
            }
            
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            self.updateFollowersAndFollowingCount()
        }
        

    }

    @objc func backViewClicked() {
        dismiss(animated: true)
    }

    @objc func phoneClicked() {
        if let url = URL(string: "tel://\(phoneNumber.text ?? "")"), UIApplication.shared.canOpenURL(url) {
            let application = UIApplication.shared
            if application.canOpenURL(url) {
                application.open(url, options: [:], completionHandler: nil)
            }
        }
    }

    @objc func mailClicked() {
        if let url = URL(string: "mailto:\(emailAddress.text ?? "")") {
            let application = UIApplication.shared
            if application.canOpenURL(url) {
                application.open(url, options: [:], completionHandler: nil)
            }
        }
    }

    @objc func websiteClicked() {
        guard let url = URL(string: makeValidURL(urlString: website.text ?? "")) else {
            return
        }
        UIApplication.shared.open(url)
    }

    func refreshCollectionViewHeight() {
        let width = self.collectionView.bounds.width
        self.collectionViewHeight
            .constant = CGFloat((width / CGFloat(3)) + 5) * CGFloat((self.usePostModels.count + 2) / 3)
    }

    @objc func postClicked(value: MyGesture) {
        performSegue(withIdentifier: "viewprofilePostViewSeg", sender: value.index)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewprofilePostViewSeg" {
            if let VC = segue.destination as? PostViewController {
                if let position = sender as? Int {
                    VC.postModels = self.usePostModels
                    VC.userModel = self.user!
                    VC.position = position
                }
                else if let postType = sender as? String {
                    let postModels = self.usePostModels.filter { postModel in
                        if postModel.postType == postType {
                            return true
                        }
                        return false
                    }
                    VC.postModels = postModels
                    VC.userModel = self.user
                    VC.position = 0
                    VC.topTitle = "Filters"
                }
            }
        } else if segue.identifier == "viewProfileChatSeg" {
            if let vc = segue.destination as? ShowChatViewController {
                let lastModel = LastMessageModel()
                lastModel.senderName = self.user!.fullName ?? "Full Name"
                lastModel.senderUid = self.user!.uid ?? "123"
                lastModel.senderToken = self.user!.notificationToken ?? "Token"
                lastModel.senderImage = self.user!.profilePic ?? ""
                lastModel.senderDeviceToken = self.user!.deviceToken ?? ""
                vc.lastMessage = lastModel
            }
        }
        else if segue.identifier == "usersListSeg" {
            if let VC = segue.destination as? UsersListViewController {
                if let value = sender as? [String : Any] {
                    VC.userModelsIDs = value["users"] as? Array<String>
                    VC.headTitle  = value["title"] as? String
                }
            }
        }
    }
}

// MARK: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension ViewUserProfileController: UICollectionViewDelegate, UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout
{
    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        let width = self.collectionView.bounds.width
        return CGSize(width: (width / 3) - 5, height: (width / 3) - 5)
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        self.noPostsAvailable.isHidden = self.usePostModels.count > 0 ? true : false
        self.postCount.text = self.usePostModels.count > 1 ? "\(self.usePostModels.count) Posts" : "\(self.usePostModels.count) Post"
        return self.usePostModels.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "profilePostCell",
            for: indexPath
        ) as? ProfilePosCollectionViewCell {
            let postModel = self.usePostModels[indexPath.row]

            cell.mImage.layer.cornerRadius = 8
            let myGest = MyGesture(target: self, action: #selector(self.postClicked))
            myGest.index = indexPath.row
            cell.mImage.isUserInteractionEnabled = true
            cell.mImage.addGestureRecognizer(myGest)

            let myGest1 = MyGesture(target: self, action: #selector(self.postClicked))
            myGest1.index = indexPath.row
            cell.captionView.isUserInteractionEnabled = true
            cell.captionView.addGestureRecognizer(myGest1)

            if postModel.postType == "image" {
                cell.captionView.isHidden = true
                if let postImages = postModel.postImages, !postImages.isEmpty {
                    if let sImage = postImages.first, !sImage.isEmpty {
                        cell.mImage.setImage(
                            imageKey: sImage,
                            placeholder: "profile-placeholder",
                            shouldShowAnimationPlaceholder: true
                        )
                    }
                }
            } else if postModel.postType == "video" {
                cell.captionView.isHidden = true
                if let postImage = postModel.videoImage, !postImage.isEmpty {
                    cell.mImage.setImage(
                        imageKey: postImage,
                        placeholder: "placeholder",
                        shouldShowAnimationPlaceholder: true
                    )
                }
            } else if postModel.postType == "text" {
                if let caption = postModel.caption, !caption.isEmpty {
                    cell.captionView.isHidden = false
                    cell.captionView.layer.cornerRadius = 8
                    cell.captionView.layer.borderWidth = 0.2
                    cell.captionView.layer.borderColor = UIColor.lightGray.cgColor
                    cell.captionLabel.text = caption
                }
            }

            self.refreshCollectionViewHeight()
            cell.layoutIfNeeded()

            return cell
        }

        return ProfilePosCollectionViewCell()
    }
}

extension ViewUserProfileController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Get the current text, assuming it is a Swift string
        let currentText = textField.text ?? ""
        
        // Calculate the new text string after the change
        guard let stringRange = Range(range, in: currentText) else {
            return false
        }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        // Check if the updated text is empty
        if updatedText.isEmpty {
            self.usePostModels.removeAll()
            self.usePostModels.append(contentsOf: self.postModels)
            self.collectionView.reloadData()
        }
        
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            if textField == searchTF {
                if let searchText = textField.text, !searchText.isEmpty {
                    self.searchBtnClicked(searchText: searchText)
                }
                else {
                    self.usePostModels.removeAll()
                    self.usePostModels.append(contentsOf: self.postModels)
                    self.collectionView.reloadData()
                }
               
            }
            return true
        }
}
