// Copyright © 2023 SOFTMENT. All rights reserved.

import AgoraRtcKit
import AVFoundation
import FirebaseFirestore
import Lottie
import SDWebImage
import UIKit

// MARK: - JoinLiveStreamViewController

class JoinLiveStreamViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    // MARK: - IBOutlets

    @IBOutlet var liveView: UIView!
    @IBOutlet var liveScreen: UIView!
    @IBOutlet var eyeView: UIView!
    @IBOutlet var mName: UILabel!
    @IBOutlet var mProfile: SDAnimatedImageView!

    @IBOutlet var audienceCounter: UILabel!
    @IBOutlet var backView: UIImageView!
    @IBOutlet var broadcasterView: UIStackView!
    @IBOutlet var micView: UIImageView!
    @IBOutlet var videoView: UIImageView!
    @IBOutlet var switchView: UIImageView!
    @IBOutlet var filterView: UIImageView!
    @IBOutlet var virtualBackView: UIImageView!
    @IBOutlet var stopLiveStreamButton: UIImageView!

    var isMute = false
    var isVideoDisable = false
    var agoraEngine: AgoraRtcEngineKit!
    let appID = "107d8337cdc34ecca9be641fed1809da"
    var token: String?
    var channelName: String?
    var sProfilePic: String?
    var sName: String?
    var agoraUID: Int?

    var joined: Bool = false
    var isAdmin = false
    @IBOutlet var liveStreamingBtn: UIView!
    @IBOutlet var scheduleBtn: UIStackView!
    @IBOutlet var chatView: UIView!
    let watermarkSize = CGSize(width: 40, height: 40)
    @IBOutlet var profilePicVideoOFF: UIImageView!
    @IBOutlet var placeholder: UIView!
    @IBOutlet var countDownView: LottieAnimationView!

    @IBOutlet var youAreNowLiveLbl: UILabel!
    var isLiveStreamingStarted = false
    @IBOutlet var closeBtn: UILabel!
    var isCancelClicked = false
    var counter = 0 // to cycle through the different types of backgrounds
    var isVirtualBackGroundEnabled: Bool = false
    @IBOutlet var hearts: LottieAnimationView!

    @IBOutlet var heartButton: UIImageView!
    var listener: ListenerRegistration?
    var likeListener: ListenerRegistration?
    var chatListener: ListenerRegistration?
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    var lastKnownLikeCount: Int?
    var liveChatModels = [LiveChatModel]()

    @IBOutlet var messageTF: UITextField!
    @IBOutlet var sendMessageBtn: UIImageView!

    @IBOutlet var liveChatTableView: UITableView!

    // MARK: - Public Methods

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        guard let _ = channelName,
              let _ = token
        else {
            DispatchQueue.main.async {
                if self.isAdmin {
                    self.dismiss(animated: true)
                } else {
                    self.beRootScreen(
                        storyBoardName: StoryBoard.tabBar,
                        mIdentifier: Identifier.tabBarViewController
                    )
                }
            }
            return
        }

        if self.channelName! == FirebaseStoreManager.auth.currentUser!.uid {
            self.isAdmin = true
        }

        self.hearts.loopMode = .playOnce
        self.feedbackGenerator.prepare()

        self.profilePicVideoOFF.layer.cornerRadius = self.profilePicVideoOFF.bounds.height / 2
        self.profilePicVideoOFF.dropShadow()
        self.profilePicVideoOFF.setImage(
            imageKey: self.sProfilePic ?? "",
            placeholder: "profile-placeholder"
        )

        if !self.isAdmin {
            self.broadcasterView.isHidden = true
            self.liveStreamingBtn.isHidden = true
            self.scheduleBtn.isHidden = true
            self.joinLive()

        } else {
            self.liveStreamingBtn.dropShadow()
            self.liveStreamingBtn.layer.cornerRadius = self.liveStreamingBtn.bounds.height / 2
            self.liveStreamingBtn.isUserInteractionEnabled = true
            self.liveStreamingBtn.addGestureRecognizer(UITapGestureRecognizer(
                target: self,
                action: #selector(self.startLiveStreaming)
            ))

            self.scheduleBtn.isUserInteractionEnabled = true
            self.scheduleBtn.addGestureRecognizer(UITapGestureRecognizer(
                target: self,
                action: #selector(self.scheduleClicked)
            ))
        }

        self.liveView.layer.cornerRadius = 4

        self.mProfile.setImage(
            imageKey: self.sProfilePic ?? "",
            placeholder: "profile-placeholder",
            shouldShowAnimationPlaceholder: true
        )

        self.eyeView.layer.cornerRadius = 4
        self.mProfile.layer.cornerRadius = self.mProfile.bounds.width / 2
        self.mName.text = self.sName ?? ""
        self.liveScreen.layer.cornerRadius = 4

        self.switchView.isUserInteractionEnabled = true
        self.switchView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.switchCameraClicked)
        ))

        self.micView.isUserInteractionEnabled = true
        self.micView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.muteClicked)))

        self.videoView.isUserInteractionEnabled = true
        self.videoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.videoClicked)))

        self.backView.isUserInteractionEnabled = true
        self.backView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.backViewClicked)
        ))
        self.closeBtn.isHidden = true
        self.closeBtn.isUserInteractionEnabled = true
        self.closeBtn.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.closeBtnClicked)
        ))

        self.virtualBackView.isUserInteractionEnabled = true
        self.virtualBackView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.virtualBackClicked)
        ))

        // HeartButton Click
        self.heartButton.isUserInteractionEnabled = true
        self.heartButton.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.heartBtnClicked)
        ))

        // StopButton
        self.stopLiveStreamButton.isUserInteractionEnabled = true
        self.stopLiveStreamButton.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.backViewClicked)
        ))

        // LiveChatTableView
        self.liveChatTableView.delegate = self
        self.liveChatTableView.dataSource = self
        self.liveChatTableView.transform = CGAffineTransform(scaleX: 1, y: -1)

        // Send Message Btn
        self.sendMessageBtn.isUserInteractionEnabled = true
        self.sendMessageBtn.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.sendMessageBtnClicked)
        ))

        self.initializeAgoraEngine()
        self.setupLocalVideo()
        self.registerChatListener(channelName: self.channelName!)
        self.registerCountListener(channelName: self.channelName!)
        self.registerLikeListener(channelName: self.channelName!, isAdmin: self.isAdmin)
    }

    @objc func sendMessageBtnClicked() {
        let sMessage = self.messageTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if sMessage != "" {
            self.messageTF.text = ""

            let liveChatModel = LiveChatModel()
            liveChatModel.time = Date()
            liveChatModel.message = sMessage
            liveChatModel.name = UserModel.data!.fullName
            liveChatModel.profile = UserModel.data!.profilePic
            let ref = FirebaseStoreManager.db.collection(Collections.liveStreamings.rawValue).document(self.channelName!)
                .collection(Collections.chats.rawValue)
            liveChatModel.id = ref.document().documentID

            try? ref.document(liveChatModel.id!).setData(from: liveChatModel)
        }
    }

    func registerLikeListener(channelName: String, isAdmin: Bool) {
        if isAdmin {
            let documentReference = FirebaseStoreManager.db.collection(Collections.liveStreamings.rawValue).document(channelName)
            documentReference.addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                guard let data = document.data() else {
                    print("Document data was empty.")
                    return
                }
                if let likeCount = data["likeCount"] as? Int {
                    // Check if the likeCount has changed
                    if likeCount != self.lastKnownLikeCount {
                        // Update last known likeCount
                        self.lastKnownLikeCount = likeCount
                        self.hearts.play()
                    }
                }
            }
        }
    }

    func registerChatListener(channelName: String) {
        self.chatListener = FirebaseStoreManager.db.collection(Collections.liveStreamings.rawValue).document(channelName)
            .collection(Collections.chats.rawValue).order(by: "time", descending: true)
            .limit(to: 50)
            .addSnapshotListener { snapshot, error in
                self.liveChatModels.removeAll()
                if let snapshot = snapshot, !snapshot.isEmpty {
                    for qdr in snapshot.documents {
                        if let liveChatModel = try? qdr.data(as: LiveChatModel.self) {
                            self.liveChatModels.append(liveChatModel)
                        }
                    }
                }

                self.liveChatTableView.reloadData()
                if self.liveChatModels.count > 0 {
                    let indexPath = IndexPath(row: 0, section: 0)
                    self.liveChatTableView.scrollToRow(at: indexPath, at: .top, animated: true)
                }
            }
    }

    func registerCountListener(channelName: String) {
        self.listener = FirebaseStoreManager.db.collection(Collections.liveStreamings.rawValue).document(channelName)
            .collection(Collections.audiences.rawValue)
            .addSnapshotListener { snapshot, error in
                if let snapshot = snapshot, !snapshot.isEmpty {
                    self.audienceCounter.text = "\(snapshot.count)"
                } else {
                    self.audienceCounter.text = "\(0)"
                }
            }
    }

    deinit {
        listener?.remove()
        likeListener?.remove()
        chatListener?.remove()
    }

    @objc func virtualBackClicked() {
        self.counter += 1
        if self.counter > 5 {
            self.counter = 0
            self.isVirtualBackGroundEnabled = false

        } else {
            self.isVirtualBackGroundEnabled = true
        }

        let virtualBackgroundSource = AgoraVirtualBackgroundSource()

        // Set the type of virtual background
        if self.counter == 1 { // Set background blur
            virtualBackgroundSource.backgroundSourceType = .blur
            virtualBackgroundSource.blurDegree = .medium

        } else if self.counter == 2 { // Set a solid background color
            virtualBackgroundSource.backgroundSourceType = .img

            if let imagePath = Bundle.main.path(
                forResource: "liveback1",
                ofType: "jpg"
            ) {
                virtualBackgroundSource.source = imagePath
            } else {
                print("Failed to find the image path")
            }
        } else if self.counter == 3 { // Set a background image
            virtualBackgroundSource.backgroundSourceType = .img
            if let imagePath = Bundle.main.path(forResource: "liveback2", ofType: "jpg") {
                virtualBackgroundSource.source = imagePath
            } else {
                print("Failed to find the image path")
            }
        } else if self.counter == 4 { // Set a background image
            virtualBackgroundSource.backgroundSourceType = .img
            if let imagePath = Bundle.main.path(forResource: "liveback3", ofType: "jpg") {
                virtualBackgroundSource.source = imagePath
            } else {
                print("Failed to find the image path")
            }
        } else if self.counter == 5 { // Set a background image
            virtualBackgroundSource.backgroundSourceType = .img
            if let imagePath = Bundle.main.path(forResource: "liveback4", ofType: "jpg") {
                virtualBackgroundSource.source = imagePath
            } else {
                print("Failed to find the image path")
            }
        }

        // Set processing properties for background
        let segmentationProperty = AgoraSegmentationProperty()
        segmentationProperty.modelType = .agoraAi // Use agoraGreen if you have a green background
        segmentationProperty.greenCapacity = 0.5 // Accuracy for identifying green colors (range 0-1)

        // Enable or disable virtual background
        self.agoraEngine.enableVirtualBackground(
            self.isVirtualBackGroundEnabled,
            backData: virtualBackgroundSource, segData: segmentationProperty
        )
    }

    @objc func heartBtnClicked() {
        self.feedbackGenerator.impactOccurred(intensity: 0.6)
        self.hearts.play()

        if !self.isAdmin {
            FirebaseStoreManager.db.collection(Collections.liveStreamings.rawValue).document(self.channelName!)
                .setData(["likeCount": FieldValue.increment(Int64(1))], merge: true)
        }
    }

    @objc func closeBtnClicked() {
        self.isCancelClicked = true
        self.liveStreamingBtn.isHidden = false
        self.scheduleBtn.isHidden = false
        self.countDownView.isHidden = true
        self.countDownView.stop()
        self.closeBtn.isHidden = true
    }

    @objc func scheduleClicked() {
        self.performSegue(withIdentifier: "scheduleSeg", sender: nil)
    }

    @objc func startLiveStreaming() {
        //  self.closeBtn.isHidden = false
        self.liveStreamingBtn.isHidden = true
        self.scheduleBtn.isHidden = true
//        self.countDownView.isHidden = false
//        self.countDownView.play()
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if !self.isCancelClicked {
                //  self.countDownView.isHidden = true
                // self.closeBtn.isHidden = true
                //  self.countDownView.pause()
                self.youAreNowLiveLbl.isHidden = false
                self.stopLiveStreamButton.isHidden = false
                self.joinLive()
                self.isLiveStreamingStarted = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.youAreNowLiveLbl.isHidden = true
                }
            }
            self.isCancelClicked = false
        }
    }

    func joinLive() {
        self.chatView.isHidden = false
        if !self.joined {
            Task {
                await self.joinChannel()
            }
        } else {
            self.leaveChannel()
            self.dismiss(animated: true)
        }
    }

    func setupLocalVideo() {
        // Enable the video module
        self.agoraEngine.enableVideo()
        // Start the local video preview
        self.agoraEngine.startPreview()

        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = 0
        videoCanvas.renderMode = .hidden
        videoCanvas.view = self.liveScreen
        // Set the local video view
        self.agoraEngine.setupLocalVideo(videoCanvas)
    }

    func joinChannel() async {
        let option = AgoraRtcChannelMediaOptions()
        if self.isAdmin {
            option.clientRoleType = .broadcaster
            self.addWaterMark()
            self.callAgoraWebHook(channelName: UserModel.data!.uid ?? "123", token: self.token ?? "123")

        } else {
            option.clientRoleType = .audience
        }
        option.channelProfile = .liveBroadcasting
        // Join the channel with a temp token. Pass in your token and channel name here
        let result = self.agoraEngine.joinChannel(
            byToken: self.token, channelId: self.channelName!, uid: 0, mediaOptions: option,
            joinSuccess: { _, uid, _ in

                if self.isAdmin {
                    FirebaseStoreManager.db.collection(Collections.liveStreamings.rawValue)
                        .document(FirebaseStoreManager.auth.currentUser!.uid).setData(
                            ["isOnline": true, "agoraUID": uid],
                            merge: true
                        )
                }
            }
        )

        // Check if joining the channel was successful and set joined Bool accordingly
        if result == 0 {
            self.joined = true
        }
    }

    func leaveChannel() {
        self.agoraEngine.stopPreview()
        let result = self.agoraEngine.leaveChannel(nil)
        // Check if leaving the channel was successful and set joined Bool accordingly
        if result == 0 {
            self.joined = false
        }
    }

    @objc func muteClicked() {
        if !self.isMute {
            self.isMute = true
            self.micView.image = UIImage(systemName: "mic.slash")
        } else {
            self.isMute = false
            self.micView.image = UIImage(systemName: "mic")
        }

        self.agoraEngine.muteLocalAudioStream(self.isMute)
    }

    func initializeAgoraEngine() {
        let config = AgoraRtcEngineConfig()
        // Pass in your App ID here.
        config.appId = self.appID

        // Use AgoraRtcEngineDelegate for the following delegate parameter.
        self.agoraEngine = AgoraRtcEngineKit.sharedEngine(with: config, delegate: self)

        let videoConfig = AgoraVideoEncoderConfiguration(
            size: AgoraVideoDimension1920x1080,
            frameRate: .fps30,
            bitrate: AgoraVideoBitrateStandard,
            orientationMode: .fixedPortrait,
            mirrorMode: .disabled
        )
        self.agoraEngine.setVideoEncoderConfiguration(videoConfig)
    }

    func addWaterMark() {
        let watermarkOptions = WatermarkOptions()

        watermarkOptions.positionInPortraitMode = CGRect(
            x: 980,
            y: 100,
            width: 92,
            height: 80
        )

        // Add the watermark
        if let url = urlForImage(named: "logo") {
            self.agoraEngine.addVideoWatermark(url, options: watermarkOptions)
        }
    }

    func urlForImage(named imageName: String) -> URL? {
        guard let image = UIImage(named: imageName) else { return nil }

        let fileManager = FileManager.default
        let tempDirectory = NSTemporaryDirectory()
        let imagePath = (tempDirectory as NSString).appendingPathComponent("\(imageName).png")

        if let imageData = image.pngData() {
            fileManager.createFile(atPath: imagePath, contents: imageData, attributes: nil)
        } else {
            return nil
        }

        return URL(fileURLWithPath: imagePath)
    }

    @objc func videoClicked() {
        if !self.isVideoDisable {
            self.agoraEngine.disableVideo()
            self.isVideoDisable = true
            self.videoView.image = UIImage(systemName: "video.slash")
            DispatchQueue.main.async {
                self.placeholder.isHidden = false
            }

        } else {
            self.agoraEngine.enableVideo()
            self.isVideoDisable = false
            self.videoView.image = UIImage(systemName: "video")
            DispatchQueue.main.async {
                self.placeholder.isHidden = true
            }
        }
    }

    @objc func switchCameraClicked() {
        self.agoraEngine.switchCamera()
    }

    @objc func backViewClicked() {
        if self.isAdmin && self.isLiveStreamingStarted {
            let alert = UIAlertController(
                title: "Live Stream".localized(),
                message: "Are you sure you want to end your live stream?".localized(),
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "End".localized(), style: .destructive, handler: { action in
                self.leaveChannel()
                self.performSegue(withIdentifier: "recordingShareSeg", sender: nil)
            }))
            alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
            self.present(alert, animated: true)
        } else {
            self.leaveChannel()
            self.dismiss(animated: true)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "recordingShareSeg" {
            if let VC = segue.destination as? LivestreamShareViewController {
                VC.ratio = CGFloat(self.liveScreen.bounds.width / self.liveScreen.bounds.height)
            }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.leaveChannel()

        DispatchQueue.global(qos: .userInitiated).async { AgoraRtcEngineKit.destroy() }
    }

    func setupRemoteView(uid: UInt) {
        if !self.isAdmin {
            self.agoraEngine.enableVideo()

            self.agoraEngine.enableAudio()
            self.agoraEngine.enableLocalAudio(true)

            let videoCanvas = AgoraRtcVideoCanvas()
            videoCanvas.uid = uid
            videoCanvas.renderMode = .hidden
            videoCanvas.view = self.liveScreen
            self.agoraEngine.setupRemoteVideo(videoCanvas)
        }
    }

    func isBroadcaster(uid: UInt) -> Bool {
        if let agoraUID = self.agoraUID {
            return uid == agoraUID
        }
        return false
    }

    func showPlaceholderForBroadcaster() {
        // Show placeholder view/image
        self.placeholder.isHidden = false
    }

    func hidePlaceholderForBroadcaster() {
        // Hide placeholder view/image
        self.placeholder.isHidden = true
    }
}

