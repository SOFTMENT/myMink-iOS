// Copyright © 2023 SOFTMENT. All rights reserved.

import AVFoundation
import CropViewController
import SDWebImage
import UIKit
import Lottie

// MARK: - ProfileViewController

class ProfileViewController: UIViewController, NotifyWhenSpotifyUpdateDelegate {
    func refreshBySpotify() {
        DispatchQueue.main.async {
            if self.isViewLoaded && self.view.window != nil {
                self.performSegue(withIdentifier: "musicDashSeg", sender: nil)
            }
        }
    }
    
    @IBOutlet weak var topFollowersLbl: UILabel!
    @IBOutlet weak var verificationBadge: UIImageView!
    @IBOutlet var followingView: UIView!
    @IBOutlet var followersView: UIView!
    @IBOutlet var followersCount: UILabel!
    @IBOutlet var followingCount: UILabel!
    @IBOutlet var topPostCount: UILabel!
    @IBOutlet var viewCount: UILabel!
    let settingsVC = SettingsViewController()
    @IBOutlet var settingsBtn: UIImageView!
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

    @IBOutlet var eventView: UIView!
    @IBOutlet var marketView: UIView!
    @IBOutlet var todoView: UIView!
    @IBOutlet var cryptoView: UIView!

    @IBOutlet var userProfile: SDAnimatedImageView!
    @IBOutlet var fullName: UILabel!
    @IBOutlet var username: UILabel!
    @IBOutlet var userstatsView: UIView!
    @IBOutlet var noPostsAvailable: UILabel!
    @IBOutlet var joiningDate: UILabel!
    @IBOutlet var addAutographBtn: UIButton!

    @IBOutlet var signatureImage: UIImageView!

    @IBOutlet weak var filterBtn: UIButton!
    
    
    @IBOutlet var searchTF: UITextField!
    @IBOutlet var musicView: UIView!
    
    @IBOutlet weak var horoscopeView: UIView!
    
    @IBOutlet weak var myMinkBotView: UIView!
    
    @IBOutlet var topPostLbl: UILabel!
    @IBOutlet var topViewLbl: UILabel!
    
    @IBOutlet weak var followersLoading: LottieAnimationView!
    @IBOutlet weak var followingLoading: LottieAnimationView!
    @IBOutlet weak var postLoading: LottieAnimationView!
    @IBOutlet weak var viewLoading: LottieAnimationView!
    
    @IBOutlet weak var businessView: UIView!
    

