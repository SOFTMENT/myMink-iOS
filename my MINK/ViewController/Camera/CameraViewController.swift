// Copyright © 2023 SOFTMENT. All rights reserved.

import AVFoundation
import CropViewController
import UIKit

// MARK: - CameraViewController

class CameraViewController: UIViewController {
    @IBOutlet var cameraView: UIView!
    @IBOutlet var imageView: UIView!
    @IBOutlet var reelView: UIView!
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var selectedImage: UIImage?
    var videoURL: URL?

    override func viewDidLoad() {
        self.imageView.layer.cornerRadius = 8
        self.imageView.isUserInteractionEnabled = true
        self.imageView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.imageViewClicked)
        ))

        self.reelView.layer.cornerRadius = 8
        self.reelView.isUserInteractionEnabled = true
        self.reelView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.reelViewClicked)
        ))

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

//            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]

        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }

        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        self.videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.videoPreviewLayer?.frame = self.cameraView.layer.bounds
        self.videoPreviewLayer?.cornerRadius = 16
        self.cameraView.layer.addSublayer(self.videoPreviewLayer!)
    }

    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        DispatchQueue.global(qos: .background).async {
            self.captureSession.stopRunning()
        }
    }

    @objc func imageViewClicked() {
        let image = UIImagePickerController()
        image.title = "Profile Picture"
        image.delegate = self
        image.modalPresentationStyle = .overFullScreen
        image.sourceType = .camera
        present(image, animated: true)
    }

    @objc func reelViewClicked() {
        let image = UIImagePickerController()
        image.delegate = self
        image.mediaTypes = ["public.movie"]
        image.sourceType = .camera
        image.modalPresentationStyle = .overFullScreen
        present(image, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cameracreatePostSeg" {
            if let VC = segue.destination as? CreatePostViewController {
                if let postType = sender as? PostType {
                    if postType == .IMAGE {
                        VC.images = [self.selectedImage!]
                    } else {
                        VC.videoPath = self.videoURL
                    }
                    VC.postType = postType
                }
            }
        }
    }
}

// MARK: UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate

extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate,
    CropViewControllerDelegate
{
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        if let editedImage = info[.originalImage] as? UIImage {
            dismiss(animated: true) {
                let cropViewController = CropViewController(image: editedImage)
                cropViewController.title = picker.title
                cropViewController.modalPresentationStyle = .currentContext
                cropViewController.delegate = self
                cropViewController.aspectRatioLockEnabled = false
                cropViewController.aspectRatioPickerButtonHidden = false
                self.present(cropViewController, animated: true, completion: nil)
            }
        } else {
            self
                .videoURL =
                info[
                    UIImagePickerController
                        .InfoKey(rawValue: UIImagePickerController.InfoKey.mediaURL.rawValue)
                ] as? URL
            dismiss(animated: true) {
                self.performSegue(withIdentifier: "cameracreatePostSeg", sender: PostType.VIDEO)
            }
        }
    }

    func cropViewController(_: CropViewController, didCropToImage image: UIImage, withRect _: CGRect, angle _: Int) {
        dismiss(animated: true) {
            self.selectedImage = image
            self.performSegue(withIdentifier: "cameracreatePostSeg", sender: PostType.IMAGE)
        }
    }

    func cropViewController(_: CropViewController, didFinishCancelled _: Bool) {
        dismiss(animated: true) {
            Constants.selectedTabbarPosition = 3
            self.beRootScreen(storyBoardName: StoryBoard.Tabbar, mIdentifier: Identifier.TABBARVIEWCONTROLLER)
        }
    }
}
