// Copyright © 2023 SOFTMENT. All rights reserved.

import BSImagePicker
import Photos
import UIKit

// MARK: - CreatePostPopupViewController

class CreatePostPopupViewController: UIViewController {
    @IBOutlet var textView: UIView!
    var videoURL: URL?
    var photoArray = [UIImage]()
    @IBOutlet var closeBtnClicked: UIImageView!
    @IBOutlet var mView: UIView!
    @IBOutlet var reelView: UIView!
    @IBOutlet var imagesView: UIView!
    var businessId : String?

    override func viewDidLoad() {
        self.textView.layer.cornerRadius = 8
        self.reelView.layer.cornerRadius = 8
        self.imagesView.layer.cornerRadius = 8
        self.mView.clipsToBounds = true
        self.mView.layer.cornerRadius = 20
        self.mView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        self.mView.isUserInteractionEnabled = true

        self.imagesView.isUserInteractionEnabled = true
        self.imagesView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.createImagePosClicked)
        ))

        self.reelView.isUserInteractionEnabled = true
        self.reelView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.uploadVideoClicked)
        ))

        self.textView.isUserInteractionEnabled = true
        self.textView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.textViewClicked)
        ))

        self.closeBtnClicked.isUserInteractionEnabled = true
        self.closeBtnClicked.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.dismissClicked)
        ))
    }

    @objc func textViewClicked() {
        self.performSegue(withIdentifier: "createPostSeg", sender: PostType.TEXT)
    }

    func uploadImages() {
        let imagePicker = ImagePickerController()
        imagePicker.settings.selection.max = 4
        presentImagePicker(imagePicker, select: { _ in
            // User selected an asset. Do something with it. Perhaps begin processing/upload?
        }, deselect: { _ in
            // User deselected an asset. Cancel whatever you did when asset was selected.
        }, cancel: { _ in
            // User canceled selection.
        }, finish: { assets in

            var imageRequestOptions: PHImageRequestOptions {
                let options = PHImageRequestOptions()
                options.version = .current
                options.resizeMode = .exact
                options.deliveryMode = .highQualityFormat
                options.isNetworkAccessAllowed = true
                options.isSynchronous = true
                return options
            }

            self.photoArray.removeAll()

            for asset in assets {
                PHImageManager.default().requestImage(
                    for: asset,
                    targetSize: PHImageManagerMaximumSize,
                    contentMode: .aspectFit,
                    options: imageRequestOptions
                ) { image, _ in
                    if let image = image {
                        self.photoArray.append(image)
                    }
                }
            }
            if !self.photoArray.isEmpty {
                self.dismiss(animated: true) {
                    self.performSegue(withIdentifier: "createPostSeg", sender: PostType.IMAGE)
                }
            }
        })
    }

    @objc func uploadVideoClicked() {
        let alert = UIAlertController(title: "Upload Video", message: "", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Using Camera", style: .default) { _ in

            let image = UIImagePickerController()
            image.delegate = self

            image.mediaTypes = ["public.movie"]
            image.sourceType = .camera
            self.present(image, animated: true)
        }

        let action2 = UIAlertAction(title: "From Photo Library", style: .default) { _ in

            let image = UIImagePickerController()
            image.delegate = self

            image.mediaTypes = ["public.movie"]
            image.sourceType = .photoLibrary
            self.present(image, animated: true)
        }

        let action3 = UIAlertAction(title: "Cancel", style: .cancel) { _ in

            alert.dismiss(animated: true, completion: nil)
        }

        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(action3)

        present(alert, animated: true, completion: nil)
    }

    @objc func createImagePosClicked() {
        self.uploadImages()
    }

    @objc func dismissClicked() {
        dismiss(animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        if segue.identifier == "createPostSeg" {
          
            if let VC = segue.destination as? CreatePostViewController {
                
                if let postType = sender as? PostType {
                    
                    if postType == .IMAGE {
                        VC.images = self.photoArray
                    } else {
                        VC.videoPath = self.videoURL
                    }
                    VC.postType = postType
                    VC.businessId = self.businessId
                }
            }
        }
    }
}

// MARK: UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension CreatePostPopupViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        self
            .videoURL =
            info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.mediaURL.rawValue)] as? URL
        dismiss(animated: true) {
            self.performSegue(withIdentifier: "createPostSeg", sender: PostType.VIDEO)
        }
    }
}
