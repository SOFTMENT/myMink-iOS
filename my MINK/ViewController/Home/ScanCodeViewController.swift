// Copyright © 2023 SOFTMENT. All rights reserved.

import AVFoundation
import Firebase
import Lottie
import UIKit

class ScanCodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession = AVCaptureSession()
    @IBOutlet var scannerView: UIView!
    @IBOutlet var animation: LottieAnimationView!
    @IBOutlet var backBtn: UIImageView!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?

    private let supportedCodeTypes: [AVMetadataObject.ObjectType] = [
        .upce, .code39, .code39Mod43, .code93, .code128, .ean8, .ean13, .aztec, .pdf417,
        .itf14, .dataMatrix, .interleaved2of5, .qr
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotifications()
        setupCaptureSession()
        setupUI()
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.updateAnimation),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.updateAnimation),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    private func setupCaptureSession() {
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            print("Failed to get the camera device")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes

            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = .resizeAspectFill
            videoPreviewLayer?.frame = scannerView.layer.bounds
            videoPreviewLayer?.cornerRadius = 16
            scannerView.layer.addSublayer(videoPreviewLayer!)
            
            DispatchQueue.global(qos: .background).async {
                self.captureSession.startRunning()
            }
        } catch {
            print(error)
        }
    }

    private func setupUI() {
        backBtn.isUserInteractionEnabled = true
        backBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        updateAnimation()
    }

    @objc private func updateAnimation() {
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.animation.contentMode = .scaleAspectFit
                self.animation.loopMode = .loop
                self.animation.animationSpeed = 0.5
                self.animation.play()
            }
        }
    }

    @objc private func backBtnClicked() {
        dismiss(animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "scanViewUserProfileSeg", let vc = segue.destination as? ViewUserProfileController, let user = sender as? UserModel {
            vc.user = user
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateVideoPreviewLayerOrientation()
    }

    private func updateVideoPreviewLayerOrientation() {
        guard let connection = videoPreviewLayer?.connection else { return }
        let orientation = UIDevice.current.orientation
        let previewLayerConnection = connection

        if previewLayerConnection.isVideoOrientationSupported {
            switch orientation {
            case .portrait:
                updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
            case .landscapeRight:
                updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeLeft)
            case .landscapeLeft:
                updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeRight)
            case .portraitUpsideDown:
                updatePreviewLayer(layer: previewLayerConnection, orientation: .portraitUpsideDown)
            default:
                updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
            }
        }
    }

    private func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
        layer.videoOrientation = orientation
        videoPreviewLayer?.frame = scannerView.bounds
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard !metadataObjects.isEmpty, let metadataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject, supportedCodeTypes.contains(metadataObj.type) else {
            scannerView.frame = CGRect.zero
            return
        }

        let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
        scannerView.frame = barCodeObject!.bounds

        if let value = metadataObj.stringValue, !value.isEmpty {
            captureSession.stopRunning()
            checkQRCode(value: value)
        } else {
            showAlert(title: "", message: "Invalid QR CODE") { self.captureSession.startRunning() }
        }
    }

    private func checkQRCode(value: String) {
        ProgressHUDShow(text: "")
        readDeepLink(link: value) { uid in
            DispatchQueue.main.async {
                self.ProgressHUDHide()
                guard let uid = uid else {
                    self.showAlert(title: "ERROR", message: "Invalid QR Code") { self.captureSession.startRunning() }
                    return
                }

                Firestore.firestore().collection(Collections.users.rawValue).document(uid).getDocument { snapshot, _ in
                    if let snapshot = snapshot, snapshot.exists, let userModel = try? snapshot.data(as: UserModel.self) {
                        self.performSegue(withIdentifier: "scanViewUserProfileSeg", sender: userModel)
                    } else {
                        self.showAlert(title: "", message: "No user found") { self.captureSession.startRunning() }
                    }
                }
            }
        }
    }

    private func showAlert(title: String, message: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completion() })
        present(alert, animated: true)
    }
}
