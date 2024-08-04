import Amplify
import ATGMediaBrowser
import AVKit
import Combine
import CropViewController
import MobileCoreServices
import UIKit

// MARK: - CreatePostViewController

class CreatePostViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet var image1: UIImageView!
    @IBOutlet var edit1: UIButton!
    @IBOutlet var imageView1: UIView!
    @IBOutlet var image2: UIImageView!
    @IBOutlet var edit2: UIButton!
    @IBOutlet var imageView2: UIView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var imageView3: UIView!
    @IBOutlet var image3: UIImageView!
    @IBOutlet var edit3: UIButton!
    @IBOutlet var image4: UIImageView!
    @IBOutlet var edit4: UIButton!
    @IBOutlet var imageView4: UIView!
    @IBOutlet var editThumbnailBtn: UIButton!
    @IBOutlet var addPostBtn: UIButton!
    @IBOutlet var captionTV: UITextView!
    @IBOutlet var videoMainView: UIView!
    @IBOutlet var backView: UIView!
    @IBOutlet var videImageView: UIImageView!

    // MARK: - Properties
    var postType: PostType?
    var photoURL = [String]()
    var images: [UIImage]?
    var orientations = [CGFloat]()
    var videoPath: URL?
    var businessId: String?

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialViews()
        configurePostType()
        registerKeyboardNotifications()
        setupGestures()
    }

    // MARK: - Setup Methods
    private func setupInitialViews() {
        captionTV.layer.cornerRadius = 8
        captionTV.layer.borderWidth = 1
        captionTV.layer.borderColor = UIColor(red: 221 / 255, green: 221 / 255, blue: 221 / 255, alpha: 1).cgColor
        captionTV.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        captionTV.text = "Write a caption here"
        captionTV.textColor = .lightGray
        captionTV.delegate = self

        [image1, image2, image3, image4].forEach {
            $0?.layer.cornerRadius = 8
        }

        [edit1, edit2, edit3, edit4].forEach {
            $0?.layer.cornerRadius = 6
        }

        editThumbnailBtn.layer.cornerRadius = 6
        addPostBtn.layer.cornerRadius = 8
        videoMainView.layer.cornerRadius = 8
        backView.layer.cornerRadius = 8
        backView.dropShadow()
    }

    private func configurePostType() {
        guard let postType = postType else {
            dismiss(animated: true)
            return
        }

        if postType == .image {
            configureImagePostType()
        } else if postType == .video {
            configureVideoPostType()
        }
    }

    private func configureImagePostType() {
        guard let images = images else {
            dismiss(animated: true)
            return
        }

        for (index, image) in images.enumerated() {
            orientations.append(image.size.width / image.size.height)
            switch index {
            case 0:
                imageView1.isHidden = false
                image1.image = image
            case 1:
                imageView2.isHidden = false
                image2.image = image
            case 2:
                imageView3.isHidden = false
                image3.image = image
            case 3:
                imageView4.isHidden = false
                image4.image = image
            default:
                break
            }
        }
    }

    private func configureVideoPostType() {
        guard let videoPath = videoPath else {
            dismiss(animated: true)
            return
        }

        videoMainView.isHidden = false
        if let thumbnailImage = generateThumbnail(path: videoPath) {
            videImageView.image = thumbnailImage
        }
    }

    private func setupGestures() {
        setupGesture(for: image1, action: #selector(postImageClicked(_:)), index: 0)
        setupGesture(for: image2, action: #selector(postImageClicked(_:)), index: 1)
        setupGesture(for: image3, action: #selector(postImageClicked(_:)), index: 2)
        setupGesture(for: image4, action: #selector(postImageClicked(_:)), index: 3)
        
        videoMainView.isUserInteractionEnabled = true
        videoMainView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(videoClicked)))

        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))

        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }

    private func setupGesture(for imageView: UIImageView, action: Selector, index: Int) {
        let gesture = MyGesture(target: self, action: action)
        gesture.index = index
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(gesture)
    }

    // MARK: - Action Methods
    @IBAction func addThumbnailClicked(_: Any) {
        guard let image = videImageView.image else { return }
        let cropViewController = CropViewController(image: image)
        cropViewController.title = "Thumbnail"
        cropViewController.delegate = self
        cropViewController.aspectRatioLockEnabled = true
        cropViewController.aspectRatioPickerButtonHidden = true
        cropViewController.customAspectRatio = CGSize(width: 1, height: 1)
        present(cropViewController, animated: true)
    }

    @IBAction func addPostBtn(_: Any) {
        createPost()
    }

    @objc private func hideKeyboard() {
        view.endEditing(true)
    }

    @objc private func backBtnClicked() {
        dismiss(animated: true)
    }

    @objc private func postImageClicked(_ gesture: MyGesture) {
        let mediaBrowser = MediaBrowserViewController(index: gesture.index, dataSource: self)
        present(mediaBrowser, animated: true, completion: nil)
    }

    @objc private func videoClicked() {
        guard let videoPath = videoPath else { return }
        let player = AVPlayer(url: videoPath)
        let vc = AVPlayerViewController()
        vc.player = player
        present(vc, animated: true) {
            vc.player?.play()
        }
    }

    // MARK: - Helper Methods
    private func createPost() {
        guard let sCaption = captionTV.text else { return }
        let postModel = PostModel()
        let postID = FirebaseStoreManager.db.collection(Collections.posts.rawValue).document().documentID
        postModel.postID = postID
        postModel.isPromoted = true
        postModel.postImagesOrientations = orientations
        postModel.postCreateDate = Date()
        postModel.postType = postType?.rawValue
        postModel.uid = FirebaseStoreManager.auth.currentUser?.uid

        if let businessId = businessId {
            postModel.bid = businessId
            postModel.isPromoted = false
        }

        if sCaption != "Write a caption here" {
            postModel.caption = sCaption
        }

        switch postType {
        case .image:
            uploadImages(for: postModel)
        case .video:
            postModel.postVideoRatio = initAspectRatioOfVideo(with: videoPath!)
            uploadVideo(for: postModel)
        case .text:
            guard !sCaption.isEmpty else {
                showSnack(messages: "Enter Caption")
                return
            }
            ProgressHUDShow(text: "")
            postAdd(postModel: postModel)
        default:
            break
        }
    }

    private func uploadImages(for postModel: PostModel) {
        photoURL.removeAll()
        let fetchGroup = DispatchGroup()
        var i = 1
        let loading = DownloadProgressHUDShow(text: "Image 1 Uploading...")

        images?.forEach { photo in
            fetchGroup.enter()
            uploadFilesOnAWS(photo: photo, folderName: "PostImages", postType: .image, shouldHideProgress: true) { downloadURL in
                if let downloadURL = downloadURL {
                    self.photoURL.append(downloadURL)
                    self.DownloadProgressHUDUpdate(loading: loading, text: "Image \(i) Uploading...")
                    i += 1
                    loading.label.layoutIfNeeded()
                }
                fetchGroup.leave()
            }
        }

        fetchGroup.notify(queue: .main) {
            self.photoURL.sort { $0 < $1 }
            Constants.imageIndex = 0
            postModel.postImages = self.photoURL

            self.createDeepLinkForPost(postModel: postModel) { url, error in
                if let url = url {
                    postModel.shareURL = url
                    self.postAdd(postModel: postModel)
                }
            }
        }
    }

    private func uploadVideo(for postModel: PostModel) {
        ProgressHUDShow(text: "")
        guard let postID = postModel.postID else {
            self.showSnack(messages: "PostID is null")
            return
        }
        resizeVideo(id: postID , url: videoPath!) { url in
            guard let url = url else { return }

            self.uploadFilesOnAWS(videoPath: url, folderName: "PostVideos", postType: .video) { downloadURL in
                guard let downloadURL = downloadURL else { return }
                postModel.postVideo = downloadURL

                self.uploadFilesOnAWS(photo: self.videImageView.image!, folderName: "PostVideos", postType: .image, shouldHideProgress: true) { downloadURL in
                    postModel.videoImage = downloadURL
                    self.createDeepLinkForPost(postModel: postModel) { url, error in
                        if let url = url {
                            postModel.shareURL = url
                            self.postAdd(postModel: postModel)
                        }
                    }
                }
            }
        }
    }

    private func postAdd(postModel: PostModel) {
      
        addPost(postModel: postModel) { error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error)
            } else {
                if self.businessId != nil {
                    self.showSnack(messages: "Post Added")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        self.dismiss(animated: true)
                    }
                } else {
                    self.performSegue(withIdentifier: "successPostSeg", sender: nil)
                }
            }
        }
    }

    private func resizeVideo(id: String, url: URL, completion: @escaping (URL?) -> Void) {
        let asset = AVAsset(url: url)
        let outputMovieURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(id).mov")
        let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPreset640x480)
        exporter?.outputURL = outputMovieURL
        exporter?.outputFileType = .mov

        exporter?.exportAsynchronously {
            DispatchQueue.main.async {
                if exporter?.error != nil {
                    completion(nil)
                } else {
                    completion(outputMovieURL)
                }
            }
        }
    }

    private func initAspectRatioOfVideo(with fileURL: URL) -> Double {
        let resolution = resolutionForLocalVideo(url: fileURL)
        guard let width = resolution?.width, let height = resolution?.height else { return 0 }
        return Double(width / height)
    }

    private func resolutionForLocalVideo(url: URL) -> CGSize? {
        guard let track = AVURLAsset(url: url).tracks(withMediaType: .video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: abs(size.width), height: abs(size.height))
    }

    // MARK: - Keyboard Handling
    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrameValue = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue else { return }
        let keyboardFrame = view.convert(keyboardFrameValue.cgRectValue, from: nil)
        scrollView.contentOffset = CGPoint(x: 0, y: keyboardFrame.size.height)
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentOffset = .zero
    }
}

// MARK: - UITextViewDelegate
extension CreatePostViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Write a caption here"
            textView.textColor = .lightGray
        }
    }
}

// MARK: - MediaBrowserViewControllerDataSource
extension CreatePostViewController: MediaBrowserViewControllerDataSource {
    func mediaBrowser(_ mediaBrowser: ATGMediaBrowser.MediaBrowserViewController, imageAt index: Int, completion: @escaping CompletionBlock) {
        switch index {
        case 0:
            completion(index, image1.image!, .default, nil)
        case 1:
            completion(index, image2.image!, .default, nil)
        case 2:
            completion(index, image3.image!, .default, nil)
        case 3:
            completion(index, image4.image!, .default, nil)
        default:
            break
        }
    }

    func numberOfItems(in mediaBrowser: ATGMediaBrowser.MediaBrowserViewController) -> Int {
        return images?.count ?? 0
    }
}

// MARK: - CropViewControllerDelegate
extension CreatePostViewController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect rect: CGRect, angle: Int) {
        videImageView.image = image
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITextFieldDelegate
extension CreatePostViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
