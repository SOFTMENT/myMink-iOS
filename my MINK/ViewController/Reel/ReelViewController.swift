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
        super.viewDidLoad()
        setupUI()
        setupObservers()
        setupManagers()
        playerPool = PlayerPool(playerCount: 5, className: "reel")
        
     
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }

    private func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isPagingEnabled = true
        tableView.contentInsetAdjustmentBehavior = .never
        let refreshView = UIView(frame: CGRect(x: 0, y: 70, width: 0, height: 0))
        tableView.addSubview(refreshView)
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        refreshView.addSubview(refreshControl)

        addReelView.isUserInteractionEnabled = true
        addReelView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(addReelViewClicked)
        ))
    }

    private func setupObservers() {
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
    }

    private func fetchDeletedPosts() {
        getDeletedPostId { postID in
            if let index = self.postModels.firstIndex(where: { $0.postID == postID }) {
                self.postModels.remove(at: index)
                self.tableView.reloadData()
            }
        }
    }
   
    private func setupManagers() {
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

    private func updateCommentCount(for postID: String) {
      
        if isScreenVisible {
            guard let index = postModels.firstIndex(where: { $0.postID == postID }) else { return }
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) as? ReelsTableViewCell {
             
                 
                cell.updateCommentCount(postID: postID)
            }
        }
       
    }

    private func updateSavedButton(for postID: String) {
        if isScreenVisible {
            guard let index = postModels.firstIndex(where: { $0.postID == postID }) else { return }
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) as? ReelsTableViewCell {
                
                
                cell.updateSavedButton(isFromCell: false)
            }
        }
    }

    private func updateFavoriteButton(for postID: String) {
        if isScreenVisible {
            
            guard let index = postModels.firstIndex(where: { $0.postID == postID }) else { return }
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) as? ReelsTableViewCell {
                
                
                cell.updateFavoriteButton(isFromCell: false)
            }
        }
    }

    func scrollToTop(animated: Bool) {
        tableView.setContentOffset(.zero, animated: animated)
    }

    @objc func addReelViewClicked() {
        performSegue(withIdentifier: "reelPostPopupSeg", sender: nil)
    }

  

    override func viewWillAppear(_: Bool) {
        isScreenVisible = true
        playAllPlayers()
    }

    func playAllPlayers() {
        if let activeCell = activeCell, isScreenVisible, !isAlreadyPlaying, Constants.selectedTabBarPosition == 4 {
            isAlreadyPlaying = true
            isScreenVisible = true
            playerPool.availablePlayers.forEach { $0.pause() }
            activeCell.player?.playImmediately(atRate: 1)
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        pauseAllPlayers()
    }
    
    func pauseAllPlayers() {
        isScreenVisible = false
        isAlreadyPlaying = false
        playerPool.availablePlayers.forEach { player in
            player.pause()
        }
        activeCell?.player?.pause()
    }

    @objc func refresh(_: AnyObject) {
        let indexPathsToDelete = (0 ..< postModels.count).map { IndexPath(row: $0, section: 0) }
        postModels.removeAll()
        tableView.deleteRows(at: indexPathsToDelete, with: .automatic)
        uniquePostIDs.removeAll()
        postDocumentSnapshot = nil
        getAllPosts(isManual: true)
    }

    func deletePostClicked(postModel: PostModel, completion: @escaping (_ error: String?) -> Void) {
        deletePost(postId: postModel.postID ?? "123") { error in
            completion(error)
        }
    }

    func getAllPosts(isManual: Bool) {
      
        if postDocumentSnapshot == nil {
            ProgressHUDShow(text: "")
        }

        var query = FirebaseStoreManager.db.collection(Collections.posts.rawValue)
            .order(by: "postCreateDate", descending: true)
            .whereField("isActive", isEqualTo: true)
            .whereField("postType", isEqualTo: "video")
            .whereField("isPromoted", isEqualTo: true)

        if let documentSnapshot = postDocumentSnapshot {
            query = query.start(afterDocument: documentSnapshot)
        }
        query.limit(to: pageSize).getDocuments { snapshot, _ in
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
                            self.checkCurrentUserLikedPost(postID: postModel.postID ?? "") { isLike in
                             
                                FavoritesManager.shared.setFavorites(with: postModel.postID ?? "", isLiked: isLike)
                                
                            }
                            self.checkCurrentUserSavePost(postID: postModel.postID ?? "") { isSave in
                                 
                                SavedManager.shared.setSave(with: postModel.postID ?? "", isSave: isSave)
                            }

                            let videoURL = "\(Constants.awsVideoBaseURL)\(path)"
                            if let url = URL(string: videoURL) {
                                if SDImageCache.shared.diskImageData(forKey: url.absoluteString) == nil {
                                    self.downloadMP4File(from: url)
                                }
                            }
                        }

                        if !self.uniquePostIDs.contains(postModel.postID ?? "") {
                            if let bid = postModel.bid, !bid.isEmpty {
                                self.getBusinesses(by: bid) { businessModel, _ in
                                    if let businessModel = businessModel {
                                        x += 1
                                        postModel.businessModel = businessModel
                                        self.uniquePostIDs.insert(postModel.postID ?? "123")
                                        self.postModels.append(postModel)
                                    } else {
                                        self.businessPostdeletedErrorFirebase(error: "Post Deleted REELViewController Business".localized())
                                        self.deletePostClicked(postModel: postModel) { _ in }
                                    }
                                    group.leave()
                                }
                            } else {
                                self.getUserDataByID(uid: postModel.uid ?? "123") { userModel, _ in
                                    if let userModel = userModel {
                                        x += 1
                                        postModel.userModel = userModel
                                        self.uniquePostIDs.insert(postModel.postID ?? "123")
                                        self.postModels.append(postModel)
                                    } else {
                                        self.businessPostdeletedErrorFirebase(error: "Post Deleted REELViewController USER".localized())
                                        self.deletePostClicked(postModel: postModel) { _ in }
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

                    self.postModels.shuffle()
                    self.ProgressHUDHide()

                    if isManual {
                        self.isFetchingData = false
                        let startIndex = self.postModels.count - x
                        let indexPaths = (startIndex ..< self.self.postModels.count).map { IndexPath(row: $0, section: 0) }
                        self.tableView.insertRows(at: indexPaths, with: .none)
                        self.pauseAllPlayers()
                        self.fetchDeletedPosts()
                    }
                
                    self.tableView.tableFooterView = nil
                }
            } else {
                self.tableView.tableFooterView = nil
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
        } else if let businessModel = postModels[value.index].businessModel {
            performSegue(withIdentifier: "showBusinessSeg", sender: businessModel)
        }
    }

    @objc func likeBtnClicked(gest: MyGesture) {
        onPressLikeButton(postModel: postModels[gest.index] , gest: gest)
    }

    @objc func commentClicked(value: MyGesture) {
        performSegue(withIdentifier: "reelCommentSeg", sender: postModels[value.index])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "reelCommentSeg" {
            if let vc = segue.destination as? CommentViewController, let value = sender as? PostModel {
                vc.postModel = value
            }
        } else if segue.identifier == "reelViewUserSeg" {
            if let vc = segue.destination as? ViewUserProfileController, let user = sender as? UserModel {
                vc.user = user
            }
        } else if segue.identifier == "showBusinessSeg" {
            if let vc = segue.destination as? ShowBusinessProfileViewController, let businessModel = sender as? BusinessModel {
                vc.businessModel = businessModel
            }
        } else if segue.identifier == "reelCreatePostSeg" {
            if let VC = segue.destination as? CreatePostViewController, sender is PostType {
                VC.videoPath = videoURL
                VC.postType = .video
            }
        }
    }


    @objc func shareBtnClicked(value: MyGesture) {
        let postModel = postModels[value.index]
        if let postType = postModel.postType, postType == "video" {
            if let shareURL = postModel.shareURL, !shareURL.isEmpty {
                shareImageAndVideo(postCell: nil, link: shareURL, postId: postModel.postID!)
            } else {
                showSnack(messages: "Share URL not found.".localized())
            }
        }
    }

    func fetchMoreData() {
        guard postDocumentSnapshot != nil, dataMayContinue else {
            return
        }
        dataMayContinue = false
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.color = UIColor.darkGray
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        tableView.tableFooterView = spinner
        getAllPosts(isManual: true)
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource

extension ReelViewController: UITableViewDelegate, UITableViewDataSource {
   
    func getLocalAssetURL(for videoURL: String) -> URL? {
        let userDefaults = UserDefaults.standard
        if let localURLString = userDefaults.string(forKey: videoURL) {
            return URL(string: localURLString)
        }
        return nil
    }

    @objc func pauseAVPlayer() {
        pauseAllPlayers()
    }

    @objc func resumeAVPlayer() {
        isScreenVisible = true
        playAllPlayers()
    }

    @objc func saveBtnClicked(gest: MyGesture) {
        onPressSaveButton(postId: postModels[gest.index].postID ?? "123", gest: gest)
    }

    func alertWithTF(postID: String) {
        let alertController = UIAlertController(
            title: "Report".localized(),
            message: "\n\n\n\n\n",
            preferredStyle: .alert
        ) // Added extra newlines for textView space

        let textView = UITextView(frame: CGRect.zero)
        textView.backgroundColor = UIColor.white
        textView.layer.cornerRadius = 8
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)

        alertController.view.addSubview(textView)

        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .default, handler: nil)
        alertController.addAction(cancelAction)

        let saveAction = UIAlertAction(title: "Submit".localized(), style: .default) { _ in
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
            
            if playerPool.availablePlayers.isEmpty {
                playerPool.loadPlayers(playerCount: 6)
                tableView.reloadData()
                
            activeCell?.player?.pause()}
            
            activeCell = cell
            player.play()
        }

        let remainingItems = postModels.count - indexPath.row
        if remainingItems <= 3 && !isFetchingData {
            isFetchingData = true
            fetchMoreData()
        }
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        postModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "reelsCell", for: indexPath) as? ReelsTableViewCell {
            let postModel = postModels[indexPath.row]

            let captionGest = MyLongPressGest(target: self, action: #selector(captionClicked(value:)))
            captionGest.value = postModel.caption ?? ""
            cell.caption.isUserInteractionEnabled = true
            cell.caption.addGestureRecognizer(captionGest)

            let shareGest = MyGesture(target: self, action: #selector(shareBtnClicked))
            shareGest.reelCell = cell
            shareGest.index = indexPath.row
            cell.shareView.isUserInteractionEnabled = true
            cell.shareView.addGestureRecognizer(shareGest)

            getCount(for: postModel.postID ?? "123", countType: "Comments") { count, _ in
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

                        let videoURL = "\(Constants.awsVideoBaseURL)\(path)"

                        if let url = URL(string: videoURL) {
                            if let videoData = SDImageCache.shared.diskImageData(forKey: url.absoluteString) {
                                let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                                let fileURL = documentsDirectoryURL.appendingPathComponent(url.lastPathComponent)
                                try? videoData.write(to: fileURL, options: .atomic)
                                let playerItem = CustomPlayerItem(url: fileURL, videoPostID: postModel.postID ?? "123")
                                cell.player!.replaceCurrentItem(with: playerItem)
                            } else {
                                downloadMP4File(from: url)
                                let playerItem = CustomPlayerItem(url: URL(string: videoURL)!, videoPostID: postModel.postID ?? "123")
                                cell.player!.replaceCurrentItem(with: playerItem)
                            }
                            playerPool.observePlayer(player)
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
            } else {
                postModel.notificationToken = postModel.userModel!.notificationToken
            }

            let commentGest = MyGesture(target: self, action: #selector(commentClicked))
            commentGest.index = indexPath.row
            cell.commentView.isUserInteractionEnabled = true
            cell.commentView.addGestureRecognizer(commentGest)

            let favGest = MyGesture(target: self, action: #selector(likeBtnClicked))
            favGest.reelCell = cell
            favGest.index = indexPath.row
            cell.enjoyImage.isUserInteractionEnabled = true
            cell.enjoyImage.addGestureRecognizer(favGest)

            cell.configure(with: postModel, vc: self)

            cell.nameAndDateStack.isUserInteractionEnabled = true

            let userGest = MyGesture(target: self, action: #selector(showUserProfile))
            userGest.index = indexPath.row
            cell.nameAndDateStack.addGestureRecognizer(userGest)

            let userGest1 = MyGesture(target: self, action: #selector(showUserProfile))
            userGest1.index = indexPath.row
            cell.userProfile.isUserInteractionEnabled = true
            cell.userProfile.addGestureRecognizer(userGest1)

            var profilePic: String?
            if let userModel = postModel.userModel {
                profilePic = userModel.profilePic
            } else {
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
            } else {
                cell.userName.text = postModel.businessModel!.name ?? ""
            }

            cell.moreBtn.isUserInteractionEnabled = true
            cell.moreBtn.showsMenuAsPrimaryAction = true
            let report = UIAction(
                title: "Report".localized(),
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



// MARK: UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension ReelViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        videoURL = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.mediaURL.rawValue)] as? URL
        dismiss(animated: true) {
            self.performSegue(withIdentifier: "reelCreatePostSeg", sender: PostType.video)
        }
    }
}

// MARK: ReturnPlayerDelegate

extension ReelViewController: ReturnPlayerDelegate {
    func returnPlayer(player: AVPlayer) {
        playerPool.returnPlayer(player)
    }
}