// MARK: AgoraRtcEngineDelegate

// MARK: - Extensions

extension JoinLiveStreamViewController: AgoraRtcEngineDelegate {
    
    
    
    /// Callback called when a new host joins the channel
    func rtcEngine(_: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed _: Int) {
        self.setupRemoteView(uid: uid)
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        if self.isBroadcaster(uid: uid) {
            self.leaveChannel()
            self.showMessage(title: "Live Stream".localized(), message: "Live streaming has ended".localized(), shouldDismiss: true)
        }
    }

    func rtcEngine(
        _ engine: AgoraRtcEngineKit,
        remoteVideoStateChangedOfUid uid: UInt,
        state: AgoraVideoRemoteState,
        reason: AgoraVideoRemoteReason,
        elapsed: Int
    ) {
        DispatchQueue.main.async {
            if state == .stopped || state == .frozen {
                // Broadcaster has disabled their video
                self.showPlaceholderForBroadcaster()
            } else if state == .decoding {
                // Broadcaster has enabled their video
                self.hidePlaceholderForBroadcaster()
            }
        }
    }
}

extension JoinLiveStreamViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.liveChatModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(
            withIdentifier: "liveChatCell",
            for: indexPath
        ) as? LiveChatTableViewCell {
            cell.transform = CGAffineTransform(scaleX: 1, y: -1)
            let liveChatModel = self.liveChatModels[indexPath.row]
            if let path = liveChatModel.profile, !path.isEmpty {
                cell.mProfile.setImage(
                    imageKey: path,
                    placeholder: "profile-placeholder",
                    shouldShowAnimationPlaceholder: true
                )
            }

            cell.mProfile.layer.cornerRadius = cell.mProfile.bounds.width / 2
            cell.mName.text = liveChatModel.name ?? ""
            cell.mMessage.text = liveChatModel.message ?? ""

            return cell
        }
        return LiveChatTableViewCell()
    }
}
