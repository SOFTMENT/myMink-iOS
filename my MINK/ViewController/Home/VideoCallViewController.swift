// Copyright © 2023 SOFTMENT. All rights reserved.

import AgoraRtcKit
import AVFoundation
import CallKit
import UIKit

class VideoCallViewController: UIViewController {
    var isMute = false
    @IBOutlet var switchCamera: UIImageView!
    @IBOutlet var muteUnmuteBtn: UIImageView!
    @IBOutlet var backView: UIImageView!
    @IBOutlet var serverView: UIView!
    @IBOutlet var localView: UIView!
    @IBOutlet var endCall: UIImageView!
    var joined: Bool = false
    var agoraEngine: AgoraRtcEngineKit!
    var userRole: AgoraClientRole = .broadcaster
    let appID = "107d8337cdc34ecca9be641fed1809da"
    var token: String?
    var channelName: String?
    var callUUID: String?
    var admin = false
    var deviceToken: String?
    var startDate: Data!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let token = token, let channelName = channelName else {
            print("Token and Channel Name missing")
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }

        if self.admin {
            self.startDate = Data()
        }

        setupViews()
        setupGestures()

        initializeAgoraEngine()
        setupLocalVideo()

        if self.admin {
            FirebaseStoreManager.db.collection("CallDenied").document(self.callUUID!)
                .addSnapshotListener { snapshot, _ in
                    if let snapshot = snapshot, snapshot.exists {
                        print("CALL ENDED")
                        self.leaveChannel()
                    }
                }
        }

        if !self.joined {
            Task {
                await self.joinChannel(token: token, channelName: channelName)
            }
        } else {
            self.leaveChannel()
        }
    }

    private func setupViews() {
        self.muteUnmuteBtn.layer.cornerRadius = 8
        self.localView.layer.cornerRadius = 12
    }

    private func setupGestures() {
        self.switchCamera.isUserInteractionEnabled = true
        self.switchCamera.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.switchCameraClicked)
        ))

        self.muteUnmuteBtn.isUserInteractionEnabled = true
        self.muteUnmuteBtn.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.muteClicked)
        ))

        self.backView.isUserInteractionEnabled = true
        self.backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.leaveChannel)))

        self.endCall.isUserInteractionEnabled = true
        self.endCall.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.leaveChannel)))
    }

    @objc func muteClicked() {
        self.isMute.toggle()
        self.muteUnmuteBtn.backgroundColor = self.isMute ? UIColor(red: 33 / 255, green: 199 / 255, blue: 135 / 255, alpha: 1) : .clear
        self.agoraEngine.muteLocalAudioStream(self.isMute)
    }

    @objc func switchCameraClicked() {
        self.agoraEngine.switchCamera()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.leaveChannel()
        DispatchQueue.global(qos: .userInitiated).async { AgoraRtcEngineKit.destroy() }
    }

    func checkForPermissions() async -> Bool {
        var hasPermissions = await avAuthorization(mediaType: .video)
        if !hasPermissions { return false }
        hasPermissions = await self.avAuthorization(mediaType: .audio)
        return hasPermissions
    }

    func avAuthorization(mediaType: AVMediaType) async -> Bool {
        let mediaAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: mediaType)
        switch mediaAuthorizationStatus {
        case .denied, .restricted: return false
        case .authorized: return true
        case .notDetermined:
            return await withCheckedContinuation { continuation in
                AVCaptureDevice.requestAccess(for: mediaType) { granted in
                    continuation.resume(returning: granted)
                }
            }
        @unknown default: return false
        }
    }

    func showMessage(title: String, text: String, delay: Int = 2) {
        let deadlineTime = DispatchTime.now() + .seconds(delay)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
            self.present(alert, animated: true)
            alert.dismiss(animated: true, completion: nil)
        }
    }

    func initializeAgoraEngine() {
        let config = AgoraRtcEngineConfig()
        config.appId = self.appID
        self.agoraEngine = AgoraRtcEngineKit.sharedEngine(with: config, delegate: self)
        self.agoraEngine.setClientRole(self.userRole)
    }

    func setupLocalVideo() {
        self.agoraEngine.enableVideo()
        self.agoraEngine.startPreview()
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = 0
        videoCanvas.renderMode = .hidden
        videoCanvas.view = self.localView
        videoCanvas.view?.layer.cornerRadius = 12
        videoCanvas.view?.clipsToBounds = true
        self.agoraEngine.setupLocalVideo(videoCanvas)
    }

    func joinChannel(token: String, channelName: String) async {
        if await !self.checkForPermissions() {
            self.showMessage(title: "Error".localized(), text: "Permissions were not granted".localized())
            return
        }

        let option = AgoraRtcChannelMediaOptions()
        option.channelProfile = .communication

        let result = self.agoraEngine.joinChannel(byToken: token, channelId: channelName, uid: 0, mediaOptions: option, joinSuccess: { _, _, _ in })
        if result == 0 {
            self.joined = true
        }
    }

    @objc func leaveChannel() {
        if self.admin {
            sendVOIPNotification(
                deviceToken: self.deviceToken ?? "",
                name: "",
                channelName: "",
                token: "",
                callEnd: true,
                callUUID: self.callUUID!
            ) { _, error in
                if let error = error {
                    print(error)
                }
            }
        }

        self.agoraEngine.stopPreview()
        let result = self.agoraEngine.leaveChannel(nil)
        if result == 0 {
            self.joined = false
        }

        if self.admin {
            dismiss(animated: true)
        } else {
            beRootScreen(storyBoardName: StoryBoard.tabBar, mIdentifier: Identifier.tabBarViewController)
        }
    }
}

extension VideoCallViewController: AgoraRtcEngineDelegate {
    func rtcEngine(_: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed _: Int) {
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.renderMode = .hidden
        videoCanvas.view = self.serverView
        self.agoraEngine.setupRemoteVideo(videoCanvas)
    }
}
