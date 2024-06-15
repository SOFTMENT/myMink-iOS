// Copyright © 2023 SOFTMENT. All rights reserved.

import Amplify
import ATGMediaBrowser
import AVKit
import Combine
import CropViewController
import DSPhotoEditorSDK
import MobileCoreServices
import UIKit

// MARK: - CreatePostViewController

class CreatePostViewController: UIViewController {
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
    var postType: PostType?
    var photoURL = [String]()
    var images: [UIImage]?
    var orientations = [CGFloat]()
    var videoPath: URL?
    var businessId : String?

    override func viewDidLoad() {
        guard let postType = postType else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }

        if postType == .IMAGE {
            if let images = images {
                for i in 0 ..< (images.count) {
                    self.orientations.append(images[i].size.width / images[i].size.height)

                    if i == 0 {
                        self.imageView1.isHidden = false

                        self.image1.image = images[i]
                    } else if i == 1 {
                        self.imageView2.isHidden = false
                        self.image2.image = images[i]
                    } else if i == 2 {
                        self.imageView3.isHidden = false
                        self.image3.image = images[i]
                    } else if i == 3 {
                        self.imageView4.isHidden = false
                        self.image4.image = images[i]
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.dismiss(animated: true)
                }
            }
        } else if postType == .VIDEO {
            if let videoPath = videoPath {
                self.videoMainView.isHidden = false
                if let image = generateThumbnail(path: videoPath) {
                    self.videImageView.image = image
                }
            } else {
                DispatchQueue.main.async {
                    self.dismiss(animated: true)
                }
            }
        }

        self.editThumbnailBtn.layer.cornerRadius = 6

        self.captionTV.layer.cornerRadius = 8
        self.captionTV.layer.borderWidth = 1
        self.captionTV.layer.borderColor = UIColor(red: 221 / 255, green: 221 / 255, blue: 221 / 255, alpha: 1).cgColor
        self.captionTV.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.captionTV.text = "Write a caption here"
        self.captionTV.textColor = UIColor.lightGray
        self.captionTV.delegate = self

        self.image1.layer.cornerRadius = 8
        self.image2.layer.cornerRadius = 8
        self.image3.layer.cornerRadius = 8
        self.image4.layer.cornerRadius = 8

        let myGest1 = MyGesture(target: self, action: #selector(self.postImageClicked))
        self.image1.isUserInteractionEnabled = true
        myGest1.index = 0
        self.image1.addGestureRecognizer(myGest1)

        let myGest2 = MyGesture(target: self, action: #selector(self.postImageClicked))
        self.image2.isUserInteractionEnabled = true
        myGest2.index = 1
        self.image2.addGestureRecognizer(myGest2)

        let myGest3 = MyGesture(target: self, action: #selector(self.postImageClicked))
        self.image3.isUserInteractionEnabled = true
        myGest3.index = 2
        self.image3.addGestureRecognizer(myGest3)

        let myGest4 = MyGesture(target: self, action: #selector(self.postImageClicked))
        self.image4.isUserInteractionEnabled = true
        myGest4.index = 3
        self.image4.addGestureRecognizer(myGest4)

        self.edit1.layer.cornerRadius = 6
        self.edit2.layer.cornerRadius = 6
        self.edit3.layer.cornerRadius = 6
        self.edit4.layer.cornerRadius = 6

        self.addPostBtn.layer.cornerRadius = 8

        self.videoMainView.layer.cornerRadius = 8
        self.videoMainView.isUserInteractionEnabled = true
        self.videoMainView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.videoClicked)
        ))
        self.backView.layer.cornerRadius = 8
        self.backView.dropShadow()
        self.backView.isUserInteractionEnabled = true
        self.backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backBtnClicked)))

        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard)))
    }

    @IBAction func addThumbnailClicked(_: Any) {
        let cropViewController = CropViewController(image: videImageView.image!)
        cropViewController.title = "Thumbnail"
        cropViewController.delegate = self

        cropViewController.aspectRatioLockEnabled = true
        cropViewController.aspectRatioPickerButtonHidden = true
        cropViewController.customAspectRatio = CGSize(width: 1, height: 1)
        present(cropViewController, animated: true)
    }

    func presentDSPhotoEditor(i: Int) {
        let dsPhotoEditorViewController = DSPhotoEditorViewController(image: images![i], toolsToHide: nil)
        dsPhotoEditorViewController!.delegate = self
        dsPhotoEditorViewController?.title = String(i)
        dsPhotoEditorViewController?.modalPresentationStyle = .fullScreen
        present(dsPhotoEditorViewController!, animated: true, completion: nil)
    }

    @IBAction func edit1Clicked(_: Any) {
        self.presentDSPhotoEditor(i: 0)
    }

    @IBAction func edit2Clicked(_: Any) {
        self.presentDSPhotoEditor(i: 1)
    }

    @IBAction func edit3Clicked(_: Any) {
        self.presentDSPhotoEditor(i: 2)
    }

    @IBAction func edit4Clicked(_: Any) {
        self.presentDSPhotoEditor(i: 3)
    }

    @objc func videoClicked() {
        if let videoPath = videoPath {
            let player = AVPlayer(url: videoPath)
            let vc = AVPlayerViewController()
            vc.player = player

            present(vc, animated: true) {
                vc.player?.play()
            }
        }
    }

    func initAspectRatioOfVideo(with fileURL: URL) -> Double {
        let resolution = self.resolutionForLocalVideo(url: fileURL)
        guard let width = resolution?.width, let height = resolution?.height else {
            return 0
        }

        return Double(width / height)
    }

    @IBAction func addPostBtn(_: Any) {
        let sCaption = self.captionTV.text

        let postModel = PostModel()
        let postID = FirebaseStoreManager.db.collection(Collections.POSTS.rawValue).document().documentID
        postModel.postID = postID
        postModel.isPromoted = true
        postModel.postImagesOrientations = self.orientations
            
        postModel.postCreateDate = Date()
        if self.postType == .IMAGE {
            postModel.postType = "image"
        } else if self.postType == .VIDEO {
            postModel.postType = "video"
        } else if self.postType == .TEXT {
            postModel.postType = "text"
        }
        postModel.uid = FirebaseStoreManager.auth.currentUser!.uid
        if let businessId = self.businessId {
            postModel.bid = businessId
            postModel.isPromoted = false
        }

        if sCaption != "Write a caption here" {
            postModel.caption = sCaption
        }

        if self.postType == .IMAGE {
            self.photoURL.removeAll()
            let fetchGroup = DispatchGroup()

            var i = 1
            let loading = DownloadProgressHUDShow(text: "Image 1 Uploading...")
            for photo in self.images! {
                fetchGroup.enter()
                uploadFilesOnAWS(
                    photo: photo,
                    folderName: "PostImages",
                    postType: .IMAGE,
                    shouldHideProgress: true
                ) { downloadURL in
                    if let downloadURL = downloadURL {
                        self.photoURL.append(downloadURL)
                        i = i + 1
                        self.DownloadProgressHUDUpdate(loading: loading, text: "Image \(i) Uploading...")
                        loading.label.layoutIfNeeded()
                    }

                    fetchGroup.leave()
                }
            }

            fetchGroup.notify(queue: DispatchQueue.main) {
                self.DownloadProgressHUDUpdate(loading: loading, text: "")
                loading.label.layoutIfNeeded()
                self.photoURL.sort { url1, url2 in
                    if url1.split(separator: "/").last! < url2.split(separator: "/").last! {
                        return true
                    }
                    return false
                }
                Constants.imageIndex = 0
                postModel.postImages = self.photoURL

                if self.postType == .IMAGE {
                    self.createDeepLinkForPost(postModel: postModel) { url, error in
                        if let url = url {
                            postModel.shareURL = url
                            self.postAdd(postModel: postModel)
                        }
                    }
                }
            }
        } else if self.postType == .VIDEO {
            postModel.postVideoRatio = self.initAspectRatioOfVideo(with: self.videoPath!)

            self.uploadVideo(postModel: postModel)

        } else {
            if sCaption == "" {
                showSnack(messages: "Enter Caption")
            } else {
                ProgressHUDShow(text: "")
                self.postAdd(postModel: postModel)
            }
        }
    }

    func postAdd(postModel: PostModel) {
        self.ProgressHUDShow(text: "")
        
        self.addPost(postModel: postModel) { error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error)
            } else {
                if let businessId = self.businessId {
                    self.showSnack(messages: "Post Added")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        self.dismiss(animated: true)
                    }
                 
                }
                else {
                    self.performSegue(withIdentifier: "successPostSeg", sender: nil)
                }
               
            }
        }
    }

    func resizeVideo(id: String, url: URL, completion: @escaping (URL?) -> Void) {
        let asset = AVAsset(url: url)

        let outputMovieURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent("\(id).mov") // 2
        // create exporter
        let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPreset640x480)

        exporter?.outputURL = outputMovieURL!
        exporter?.outputFileType = .mov
        // export!
        exporter?.exportAsynchronously(completionHandler: { [weak exporter] in // 4
            DispatchQueue.main.async {
                if (exporter?.error) != nil {
                    completion(nil)
                } else {
                    completion(outputMovieURL)
                }
            }
        })
    }

    func uploadVideo(postModel: PostModel) {
        ProgressHUDShow(text: "")
        self.resizeVideo(id: postModel.postID ?? "123", url: self.videoPath!) { url in

            if let url = url {
                self.uploadFilesOnAWS(
                    videoPath: url,
                   
                    folderName: "PostVideos",
                    postType: .VIDEO
                ) { downloadURL in

                    if let downloadURL = downloadURL {
                        postModel.postVideo = downloadURL

                        self.uploadFilesOnAWS(
                            photo: self.videImageView.image!,
                            folderName: "PostVideos",
                            postType: .IMAGE,
                            shouldHideProgress: true
                        ) { downloadURL in
                            postModel.videoImage = downloadURL
                            if self.postType == .VIDEO {
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
            }
        }
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }

    @objc func backBtnClicked() {
        dismiss(animated: true)
    }

    @objc func postImageClicked(value: MyGesture) {
        let mediaBrowser = MediaBrowserViewController(index: value.index, dataSource: self)
        present(mediaBrowser, animated: true, completion: nil)
    }

    // MARK: Private

    private func resolutionForLocalVideo(url: URL) -> CGSize? {
        guard let track = AVURLAsset(url: url).tracks(withMediaType: AVMediaType.video).first else {
            return nil
        }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: abs(size.width), height: abs(size.height))
    }
}

// MARK: UITextViewDelegate

extension CreatePostViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Write a caption here"
            textView.textColor = UIColor.lightGray
        }
    }
}

