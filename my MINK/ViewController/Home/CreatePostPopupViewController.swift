import BSImagePicker
import Photos
import UIKit

// MARK: - CreatePostPopupViewController

class CreatePostPopupViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet var textView: UIView!
    @IBOutlet var closeBtnClicked: UIImageView!
    @IBOutlet var mView: UIView!
    @IBOutlet var reelView: UIView!
    @IBOutlet var imagesView: UIView!
    
    // MARK: - Properties
    var videoURL: URL?
    var photoArray = [UIImage]()
    var businessId: String?

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupGestures()
    }

    // MARK: - Setup Methods
    private func setupViews() {
        textView.layer.cornerRadius = 8
        reelView.layer.cornerRadius = 8
        imagesView.layer.cornerRadius = 8
        mView.clipsToBounds = true
        mView.layer.cornerRadius = 20
        mView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }

    private func setupGestures() {
        setupGesture(for: imagesView, action: #selector(createImagePosClicked))
        setupGesture(for: reelView, action: #selector(uploadVideoClicked))
        setupGesture(for: textView, action: #selector(textViewClicked))
        setupGesture(for: closeBtnClicked, action: #selector(dismissClicked))
    }

    private func setupGesture(for view: UIView, action: Selector) {
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: action))
    }

    // MARK: - Action Methods
    @objc private func textViewClicked() {
        performSegue(withIdentifier: "createPostSeg", sender: PostType.text)
    }

    @objc private func createImagePosClicked() {
        uploadImages()
    }

    @objc private func uploadVideoClicked() {
        let alert = UIAlertController(title: "Upload Video".localized(), message: "", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Using Camera".localized(), style: .default) { _ in
            self.presentImagePickerController(sourceType: .camera)
        }
        let action2 = UIAlertAction(title: "From Photo Library".localized(), style: .default) { _ in
            self.presentImagePickerController(sourceType: .photoLibrary)
        }
        let action3 = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(action3)
        present(alert, animated: true, completion: nil)
    }

    @objc private func dismissClicked() {
        dismiss(animated: true)
    }

    // MARK: - Helper Methods
    private func presentImagePickerController(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.mediaTypes = ["public.movie"]
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true)
    }

    private func uploadImages() {
        let imagePicker = ImagePickerController()
        imagePicker.settings.selection.max = 4
        presentImagePicker(imagePicker, select: { _ in
            // User selected an asset. Do something with it.
        }, deselect: { _ in
            // User deselected an asset. Cancel whatever you did when asset was selected.
        }, cancel: { _ in
            // User canceled selection.
        }, finish: { assets in
            self.photoArray.removeAll()
            self.fetchSelectedImages(from: assets)
            if !self.photoArray.isEmpty {
                self.dismiss(animated: true) {
                    self.performSegue(withIdentifier: "createPostSeg", sender: PostType.image)
                }
            }
        })
    }

    private func fetchSelectedImages(from assets: [PHAsset]) {
        let options = PHImageRequestOptions()
        options.version = .current
        options.resizeMode = .exact
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.isSynchronous = true

        for asset in assets {
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: PHImageManagerMaximumSize,
                contentMode: .aspectFit,
                options: options
            ) { image, _ in
                if let image = image {
                    self.photoArray.append(image)
                }
            }
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createPostSeg", let vc = segue.destination as? CreatePostViewController {
            if let postType = sender as? PostType {
                if postType == .image {
                    vc.images = self.photoArray
                } else {
                    vc.videoPath = self.videoURL
                }
                vc.postType = postType
                vc.businessId = self.businessId
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension CreatePostPopupViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL
        dismiss(animated: true) {
            self.performSegue(withIdentifier: "createPostSeg", sender: PostType.video)
        }
    }
}
