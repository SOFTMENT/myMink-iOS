// Copyright © 2023 SOFTMENT. All rights reserved.

import UIKit

class LivestreamShareViewController: UIViewController {
    @IBOutlet var mView: UIView!

    @IBOutlet var noBtn: UIButton!

    @IBOutlet var shareBtn: UIButton!
    var liveRecordModel: LiveRecordingModel?
    var ratio: CGFloat?

    override func viewDidLoad() {
        self.noBtn.layer.cornerRadius = 8
        self.shareBtn.layer.cornerRadius = 8

        self.mView.clipsToBounds = true
        self.mView.layer.cornerRadius = 32
        self.mView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        self.fetchLiveRecording()
    }

    func fetchLiveRecording() {
        FirebaseStoreManager.db.collection("LiveRecordings").document(FirebaseStoreManager.auth.currentUser!.uid)
            .getDocument { snapshot, error in

                if let snapshot = snapshot, snapshot.exists {
                    if let liveRecordModel = try? snapshot.data(as: LiveRecordingModel.self) {
                        if liveRecordModel.video != nil && liveRecordModel.thumbnail != nil {
                            liveRecordModel
                                .ratio = self.ratio
                            self.liveRecordModel = liveRecordModel
                            self.deleteLiveRecording(uid: FirebaseStoreManager.auth.currentUser!.uid)
                        }
                    }
                }
            }
    }

    @IBAction func noBtnClicked(_ sender: Any) {
        self.beRootScreen(storyBoardName: StoryBoard.Tabbar, mIdentifier: Identifier.TABBARVIEWCONTROLLER)
    }

    @IBAction func shareBtnClicked(_ sender: Any) {
        if let liveRecordModel = liveRecordModel {
            let postModel = PostModel()
            let postID = "\(liveRecordModel.sId ?? "")_\(liveRecordModel.channelName ?? "")"
            postModel.postID = postID

            postModel.postCreateDate = Date()
            postModel.postType = "video"
            postModel.caption = "\(UserModel.data!.fullName ?? "") was Live"
            postModel.uid = FirebaseStoreManager.auth.currentUser!.uid
            postModel.postVideoRatio = self.liveRecordModel!.ratio
            postModel.videoImage = self.liveRecordModel!.thumbnail
            postModel.postVideo = self.liveRecordModel!.video
            postModel.isLiveStream = true

            self.createDeepLinkForPost(postModel: postModel) { url, error in
                if let url = url {
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
            
           
        } else {
            let alert = UIAlertController(
                title: "Can't post this stream",
                message: "Your livestream must be at least 10 seconds long.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Dashboard", style: .default, handler: { action in
                self.beRootScreen(storyBoardName: StoryBoard.Tabbar, mIdentifier: Identifier.TABBARVIEWCONTROLLER)
            }))

            present(alert, animated: true)
        }
    }
}
