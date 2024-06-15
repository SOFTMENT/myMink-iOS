// Copyright © 2023 SOFTMENT. All rights reserved.

import AVFoundation
import Firebase
import SDWebImage
import UIKit
import Combine

// MARK: - ReelViewController

class ReelViewController: UIViewController {
    var videoURL: URL?

    // MARK: - IBOutlets

    @IBOutlet var addReelView: UIImageView!
    let refreshControl = UIRefreshControl()
    var postModels = [PostModel]()
    var pageSize = 15
    var postDocumentSnapshot: DocumentSnapshot?
    var dataMayContinue = true
    @IBOutlet var tableView: UITableView!
    let textView = UITextView(frame: CGRect.zero)
    var uniquePostIDs: Set<String> = Set()
    var activeCell: ReelsTableViewCell?
    var playerPool: PlayerPool!
    var isFetchingData = false
    var isScreenVisible = false
    var isAlreadyPlaying = false
    private var cancellables = Set<AnyCancellable>()
    let fileManager = FileManager.default

    // MARK: - Public Methods

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.isPagingEnabled = true
        self.tableView.contentInsetAdjustmentBehavior = .never
        let refreshView = UIView(frame: CGRect(x: 0, y: 70, width: 0, height: 0))
        self.tableView.addSubview(refreshView)
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.tintColor = .white
        self.refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        refreshView.addSubview(self.refreshControl)

