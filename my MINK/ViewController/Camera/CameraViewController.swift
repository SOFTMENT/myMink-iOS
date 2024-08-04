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
        super.viewDidLoad()
        setupUI()
        setupCamera()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.global(qos: .background).async {
            self.captureSession.stopRunning()
        }
    }

    private func setupUI() {
        imageView.layer.cornerRadius = 8
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(imageViewClicked)
        ))

        reelView.layer.cornerRadius = 8
        reelView.isUserInteractionEnabled = true
        reelView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(reelViewClicked)
        ))
    }

    private func setupCamera() {
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            print("Failed to get the camera device")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)

            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = cameraView.layer.bounds
            videoPreviewLayer?.cornerRadius = 16
            cameraView.layer.addSublayer(videoPreviewLayer!)
        } catch {
            print(error)
            return
        }
    }

    @objc func imageViewClicked() {
        let imagePicker = UIImagePickerController()
        imagePicker.title = "Profile Picture"
        imagePicker.delegate = self
        imagePicker.modalPresentationStyle = .overFullScreen
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true)
    }

    @objc func reelViewClicked() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.mediaTypes = ["public.movie"]
        imagePicker.sourceType = .camera
        imagePicker.modalPresentationStyle = .overFullScreen
        present(imagePicker, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cameracreatePostSeg" {
            if let VC = segue.destination as? CreatePostViewController {
                if let postType = sender as? PostType {
                    if postType == .image {
                        VC.images = [selectedImage!]
                    } else {
                        VC.videoPath = videoURL
                    }
                    VC.postType = postType
                }
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate

extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
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
            videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL
            dismiss(animated: true) {
                self.performSegue(withIdentifier: "cameracreatePostSeg", sender: PostType.video)
            }
        }
    }

    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect rect: CGRect, angle: Int) {
        dismiss(animated: true) {
            self.selectedImage = image
            self.performSegue(withIdentifier: "cameracreatePostSeg", sender: PostType.image)
        }
    }

    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        dismiss(animated: true) {
            Constants.selectedTabBarPosition = 3
            self.beRootScreen(storyBoardName: StoryBoard.tabBar, mIdentifier: Identifier.tabBarViewController)
        }
    }
}
