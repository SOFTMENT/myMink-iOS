// Copyright © 2023 SOFTMENT. All rights reserved.

import AgoraRtcKit
import AVFoundation
import CallKit
import UIKit

// MARK: - VideoCallViewController

class VideoCallViewController: UIViewController {
    var isMute = false
    @IBOutlet var switchCamera: UIImageView!
    @IBOutlet var muteUnmuteBtn: UIImageView!
    @IBOutlet var backView: UIImageView!
    @IBOutlet var serverView: UIView!
    @IBOutlet var localView: UIView!
    @IBOutlet var endCall: UIImageView!
    var joined: Bool = false
    /// The main entry point for Video SDK
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

        self.switchCamera.isUserInteractionEnabled = true
        self.switchCamera.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.switchCameraClicked)
        ))

        self.muteUnmuteBtn.layer.cornerRadius = 8
        self.muteUnmuteBtn.isUserInteractionEnabled = true
        self.muteUnmuteBtn.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.muteClicked)
        ))

        self.backView.isUserInteractionEnabled = true
        self.backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.leaveChannel)))

        self.localView.layer.cornerRadius = 12

        self.endCall.isUserInteractionEnabled = true
        self.endCall.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.leaveChannel)))
        self.initializeAgoraEngine()
        self.setupLocalVideo()

        // CallDenied
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

    @objc func muteClicked() {
        if !self.isMute {
            self.isMute = true
            self.muteUnmuteBtn.backgroundColor = UIColor(red: 33 / 255, green: 199 / 255, blue: 135 / 255, alpha: 1)
        } else {
            self.isMute = false
            self.muteUnmuteBtn.backgroundColor = .clear
        }

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
        // Break out, because camera permissions have been denied or restricted.
        if !hasPermissions {
            return false
        }
        hasPermissions = await self.avAuthorization(mediaType: .audio)
        return hasPermissions
    }

    func avAuthorization(mediaType: AVMediaType) async -> Bool {
        let mediaAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: mediaType)
        switch mediaAuthorizationStatus {
        case .denied,
             .restricted: return false
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
        // Pass in your App ID here.
        config.appId = self.appID

        // Use AgoraRtcEngineDelegate for the following delegate parameter.
        self.agoraEngine = AgoraRtcEngineKit.sharedEngine(with: config, delegate: self)

        self.agoraEngine.setClientRole(self.userRole)
    }

    func setupLocalVideo() {
        // Enable the video module
        self.agoraEngine.enableVideo()
        // Start the local video preview
        self.agoraEngine.startPreview()
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = 0
        videoCanvas.renderMode = .hidden
        videoCanvas.view = self.localView
        videoCanvas.view?.layer.cornerRadius = 12
        videoCanvas.view?.clipsToBounds = true

        // Set the local video view
        self.agoraEngine.setupLocalVideo(videoCanvas)
    }

    func joinChannel(token: String, channelName: String) async {
        if await !self.checkForPermissions() {
            self.showMessage(title: "Error", text: "Permissions were not granted")
            return
        }

        let option = AgoraRtcChannelMediaOptions()

        // For a video call scenario, set the channel profile as communication.
        option.channelProfile = .communication

        // Join the channel with a temp token. Pass in your token and channel name here
        let result = self.agoraEngine.joinChannel(
            byToken: token, channelId: channelName, uid: 0, mediaOptions: option,
            joinSuccess: { _, _, _ in }
        )
        // Check if joining the channel was successful and set joined Bool accordingly
        if result == 0 {
            self.joined = true
            // showMessage(title: "Success", text: "Successfully joined the channel as \(self.userRole)")
        }
    }

    @objc func leaveChannel() {
        if self.admin {
            sendVOIPNotification(
                deviceToken: self.deviceToken ?? "123",
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
        // Check if leaving the channel was successful and set joined Bool accordingly
        if result == 0 {
            self.joined = false
        }

        if self.admin {
            dismiss(animated: true)
        } else {
            beRootScreen(storyBoardName: StoryBoard.Tabbar, mIdentifier: Identifier.TABBARVIEWCONTROLLER)
        }
    }
}

// MARK: AgoraRtcEngineDelegate

extension VideoCallViewController: AgoraRtcEngineDelegate {
    /// Callback called when a new host joins the channel
    func rtcEngine(_: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed _: Int) {
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid

        videoCanvas.renderMode = .hidden
        videoCanvas.view = self.serverView
        self.agoraEngine.setupRemoteVideo(videoCanvas)
    }
}