        self.addReelView.isUserInteractionEnabled = true
        self.addReelView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.addReelViewClicked)
        ))
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(resumeAVPlayer),
            name: NSNotification.Name("ResumeAVPlayerNotification"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(pauseAVPlayer),
            name: NSNotification.Name("PauseAVPlayerNotification"),
            object: nil
        )
        
       
        
        self.getDeletedPostId { postID in
            if let index = self.postModels.firstIndex(where: { postModel in
                if postModel.postID == postID {
                    return true
                }
                return false
            }) {
                self.postModels.remove(at: index)

                self.tableView.reloadData()
            }
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
        
        self.playerPool = PlayerPool(playerCount: 5)
    }
    
    private func updateCommentCount(for postID: String) {
        guard let index = postModels.firstIndex(where: { $0.postID == postID }) else { return }
            let indexPath = IndexPath(row: index, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) as? ReelsTableViewCell {
                cell.updateCommentCount(postID: postID)
            }
        }
    
    private func updateSavedButton(for postID: String) {
        guard let index = postModels.firstIndex(where: { $0.postID == postID }) else { return }
            let indexPath = IndexPath(row: index, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) as? ReelsTableViewCell {
            cell.updateSavedButton(isFromCell: false)
            }
        }
    
    private func updateFavoriteButton(for postID: String) {
        guard let index = postModels.firstIndex(where: { $0.postID == postID }) else { return }
            let indexPath = IndexPath(row: index, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) as? ReelsTableViewCell {
            cell.updateFavoriteButton(isFromCell: false)
            }
        }
    func scrollToTop(animated: Bool) {
        tableView.setContentOffset(.zero, animated: animated)
    }
    
    @objc func addReelViewClicked() {
        performSegue(withIdentifier: "reelPostPopupSeg", sender: nil)
    }

    override func viewWillDisappear(_: Bool) {
        self.pauseAllPlayers()
    }

    override func viewWillAppear(_: Bool) {
        self.isScreenVisible = true
        self.playAllPlayers()
    }

    func playAllPlayers() {
        if let activeCell = activeCell, isScreenVisible, !isAlreadyPlaying, Constants.selectedTabbarPosition == 4 {
            self.isAlreadyPlaying = true
            self.isScreenVisible = true
            activeCell.player?.playImmediately(atRate: 1)
        }
    }

    func pauseAllPlayers() {
        if let activeCell = activeCell {
            self.isScreenVisible = false
            self.isAlreadyPlaying = false

            DispatchQueue.main.async {
                activeCell.player?.pause()
            }
        }
    }

    @objc func refresh(_: AnyObject) {
        let indexPathsToDelete = (0 ..< self.postModels.count).map { IndexPath(row: $0, section: 0) }
        self.postModels.removeAll()
        self.tableView.deleteRows(at: indexPathsToDelete, with: .automatic)
        self.uniquePostIDs.removeAll()
        self.postDocumentSnapshot = nil
        self.getAllPosts(isManual: true)
    }

    func deletePostClicked(postModel: PostModel, completion : @escaping (_ error : String?)->Void) {
       

        self.deletePost(postId: postModel.postID ?? "123") { error in
            completion(error)
        }
    }

    func getAllPosts(isManual: Bool) {
        if self.postDocumentSnapshot == nil {
            ProgressHUDShow(text: "")
        }

        var query = FirebaseStoreManager.db.collection(Collections.POSTS.rawValue).order(by: "postCreateDate", descending: true).whereField("isActive", isEqualTo: true)
            .whereField("postType", isEqualTo: "video").whereField("isPromoted", isEqualTo: true)

        if let documentSnapshot = postDocumentSnapshot {
            query = query.start(afterDocument: documentSnapshot)
        }
        query.limit(to: self.pageSize).getDocuments { snapshot, _ in
            self.refreshControl.endRefreshing()
            self.postDocumentSnapshot = nil
            self.dataMayContinue = false
            var x = 0
            if let snapshot = snapshot, !snapshot.isEmpty {
                let group = DispatchGroup()
                for qdr in snapshot.documents {
                    group.enter()

                    if let postModel = try? qdr.data(as: PostModel.self) {
                        if let path = postModel.postVideo {
                            
                            self.checkCurrentUserLikedPost(postID: postModel.postID ?? "123") { isLike in
                                FavoritesManager.shared.setFavorites(with: postModel.postID ?? "123", isLiked: isLike)
                            }
                        
                            self.checkCurrentUserSavePost(postID: postModel.postID ?? "123") { isLike in
                                SavedManager.shared.setSave(with: postModel.postID ?? "123", isSave: isLike)
                            }
                            
                            let videoURL = "\(Constants.AWS_VIDEO_BASE_URL)\(path)"
                            if let url = URL(string: videoURL) {
                                if SDImageCache.shared.diskImageData(forKey: url.absoluteString) == nil {
                                    self.downloadMP4File(from: url)
                                }
                            }
                        }

                        if !self.uniquePostIDs.contains(postModel.postID ?? "") {
                            if let bid = postModel.bid , !bid.isEmpty {
                                self.getBusinesses(by: bid)  { businessModel, _ in
                                    if let businessModel = businessModel {
                                        x = x + 1
                                        postModel.businessModel = businessModel
                                        self.uniquePostIDs.insert(postModel.postID ?? "123")
                                        self.postModels.append(postModel)
                                    }
                                    else {
                                  
                                        self.businessPostdeletedErrorFirebase(error: "Post Deleted REELViewController Business")
                                        self.deletePostClicked(postModel: postModel) { _ in
                                            
                                        }
                                    }
                                    group.leave()
                                }
                            }
                            else {
                                self.getUserDataByID(uid: postModel.uid ?? "123") { userModel, _ in
                                    if let userModel = userModel {
                                        x = x + 1
                                        
                                        postModel.userModel = userModel
                                        self.uniquePostIDs.insert(postModel.postID ?? "123")
                                        self.postModels.append(postModel)
                                    } else {
                                     
                                        self.businessPostdeletedErrorFirebase(error: "Post Deleted REELViewController USER")
                                        self.deletePostClicked(postModel: postModel) { _ in
                                            
                                        }
                                    }
                                    group.leave()
                                }
                            }
                          
                            
                        } else {
                            group.leave()
                        }
                    }
                }

                group.notify(queue: .main) {
                    if snapshot.documents.count >= self.pageSize {
                        self.postDocumentSnapshot = snapshot.documents.last
                        self.dataMayContinue = true
                    }

                    self.postModels.sort { postModel1, postModels2 in
                        if postModel1.postCreateDate! > postModels2.postCreateDate! {
                            return true
                        }
                        return false
                    }

                    self.ProgressHUDHide()

                    if isManual {
                        self.isFetchingData = false
                        let startIndex = self.postModels.count - x
                        let indexPaths = (startIndex ..< self.self.postModels.count)
                            .map { IndexPath(row: $0, section: 0) }
                        self.tableView.insertRows(at: indexPaths, with: .none)
                    }
                }
            } else {
                self.ProgressHUDHide()
            }
        }
    }

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

    @objc func showUserProfile(value: MyGesture) {
        if let userModel = postModels[value.index].userModel {
            performSegue(withIdentifier: "reelViewUserSeg", sender: userModel)
        }
        else  if let businessModel = postModels[value.index].businessModel {
            performSegue(withIdentifier: "showBusinessSeg", sender: businessModel)
        }
       
    }

    @objc func likeBtnClicked(gest: MyGesture) {
        onPressLikeButton(postId: self.postModels[gest.index].postID ?? "123", gest: gest)
    }

    @objc func commentClicked(value: MyGesture) {
        performSegue(withIdentifier: "reelCommentSeg", sender: self.postModels[value.index])
    }

    @objc func shareBtnClicked(value: MyGesture) {
        let postModel = self.postModels[value.index]

        if let postType = postModel.postType {
            if postType == "video" {
                if let shareURL = postModel.shareURL, !shareURL.isEmpty {
                    self.shareImageAndVideo(postCell: nil, link: shareURL, postId: postModel.postID!)
                } else {
                    self.showSnack(messages: "Share URL not found.")
                }
            }
        }
    }

    func fetchMoreData() {
        guard self.postDocumentSnapshot != nil, self.dataMayContinue else {
            return
        }

        self.dataMayContinue = false

        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.color = UIColor.darkGray
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        self.tableView.tableFooterView = spinner
        self.getAllPosts(isManual: true)
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource

// MARK: - Extensions

extension ReelViewController: UITableViewDelegate, UITableViewDataSource {


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "reelCommentSeg" {
            if let vc = segue.destination as? CommentViewController {
                if let value = sender as? PostModel {
                    vc.postModel = value
                  
                }
            }
        } else if segue.identifier == "reelViewUserSeg" {
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
        else if segue.identifier == "reelCreatePostSeg" {
            if let VC = segue.destination as? CreatePostViewController {
                if sender is PostType {
                    VC.videoPath = self.videoURL
                    VC.postType = .VIDEO
                }
            }
        }
    }

    func getLocalAssetURL(for videoURL: String) -> URL? {
        let userDefaults = UserDefaults.standard
        if let localURLString = userDefaults.string(forKey: videoURL) {
            return URL(string: localURLString)
        }
        return nil
    }

    @objc func pauseAVPlayer() {
        self.pauseAllPlayers()
    }

    @objc func resumeAVPlayer() {
        self.isScreenVisible = true
        self.playAllPlayers()
    }

    @objc func saveBtnClicked(gest: MyGesture) {
        onPressSaveButton(postId: self.postModels[gest.index].postID ?? "123", gest: gest)
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

    func tableView(_: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt _: IndexPath) {
        if let cell = cell as? ReelsTableViewCell, let player = cell.player {
            player.pause()
        }
    }

    func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? ReelsTableViewCell, let player = cell.player {
            if self.playerPool.availablePlayers.isEmpty {
                self.playerPool.loadPlayers(playerCount: 6)
                self.tableView.reloadData()
            }
            self.activeCell = cell

            player.play()
        }

        let remainingItems = self.postModels.count - indexPath.row
        if remainingItems <= 3 && !self.isFetchingData {
            self.isFetchingData = true
            self.fetchMoreData()
        }
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        self.postModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView
            .dequeueReusableCell(withIdentifier: "reelsCell", for: indexPath) as? ReelsTableViewCell
        {
            let postModel = self.postModels[indexPath.row]

            let captionGest = MyLongPressGest(target: self, action: #selector(self.captionClicked(value:)))
            captionGest.value = postModel.caption ?? ""
            cell.caption.isUserInteractionEnabled = true
            cell.caption.addGestureRecognizer(captionGest)

            let shareGest = MyGesture(target: self, action: #selector(self.shareBtnClicked))
            shareGest.reelCell = cell
            shareGest.index = indexPath.row
            cell.shareView.isUserInteractionEnabled = true
            cell.shareView.addGestureRecognizer(shareGest)

            
            
           
            getCount(for: postModel.postID ?? "123", countType: "Comments") { count, error in
                if let count = count {
                    cell.commentCount.text = "\(count)"
                }
            }
           

            cell.watchCount.text = "\(postModel.watchCount ?? 0)"

    
            
            cell.saveImage.isUserInteractionEnabled = true
            let saveViewGest = MyGesture(target: self, action: #selector(saveBtnClicked))
            saveViewGest.index = indexPath.row
            saveViewGest.reelCell = cell
            cell.saveImage.addGestureRecognizer(saveViewGest)

            cell.videoImage.translatesAutoresizingMaskIntoConstraints = false
            cell.userProfile.roundCorners(corners: .allCorners, radius: cell.userProfile.bounds.width / 2)

            if let videoImagePath = postModel.videoImage, !videoImagePath.isEmpty {
                var newConstraint = cell.videoRatio.constraintWithMultiplier(9.0 / 16)
                if let orientation = postModel.postVideoRatio {
                    newConstraint = cell.videoRatio.constraintWithMultiplier(orientation)
                }

                cell.videoMainView.removeConstraint(cell.videoRatio)
                cell.videoMainView.addConstraint(newConstraint)
                cell.videoMainView.layoutIfNeeded()
                cell.videoRatio = newConstraint

                let placeholder1 = SDAnimatedImage(named: "imageload.gif")
                cell.videoImage.image = placeholder1
            }

            if let path = postModel.postVideo {
                if cell.player == nil {
                    if let player = playerPool.getPlayer() {
                        cell.playerLayer?.removeFromSuperlayer()
                        cell.playerLayer = nil
                        cell.returnPlayerDelegate = self
                        cell.player = player
                        cell.playerLayer?.videoGravity = .resizeAspectFill

                        let videoURL = "\(Constants.AWS_VIDEO_BASE_URL)\(path)"

                        if let url = URL(string: videoURL) {
                            if let videoData = SDImageCache.shared
                                .diskImageData(forKey: url.absoluteString)
                            {
                                let documentsDirectoryURL = FileManager.default.urls(
                                    for: .documentDirectory,
                                    in: .userDomainMask
                                ).first!
                                let fileURL = documentsDirectoryURL
                                    .appendingPathComponent(url.lastPathComponent)

                                try? videoData.write(to: fileURL, options: .atomic)

                                let playerItem = CustomPlayerItem(url: fileURL, videoPostID: postModel.postID ?? "123")
                                cell.player!.replaceCurrentItem(with: playerItem)

                                // Setup your player view and play the video.
                            } else {
                                downloadMP4File(from: url)
                                // Continue to play online while downloading for cache
                                let playerItem = CustomPlayerItem(
                                    url: URL(string: videoURL)!,
                                    videoPostID: postModel.postID ?? "123"
                                )
                                cell.player!.replaceCurrentItem(with: playerItem)
                            }
                            self.playerPool.observePlayer(player)
                            let playerLayer = AVPlayerLayer(player: player)
                            playerLayer.frame = cell.videoImage.bounds
                            cell.videoImage.layer.addSublayer(playerLayer)
                            cell.playerLayer = playerLayer
                        }
                    }
                }
            }

            cell.videoImage.clipsToBounds = true

            if let caption = postModel.caption {
                cell.caption.isHidden = false
                cell.caption.text = caption
            } else {
                cell.caption.isHidden = true
            }

            cell.date.text = (postModel.postCreateDate ?? Date()).timeAgoSinceDate()

            
            if let businessModel = postModel.businessModel {
                postModel.notificationToken = businessModel.notificationToken
            }
            else {
                postModel.notificationToken = postModel.userModel!.notificationToken
            }

                let commentGest = MyGesture(target: self, action: #selector(self.commentClicked))
                commentGest.index = indexPath.row
                cell.commentView.isUserInteractionEnabled = true
                cell.commentView.addGestureRecognizer(commentGest)

                let favGest = MyGesture(target: self, action: #selector(self.likeBtnClicked))
                favGest.reelCell = cell
                favGest.index = indexPath.row
                cell.enjoyImage.isUserInteractionEnabled = true
                cell.enjoyImage.addGestureRecognizer(favGest)
                
                    cell.configure(with: postModel, vc: self)
                

                cell.nameAndDateStack.isUserInteractionEnabled = true
              
                  
           
                    
                    let userGest = MyGesture(target: self, action: #selector(self.showUserProfile))
                userGest.index = indexPath.row
                    cell.nameAndDateStack.addGestureRecognizer(userGest)
                   
               

                let userGest1 = MyGesture(target: self, action: #selector(self.showUserProfile))
                userGest1.index = indexPath.row
                cell.userProfile.isUserInteractionEnabled = true
                cell.userProfile.addGestureRecognizer(userGest1)
            var profilePic : String?
            if let userModel = postModel.userModel {
               profilePic = userModel.profilePic

            }
            else  {
                profilePic = postModel.businessModel!.profilePicture

            }
            
            if let profilePath = profilePic, !profilePath.isEmpty {
                cell.userProfile.setImage(
                    imageKey: profilePath,
                    placeholder: "profile-placeholder",
                    width: 100,
                    height: 100,
                    shouldShowAnimationPlaceholder: true
                )
            }

            if let userModel = postModel.userModel {
                cell.userName.text = userModel.fullName ?? ""
            }
            else {
                cell.userName.text = postModel.businessModel!.name ?? ""
            }
           

            cell.moreBtn.isUserInteractionEnabled = true
            cell.moreBtn.showsMenuAsPrimaryAction = true
            let report = UIAction(
                title: "Report",
                image: UIImage(systemName: "exclamationmark.triangle.fill")
            ) { _ in

                self.alertWithTF(postID: postModel.postID ?? "123")
            }

            cell.moreBtn.menu = UIMenu(title: "", children: [report])

            return cell
        }

        return ReelsTableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        CGFloat(tableView.bounds.height)
    }
}

// MARK: ReloadTableViewDelegate

extension ReelViewController: ReloadTableViewDelegate {
    func reloadTableView() {
        self.tableView.reloadData()
    }
}

// MARK: UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension ReelViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        self
            .videoURL =
            info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.mediaURL.rawValue)] as? URL
        dismiss(animated: true) {
            self.performSegue(withIdentifier: "reelCreatePostSeg", sender: PostType.VIDEO)
        }
    }
}

// MARK: ReturnPlayerDelegate

extension ReelViewController: ReturnPlayerDelegate {
    func returnPlayer(player: AVPlayer) {
        self.playerPool.returnPlayer(player)
    }
}
