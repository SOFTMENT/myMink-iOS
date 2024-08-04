// Copyright © 2023 SOFTMENT. All rights reserved.

import UIKit

class LivestreamShareViewController: UIViewController {
    @IBOutlet var mView: UIView!
    @IBOutlet var noBtn: UIButton!
    @IBOutlet var shareBtn: UIButton!
    var liveRecordModel: LiveRecordingModel?
    var ratio: CGFloat?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchLiveRecording()
    }

    private func setupUI() {
        noBtn.layer.cornerRadius = 8
        shareBtn.layer.cornerRadius = 8

        mView.clipsToBounds = true
        mView.layer.cornerRadius = 32
        mView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }

    private func fetchLiveRecording() {
        FirebaseStoreManager.db.collection(Collections.liveRecording.rawValue).document(FirebaseStoreManager.auth.currentUser!.uid)
            .getDocument { snapshot, error in
                if let snapshot = snapshot, snapshot.exists {
                    if let liveRecordModel = try? snapshot.data(as: LiveRecordingModel.self) {
                        if liveRecordModel.video != nil && liveRecordModel.thumbnail != nil {
                            liveRecordModel.ratio = self.ratio
                            self.liveRecordModel = liveRecordModel
                            self.deleteLiveRecording(uid: FirebaseStoreManager.auth.currentUser!.uid)
                        }
                    }
                }
            }
    }

    @IBAction func noBtnClicked(_: Any) {
        beRootScreen(storyBoardName: StoryBoard.tabBar, mIdentifier: Identifier.tabBarViewController)
    }

    @IBAction func shareBtnClicked(_: Any) {
        guard let liveRecordModel = liveRecordModel else {
            showAlertForShortStream()
            return
        }
        createPostFromLiveRecording(liveRecordModel: liveRecordModel)
    }

    private func createPostFromLiveRecording(liveRecordModel: LiveRecordingModel) {
        let postModel = createPostModel(from: liveRecordModel)
        createDeepLinkForPost(postModel: postModel) { url, error in
            guard let url = url else {
                self.showError(error!.localizedDescription)
                return
            }
            postModel.shareURL = url
            self.addPost(postModel: postModel) { error in
                if let error = error {
                    self.showError(error)
                } else {
                    self.performSegue(withIdentifier: "liveSuccessPostSeg", sender: nil)
                }
            }
        }
    }

    private func createPostModel(from liveRecordModel: LiveRecordingModel) -> PostModel {
        let postModel = PostModel()
        let postID = "\(liveRecordModel.sId ?? "")_\(liveRecordModel.channelName ?? "")"
        postModel.postID = postID
        postModel.postCreateDate = Date()
        postModel.isPromoted = true
        postModel.postType = "video"
        postModel.caption = "\(UserModel.data?.fullName ?? "") was Live"
        postModel.uid = FirebaseStoreManager.auth.currentUser?.uid
        postModel.postVideoRatio = liveRecordModel.ratio
        postModel.videoImage = liveRecordModel.thumbnail
        postModel.postVideo = liveRecordModel.video
        postModel.isLiveStream = true
        return postModel
    }

    private func showAlertForShortStream() {
        
        let alert = UIAlertController(
            title: "Can't post this stream",
            message: "Your livestream must be at least 10 seconds long.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Dashboard", style: .default, handler: { _ in
            self.beRootScreen(storyBoardName: StoryBoard.tabBar, mIdentifier: Identifier.tabBarViewController)
        }))
        present(alert, animated: true)
        
    }
}