    override func viewDidLoad() {
        guard let user = UserModel.data else {
            DispatchQueue.main.async {
                self.logoutPlease()
            }
            return
        }

        
        searchTF.delegate = self
        
        followersLoading.loopMode = .loop
        followersLoading.contentMode = .scaleAspectFill
        followersLoading.play()
        
        
        followingLoading.loopMode = .loop
        followingLoading.contentMode = .scaleAspectFill
        followingLoading.play()
        
        postLoading.loopMode = .loop
        postLoading.contentMode = .scaleAspectFill
        postLoading.play()
        
        viewLoading.loopMode = .loop
        viewLoading.contentMode = .scaleAspectFill
        viewLoading.play()
        
        
        
        self.scrollView.contentInsetAdjustmentBehavior = .never

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

        self.userProfile.makeRounded()
        self.userstatsView.layer.cornerRadius = 8

        if let autoGraphImage = user.autoGraphImage, !autoGraphImage.isEmpty {
            self.signatureImage.setImage(imageKey: autoGraphImage, placeholder: "", width: 100, height: 100)
            self.addAutographBtn.isHidden = true
            self.signatureImage.isHidden = false
        } else {
            self.addAutographBtn.isHidden = false
            self.signatureImage.isHidden = true
        }

        self.filterBtn.layer.cornerRadius = 8
        self.searchTF.layer.cornerRadius = 8
        self.searchTF.setLeftPaddingPoints(16)
        self.searchTF.setRightPaddingPoints(10)
        self.searchTF.setLeftIcons(icon: UIImage(systemName: "magnifyingglass")!)

        self.signatureImage.isUserInteractionEnabled = true
        self.signatureImage.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.autoGraphClicked)
        ))

        self.eventView.layer.cornerRadius = 8
        self.eventView.isUserInteractionEnabled = true
        self.eventView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(eventViewClicked)))
        
        self.horoscopeView.isUserInteractionEnabled = true
        self.horoscopeView.layer.cornerRadius = 8
        self.horoscopeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(horoscopeClicked)))
        
        self.marketView.layer.cornerRadius = 8
        self.marketView.isUserInteractionEnabled  = true
        self.marketView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(marketViewClicked)))
        
        self.todoView.layer.cornerRadius = 8
        self.todoView.isUserInteractionEnabled = true
        self.todoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(todoViewClicked)))
        
        self.myMinkBotView.isUserInteractionEnabled = true
        self.myMinkBotView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(myMinkBotClicked)))
        
        
        self.cryptoView.layer.cornerRadius = 8
        self.musicView.layer.cornerRadius = 8

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

        self.websiteView.isHidden = true
        self.websiteView.isUserInteractionEnabled = true
        self.websiteView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.websiteClicked)
        ))

        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        let flowLayout = UICollectionViewFlowLayout()
        let width = self.collectionView.bounds.width
        flowLayout.itemSize = CGSize(width: (width / 3) - 5, height: (width / 3) - 5)
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.vertical
        flowLayout.minimumInteritemSpacing = 0
        self.collectionView.collectionViewLayout = flowLayout

        self.joiningDate.text = "Joined on \(convertDateFormaterWithoutDash(user.registredAt ?? Date()))"

        getPostsBy(uid: FirebaseStoreManager.auth.currentUser!.uid, accountType: .USER) { pModels, error in

            if let error = error {
                self.showError(error)
            } else {
                self.usePostModels.removeAll()
                self.postModels.removeAll()
                if let pModels = pModels, !pModels.isEmpty {
                    self.postModels.append(contentsOf: pModels)
                    self.usePostModels.append(contentsOf: pModels)
                }
                let count = self.postModels.count
                self.postLoading.isHidden = true
                self.topPostCount.isHidden = false
                
               
                self.topPostLbl.text = count > 1 ? "Posts" : "Post"
                self.topPostCount.text = "\(count)"
                self.collectionView.reloadData()
            }
        }
    

        self.addAutographBtn.layer.cornerRadius = 6

        // SettingsClicked
        self.settingsBtn.isUserInteractionEnabled = true
        self.settingsBtn.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.settingsClicked)
        ))

        // CryptoViewClicked
        self.cryptoView.isUserInteractionEnabled = true
        self.cryptoView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.cryptoCurrencyClicked)
        ))
        
        //BusinessClicked
        self.businessView.isUserInteractionEnabled = true
        self.businessView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(businessClicked)))

        // MusicClicked
        self.musicView.isUserInteractionEnabled = true
        self.musicView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.musicClicked)))

        refreshUI()

        // LongPressed
        let gest1 = MyLongPressGest(target: self, action: #selector(self.lblClicked))
        gest1.value = self.phoneNumber.text ?? ""
        self.phoneNumber.isUserInteractionEnabled = true
        self.phoneNumber.addGestureRecognizer(gest1)

        let gest2 = MyLongPressGest(target: self, action: #selector(self.lblClicked))
        gest2.value = self.emailAddress.text ?? ""
        self.emailAddress.isUserInteractionEnabled = true
        self.emailAddress.addGestureRecognizer(gest2)

        let gest3 = MyLongPressGest(target: self, action: #selector(self.lblClicked))
        gest3.value = self.website.text ?? ""
        self.website.isUserInteractionEnabled = true
        self.website.addGestureRecognizer(gest3)

        let gest4 = MyLongPressGest(target: self, action: #selector(self.lblClicked))
        gest4.value = self.address.text ?? ""
        self.address.isUserInteractionEnabled = true
        self.address.addGestureRecognizer(gest4)

        let gest5 = MyLongPressGest(target: self, action: #selector(self.lblClicked))
        gest5.value = self.bioGraphy.text ?? ""
        self.bioGraphy.isUserInteractionEnabled = true
        self.bioGraphy.addGestureRecognizer(gest5)

        if let sceneDelegate = UIApplication.shared.connectedScenes
            .first?.delegate as? SceneDelegate
        {
            sceneDelegate.spotifyDelegate = self
        }
        
    }
    
    @objc func businessClicked(){
        performSegue(withIdentifier: "businessSeg", sender: nil)
    }
    
    func scrollToTop(animated: Bool) {
        if scrollView != nil {
            scrollView.setContentOffset(.zero, animated: animated)
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

            self.performSegue(withIdentifier: "postViewSeg", sender: "image")
        }

        let video = UIAction(
            title: "Video",
            image: UIImage(systemName: "video.circle.fill")
        ) { _ in

            self.performSegue(withIdentifier: "postViewSeg", sender: "video")
        }
        
        let text = UIAction(
            title: "Text",
            image: UIImage(systemName: "text.quote")
        ) { _ in

            self.performSegue(withIdentifier: "postViewSeg", sender: "text")
        }
     
        uiMenuElements.append(image)
        uiMenuElements.append(video)
        uiMenuElements.append(text)

        filterBtn.menu = UIMenu(title: "", children: uiMenuElements)
    }
    
    @objc func marketViewClicked(){
        performSegue(withIdentifier: "marketplaceSeg", sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refresFromWillAppear()
       
        DispatchQueue.main.async {
            if Constants.FROM_EVENT_CREATE {
                Constants.FROM_EVENT_CREATE = false
                self.performSegue(withIdentifier: "eventSeg", sender: nil)
            }
        }
        
    }
    
    func refresFromWillAppear() {
        
        getCount(for: FirebaseStoreManager.auth.currentUser!.uid, countType: Collections.FOLLOW.rawValue) { mcount, error in
            var count  = 0
            if let mcount = mcount {
               count = mcount
            }
            
            self.followersLoading.isHidden = true
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
        
     
       
        getCount(for: FirebaseStoreManager.auth.currentUser!.uid, countType: "Following") { count, error in
            self.followingLoading.isHidden = true
            self.followingCount.isHidden = false
            self.followingCount.text = "\(count ?? 0)"
  
        }
        
        getCount(for: FirebaseStoreManager.auth.currentUser!.uid, countType: "ProfileViews") { count, error in
            self.viewLoading.isHidden = true
            self.viewCount.isHidden = false
            self.topViewLbl.text = (count ?? 0) > 1 ? "Views" : "View"
            self.viewCount.text = "\(count ?? 0)"
        }
    }
    
    
    @objc func myMinkBotClicked(){
        performSegue(withIdentifier: "myminkbotSeg", sender: nil)
    }
    
    @objc func horoscopeClicked(){
        performSegue(withIdentifier: "horoscopeSeg", sender: nil)
    }

    @objc func todoViewClicked(){
        let userDefaults = UserDefaults.standard
        if  userDefaults.bool(forKey: "todo2ndTime") {
            performSegue(withIdentifier: "todoDashboardSeg", sender: nil)
        }
        else {
            performSegue(withIdentifier: "todoOnboardSeg", sender: nil)
        
        }
    }
    
    func searchBtnClicked(searchText : String){
        ProgressHUDShow(text: "Searching...")
        algoliaSearch(searchText: searchText, indexName: .POSTS, filters: "uid:\(FirebaseStoreManager.auth.currentUser!.uid)") { models in
            
            DispatchQueue.main.async {
                self.ProgressHUDHide()
                
                self.usePostModels.removeAll()
                self.usePostModels.append(contentsOf: models as? [PostModel] ?? [])
                self.collectionView.reloadData()
                
            }
            
            
        }
    }
    
    @objc func musicClicked() {
        performSegue(withIdentifier: "musicDashSeg", sender: nil)
    }
    
    @objc func eventViewClicked(){
        performSegue(withIdentifier: "eventSeg", sender: nil)
    }

    @objc func lblClicked(value: MyLongPressGest) {
        let text = value.value

        if UIPasteboard.general.string == text {
            return
        }
        UIPasteboard.general.string = text
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        showSnack(messages: "Caption has copied.")
    }

    @objc func followersViewClicked() {
        
        self.ProgressHUDShow(text: "")
        self.getFollowersByUid(uid: FirebaseStoreManager.auth.currentUser!.uid) { followModels in
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

    @objc func followingViewClicked() {
        self.ProgressHUDShow(text: "")
        self.getFollowingByUid(uid: FirebaseStoreManager.auth.currentUser!.uid) { followModels in
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

    @objc func phoneClicked() {
        if let url = URL(string: "tel://\(UserModel.data!.phoneNumber ?? "")"), UIApplication.shared.canOpenURL(url) {
            let application = UIApplication.shared
            if application.canOpenURL(url) {
                application.open(url, options: [:], completionHandler: nil)
            }
        }
    }

    @objc func mailClicked() {
        if let url = URL(string: "mailto:\(UserModel.data!.email ?? "")") {
            let application = UIApplication.shared
            if application.canOpenURL(url) {
                application.open(url, options: [:], completionHandler: nil)
            }
        }
    }

    @objc func websiteClicked() {
        guard let url = URL(string: makeValidURL(urlString: UserModel.data!.website ?? "")) else {
            return
        }
        UIApplication.shared.open(url)
    }

    @objc func settingsClicked() {
        self.settingsVC.modalPresentationStyle = .custom
        self.settingsVC.transitioningDelegate = self
        present(self.settingsVC, animated: true, completion: nil)
    }

    @objc func cryptoCurrencyClicked() {
        performSegue(withIdentifier: "cryptoSeg", sender: nil)
    }

    func refreshCollectionViewHeight() {
        let width = self.collectionView.bounds.width
        self.collectionViewHeight
            .constant = CGFloat((width / CGFloat(3)) + 5) * CGFloat((self.usePostModels.count + 2) / 3)
    }

    @objc func postClicked(value: MyGesture) {
        performSegue(withIdentifier: "postViewSeg", sender: value.index)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "postViewSeg" {
            if let VC = segue.destination as? PostViewController {
                if let position = sender as? Int {
                    VC.postModels = self.usePostModels
                    VC.userModel = UserModel.data!
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
                    VC.userModel = UserModel.data!
                    VC.position = 0
                    VC.topTitle = "Filters"
                }
            }
        } else if segue.identifier == "updateProfileSeg" {
            if let VC = segue.destination as? EditProfileViewController {
                VC.delegate = self
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

    @objc func autoGraphClicked() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Replace Autograph", style: .default, handler: { _ in
            self.showUploadPopupAutograph()
        }))
        alert.addAction(UIAlertAction(title: "Remove Autograph", style: .destructive, handler: { _ in
            self.addAutographBtn.isHidden = false
            self.signatureImage.isHidden = true
            FirebaseStoreManager.db.collection(Collections.USERS.rawValue).document(FirebaseStoreManager.auth.currentUser!.uid)
                .setData(["autoGraphImage": ""], merge: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    @IBAction func addAutographBtnClicked(_: Any) {
        self.showUploadPopupAutograph()
    }

    func showUploadPopupAutograph() {
        let alert = UIAlertController(title: "Upload Autograph", message: "", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Using Camera", style: .default) { _ in

            let image = UIImagePickerController()
            image.title = "Autograph"
            image.delegate = self
            image.sourceType = .camera
            image.modalPresentationStyle = .overFullScreen
            self.present(image, animated: true)
        }

        let action2 = UIAlertAction(title: "From Photo Library", style: .default) { _ in

            let image = UIImagePickerController()
            image.delegate = self
            image.title = "Autograph"
            image.sourceType = .photoLibrary
            image.modalPresentationStyle = .overFullScreen
            self.present(image, animated: true)
        }

        let action3 = UIAlertAction(title: "Cancel", style: .cancel) { _ in

            alert.dismiss(animated: true, completion: nil)
        }

        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(action3)

        present(alert, animated: true, completion: nil)
    }
}

// MARK: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout
{
    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        let width = self.collectionView.bounds.width
        return CGSize(width: (width / 3) - 5, height: (width / 3) - 5)
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        self.postCount.text = self.usePostModels.count > 1 ? "\(self.usePostModels.count) Posts" : "\(self.usePostModels.count) Post"
        self.noPostsAvailable.isHidden = self.usePostModels.count > 0 ? true : false
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
                            placeholder: "placeholder",
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

// MARK: UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate,
    CropViewControllerDelegate
{
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        if let editedImage = info[.originalImage] as? UIImage {
            dismiss(animated: true) {
                let cropViewController = CropViewController(image: editedImage)
                cropViewController.title = picker.title
                cropViewController.delegate = self
                cropViewController.modalPresentationStyle = .fullScreen
                cropViewController.aspectRatioLockEnabled = false
                cropViewController.aspectRatioPickerButtonHidden = false
                self.present(cropViewController, animated: true)
            }
        }

        dismiss(animated: true, completion: nil)
    }

    func cropViewController(_: CropViewController, didFinishCancelled _: Bool) {
        dismiss(animated: true) {
            Constants.selectedTabbarPosition = 6
            self.beRootScreen(storyBoardName: StoryBoard.Tabbar, mIdentifier: Identifier.TABBARVIEWCONTROLLER)
        }
    }

    func cropViewController(_: CropViewController, didCropToImage image: UIImage, withRect _: CGRect, angle _: Int) {
        if let data = image.jpegData(compressionQuality: 0.8) {
            ProgressHUDShow(text: "")
            removeBackground(imageData: data) { transparentImageData, error in

                if let error = error {
                    self.ProgressHUDHide()
                    self.showError(error.localizedLowercase)
                } else {
                    self.signatureImage.image = UIImage(data: transparentImageData!)
                    self.addAutographBtn.isHidden = true
                    self.signatureImage.isHidden = false

                    self.uploadFilesOnAWS(
                        photo: UIImage(data: transparentImageData!),
                        previousKey: UserModel.data!.autoGraphImage,
                        folderName: "Autograph",
                        postType: .IMAGE,
                        shouldHideProgress: true,
                        type: "png"
                    ) { downloadURL in
                        self.ProgressHUDHide()
                        if let downloadURL = downloadURL {
                            
                        
                            
                            FirebaseStoreManager.db.collection(Collections.USERS.rawValue)
                                .document(FirebaseStoreManager.auth.currentUser!.uid)
                                .setData(["autoGraphImage": downloadURL], merge: true) { _ in
                                    UserModel.data!.autoGraphImage = downloadURL
                                    Constants.selectedTabbarPosition = 6
                                    self.beRootScreen(
                                        storyBoardName: StoryBoard.Tabbar,
                                        mIdentifier: Identifier.TABBARVIEWCONTROLLER
                                    )
                                }
                        } else {
                            self.showError("Upload ERROR")
                        }
                    }
                }
            }
        }

        dismiss(animated: true, completion: nil)
    }
}

// MARK: UIViewControllerTransitioningDelegate

extension ProfileViewController: UIViewControllerTransitioningDelegate {
    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source _: UIViewController
    ) -> UIPresentationController? {
        SettingsPresentationController(presentedViewController: presented, presenting: presenting, profileVC: self)
    }
}

// MARK: EditProfileDelegate

extension ProfileViewController: EditProfileDelegate {
    func refreshUI() {
        if let user = UserModel.data {
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
            } else {
                self.websiteView.isHidden = true
            }

            self.bioGraphy.text = user.biography ?? ""
            self.address.text = user.location ?? ""

            if let sphoneNumber = user.phoneNumber, !sphoneNumber.isEmpty {
                self.phoneNumberView.isHidden = false
                self.phoneNumber.text = sphoneNumber
            } else {
                self.phoneNumberView.isHidden = true
            }
            if let semail = user.email, !semail.isEmpty {
                self.emailAddressView.isHidden = false
                self.emailAddress.text = semail
            } else {
                self.emailAddressView.isHidden = true
            }
        }
    }
}

protocol NotifyWhenSpotifyUpdateDelegate {
    func refreshBySpotify()
}

extension ProfileViewController : UITextFieldDelegate {
    
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
