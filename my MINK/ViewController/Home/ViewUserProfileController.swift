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
    var socialMediaModels = [SocialMediaModel]()
    var amIFollowing: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUser()
        setupViews()
        setupGestures()
        fetchData()
    }

    private func setupUser() {
        guard let user = user else {
            dismiss(animated: true)
            return
        }

        if let isPrivate = user.isAccountPrivate, isPrivate {
            shouldHideUserPersonalInfo(isHidden: true)
        }

        if UserModel.data?.uid == user.uid {
            chatFollowStack.isHidden = true
            shouldHideUserPersonalInfo(isHidden: false)
            dotsView.isHidden = true
        }
    }

    private func setupViews() {
        followerLoading.setupLottie()
        followingLoading.setupLottie()
        postsLoading.setupLottie()
        viewsLoading.setupLottie()

        setupFollowersView()
        setupFollowingView()
        setupMessageButton()
        setupFollowButton()

        userProfile.makeRounded()
        userstatsView.layer.cornerRadius = 8
        scrollView.contentInsetAdjustmentBehavior = .never

        if let autoGraphImage = user?.autoGraphImage, !autoGraphImage.isEmpty {
            signatureImage.setImage(imageKey: autoGraphImage, placeholder: "", width: 100, height: 100)
            signatureImage.isHidden = false
            signView.isHidden = false
        } else {
            signatureImage.isHidden = true
            signView.isHidden = true
        }

        websiteView.setupHiddenView(target: self, action: #selector(websiteClicked))

        filterBtn.layer.cornerRadius = 8
        searchTF.layer.cornerRadius = 8
        searchTF.setLeftPaddingPoints(16)
        searchTF.setRightPaddingPoints(10)
        searchTF.setLeftIcons(icon: UIImage(systemName: "magnifyingglass")!)
        searchTF.delegate = self
        
        dotsView.isUserInteractionEnabled = true
        dotsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(menuClicked)))

        if let path = user?.profilePic, !path.isEmpty {
            userProfile.setImage(
                imageKey: path,
                placeholder: "profile-placeholder",
                width: 250,
                height: 250,
                shouldShowAnimationPlaceholder: true
            )
        }
        fullName.text = user?.fullName ?? "my MINK".localized()
        username.text = "@\(user?.username ?? "username".localized())"

        if let swebsite = user?.website, !swebsite.isEmpty {
            websiteView.isHidden = false
            website.text = swebsite
        }
        bioGraphy.text = user?.biography ?? ""
        address.text = user?.location ?? ""

        phoneNumberView.setupHiddenView(target: self, action: #selector(phoneClicked))
        emailAddressView.setupHiddenView(target: self, action: #selector(mailClicked))

        if let sphoneNumber = user?.phoneNumber, !sphoneNumber.isEmpty {
            phoneNumberView.isHidden = false
            phoneNumber.text = sphoneNumber
        }
        if let semail = user?.email, !semail.isEmpty {
            emailAddressView.isHidden = false
            emailAddress.text = semail
        }

        collectionView.delegate = self
        collectionView.dataSource = self
        let flowLayout = UICollectionViewFlowLayout()
        let width = collectionView.bounds.width
        flowLayout.itemSize = CGSize(width: (width / 3) - 5, height: (width / 3) - 5)
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = 0
        collectionView.collectionViewLayout = flowLayout

        joiningDate.text = String(format: "Joined on %@".localized(), convertDateFormaterWithoutDash(user?.registredAt ?? Date()))

    }

    
    @objc func menuClicked() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        ProgressHUDShow(text: "")
        
        isUserBlock(userId: user!.uid ?? "") { isUserBlock in
            self.ProgressHUDHide()
            
        
            alert.addAction(UIAlertAction(title: isUserBlock ? "Unblock \(self.user!.fullName ?? "")" : "Block \(self.user!.fullName ?? "")", style: .default, handler: { action in
             
                if isUserBlock {
                    self.ProgressHUDShow(text: "Unblocking...")
                    self.unBlockUser(blockedUserID: self.user!.uid ?? "") { error in
                        self.ProgressHUDHide()
                        if let error = error {
                            self.showError(error)
                        }
                        else {
                            self.showSnack(messages: "Unblocked successfully")
                        }
                        
                    }
                }
                else {
                    self.ProgressHUDShow(text: "Blocking...")
                    self.blockUser(blockedUserID: self.user!.uid ?? "") { error in
                        self.ProgressHUDHide()
                        if let error = error {
                            self.showError(error)
                        }
                        else {
                            self.followBtn.backgroundColor = UIColor(red: 210 / 255, green: 0, blue: 1 / 255, alpha: 1)
                            self.followBtn.isSelected = false
                            self.followBtn.setTitleColor(.white, for: .normal)
                            self.followBtn.setTitle("Follow".localized(), for: .normal)
                            self.deleteFollow(mainUserId: FirebaseStoreManager.auth.currentUser!.uid, followerUserId: self.user!.uid!) { _ in
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                    self.updateFollowersAndFollowingCount()
                                }
                            }
                            self.showSnack(messages: "Blocked successfully")
                        }
                        
                    }
                }
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(alert, animated: true)
            
        }
        
       
        
    }
    private func setupFollowersView() {
        followersView.isUserInteractionEnabled = true
        followersView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(followersViewClicked)))
    }

    private func setupFollowingView() {
        followingView.isUserInteractionEnabled = true
        followingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(followingViewClicked)))
    }

    private func setupMessageButton() {
        messageBtn.layer.cornerRadius = 8
    }

    private func setupFollowButton() {
        followBtn.layer.cornerRadius = 8
        followBtn.isSelected = false

        guard let currentUserID = UserModel.data?.uid, let userID = user?.uid else { return }

        FirebaseStoreManager.db.collection(Collections.users.rawValue).document(currentUserID)
            .collection(Collections.following.rawValue).document(userID).addSnapshotListener { snapshot, error in
                if error == nil {
                    if let snapshot = snapshot, snapshot.exists {
                        self.setupFollowingButton()
                    } else {
                        self.amIFollowing = false
                        if let isPrivate = self.user?.isAccountPrivate, isPrivate {
                            self.shouldHideUserPersonalInfo(isHidden: true)
                        }
                    }
                }
            }
    }

    private func setupFollowingButton() {
        followBtn.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        followBtn.isSelected = true
        followBtn.setTitleColor(.black, for: .selected)
        followBtn.setTitle("Following".localized(), for: .normal)
        amIFollowing = true
        shouldHideUserPersonalInfo(isHidden: false)
    }

    private func setupGestures() {
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        setupSocialMediaGestures()
    }

    private func setupSocialMediaGestures() {
        setupSocialMediaView(twitterView, action: #selector(socialViewClicked), socialType: .twitter)
        setupSocialMediaView(instagramView, action: #selector(socialViewClicked), socialType: .instagram)
        setupSocialMediaView(tiktokView, action: #selector(socialViewClicked), socialType: .tiktok)
        setupSocialMediaView(facebookView, action: #selector(socialViewClicked), socialType: .facebook)
        setupSocialMediaView(youtubeView, action: #selector(socialViewClicked), socialType: .youtube)
        setupSocialMediaView(rumView, action: #selector(socialViewClicked), socialType: .rumble)
        setupSocialMediaView(twitchView, action: #selector(socialViewClicked), socialType: .twitch)
        setupSocialMediaView(redditView, action: #selector(socialViewClicked), socialType: .reddit)
        setupSocialMediaView(tumblr, action: #selector(socialViewClicked), socialType: .tumblr)
        setupSocialMediaView(discordView, action: #selector(socialViewClicked), socialType: .discord)
        setupSocialMediaView(telegramView, action: #selector(socialViewClicked), socialType: .telegram)
        setupSocialMediaView(mastodonView, action: #selector(socialViewClicked), socialType: .mastodon)
        setupSocialMediaView(pintrestView, action: #selector(socialViewClicked), socialType: .pinterest)
        setupSocialMediaView(etsyView, action: #selector(socialViewClicked), socialType: .etsy)
        setupSocialMediaView(linkedinView, action: #selector(socialViewClicked), socialType: .linkedin)
        setupSocialMediaView(whatsAppView, action: #selector(socialViewClicked), socialType: .whatsapp)
    }

    private func setupSocialMediaView(_ view: UIView, action: Selector, socialType: SocialMedia) {
        view.isUserInteractionEnabled = true
        let gesture = MyGesture(target: self, action: action)
        gesture.socialType = socialType
        view.addGestureRecognizer(gesture)
    }

    private func fetchData() {
        guard let user = user,let userID = user.uid  else { return }
        
    
    
        getPostsBy(uid: userID, accountType: .user) { pModels, error in
            self.handlePostFetch(pModels: pModels, error: error)
        }
        if FirebaseStoreManager.auth.currentUser!.uid != userID {
            increaseProfileView(mUid: FirebaseStoreManager.auth.currentUser!.uid, mFriendUid: userID)
        }

        getCount(for: userID, countType: Collections.profileViews.rawValue) { count, error in
            self.handleProfileViewsCount(count: count)
        }

        updateFollowersAndFollowingCount()
        fetchSocialMedia()
    }

    private func handlePostFetch(pModels: [PostModel]?, error: String?) {
        if let error = error {
            showError(error)
        } else {
            usePostModels.removeAll()
            postModels.removeAll()
            if let pModels = pModels, !pModels.isEmpty {
                postModels.append(contentsOf: pModels)
                usePostModels.append(contentsOf: pModels)
            }
            updatePostCount()
        }
    }

    private func updatePostCount() {
        topPostCount.isHidden = false
        postsLoading.isHidden = true

        let count = postModels.count
        topPostsLbl.text = count > 1 ? "Posts".localized() : "Post".localized()
        topPostCount.text = "\(count)"
        collectionView.reloadData()
    }

    private func handleProfileViewsCount(count: Int?) {
        viewsLoading.isHidden = true
        viewCount.isHidden = false
        topViewsLbl.text = (count ?? 0) > 1 ? "Views".localized() : "View".localized()
        viewCount.text = "\(count ?? 0)"
    }

    private func fetchSocialMedia() {
        guard let userID = user?.uid else { return }

        getAllSocialMedia(uid: userID) { socialMediaModels in
            self.handleSocialMediaFetch(socialMediaModels: socialMediaModels)
        }
    }

    private func handleSocialMediaFetch(socialMediaModels: [SocialMediaModel]?) {
        hideAllSocialMedia()

        if let socialMediaModels = socialMediaModels {
            self.socialMediaModels = socialMediaModels
            socialMediaView.isHidden = self.socialMediaModels.isEmpty
            for model in socialMediaModels {
                updateSocialMediaView(model: model)
            }
        }
    }

    private func updateSocialMediaView(model: SocialMediaModel) {
        switch model.name {
        case SocialMedia.twitter.rawValue:
            updateSocialMediaNumber(view: twitterView, numberLabel: twitterNumber, circleView: twitterCircle)
        case SocialMedia.instagram.rawValue:
            updateSocialMediaNumber(view: instagramView, numberLabel: instagramNumber, circleView: instagramCircle)
        case SocialMedia.tiktok.rawValue:
            updateSocialMediaNumber(view: tiktokView, numberLabel: tikTokNumber, circleView: tiktokCircle)
        case SocialMedia.facebook.rawValue:
            updateSocialMediaNumber(view: facebookView, numberLabel: facebookNumber, circleView: facebookCircle)
        case SocialMedia.youtube.rawValue:
            updateSocialMediaNumber(view: youtubeView, numberLabel: youtubeNumber, circleView: youtubeCircle)
        case SocialMedia.rumble.rawValue:
            updateSocialMediaNumber(view: rumView, numberLabel: rumNumber, circleView: rumCircle)
        case SocialMedia.twitch.rawValue:
            updateSocialMediaNumber(view: twitchView, numberLabel: twitchNumber, circleView: twitchCircle)
        case SocialMedia.reddit.rawValue:
            updateSocialMediaNumber(view: redditView, numberLabel: redditNumber, circleView: redditCircle)
        case SocialMedia.tumblr.rawValue:
            updateSocialMediaNumber(view: tumblr, numberLabel: tumblrNumer, circleView: tumblrCircle)
        case SocialMedia.discord.rawValue:
            updateSocialMediaNumber(view: discordView, numberLabel: discordNumber, circleView: discordCircle)
        case SocialMedia.telegram.rawValue:
            updateSocialMediaNumber(view: telegramView, numberLabel: telegramNumber, circleView: telegramCircle)
        case SocialMedia.mastodon.rawValue:
            updateSocialMediaNumber(view: mastodonView, numberLabel: mastodonNumber, circleView: mastodonCircle)
        case SocialMedia.pinterest.rawValue:
            updateSocialMediaNumber(view: pintrestView, numberLabel: pintrestNumber, circleView: pintrestCircle)
        case SocialMedia.etsy.rawValue:
            updateSocialMediaNumber(view: etsyView, numberLabel: etsyNumber, circleView: etsyCircle)
        case SocialMedia.linkedin.rawValue:
            updateSocialMediaNumber(view: linkedinView, numberLabel: linkedinNumber, circleView: linkedinCircle)
        case SocialMedia.whatsapp.rawValue:
            updateSocialMediaNumber(view: whatsAppView, numberLabel: whatsAppNumber, circleView: whatsAppCircle)
        default:
            break
        }
    }

    private func updateSocialMediaNumber(view: UIView, numberLabel: UILabel, circleView: CircleView) {
        view.isHidden = false
        numberLabel.text = String((Int(numberLabel.text ?? "1") ?? 1) + 1)
        if (Int(numberLabel.text ?? "1") ?? 1) > 1 {
            circleView.isHidden = false
        }
    }

    @objc func socialViewClicked(value: MyGesture) {
        let models = socialMediaModels.filter { $0.name == value.socialType?.rawValue }

        if models.count > 1 {
            showAlertForOpen(models: models)
        } else if let link = models.first?.link, let url = URL(string: makeValidURL(urlString: link)) {
            self.openURL(link)
        }
    }
    
    private func openURL(_ urlString: String) {
        dismiss(animated: true)
        guard let url = URL(string: urlString) else {
            return
        }
        
        // Use the updated open method with options and completion handler
        UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
            if success {
                print("URL was opened successfully.")
            } else {
                print("Failed to open the URL.")
            }
        })
    }

    func showAlertForOpen(models: [SocialMediaModel]) {
        let alert = UIAlertController(title: nil, message: "Select Account".localized(), preferredStyle: .actionSheet)
        for model in models {
            alert.addAction(UIAlertAction(title: model.link ?? "NIL", style: .default) { _ in
                if let link = model.link, let url = URL(string: self.makeValidURL(urlString: link)) {
                    self.openURL(link)
                }
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        present(alert, animated: true)
    }

    func hideAllSocialMedia() {
        twitterView.hideViewWithNumber(numberLabel: twitterNumber, circleView: twitterCircle)
        instagramView.hideViewWithNumber(numberLabel: instagramNumber, circleView: instagramCircle)
        tiktokView.hideViewWithNumber(numberLabel: tikTokNumber, circleView: tiktokCircle)
        facebookView.hideViewWithNumber(numberLabel: facebookNumber, circleView: facebookCircle)
        youtubeView.hideViewWithNumber(numberLabel: youtubeNumber, circleView: youtubeCircle)
        rumView.hideViewWithNumber(numberLabel: rumNumber, circleView: rumCircle)
        twitchView.hideViewWithNumber(numberLabel: twitchNumber, circleView: twitchCircle)
        redditView.hideViewWithNumber(numberLabel: redditNumber, circleView: redditCircle)
        tumblr.hideViewWithNumber(numberLabel: tumblrNumer, circleView: tumblrCircle)
        discordView.hideViewWithNumber(numberLabel: discordNumber, circleView: discordCircle)
        telegramView.hideViewWithNumber(numberLabel: telegramNumber, circleView: telegramCircle)
        mastodonView.hideViewWithNumber(numberLabel: mastodonNumber, circleView: mastodonCircle)
        pintrestView.hideViewWithNumber(numberLabel: pintrestNumber, circleView: pintrestCircle)
        etsyView.hideViewWithNumber(numberLabel: etsyNumber, circleView: etsyCircle)
        linkedinView.hideViewWithNumber(numberLabel: linkedinNumber, circleView: linkedinCircle)
        whatsAppView.hideViewWithNumber(numberLabel: whatsAppNumber, circleView: whatsAppCircle)
    }

    func updateFollowersAndFollowingCount() {
        guard let user = user, let userID = user.uid else { return }

        

        getCount(for: userID, countType: Collections.follow.rawValue) { count, error in
            self.handleFollowerCount(count: count)
        }

        getCount(for: userID, countType: Collections.following.rawValue) { count, error in
            self.handleFollowingCount(count: count)
        }
    }

    private func handleFollowerCount(count: Int?) {
        followerLoading.isHidden = true
        followersCount.isHidden = false

        let count = count ?? 0
        topFollowersLbl.text = count > 1 ? "Followers".localized() : "Follower".localized()
        followersCount.text = "\(count)"

        if haveBlueTick(userModel: user) {
            verificationBadge.isHidden = false
            verificationBadge.image = UIImage(named: "verified")
        } else if haveBlackTick(userModel: user) {
            verificationBadge.isHidden = false
            verificationBadge.image = UIImage(named: "verification")
        } else {
            verificationBadge.isHidden = true
        }
    }

    private func handleFollowingCount(count: Int?) {
        followingLoading.isHidden = true
        followingCount.isHidden = false
        followingCount.text = "\(count ?? 0)"
    }

    func searchBtnClicked(searchText: String) {
        ProgressHUDShow(text: "Searching...".localized())
        guard let userID = self.user?.uid else { return }

        algoliaSearch(searchText: searchText, indexName: .posts, filters: "uid:\(userID)") { models in
            DispatchQueue.main.async {
                self.ProgressHUDHide()
                self.usePostModels = models as? [PostModel] ?? []
                self.collectionView.reloadData()
            }
        }
    }

    @IBAction func filterBtnClicked(_ sender: Any) {
        var uiMenuElements = [UIMenuElement]()

        filterBtn.isUserInteractionEnabled = true
        filterBtn.showsMenuAsPrimaryAction = true

        let image = UIAction(title: "Image".localized(), image: UIImage(systemName: "photo.circle.fill")) { _ in
            self.performSegue(withIdentifier: "viewprofilePostViewSeg", sender: "image")
        }

        let video = UIAction(title: "Video".localized(), image: UIImage(systemName: "video.circle.fill")) { _ in
            self.performSegue(withIdentifier: "viewprofilePostViewSeg", sender: "video")
        }

        let text = UIAction(title: "Text".localized(), image: UIImage(systemName: "text.quote")) { _ in
            self.performSegue(withIdentifier: "viewprofilePostViewSeg", sender: "text")
        }

        uiMenuElements.append(image)
        uiMenuElements.append(video)
        uiMenuElements.append(text)

        filterBtn.menu = UIMenu(title: "", children: uiMenuElements)
    }

    func shouldHideUserPersonalInfo(isHidden: Bool) {
        userPersonalnfoView.isHidden = isHidden
        userPostView.isHidden = isHidden
    }

    @objc func followersViewClicked() {
        guard let user = user else { return }

        if let isPrivate = user.isAccountPrivate, isPrivate, !amIFollowing {
            showMessage(title: "Private Account".localized(), message: "This account is private. Follow to see their followers, following & posts.".localized())
        } else {
            ProgressHUDShow(text: "")
            getFollowersByUid(uid: user.uid ?? "") { followModels in
                self.ProgressHUDHide()
                let usersIds = followModels?.compactMap { $0.uid } ?? []
                let value = ["title": "Followers", "users": usersIds]
                self.performSegue(withIdentifier: "usersListSeg", sender: value)
            }
        }
    }

    @objc func followingViewClicked() {
        guard let user = user else { return }

        if let isPrivate = user.isAccountPrivate, isPrivate, !amIFollowing {
            showMessage(title: "Private Account".localized(), message: "This account is private. Follow to see their followers, following & posts.".localized())
        } else {
            ProgressHUDShow(text: "")
            getFollowingByUid(uid: user.uid ?? "") { followModels in
                self.ProgressHUDHide()
                let usersIds = followModels?.compactMap { $0.uid } ?? []
                let value = ["title": "Following", "users": usersIds]
                self.performSegue(withIdentifier: "usersListSeg", sender: value)
            }
        }
    }

    @IBAction func messageBtnClicked(_: Any) {
        performSegue(withIdentifier: "viewProfileChatSeg", sender: nil)
    }

    @IBAction func followBtnClicked(_: Any) {
       

        guard let user = user, let currentUserID = UserModel.data?.uid, let userID = user.uid else { return }

        if !followBtn.isSelected {
            followBtn.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
            followBtn.isSelected = true
            followBtn.setTitleColor(.black, for: .selected)
            followBtn.setTitle("Following".localized(), for: .normal)
            addFollow(mUser: UserModel.data!, fUser: user)
            
            self.addNotification(to: "", userId: user.uid!, type: Notifications.following.rawValue)

            PushNotificationSender().sendPushNotification(
                title: "Good News",
                body: "\(UserModel.data?.fullName ?? "") is following you.",
                topic: user.notificationToken ?? ""
            )
        } else {
            followBtn.backgroundColor = UIColor(red: 210 / 255, green: 0, blue: 1 / 255, alpha: 1)
            followBtn.isSelected = false
            followBtn.setTitleColor(.white, for: .normal)
            followBtn.setTitle("Follow".localized(), for: .normal)

            deleteFollow(mainUserId: currentUserID, followerUserId: userID) { error in
                if error != nil {
                    self.setupFollowingButton()
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
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    @objc func mailClicked() {
        if let url = URL(string: "mailto:\(emailAddress.text ?? "")"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    @objc func websiteClicked() {
        guard let url = URL(string: makeValidURL(urlString: website.text ?? "")) else {
            return
        }
        UIApplication.shared.open(url)
    }

    func refreshCollectionViewHeight() {
        let width = collectionView.bounds.width
        collectionViewHeight.constant = CGFloat((width / CGFloat(3)) + 5) * CGFloat((usePostModels.count + 2) / 3)
    }

    @objc func postClicked(value: MyGesture) {
        performSegue(withIdentifier: "viewprofilePostViewSeg", sender: value.index)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewprofilePostViewSeg" {
            if let VC = segue.destination as? PostViewController {
                if let position = sender as? Int {
                    VC.postModels = usePostModels
                    VC.userModel = user
                    VC.position = position
                } else if let postType = sender as? String {
                    let postModels = usePostModels.filter { $0.postType == postType }
                    VC.postModels = postModels
                    VC.userModel = user
                    VC.position = 0
                    VC.topTitle = "Filters"
                }
            }
        } else if segue.identifier == "viewProfileChatSeg" {
            if let vc = segue.destination as? ShowChatViewController {
                let lastModel = LastMessageModel()
                lastModel.senderName = user?.fullName ?? "Full Name".localized()
                lastModel.senderUid = user?.uid ?? ""
                lastModel.senderToken = user?.notificationToken ?? "Token".localized()
                lastModel.senderImage = user?.profilePic ?? ""
                lastModel.senderDeviceToken = user?.deviceToken ?? ""
                vc.lastMessage = lastModel
            }
        } else if segue.identifier == "usersListSeg" {
            if let VC = segue.destination as? UsersListViewController {
                if let value = sender as? [String: Any] {
                    VC.userModelsIDs = value["users"] as? [String]
                    VC.headTitle = value["title"] as? String
                }
            }
        }
    }
}

// MARK: - Extensions

extension LottieAnimationView {
    func setupLottie() {
        loopMode = .loop
        contentMode = .scaleAspectFill
        play()
    }
}

extension UIView {
    func setupHiddenView(target: Any, action: Selector) {
        isHidden = true
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: target, action: action))
    }

    func hideViewWithNumber(numberLabel: UILabel, circleView: CircleView) {
        isHidden = true
        numberLabel.text = "0"
        circleView.isHidden = true
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
        self.postCount.text = self.usePostModels.count > 1
            ? String(format: "%d Posts".localized(), self.usePostModels.count)
            : String(format: "%d Post".localized(), self.usePostModels.count)

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
