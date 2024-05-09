// Copyright © 2023 SOFTMENT. All rights reserved.

import Amplify
import ATGMediaBrowser
import AVFoundation
import AVKit
import Combine
import Firebase
import SDWebImage
import UIKit
import Combine

// MARK: - PostViewController

class PostViewController: UIViewController {
    @IBOutlet var backView: UIView!
    @IBOutlet var topUsername: UILabel!
    @IBOutlet var topPostLbl: UILabel!

    @IBOutlet var noPostsAvailable: UILabel!
    @IBOutlet var tableView: UITableView!
    var postSelectedIndex = 0
    var cell: PostTableViewCell!
    var postModels: [PostModel]!
    var userModel: UserModel?
    var businessModel : BusinessModel?
    let textView = UITextView(frame: CGRect.zero)
    /// In your type's instance variables
    var tabbar: TabbarViewController?
    var uniquePostIDs: Set<String> = Set()
    var activePlayers: [AVPlayer] = []
    var playerPool: PlayerPool!
    var position: Int!
    var isMute: Bool = true
    var topTitle : String?
    private var cancellables = Set<AnyCancellable>()
    override func viewDidLoad() {
        
        self.backView.isUserInteractionEnabled = true
        self.backView.dropShadow()
        self.backView.layer.cornerRadius = 8
        self.backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backBtnClicked)))

        self.playerPool = PlayerPool(playerCount: 6)

        if let userModel = self.userModel {
            self.topUsername.text = userModel.username!.uppercased()
            if postModels.count > 0 {
                self.tableView.contentInsetAdjustmentBehavior = .never
                self.tableView.showsVerticalScrollIndicator = false
                self.tableView.scrollIndicatorInsets = .zero
                self.tableView.delegate = self
                self.tableView.dataSource = self

                DispatchQueue.main.async {
                    self.tableView.scrollToRow(at: IndexPath(row: self.position, section: 0), at: .top, animated: false)
                }
           
            }
        } 
        else if let businessModel = self.businessModel {
            self.topUsername.text = businessModel.name!.uppercased()
            if postModels.count > 0 {
                self.tableView.contentInsetAdjustmentBehavior = .never
                self.tableView.showsVerticalScrollIndicator = false
                self.tableView.scrollIndicatorInsets = .zero
                self.tableView.delegate = self
                self.tableView.dataSource = self

                DispatchQueue.main.async {
                    self.tableView.scrollToRow(at: IndexPath(row: self.position, section: 0), at: .top, animated: false)
                }
           
            }
        }
        else {
            self.topUsername.isHidden = true
            self.topPostLbl.text = "Explore"
            if postModels.count > 0 {
                self.loadUserData()
            }
        }
        
        
      
       
        self.tableView.showsVerticalScrollIndicator = false
        
        if let topTitle = self.topTitle {
            self.topPostLbl.text = topTitle
        }
        
        FavoritesManager.shared.favoriteChanged
                   .sink { [weak self] postID in
                       self?.updateFavoriteButton(for: postID)
                   }
                   .store(in: &cancellables)
        
        SavedManager.shared.saveChanged
                   .sink { [weak self] postID in
                       self?.updateSavedButton(for: postID)
                   }
                   .store(in: &cancellables)
        
        CommentManager.shared.commentChanged
                    .sink { [weak self] postID in
                        self?.updateCommentCount(for: postID)
                    }
                    .store(in: &cancellables)
    }
    
    private func updateFavoriteButton(for postID: String) {
        guard let index = postModels.firstIndex(where: { $0.postID == postID }) else { return }
            let indexPath = IndexPath(row: index, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) as? PostTableViewCell {
            cell.updateFavoriteButton(isFromCell: false)
            }
        }
    private func updateCommentCount(for postID: String) {
        guard let index = postModels.firstIndex(where: { $0.postID == postID }) else { return }
            let indexPath = IndexPath(row: index, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) as? PostTableViewCell {
                cell.updateCommentCount(postID: postID)
            }
        }
    private func updateSavedButton(for postID: String) {
        guard let index = postModels.firstIndex(where: { $0.postID == postID }) else { return }
            let indexPath = IndexPath(row: index, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) as? PostTableViewCell {
            cell.updateSavedButton(isFromCell: false)
            }
        }
    
    func loadUserData() {
        ProgressHUDShow(text: "")
        let group = DispatchGroup()
        for postModel in self.postModels {
            self.checkCurrentUserLikedPost(postID: postModel.postID ?? "123") { isLike in
                FavoritesManager.shared.setFavorites(with: postModel.postID ?? "123", isLiked: isLike)
            }
            group.enter()
            
            if let bid = postModel.bid , !bid.isEmpty {
                getBusinesses(by: bid)  { businessModel, _ in

                    if let businessModel = businessModel {
                        postModel.businessModel = businessModel
                       
                    } else {
                        
                        self.businessPostdeletedErrorFirebase(error: "Post Deleted PostViewController Business")
                    
                        self.deletePostClicked(postModel: postModel) { _ in
                            
                        }
                        self.postModels.remove(postModel)
                    }
                    group.leave()
                }
            }
            else {
                getUserDataByID(uid: postModel.uid ?? "123") { userModel, _ in

                    if let userModel = userModel {
                        
                        postModel.userModel = userModel
                    } else {
                      
                        self.businessPostdeletedErrorFirebase(error: "Post Deleted PostViewController User")
                        self.deletePostClicked(postModel: postModel) { _ in
                            
                        }
                        self.postModels.remove(postModel)
                    }
                    group.leave()
                }
            }

            
        }

        group.notify(queue: .main) {
            self.ProgressHUDHide()
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.reloadData()
            DispatchQueue.main.async {
                self.tableView.scrollToRow(at: IndexPath(row: self.position, section: 0), at: .top, animated: false)
            }

            self.handleScroll()
        }
    }

    @objc func backBtnClicked() {
        dismiss(animated: false)
    }

    override func viewWillDisappear(_: Bool) {
        self.pauseAllPlayers()
    }
    
    @objc func likeViewClicked(value : MyGesture){
        self.ProgressHUDShow(text: "")
        self.getLikes(postId: value.id) { likeModels in
            self.ProgressHUDHide()
            var usersIds = Array<String>()
            for likeModel in likeModels!  {
                if let userId = likeModel.userID {
                    usersIds.append(userId)
                }
                
            }
            self.performSegue(withIdentifier: "showUsersSeg", sender: usersIds)
        }
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        handleScroll()
    }

    @objc func shareBtnClicked(value: MyGesture) {
        let postModel = self.postModels[value.index]

        if let postType = postModel.postType {
            if postType == "image" || postType == "video" {
                if let shareURL = postModel.shareURL, !shareURL.isEmpty {
                    self.shareImageAndVideo(postCell: value.postCell, link: shareURL, postId: postModel.postID!)
                } else {
                    self.showSnack(messages: "Share URL not found.")
                }
            } else {
                if let image = preparePostScreenshot(view: value.postCell.mView) {
                    var imagesToShare = [AnyObject]()
                    imagesToShare.append(image)

                    let activityViewController = UIActivityViewController(
                        activityItems: imagesToShare,
                        applicationActivities: nil
                    )
                    activityViewController.popoverPresentationController?.sourceView = view
                    activityViewController.completionWithItemsHandler = { (_, completed: Bool, _: [Any]?, _: Error?) in
                        if completed {
                            value.postCell.shareCount.text = "\(Int(value.postCell.shareCount.text ?? "0")! + 1)"
                            self.addShares(postID: postModel.postID!)
                        }
                    }
                    present(activityViewController, animated: true, completion: nil)
                }
            }
        }
    }

    @objc func likeBtnClicked(gest: MyGesture) {
        onPressLikeButton( postId: self.postModels[gest.index].postID ?? "123", gest: gest)
    }

    func alertWithTF(postID: String) {
        let alertController = UIAlertController(
            title: "Report",
            message: "\n\n\n\n\n",
            preferredStyle: .alert
        ) // Added extra newlines for textView space

        let textView = UITextView(frame: CGRect.zero)
        textView.backgroundColor = UIColor.white
        textView.layer.cornerRadius = 8
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)

        alertController.view.addSubview(textView)

        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)

        let saveAction = UIAlertAction(title: "Submit", style: .default) { _ in
            let enteredText = textView.text
            if enteredText != "" {
                self.reportPost(reason: enteredText ?? "", postID: postID) { message in
                    self.showSnack(messages: message)
                }
            }
        }
        alertController.addAction(saveAction)

        // Constraints for the textView (Positioning it within the UIAlertController)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: alertController.view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: alertController.view.trailingAnchor, constant: -16),
            textView.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 50),
            textView.heightAnchor.constraint(equalToConstant: 80)
        ])

        present(alertController, animated: true, completion: nil)
    }

    @objc func commentClicked(value: MyGesture) {
        performSegue(withIdentifier: "profilePostCommentSeg", sender: self.postModels[value.index])
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "profilePostCommentSeg" {
            if let vc = segue.destination as? CommentViewController {
                if let value = sender as? PostModel {
                    vc.postModel = value
                 
                }
            }
        } else if segue.identifier == "profileEditPostSeg" {
            if let VC = segue.destination as? EditPostViewController {
                if let postModel = sender as? PostModel {
                    VC.postModel = postModel
                    VC.updatePostDelegate = self
                }
            }
        } else if segue.identifier == "userPostViewUserProfileSeg" {
            if let vc = segue.destination as? ViewUserProfileController {
                if let user = sender as? UserModel {
                    vc.user = user
                }
            }
        }
        else if segue.identifier == "showBusinessSeg" {
            if let vc = segue.destination as? ShowBusinessProfileViewController {
                if let businessModel = sender as? BusinessModel {
                    vc.businessModel = businessModel
                }
            }
        }
        else if segue.identifier == "showUsersSeg" {
            if let VC = segue.destination as? UsersListViewController {
                if let usersIds = sender as? Array<String> {
                    VC.userModelsIDs = usersIds
                    VC.headTitle  = "Enjoys"
                }
            }
        }
    }

    @objc func postVideoClicked(value: MyGesture) {
        let postModel = self.postModels[value.index]

        if let path = postModel.postVideo {
            value.postCell.player?.pause()

            let videoURL = "\(Constants.AWS_VIDEO_BASE_URL)\(path)"

            let player = AVPlayer(url: URL(string: videoURL)!)
            let vc = AVPlayerViewController()
            vc.player = player
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true) {
                vc.player?.play()
            }
        }
    }

    @objc func postImageClicked(value: MyGesture) {
        self.postSelectedIndex = value.index
        self.cell = value.postCell
        let mediaBrowser = MediaBrowserViewController(index: value.currentSelectedImageIndex, dataSource: self)

        present(mediaBrowser, animated: true, completion: nil)
    }

    @objc func showUserProfile(value: MyGesture) {
        if let userModel = postModels[value.index].userModel {
            performSegue(withIdentifier: "userPostViewUserProfileSeg", sender: userModel)
        }
        else  if let businessModel = postModels[value.index].businessModel {
            performSegue(withIdentifier: "showBusinessSeg", sender: businessModel)
        }
    }

    func deletePostClicked(postModel: PostModel,completion: @escaping (String?) -> Void) {
       
        self.deletePost(postId: postModel.postID ?? "123") { error in
            completion(error)
        }

       
    }

    @objc func saveBtnClicked(gest: MyGesture) {
        onPressSaveButton(postId: self.postModels[gest.index].postID ?? "123", gest: gest)
    }
    
    @objc func muteUnmuteClicked(gest: MyGesture) {
        self.isMute = !self.isMute
        gest.postCell.player?.isMuted = self.isMute

        // Update all visible cells
        for cell in self.tableView.visibleCells as! [PostTableViewCell] {
            cell.muteUnmuteBtn
                .image = (self.isMute) ? UIImage(named: "mute") :
                UIImage(named: "unmute")
        }
    }

    func pauseAllPlayers() {
        for player in self.activePlayers {
            player.pause()
        }
    }


    
    
    // Function to resume all active players if needed

    @objc func captionClicked(value: MyLongPressGest) {
        let caption = value.value

        if UIPasteboard.general.string == caption {
            return
        }
        UIPasteboard.general.string = caption
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        showSnack(messages: "Caption has copied.")
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource

extension PostViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt _: IndexPath) {
        if let cell = cell as? PostTableViewCell, let player = cell.player {
            player.pause()
        }
    }

    func scrollViewDidScroll(_: UIScrollView) {
        self.handleScroll()
    }

    func handleScroll() {
        if let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows, !indexPathsForVisibleRows.isEmpty {
            var focusCell: PostTableViewCell?

            for indexPath in indexPathsForVisibleRows {
                if let cell = tableView.cellForRow(at: indexPath) as? PostTableViewCell {
                    if focusCell == nil {
                        let rect = cell.videoImage.bounds
                        let rect1 = self.tableView.rectForRow(at: indexPath)
                        let tableRect = CGRect(
                            x: rect1.minX,
                            y: rect1.minY + 200,
                            width: rect1.width,
                            height: rect.height - 250
                        )

                        if self.tableView.bounds.contains(tableRect) {
                            if self.playerPool.availablePlayers.isEmpty {
                                self.playerPool.loadPlayers(playerCount: 6)
                                self.tableView.reloadData()
                            }

                            cell.player?.automaticallyWaitsToMinimizeStalling = false
                            cell.player?.playImmediately(atRate: 1)

                            focusCell = cell
                        } else {
                            cell.player?.isMuted = self.isMute
                            cell.muteUnmuteBtn.image = self.isMute ? UIImage(named: "mute") : UIImage(named: "unmute")
                            cell.player?.pause()
                        }
                    } else {
                        cell.player?.pause()
                    }
                }
            }
        }
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        self.noPostsAvailable.isHidden = self.postModels.count > 0 ? true : false
        return self.postModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostTableViewCell

        if self.postModels.count > indexPath.row {
            let postModel = self.postModels[indexPath.row]
            var userModel: UserModel?
            var businessModel : BusinessModel?
            
            
            if let business = postModel.businessModel {
                businessModel = business
            }
            else if let business = self.businessModel {
                businessModel = business
            }
            else if let user = postModel.userModel {
                userModel = user
            }
            else if let user = self.userModel {
                userModel = user
            }
           
            else {
             
                self.businessPostdeletedErrorFirebase(error: "Post Deleted PostViewController CELL")
                self.deletePostClicked(postModel: postModel) { _ in
                    
                }
                self.postModels.remove(postModel)
                self.tableView.reloadData()
            }

            
            cell.sponsoredStack.isHidden = true
            //Sponsored Check
            if let bid = postModel.bid, !bid.isEmpty {
                cell.sponsoredStack.isHidden = false
            }
            
            cell.image1.isHidden = true
            cell.image2.isHidden = true
            cell.image3.isHidden = true
            cell.image4.isHidden = true
            cell.videoMainView.isHidden = true

            cell.image1.image = UIImage(named: "placeholder")
            cell.image2.image = UIImage(named: "placeholder")
            cell.image3.image = UIImage(named: "placeholder")
            cell.image4.image = UIImage(named: "placeholder")

            cell.profilePic.image = UIImage(named: "profile-placeholder")

            cell.mView.layer.cornerRadius = 8
            cell.profilePic.makeRounded()
            cell.image1.layer.cornerRadius = 8
            cell.image2.layer.cornerRadius = 8
            cell.image3.layer.cornerRadius = 8
            cell.image4.layer.cornerRadius = 8

            let captionGest = MyLongPressGest(target: self, action: #selector(self.captionClicked(value:)))
            captionGest.value = postModel.caption ?? ""
            cell.postDesc.isUserInteractionEnabled = true
            cell.postDesc.addGestureRecognizer(captionGest)

           
            
        
            

            var uiMenuElements = [UIMenuElement]()

            cell.moreBtn.isUserInteractionEnabled = true
            cell.moreBtn.showsMenuAsPrimaryAction = true
            
            if businessModel != nil {
                if postModel.isPromoted == nil || postModel.isPromoted! == false {
                    let promote = UIAction(
                        title: "Promote",
                        image: UIImage(systemName: "square.and.arrow.up.fill")
                    ) { _ in
                        
                        self.ProgressHUDShow(text: "Promoting...")
                      
                        FirebaseStoreManager.db.collection("Posts").document(postModel.postID!).setData(["isPromoted" : true], merge: true) { error in
                            self.ProgressHUDHide()
                            self.showSnack(messages: "Promoted")
                            postModel.isPromoted = true
                        }
                        
                    }
                    
                    uiMenuElements.append(promote)
                }
               
            }
            
            let edit = UIAction(
                title: "Edit",
                image: UIImage(systemName: "pencil.circle.fill")
            ) { _ in

                self.performSegue(withIdentifier: "profileEditPostSeg", sender: postModel)
            }
            let delete = UIAction(
                title: "Delete",
                image: UIImage(systemName: "trash.fill")
            ) { _ in

                self.ProgressHUDShow(text: "Deleting...")
                self.deletePostClicked(postModel: postModel) { error in
                    
                    DispatchQueue.main.async {
                        self.ProgressHUDHide()
                        if let error  = error {
                            self.showError(error)
                        }
                    }
                }
            }

            if FirebaseStoreManager.auth.currentUser!.uid == postModel.uid {
                uiMenuElements.append(edit)
                uiMenuElements.append(delete)
            }

            let report = UIAction(
                title: "Report",
                image: UIImage(systemName: "exclamationmark.triangle.fill")
            ) { _ in

                self.alertWithTF(postID: postModel.postID ?? "123")
            }

            uiMenuElements.append(report)
            
            if let caption = postModel.caption, !caption.isEmpty {
                let transalte = UIAction(title: "Translate", image: UIImage(systemName: "translate")) { _ in
                    self.ProgressHUDShow(text: "Translating...")
                    TranslationService.shared.translateText(text: caption) { translate in
                        DispatchQueue.main.async {
                            self.ProgressHUDHide()
                            cell.postDesc.text = translate.removingPercentEncoding ?? ""
                        }
                    }
                }
                uiMenuElements.append(transalte)
            }                    
            
            
           
            
            cell.moreBtn.menu = UIMenu(title: "", children: uiMenuElements)
            // cell.moreBtn.menu?.setValue(<#T##value: Any?##Any?#>, forKey: <#T##String#>)

            cell.createDate.text = convertDateFormaterWithoutDash(postModel.postCreateDate ?? Date())
            cell.createTime.text = "| \(convertDateIntoTime(postModel.postCreateDate ?? Date()))"
            cell.postDesc.text = postModel.caption ?? ""
          
            cell.commentCount.text = "\(postModel.comment ?? 0)"

            let shareGest = MyGesture(target: self, action: #selector(self.shareBtnClicked))
            shareGest.postCell = cell
            shareGest.index = indexPath.row
            cell.shareView.isUserInteractionEnabled = true
            cell.shareView.addGestureRecognizer(shareGest)

           
            getCount(for: postModel.postID ?? "123", countType: "Shares") { count, error in
                if let count = count {
                    cell.shareCount.text = "\(count)"
                }
            }
           
            getCount(for: postModel.postID ?? "123", countType: "Comments") { count, error in
                if let count = count {
                    cell.commentCount.text = "\(count)"
                }
            }
            
       
            
           
            cell.configure(with: postModel, vc: self)
            
            checkCurrentUserSavePost(postID: postModel.postID ?? "123"){ isSaved in
                if isSaved {
                    cell.saveImage.image = UIImage(systemName: "bookmark.fill")
                    cell.saveImage.tintColor = UIColor(red: 154/255, green: 154/255, blue: 154/255, alpha: 1)
                } else {
                    cell.saveImage.image = UIImage(systemName: "bookmark")
                    cell.saveImage.tintColor = UIColor(red: 154/255, green: 154/255, blue: 154/255, alpha: 1)
                }
            }
            
            cell.saveView.isUserInteractionEnabled = true
            let saveViewGest = MyGesture(target: self, action: #selector(saveBtnClicked))
            saveViewGest.index = indexPath.row
            saveViewGest.postCell = cell
            cell.saveView.addGestureRecognizer(saveViewGest)

            if postModel.postType == "image" {
                cell.videoMainView.isHidden = true

                if let postImages = postModel.postImages, !postImages.isEmpty {
                    cell.imageStack.isHidden = false

                    for i in 0 ..< (postImages.count) {
                        let myImageClickedGest = MyGesture(target: self, action: #selector(self.postImageClicked))
                        myImageClickedGest.index = indexPath.row
                        myImageClickedGest.postCell = cell

                        if i == 0 {
                            cell.image1.isUserInteractionEnabled = true

                            var newConstraint = cell.image1Ratio.constraintWithMultiplier(1)

                            if let orientations = postModel.postImagesOrientations {
                                newConstraint = cell.image1Ratio.constraintWithMultiplier(orientations[0])
                            }
                            cell.image1.removeConstraint(cell.image1Ratio)
                            cell.image1.addConstraint(newConstraint)
                            cell.image1.layoutIfNeeded()
                            cell.image1Ratio = newConstraint

                            myImageClickedGest.currentSelectedImageIndex = 0
                            cell.image1.addGestureRecognizer(myImageClickedGest)
                            cell.image1.isHidden = false

                            cell.image1.setImage(
                                imageKey: postImages[i],
                                placeholder: "placeholder",
                                width: 900,
                                height: 900,
                                shouldShowAnimationPlaceholder: true
                            )
                        } else if i == 1 {
                            var newConstraint = cell.image2Ratio.constraintWithMultiplier(1)
                            if let orientations = postModel.postImagesOrientations {
                                newConstraint = cell.image2Ratio.constraintWithMultiplier(orientations[1])
                            }
                            cell.image2.removeConstraint(cell.image2Ratio)
                            cell.image2.addConstraint(newConstraint)
                            cell.image2.layoutIfNeeded()
                            cell.image2Ratio = newConstraint

                            cell.image2.isUserInteractionEnabled = true
                            myImageClickedGest.currentSelectedImageIndex = 1
                            cell.image2.addGestureRecognizer(myImageClickedGest)
                            cell.image2.isHidden = false

                            cell.image2.setImage(
                                imageKey: postImages[i],
                                placeholder: "placeholder",
                                width: 900,
                                height: 900,
                                shouldShowAnimationPlaceholder: true
                            )
                        } else if i == 2 {
                            var newConstraint = cell.image3Ratio.constraintWithMultiplier(1)
                            if let orientations = postModel.postImagesOrientations {
                                newConstraint = cell.image3Ratio.constraintWithMultiplier(orientations[2])
                            }

                            cell.image3.removeConstraint(cell.image3Ratio)
                            cell.image3.addConstraint(newConstraint)
                            cell.image3.layoutIfNeeded()
                            cell.image3Ratio = newConstraint

                            cell.image3.isUserInteractionEnabled = true
                            myImageClickedGest.currentSelectedImageIndex = 2
                            cell.image3.addGestureRecognizer(myImageClickedGest)
                            cell.image3.isHidden = false

                            cell.image3.setImage(
                                imageKey: postImages[i],
                                placeholder: "placeholder",
                                width: 900,
                                height: 900,
                                shouldShowAnimationPlaceholder: true
                            )
                        } else if i == 3 {
                            var newConstraint = cell.image4Ratio.constraintWithMultiplier(1)
                            if let orientations = postModel.postImagesOrientations {
                                newConstraint = cell.image4Ratio.constraintWithMultiplier(orientations[3])
                            }
                            cell.image4.removeConstraint(cell.image4Ratio)
                            cell.image4.addConstraint(newConstraint)
                            cell.image4.layoutIfNeeded()
                            cell.image4Ratio = newConstraint

                            cell.image4.isUserInteractionEnabled = true
                            myImageClickedGest.currentSelectedImageIndex = 3
                            cell.image4.addGestureRecognizer(myImageClickedGest)
                            cell.image4.isHidden = false

                            cell.image4.setImage(
                                imageKey: postImages[i],
                                placeholder: "placeholder",
                                width: 900,
                                height: 900,
                                shouldShowAnimationPlaceholder: true
                            )
                        }
                    }
                }
            } else if postModel.postType == "video" {
                cell.imageStack.isHidden = true

                if let videoImagePath = postModel.videoImage, !videoImagePath.isEmpty {
                    var newConstraint = cell.videoRatio.constraintWithMultiplier(9.0 / 16)
                    if let orientation = postModel.postVideoRatio {
                        newConstraint = cell.videoRatio.constraintWithMultiplier(orientation)
                    }

                    cell.videoMainView.removeConstraint(cell.videoRatio)
                    cell.videoMainView.addConstraint(newConstraint)
                    cell.videoRatio = newConstraint

                    cell.videoImage.isUserInteractionEnabled = true
                    let myVideoGesture = MyGesture(target: self, action: #selector(self.postVideoClicked))
                    myVideoGesture.index = indexPath.row
                    myVideoGesture.postCell = cell
                    cell.videoImage.addGestureRecognizer(myVideoGesture)
                    cell.videoMainView.isHidden = false
                    cell.videoImage.setImage(
                        imageKey: videoImagePath,
                        placeholder: "placeholder",
                        width: 900,
                        height: 900,
                        shouldShowAnimationPlaceholder: true
                    )
                    cell.videoMainView.layoutIfNeeded()
                }

                cell.muteUnmuteBtn.isUserInteractionEnabled = true
                let muteGest = MyGesture(target: self, action: #selector(self.muteUnmuteClicked(gest:)))
                muteGest.index = indexPath.row
                muteGest.postCell = cell
                cell.muteUnmuteBtn.addGestureRecognizer(muteGest)

                cell.videoImage.layer.cornerRadius = 8
                cell.videoImage.clipsToBounds = true
            }

            if let path = postModel.postVideo {
                if let player = playerPool.getPlayer() {
                    self.activePlayers.append(player)
                    cell.playerLayer?.removeFromSuperlayer()
                    cell.playerLayer = nil
                    cell.player = player
                    cell.returnPlayerDelegate = self
                    let videoURL = "\(Constants.AWS_VIDEO_BASE_URL)\(path)"
                    let playerItem = CustomPlayerItem(
                        url: URL(string: videoURL)!,
                        videoPostID: postModel.postID ?? "123"
                    )
                    playerItem.preferredForwardBufferDuration = 3
                    player.replaceCurrentItem(with: playerItem)
                    let playerLayer = AVPlayerLayer(player: player)
                    playerLayer.videoGravity = .resizeAspectFill

                    cell.videoImage.layer.addSublayer(playerLayer)
                    cell.playerLayer = playerLayer
                    self.playerPool.observePlayer(player)

                    cell.player?.isMuted = self.isMute
                    cell.muteUnmuteBtn.image = self.isMute ? UIImage(named: "mute") : UIImage(named: "unmute")
                }
            }
            
        
            
            cell.nameAndDateStack.isUserInteractionEnabled = true
           
             
               
                let userGest = MyGesture(target: self, action: #selector(self.showUserProfile))
                userGest.index = indexPath.row
                cell.nameAndDateStack.addGestureRecognizer(userGest)
               
            
            
            cell.likeView.isUserInteractionEnabled = true
            let likeViewGest = MyGesture(target: self, action: #selector(likeViewClicked))
            likeViewGest.id = postModel.postID ?? ""
            cell.likeView.addGestureRecognizer(likeViewGest)
          
            cell.profilePic.isUserInteractionEnabled = true

            if let userModel = userModel {
                postModel.notificationToken = userModel.notificationToken

            }
            else  {
                postModel.notificationToken = businessModel!.notificationToken

            }
            
            let commentGest = MyGesture(target: self, action: #selector(self.commentClicked))
            commentGest.index = indexPath.row
            commentGest.postCell = cell
            cell.commentView.isUserInteractionEnabled = true
            cell.commentView.addGestureRecognizer(commentGest)

            let favGest = MyGesture(target: self, action: #selector(self.likeBtnClicked))
            favGest.postCell = cell
            favGest.index = indexPath.row
            cell.likeImage.isUserInteractionEnabled = true
            cell.likeImage.addGestureRecognizer(favGest)

          

            let userGest1 = MyGesture(target: self, action: #selector(self.showUserProfile))
            userGest1.index = indexPath.row
            cell.profilePic.addGestureRecognizer(userGest1)

            var profilePic : String?
            if let userModel = userModel {
               profilePic = userModel.profilePic

            }
            else  {
                profilePic = businessModel!.profilePicture

            }
            
            if let profilePath = profilePic, !profilePath.isEmpty {
                cell.profilePic.setImage(
                    imageKey: profilePath,
                    placeholder: "profile-placeholder",
                    width: 100,
                    height: 100,
                    shouldShowAnimationPlaceholder: true
                )
            }

            if let userModel = userModel {
                cell.userName.text = userModel.fullName ?? ""
            }
            else {
                cell.userName.text = businessModel!.name ?? ""
            }
          
        }

        return cell
    }
}

// MARK: MediaBrowserViewControllerDataSource

extension PostViewController: MediaBrowserViewControllerDataSource {
    func mediaBrowser(
        _: ATGMediaBrowser.MediaBrowserViewController,
        imageAt index: Int,
        completion: @escaping CompletionBlock
    ) {
        if index == 0 {
            completion(index, self.cell.image1.image!, ZoomScale.default, nil)
        } else if index == 1 {
            completion(index, self.cell.image2.image!, ZoomScale.default, nil)
        } else if index == 2 {
            completion(index, self.cell.image3.image!, ZoomScale.default, nil)
        } else {
            completion(index, self.cell.image4.image!, ZoomScale.default, nil)
        }
    }

    func numberOfItems(in _: ATGMediaBrowser.MediaBrowserViewController) -> Int {
        self.postModels[self.postSelectedIndex].postImages!.count
    }
}

// MARK: ReloadTableViewDelegate

extension PostViewController: ReloadTableViewDelegate {
    func reloadTableView() {
        self.tableView.reloadData()
        self.handleScroll()
    }
}

// MARK: ReturnPlayerDelegate

extension PostViewController: ReturnPlayerDelegate {
    func returnPlayer(player: AVPlayer) {
        self.playerPool.returnPlayer(player)
        self.activePlayers.remove(player)
    }
}

// MARK: UpdatePostDelegate

extension PostViewController: UpdatePostDelegate {
    func updatePost(postModel: PostModel) {
        if let foundIndex = postModels.firstIndex(where: { $0.postID == postModel.postID }) {
            self.postModels[foundIndex].caption = postModel.caption

            let indexPath = IndexPath(row: foundIndex, section: 0)
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}
