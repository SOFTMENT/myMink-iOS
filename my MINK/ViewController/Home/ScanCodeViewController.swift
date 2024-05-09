// Copyright © 2023 SOFTMENT. All rights reserved.

import AVFoundation
import Firebase
import Lottie
import UIKit

class ScanCodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    // MARK: Internal

    var captureSession = AVCaptureSession()
    @IBOutlet var scannerView: UIView!
    @IBOutlet var animation: LottieAnimationView!
    @IBOutlet var backBtn: UIImageView!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.update),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.update),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        // Get the back-facing camera for capturing videos
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            print("Failed to get the camera device")
            return
        }

        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)

            // Set the input device on the capture session.
            self.captureSession.addInput(input)

            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            self.captureSession.addOutput(captureMetadataOutput)

            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = self.supportedCodeTypes
//            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]

        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }

        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        self.videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.videoPreviewLayer?.frame = self.scannerView.layer.bounds
        self.videoPreviewLayer?.cornerRadius = 16
        self.scannerView.layer.addSublayer(self.videoPreviewLayer!)

        // Start video capture.
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
        self.update()

        self.backBtn.isUserInteractionEnabled = true
        self.backBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backBtnClicked)))
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "scanViewUserProfileSeg" {
            if let vc = segue.destination as? ViewUserProfileController {
                if let user = sender as? UserModel {
                    vc.user = user
                }
            }
        }
    }

    @objc func update() {
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()

            DispatchQueue.main.async {
                self.animation.contentMode = .scaleAspectFit

                // 2. Set animation loop mode

                self.animation.loopMode = .loop

                // 3. Adjust animation speed

                self.animation.animationSpeed = 0.5

                // 4. Play animation
                self.animation.play()
            }
        }
    }

    @objc func backBtnClicked() {
        dismiss(animated: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let connection = videoPreviewLayer?.connection {
            let currentDevice = UIDevice.current
            let orientation: UIDeviceOrientation = currentDevice.orientation
            let previewLayerConnection: AVCaptureConnection = connection

            if previewLayerConnection.isVideoOrientationSupported {
                switch orientation {
                case .portrait:
                    self.updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                case .landscapeRight:
                    self.updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeLeft)
                case .landscapeLeft:
                    self.updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeRight)
                case .portraitUpsideDown:
                    self.updatePreviewLayer(layer: previewLayerConnection, orientation: .portraitUpsideDown)
                default:
                    self.updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                }
            }
        }
    }

    func checkQRCode(value: String) {
        print(value)
        ProgressHUDShow(text: "")
        readDeepLink(link: value) { uid in

            DispatchQueue.main.async {
                if let uid = uid {
                    Firestore.firestore().collection("Users").document(uid).getDocument { snapshot, _ in
                        DispatchQueue.main.async {
                            self.ProgressHUDHide()
                            if let snapshot = snapshot, snapshot.exists {
                                if let userModel = try? snapshot.data(as: UserModel.self) {
                                    DispatchQueue.global(qos: .background).async {
                                        self.captureSession.startRunning()
                                    }

                                    self.performSegue(withIdentifier: "scanViewUserProfileSeg", sender: userModel)
                                }
                            } else {
                                let alert = UIAlertController(
                                    title: "",
                                    message: "No user found",
                                    preferredStyle: UIAlertController.Style.alert
                                )
                                // add an action (button)

                                alert.addAction(UIAlertAction(
                                    title: "OK",
                                    style: UIAlertAction.Style.default,
                                    handler: { _ in
                                        DispatchQueue.global(qos: .background).async {
                                            self.captureSession.startRunning()
                                        }
                                    }
                                ))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                } else {
                    self.ProgressHUDHide()
                    let alert = UIAlertController(
                        title: "ERROR",
                        message: "Invalid QR Code",
                        preferredStyle: UIAlertController.Style.alert
                    )
                    // add an action (button)

                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { _ in
                        DispatchQueue.global(qos: .background).async {
                            self.captureSession.startRunning()
                        }
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

    func metadataOutput(
        _: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from _: AVCaptureConnection
    ) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.isEmpty {
            self.scannerView.frame = CGRect.zero

            return
        }

        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject

        if self.supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata (or barcode) then update the status label's text
            // and set the bounds
            let barCodeObject = self.videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            self.scannerView.frame = barCodeObject!.bounds

            if metadataObj.stringValue != nil {
                self.captureSession.stopRunning()

                let value = metadataObj.stringValue ?? ""
                if !value.isEmpty {
                    self.checkQRCode(value: value)
                } else {
                    let alert = UIAlertController(
                        title: "",
                        message: "Invalid QR CODE",
                        preferredStyle: UIAlertController.Style.alert
                    )
                    // add an action (button)

                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { _ in
                        self.captureSession.startRunning()
                    }))
                    present(alert, animated: true, completion: nil)
                }
            }
        }
    }

    // MARK: Private

    private let supportedCodeTypes = [
        AVMetadataObject.ObjectType.upce,
        AVMetadataObject.ObjectType.code39,
        AVMetadataObject.ObjectType.code39Mod43,
        AVMetadataObject.ObjectType.code93,
        AVMetadataObject.ObjectType.code128,
        AVMetadataObject.ObjectType.ean8,
        AVMetadataObject.ObjectType.ean13,
        AVMetadataObject.ObjectType.aztec,
        AVMetadataObject.ObjectType.pdf417,
        AVMetadataObject.ObjectType.itf14,
        AVMetadataObject.ObjectType.dataMatrix,
        AVMetadataObject.ObjectType.interleaved2of5,
        AVMetadataObject.ObjectType.qr
    ]

    private func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
        layer.videoOrientation = orientation
        self.videoPreviewLayer?.frame = self.scannerView.bounds
    }
}
