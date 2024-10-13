import ActiveLabel
import Amplify
import ATGMediaBrowser
import AVFoundation
import AVKit
import BranchSDK
import Combine
import CoreLocation
import Firebase
import SDWebImage
import UIKit
import CountryPicker
import FirebaseFirestore

// MARK: - HomeViewController
class HomeViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet var headerView: UIView!
    @IBOutlet var noPostsAvailable: UILabel!
    @IBOutlet var mName: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var addView: UIView!
    @IBOutlet weak var tempLbl: UILabel!
    @IBOutlet weak var tempView: UIView!
    @IBOutlet var notificationView: UIView!
    @IBOutlet var scannerView: UIView!
    @IBOutlet var messageView: UIView!
    @IBOutlet var searchTF: UITextField!
    @IBOutlet var filterBtn: UIView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var mProfilePic: SDAnimatedImageView!

    // MARK: - Properties
    let refreshControl = UIRefreshControl()
    var postSelectedIndex = 0
    var cell: PostTableViewCell!
    var postModels = [PostModel]()
    var postDocumentSnapshot: DocumentSnapshot?
    var pageSize = 8
    var dataMayContinue = true
    var uniquePostIDs: Set<String> = Set()
    var activePlayers: [AVPlayer] = []
    var playerPool: PlayerPool!
    var isMute: Bool = true
    var shouldHandleDynamicLink: Bool = false
    private var followerListner : ListenerRegistration?
    let locationManager = CLLocationManager()
    var weatherModel : WeatherModel?
    private var cancellables = Set<AnyCancellable>()
    var weatherTimer: Timer?

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialViews()
        setupLocationManager()
        setupRefreshControl()
        setupProfilePic()
        setupAddView()
        setupNotificationView()
        setupMessageView()
        setupScannerView()
        setupFilterButton()
        setupSearchTextField()
        setupTableView()
        setupPlayerPool()
        startWeatherTimer()
        setupObservers()
        setupCountryModel()
        
        if haveBlueTick(userModel: UserModel.data) {
            getFollowingPosts()
        } else {
            getAllPosts()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateProfilePicAndName()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pauseAllPlayers()
    }

    private func setupCountryModel(){
        let jsonData = Data(Constants.countryJSONString.utf8)
              let decoder = JSONDecoder()
              do {
                  Constants.countryModels = try decoder.decode([CountryModel].self, from: jsonData)
                  
              } catch {
                  Constants.countryModels = []
                  
              }
    }
    
    // MARK: - Setup Methods
    private func setupInitialViews() {
        guard UserModel.data != nil, FirebaseStoreManager.auth.currentUser != nil else {
            DispatchQueue.main.async { self.logoutPlease() }
            return
        }
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    private func setupRefreshControl() {
        let refreshView = UIView(frame: CGRect(x: 0, y: 70, width: 0, height: 0))
        tableView.addSubview(refreshView)
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshView.addSubview(refreshControl)
    }

    private func setupProfilePic() {
        mProfilePic.makeRounded()
    }

    private func setupAddView() {
        addView.layer.cornerRadius = 8
        addView.isUserInteractionEnabled = true
        addView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addPostClicked)))
    }

    private func setupNotificationView() {
        notificationView.layer.cornerRadius = 8
        notificationView.isUserInteractionEnabled = true
        notificationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(notificationViewClicked)))
    }

    private func setupMessageView() {
        messageView.layer.cornerRadius = 8
        messageView.isUserInteractionEnabled = true
        messageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(messageViewClicked)))
    }

    private func setupScannerView() {
        scannerView.layer.cornerRadius = 8
        scannerView.isUserInteractionEnabled = true
        scannerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(scannerViewClicked)))
    }

    private func setupFilterButton() {
        filterBtn.layer.cornerRadius = 8
        filterBtn.isUserInteractionEnabled = true
        filterBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(searchBtnClicked)))
    }

    private func setupSearchTextField() {
        searchTF.layer.cornerRadius = 8
        searchTF.layer.borderColor = UIColor.lightGray.cgColor
        searchTF.layer.borderWidth = 0.4
        searchTF.attributedPlaceholder = NSAttributedString(string: searchTF.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 225 / 255, green: 225 / 255, blue: 225 / 255, alpha: 1)])
        searchTF.setLeftPaddingPoints(16)
        searchTF.setRightPaddingPoints(10)
        searchTF.setLeftIcons(icon: UIImage(systemName: "magnifyingglass")!)
        searchTF.delegate = self
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        tableView.contentInsetAdjustmentBehavior = .never
    }


    
    private func setupPlayerPool() {
        playerPool = PlayerPool(playerCount: 6)
    }

    private func startWeatherTimer() {
        weatherTimer = Timer.scheduledTimer(timeInterval: 1800, target: self, selector: #selector(fetchWeatherUpdate), userInfo: nil, repeats: true)
    }

    private func setupObservers() {
        FavoritesManager.shared.favoriteChanged.sink { [weak self] postID in
            self?.updateFavoriteButton(for: postID)
        }.store(in: &cancellables)

        SavedManager.shared.saveChanged.sink { [weak self] postID in
            self?.updateSavedButton(for: postID)
        }.store(in: &cancellables)

        CommentManager.shared.commentChanged.sink { [weak self] postID in
            self?.updateCommentCount(for: postID)
        }.store(in: &cancellables)

        FollowingManager.shared.followingChanged.sink { [weak self] uid in
            self?.followingChanged(uid: uid)
        }.store(in: &cancellables)
    }

    // MARK: - Helper Methods
    private func updateProfilePicAndName() {
        if let userModel = UserModel.data {
            if let path = userModel.profilePic, !path.isEmpty {
                mProfilePic.setImage(imageKey: path, placeholder: "profile-placeholder", width: 200, height: 200, shouldShowAnimationPlaceholder: true)
            }
            mName.text = userModel.fullName ?? ""
        }
    }

    private func updateFavoriteButton(for postID: String) {
        guard let index = postModels.firstIndex(where: { $0.postID == postID }) else { return }
        let indexPath = IndexPath(row: index, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) as? PostTableViewCell {
            cell.updateFavoriteButton(isFromCell: false, postModel: postModels[index])
        }
    }

    private func updateSavedButton(for postID: String) {
        guard let index = postModels.firstIndex(where: { $0.postID == postID }) else { return }
        let indexPath = IndexPath(row: index, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) as? PostTableViewCell {
            cell.updateSavedButton(isFromCell: false, postModel: postModels[index])
        }
    }

    private func updateCommentCount(for postID: String) {
        guard let index = postModels.firstIndex(where: { $0.postID == postID }) else { return }
        let indexPath = IndexPath(row: index, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) as? PostTableViewCell {
            cell.updateCommentCount(postID: postID)
        }
    }

    private func fetchPosts(postIds: [String], documents: [QueryDocumentSnapshot]) {
        let db = Firestore.firestore()
        let query = db.collection(Collections.posts.rawValue)
            .whereField("postID", in: postIds)
            .whereField("isActive", isEqualTo: true)
            .whereField("isPromoted", isEqualTo: true)
            .order(by: "postCreateDate", descending: true)

        query.getDocuments { snapshot, error in
            if let error = error {
                self.ProgressHUDHide()
                self.handleError(error)
                return
            }
            guard let snapshot = snapshot, !snapshot.isEmpty else {
                self.stopSpinner()
                self.ProgressHUDHide()
                return
            }
            self.processSnapshot(snapshot, documents: documents)
        }
    }

    private func processSnapshot(_ snapshot: QuerySnapshot, documents: [QueryDocumentSnapshot]) {
        self.postDocumentSnapshot = nil
        self.dataMayContinue = false

        let group = DispatchGroup()
        var newPostModels = [PostModel]()

        for document in snapshot.documents {
            group.enter()
            self.processDocument(document) { processedPostModel in
                if let postModel = processedPostModel {
                    self.checkCurrentUserLikedPost(postID: postModel.postID ?? "") { isLike in
                     
                     
                        FavoritesManager.shared.setFavorites(with: postModel.postID ?? "", isLiked: isLike)
                        
                    }
                    self.checkCurrentUserSavePost(postID: postModel.postID ?? "") { isSave in

                     
                        SavedManager.shared.setSave(with: postModel.postID ?? "", isSave: isSave)
                    }
                    newPostModels.append(postModel)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.handleNewPosts(newPostModels, documents: documents, in: snapshot)
         
        }
    }

    private func followingChanged(uid: String?) {
        if let uid = uid {
            postModels.removeAll { $0.uid == uid }
            self.tableView.reloadData()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.refresh()
            }
        }
    }

    private func alertWithTF(postID: String) {
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
            let enteredText = textView.text ?? ""
            if !enteredText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                self.reportPost(reason: enteredText, postID: postID) { message in
                    self.showSnack(messages: message)
                }
            } else {
                // Handle empty text case
                self.showSnack(messages: "Please enter a reason for reporting.".localized())
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


    private func handleNewPosts(_ newPosts: [PostModel], documents: [QueryDocumentSnapshot], in snapshot: QuerySnapshot) {
        if documents.count >= pageSize {
            self.postDocumentSnapshot = documents.last
            self.dataMayContinue = true
        }

        self.postModels.append(contentsOf: newPosts)
        self.postModels.sort { $0.postCreateDate ?? Date.distantPast > $1.postCreateDate ?? Date.distantPast }

        self.ProgressHUDHide()
        let startIndex = self.postModels.count - newPosts.count
        let indexPaths = (startIndex ..< self.postModels.count).map { IndexPath(row: $0, section: 0) }
        self.tableView.insertRows(at: indexPaths, with: .none)
        
        self.handleScroll()
    }

    private func handleError(_ error: Error) {
        // Handle the error appropriately
        self.showError(error.localizedDescription)
    }

    private func showProgressHUDIfNeeded() {
        if self.postDocumentSnapshot == nil {
            ProgressHUDShow(text: "")
        }
    }

    private func stopSpinner() {
        if let spinner = self.tableView.tableFooterView as? UIActivityIndicatorView {
            spinner.stopAnimating()
            self.tableView.tableFooterView = nil
        }
    }

    private func updateTableViewHeight() {
        self.tableView.layoutIfNeeded()
    }

    // MARK: - API Calls
    private func getFollowingPosts(shouldScrollToTop: Bool = false) {
        showProgressHUDIfNeeded()
        guard let userId = Auth.auth().currentUser?.uid else {
            self.ProgressHUDHide()
            return
        }
        let feedRef = FirebaseStoreManager.db.collection(Collections.feeds.rawValue).document(userId)

        var query: Query = feedRef.collection("postIds")
            .order(by: "postCreateDate", descending: true)
            .limit(to: pageSize)

        if let lastDocument = postDocumentSnapshot {
            query = query.start(afterDocument: lastDocument)
        }

        query.getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            self.refreshControl.endRefreshing()
            if shouldScrollToTop {
                self.scrollToTop(animated: true)
            }
            if let error = error {
                self.ProgressHUDHide()
                self.handleError(error)
                return
            }

            guard let snapshot = snapshot, !snapshot.isEmpty else {
                self.ProgressHUDHide()
                self.stopSpinner()
                return
            }

         
            self.postDocumentSnapshot = snapshot.documents.last
            let postIds = snapshot.documents.map { $0.documentID }
            self.fetchPosts(postIds: postIds, documents: snapshot.documents)
        }
    }

    private func getAllPosts(shouldScrollToTop: Bool = false) {
       showProgressHUDIfNeeded()
        var query = FirebaseStoreManager.db.collection(Collections.posts.rawValue)
            .order(by: "postCreateDate", descending: true)
            .whereField("isActive", isEqualTo: true)
            .whereField("isPromoted", isEqualTo: true)
        query = applyPaginationIfNeeded(to: query)

        query.limit(to: pageSize).getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            self.refreshControl.endRefreshing()
            if shouldScrollToTop {
                self.scrollToTop(animated: true)
            }

            if let error = error {
                self.handleError(error)
                return
            }

            guard let snapshot = snapshot, !snapshot.isEmpty else {
                self.stopSpinner()
                self.ProgressHUDHide()
                return
            }

            self.processSnapshot(snapshot, documents: snapshot.documents)
        }
    }

    @objc private func fetchWeatherUpdate() {
        locationManager.requestLocation()
    }

    private func searchStart(searchText: String) {
        ProgressHUDShow(text: "Searching...".localized())
        algoliaSearch(searchText: searchText, indexName: .posts, filters: "") { models in
            DispatchQueue.main.async {
                self.ProgressHUDHide()
                self.searchTF.text = ""
                self.performSegue(withIdentifier: "viewPostsSeg", sender: models as? [PostModel] ?? [])
            }
        }
    }

    private func applyPaginationIfNeeded(to query: FirebaseFirestore.Query) -> FirebaseFirestore.Query {
        if let documentSnapshot = postDocumentSnapshot {
            return query.start(afterDocument: documentSnapshot)
        }
        return query
    }

    private func processDocument(_ document: QueryDocumentSnapshot, completion: @escaping (PostModel?) -> Void) {
        guard let postModel = try? document.data(as: PostModel.self) else {
            completion(nil)
            return
        }

        handleMediaType(for: postModel) {
            self.completePostModelProcessing(postModel, completion: completion)
        }
    }

    private func handleMediaType(for postModel: PostModel, completion: @escaping () -> Void) {
        if postModel.postType == "image", let images = postModel.postImages, !images.isEmpty {
            downloadMedia(from: images, baseUrl: Constants.awsImageBaseURL, completion: completion)
        } else if postModel.postType == "video", let path = postModel.postVideo {
            downloadMedia(from: [path], baseUrl: Constants.awsVideoBaseURL, completion: completion)
        } else {
            completion()
        }
    }

    private func downloadMedia(from paths: [String], baseUrl: String, completion: @escaping () -> Void) {
        for path in paths {
            let fullUrl = "\(baseUrl)/\(path)"
            guard let url = URL(string: fullUrl),
                  SDImageCache.shared.diskImageData(forKey: url.absoluteString) == nil else {
                continue
            }
            downloadMP4File(from: url)
        }
        completion()
    }

    private func completePostModelProcessing(_ postModel: PostModel, completion: @escaping (PostModel?) -> Void) {
        guard let postId = postModel.postID, !uniquePostIDs.contains(postId) else {
            completion(nil)
            return
        }
        uniquePostIDs.insert(postId)

        if let bid = postModel.bid, !bid.isEmpty {
            getBusinesses(by: bid) { businessModel, _ in
                postModel.businessModel = businessModel
                completion(businessModel != nil ? postModel : nil)
            }
        } else {
            getUserDataByID(uid: postModel.uid ?? "") { userModel, _ in
                postModel.userModel = userModel
                completion(userModel != nil ? postModel : nil)
            }
        }
    }
    
    @objc func notificationViewClicked() {
        
        
        Constants.selectedTabBarPosition = 5
        self.beRootScreen(storyBoardName: StoryBoard.tabBar, mIdentifier: Identifier.tabBarViewController)
    }

    // MARK: - Action Methods
    @objc func tempViewClicked() {
        if hasMembership() {
            if let weatherModel = weatherModel {
                performSegue(withIdentifier: "weatherReportSeg", sender: weatherModel)
            }
        } else {
            performSegue(withIdentifier: "membershipSeg", sender: nil)
        }
    }

    @objc func searchBtnClicked() {
        if hasMembership() {
            let sSearch = searchTF.text
            if let searchText = sSearch, !searchText.isEmpty {
                searchStart(searchText: searchText)
            }
        } else {
            performSegue(withIdentifier: "membershipSeg", sender: nil)
        }
    }

    @objc func scannerViewClicked() {
        if hasMembership() {
            performSegue(withIdentifier: "qrcodeSeg", sender: nil)
        } else {
            performSegue(withIdentifier: "membershipSeg", sender: nil)
        }
    }

    @objc func refresh() {
        let indexPathsToDelete = (0 ..< postModels.count).map { IndexPath(row: $0, section: 0) }
        postModels.removeAll()
        tableView.deleteRows(at: indexPathsToDelete, with: .automatic)

        uniquePostIDs.removeAll()
        postDocumentSnapshot = nil

        if haveBlueTick(userModel: UserModel.data) {
            getFollowingPosts(shouldScrollToTop: true)
        } else {
            getAllPosts(shouldScrollToTop: true)
        }
    }

    @objc func messageViewClicked() {
        if hasMembership() {
            performSegue(withIdentifier: "chatSeg", sender: nil)
        } else {
            performSegue(withIdentifier: "membershipSeg", sender: nil)
        }
    }

    @objc func addPostClicked() {
        if hasMembership() {
            performSegue(withIdentifier: "popupCreatePostSeg", sender: nil)
        } else {
            performSegue(withIdentifier: "membershipSeg", sender: nil)
        }
    }

    @objc func shareBtnClicked(value: MyGesture) {
        let postModel = postModels[value.index]

        if let postType = postModel.postType {
            if postType == "image" || postType == "video" {
                if let shareURL = postModel.shareURL, !shareURL.isEmpty {
                    shareImageAndVideo(postCell: value.postCell, link: shareURL, postId: postModel.postID ?? "")
                } else {
                    showSnack(messages: "Share URL not found.".localized())
                }
            } else {
                if let image = preparePostScreenshot(view: value.postCell.mView) {
                    var imagesToShare = [AnyObject]()
                    imagesToShare.append(image)

                    let activityViewController = UIActivityViewController(activityItems: imagesToShare, applicationActivities: nil)
                    activityViewController.popoverPresentationController?.sourceView = view
                    activityViewController.completionWithItemsHandler = { (_, completed: Bool, _: [Any]?, _: Error?) in
                        if completed {
                            value.postCell.shareCount.text = "\(Int(value.postCell.shareCount.text ?? "0")! + 1)"
                            self.addShares(postID: postModel.postID ?? "")
                        }
                    }

                    present(activityViewController, animated: true, completion: nil)
                }
            }
        }
    }

    @objc func likeBtnClicked(gest: MyGesture) {
        onPressLikeButton(postModel: postModels[gest.index], gest: gest)
    }

    @objc func saveBtnClicked(gest: MyGesture) {
        onPressSaveButton(postId: postModels[gest.index].postID ?? "", gest: gest)
    }

    @objc func commentClicked(value: MyGesture) {
        performSegue(withIdentifier: "commentSeg", sender: postModels[value.index])
    }

    @objc func postVideoClicked(value: MyGesture) {
        if hasMembership() {
            let postModel = postModels[value.index]
            if let path = postModel.postVideo {
                value.postCell.player?.pause()
                let videoURL = "\(Constants.awsVideoBaseURL)\(path)"
                let player = AVPlayer(url: URL(string: videoURL)!)
                let vc = AVPlayerViewController()
                vc.player = player
                vc.modalPresentationStyle = .overFullScreen
                present(vc, animated: true) {
                    vc.player?.play()
                }
            }
        } else {
            performSegue(withIdentifier: "membershipSeg", sender: nil)
        }
    }

    @objc func postImageClicked(value: MyGesture) {
        if hasMembership() {
            postSelectedIndex = value.index
            cell = value.postCell
            let mediaBrowser = MediaBrowserViewController(index: value.currentSelectedImageIndex, dataSource: self)
            present(mediaBrowser, animated: true, completion: nil)
        } else {
            performSegue(withIdentifier: "membershipSeg", sender: nil)
        }
    }

    @objc func showUserProfile(value: MyGesture) {
        if let userModel = postModels[value.index].userModel {
            performSegue(withIdentifier: "homeViewUserProfileSeg", sender: userModel)
        } else if let businessModel = postModels[value.index].businessModel {
            performSegue(withIdentifier: "showBusinessSeg", sender: businessModel)
        }
    }

    @objc func likeViewClicked(value: MyGesture) {
        ProgressHUDShow(text: "")
        getLikes(postId: value.id) { likeModels in
            self.ProgressHUDHide()
            var usersIds = [String]()
            for likeModel in likeModels! {
                if let userId = likeModel.userID {
                    usersIds.append(userId)
                }
            }
            self.performSegue(withIdentifier: "showUsersSeg", sender: usersIds)
        }
    }

    @objc func muteUnmuteClicked(gest: MyGesture) {
        isMute = !isMute
        gest.postCell.player?.isMuted = isMute

        for cell in tableView.visibleCells as! [PostTableViewCell] {
            cell.muteUnmuteBtn.image = (isMute) ? UIImage(named: "mute") : UIImage(named: "unmute")
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
        showSnack(messages: "Caption has copied.".localized())
    }

    @objc func deletePostClicked(postModel: PostModel, completion: @escaping (String?) -> Void) {
        deletePost(postId: postModel.postID ?? "") { error in
            completion(error)
        }
    }

    // MARK: - Helper Methods
    func pauseAllPlayers() {
        for player in activePlayers {
            player.pause()
        }
    }

    func scrollToTop(animated: Bool) {
        tableView.setContentOffset(.zero, animated: animated)
    }

    func performDynamicLinkSegue() {
        if let data = Constants.deeplinkData {
            self.routeBasedOnParams(data)
        }
    }

    func routeBasedOnParams(_ params: [String: AnyObject]) {
        Constants.deeplinkData = nil
        if let linkType = params["~feature"] as? String {
            switch linkType {
            case BranchIOFeature.liveStream.rawValue:
                handleLivestreamLink(params)
            case BranchIOFeature.userProfile.rawValue:
                handleUserLink(params)
           
            default:
                print("Unknown link type")
            }
        }
    }
    
   

    func handleLivestreamLink(_ params: [String: AnyObject]) {
        if let uid = params["uid"] as? String {
            if uid == FirebaseStoreManager.auth.currentUser!.uid {
                self.startLiveStream(shouldShowProgress: false)
            } else {
                self.getLivestreamingByUid(uid: uid) { liveModel in
                    if let liveModel = liveModel, let isOnline = liveModel.isOnline, isOnline {
                        self.performSegue(withIdentifier: "joinLiveStreamSeg", sender: liveModel)
                    } else {
                        self.showMessage(title: "Livestraming".localized(), message: "Host is not live.".localized(), shouldDismiss: false)
                    }
                }
            }
        }
    }

    func handleUserLink(_ params: [String: AnyObject]) {
        if let uid = params["uid"] as? String, !uid.isEmpty {
            getUserDataByID(uid: uid) { userModel, _ in
                if let userModel = userModel {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "homeViewUserProfileSeg", sender: userModel)
                    }
                }
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

        if haveBlueTick(userModel: UserModel.data) {
            getFollowingPosts()
        } else {
            getAllPosts()
        }
    }

    func cleanPostModels() {
        postModels.removeAll()
        tableView.reloadData()
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "commentSeg" {
            if let vc = segue.destination as? CommentViewController {
                if let value = sender as? PostModel {
                    vc.postModel = value
                }
            }
        } else if segue.identifier == "homePostEditSeg" {
            if let VC = segue.destination as? EditPostViewController {
                if let postModel = sender as? PostModel {
                    VC.postModel = postModel
                    VC.updatePostDelegate = self
                }
            }
        } else if segue.identifier == "homeViewUserProfileSeg" {
            if let vc = segue.destination as? ViewUserProfileController {
                if let user = sender as? UserModel {
                    vc.user = user
                }
            }
        } else if segue.identifier == "viewPostsSeg" {
            if let VC = segue.destination as? PostViewController {
                if let postModels = sender as? [PostModel] {
                    VC.postModels = postModels
                    VC.position = 0
                    VC.topTitle = "Search"
                }
            }
        } else if segue.identifier == "weatherReportSeg" {
            if let VC = segue.destination as? WeatherReportViewController {
                if let weatherModel = sender as? WeatherModel {
                    VC.weatherModel = weatherModel
                }
            }
        } else if segue.identifier == "showUsersSeg" {
            if let VC = segue.destination as? UsersListViewController {
                if let usersIds = sender as? [String] {
                    VC.userModelsIDs = usersIds
                    VC.headTitle = "Enjoys"
                }
            }
        } else if segue.identifier == "joinLiveStreamSeg" {
            if let VC = segue.destination as? JoinLiveStreamViewController {
                if let liveModel = sender as? LiveStreamingModel {
                    VC.token = liveModel.token
                    VC.channelName = liveModel.uid
                    VC.sName = liveModel.fullName
                    VC.sProfilePic = liveModel.profilePic
                    VC.agoraUID = liveModel.agoraUID
                }
            }
        } else if segue.identifier == "showBusinessSeg" {
            if let vc = segue.destination as? ShowBusinessProfileViewController {
                if let businessModel = sender as? BusinessModel {
                    vc.businessModel = businessModel
                }
            }
        }
    }

    deinit {
        followerListner?.remove()
        NotificationCenter.default.removeObserver(self)
    }
}


// MARK: UITableViewDelegate, UITableViewDataSource

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt _: IndexPath) {
        if let cell = cell as? PostTableViewCell, let player = cell.player {
            player.pause()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= 0
            && scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)
        {
            
            self.fetchMoreData()
        } else {
            self.handleScroll()
        }
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
            
            cell.postDesc.isHidden = true
            cell.postDesc.enabledTypes = [.url]
            cell.postDesc.URLSelectedColor = .link
            cell.postDesc.URLColor = .link
            cell.postDesc.handleURLTap { url in
                
                let validURLString = self.makeValidURL(urlString: url.absoluteString)
                
                if let url = URL(string: validURLString) {
                    UIApplication.shared.open(url)
                }
            }
            
            if let caption = postModel.caption, !caption.isEmpty {
                cell.postDesc.text = caption
                cell.postDesc.isHidden = false
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
            let edit = UIAction(
                title: "Edit",
                image: UIImage(systemName: "pencil.circle.fill")
            ) { _ in
                
                self.performSegue(withIdentifier: "homePostEditSeg", sender: postModel)
            }
            
            let delete = UIAction(
                title: "Delete",
                image: UIImage(systemName: "trash.fill")
            ) { _ in
                
                let alert = UIAlertController(
                    title: "DELETE POST",
                    message: "Are you sure you want to delete this post?",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                    
                    self.ProgressHUDShow(text: "Deleting...")
                    self.deletePostClicked(postModel: postModel) { error in
                        
                        DispatchQueue.main.async {
                            self.ProgressHUDHide()
                            if let error  = error {
                                self.showError(error)
                            }
                        }
                    }
                }))
                self.present(alert, animated: true)
            }
            
            if FirebaseStoreManager.auth.currentUser!.uid == postModel.uid {
                uiMenuElements.append(edit)
                uiMenuElements.append(delete)
            }
            
            let report = UIAction(
                title: "Report".localized(),
                image: UIImage(systemName: "exclamationmark.triangle.fill")
            ) { _ in
                
                self.alertWithTF(postID: postModel.postID ?? "123")
            }
            
    
            uiMenuElements.append(report)
            
            if let caption = postModel.caption, !caption.isEmpty {
                let transalte = UIAction(title: "Translate".localized(), image: UIImage(systemName: "translate")) { _ in
                    self.ProgressHUDShow(text: "Translating...".localized())
                    TranslationService.shared.translateText(text: caption) { translateString in
                        DispatchQueue.main.async {
                            self.ProgressHUDHide()
                            cell.postDesc.text = translateString.removingPercentEncoding ?? ""
                           
                        }
                    }
                }
                uiMenuElements.append(transalte)
            }
            
            cell.moreBtn.menu = UIMenu(title: "", children: uiMenuElements)
            
            
            cell.createDate.text = convertDateFormaterWithoutDash(postModel.postCreateDate ?? Date())
            cell.createTime.text = "| \(convertDateIntoTime(postModel.postCreateDate ?? Date()))"
            
            
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
           
           
            
            cell.likeView.isUserInteractionEnabled = true
            let likeViewGest = MyGesture(target: self, action: #selector(likeViewClicked))
            likeViewGest.id = postModel.postID ?? ""
            cell.likeView.addGestureRecognizer(likeViewGest)
            
           
            cell.configure(with: postModel, vc: self)
            
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
                                width: 850,
                                height: 850,
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
                                width: 850,
                                height: 850,
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
                                width: 850,
                                height: 850,
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
                                width: 850,
                                height: 850,
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
                        width: 850,
                        height: 850,
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
                
                if let path = postModel.postVideo {
                    if let player = playerPool.getPlayer() {
                        self.activePlayers.append(player)
                        cell.playerLayer?.removeFromSuperlayer()
                        cell.playerLayer = nil
                        cell.player = player
                        cell.returnPlayerDelegate = self
                        let videoURL = "\(Constants.awsVideoBaseURL)\(path)"
                        if let url = URL(string: videoURL) {
                            if let videoData = SDImageCache.shared.diskImageData(forKey: url.absoluteString) {
                                let documentsDirectoryURL = FileManager.default.urls(
                                    for: .documentDirectory,
                                    in: .userDomainMask
                                ).first!
                                let fileURL = documentsDirectoryURL.appendingPathComponent(url.lastPathComponent)
                                
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
                            playerLayer.videoGravity = .resizeAspectFill
                            
                            cell.videoImage.layer.addSublayer(playerLayer)
                            cell.playerLayer = playerLayer
                            
                            cell.player?.isMuted = self.isMute
                            cell.muteUnmuteBtn.image = self.isMute ? UIImage(named: "mute") : UIImage(named: "unmute")
                        }
                    }
                }
            }
            
            
                cell.profilePic.isUserInteractionEnabled = true
            
          
                if let businessModel = postModel.businessModel {
                    postModel.notificationToken = businessModel.notificationToken
                }
                else {
                    postModel.notificationToken = postModel.userModel!.notificationToken
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
                
                cell.nameAndDateStack.isUserInteractionEnabled = true
    
                    let userGest = MyGesture(target: self, action: #selector(self.showUserProfile))
                userGest.index = indexPath.row
                    cell.nameAndDateStack.addGestureRecognizer(userGest)
                    
             
                
                let userGest1 = MyGesture(target: self, action: #selector(self.showUserProfile))
                userGest1.index = indexPath.row
                cell.profilePic.addGestureRecognizer(userGest1)
                
                var profilePic : String?
                if let userModel = postModel.userModel {
                   profilePic = userModel.profilePic

                }
                else  {
                    profilePic = postModel.businessModel!.profilePicture

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

                if let userModel = postModel.userModel {
                    cell.userName.text = userModel.fullName ?? ""
                }
                else {
                    cell.userName.text = postModel.businessModel!.name ?? ""
                }
          
    
            
            DispatchQueue.main.async {
                self.updateTableViewHeight()
            }
        }
        
        return cell
    }
}

// MARK: MediaBrowserViewControllerDataSource

extension HomeViewController: MediaBrowserViewControllerDataSource {
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



extension NSLayoutConstraint {
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        NSLayoutConstraint(
            item: firstItem!,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant
        )
    }
}

extension AVPlayer {
    var isPlaying: Bool {
        rate != 0 && error == nil
    }
}

// MARK: - HomeViewController + ReturnPlayerDelegate

extension HomeViewController: ReturnPlayerDelegate {
    func returnPlayer(player: AVPlayer) {
        self.playerPool.returnPlayer(player)
        self.activePlayers.remove(player)
    }
}

// MARK: - HomeViewController + UpdatePostDelegate

extension HomeViewController: UpdatePostDelegate {
    func updatePost(postModel: PostModel) {
        if let foundIndex = postModels.firstIndex(where: { $0.postID == postModel.postID }) {
            self.postModels[foundIndex].caption = postModel.caption
            
            let indexPath = IndexPath(row: foundIndex, section: 0)
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}
extension HomeViewController : CLLocationManagerDelegate {
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            
            self.getWeatherInformation(lat: location.coordinate.latitude, long: location.coordinate.longitude) { weatherModel, error in
                DispatchQueue.main.async {
                    if error != nil {
                        
                        
                        self.tempView.isHidden = true
                        
                    }
                    else {
                        self.tempView.isHidden = false
                        self.weatherModel = weatherModel
                        self.tempView.isHidden = false
                        self.tempView.isUserInteractionEnabled = true
                        self.tempView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tempViewClicked)))
                        
                        self.tempLbl.text =  "\(String(format: "%.1f", weatherModel!.current!.temp!))°C"
                    
                        
                    }
                }
                
            }
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.tempView.isHidden = true
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.requestLocation()
        }
    }
    
}

extension HomeViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchTF {
            self.searchBtnClicked()
        }
        return true
    }
}