// MARK: MediaBrowserViewControllerDataSource

extension CreatePostViewController: MediaBrowserViewControllerDataSource {
    func mediaBrowser(
        _: ATGMediaBrowser.MediaBrowserViewController,
        imageAt index: Int,
        completion: @escaping CompletionBlock
    ) {
        if index == 0 {
            completion(index, self.image1.image!, ZoomScale.default, nil)
        } else if index == 1 {
            completion(index, self.image2.image!, ZoomScale.default, nil)
        } else if index == 2 {
            completion(index, self.image3.image!, ZoomScale.default, nil)
        } else {
            completion(index, self.image4.image!, ZoomScale.default, nil)
        }
    }

    func numberOfItems(in _: ATGMediaBrowser.MediaBrowserViewController) -> Int {
        self.images?.count ?? 0
    }
}

// MARK: DSPhotoEditorViewControllerDelegate

extension CreatePostViewController: DSPhotoEditorViewControllerDelegate {
    func dsPhotoEditor(_ editor: DSPhotoEditorViewController!, finishedWith image: UIImage!) {
        dismiss(animated: true) {
            if editor.title == "0" {
                self.images![0] = image
                self.image1.image = image
            } else if editor.title == "1" {
                self.images![1] = image
                self.image2.image = image
            } else if editor.title == "2" {
                self.images![2] = image
                self.image3.image = image
            } else if editor.title == "3" {
                self.images![3] = image
                self.image4.image = image
            }
        }
    }

    func dsPhotoEditorCanceled(_: DSPhotoEditorViewController!) {
        dismiss(animated: true, completion: nil)
    }
}

extension CreatePostViewController {
    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillShow(_:)),
            name: UIControl.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillHide(_:)),
            name: UIControl.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrameValue = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue
        else {
            return
        }
        let keyboardFrame = view.convert(keyboardFrameValue.cgRectValue, from: nil)
        self.scrollView.contentOffset = CGPoint(x: 0, y: keyboardFrame.size.height)
    }

    @objc func keyboardWillHide(_: Notification) {
        self.scrollView.contentOffset = .zero
    }
}

// MARK: UITextFieldDelegate

extension CreatePostViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

// MARK: CropViewControllerDelegate

extension CreatePostViewController: CropViewControllerDelegate {
    func cropViewController(_: CropViewController, didCropToImage image: UIImage, withRect _: CGRect, angle _: Int) {
        self.videImageView.image = image
        dismiss(animated: true, completion: nil)
    }
}
