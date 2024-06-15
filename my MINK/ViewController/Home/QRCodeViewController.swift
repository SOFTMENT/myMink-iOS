// Copyright © 2023 SOFTMENT. All rights reserved.

import SDWebImage
import UIKit

class QRCodeViewController: UIViewController {
    @IBOutlet var mView: UIView!
    @IBOutlet var backView: UIView!
    @IBOutlet var mProfile: SDAnimatedImageView!

    @IBOutlet var mName: UILabel!
    @IBOutlet var qrView: UIView!
    @IBOutlet var qrImage: UIImageView!
    @IBOutlet var copyLinkBtn: UIButton!

    @IBOutlet var scanQr: UIButton!
    @IBOutlet var shareBtn: UIButton!

    override func viewDidLoad() {
        self.mProfile.makeRounded()
        self.qrView.layer.cornerRadius = 10
        self.qrView.dropShadow()
        self.shareBtn.layer.cornerRadius = 8
        self.copyLinkBtn.layer.cornerRadius = 8
        self.scanQr.layer.cornerRadius = 8

        self.backView.layer.cornerRadius = 8
        self.backView.dropShadow()
        self.backView.isUserInteractionEnabled = true
        self.backView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.backViewClicked)
        ))

        self.mName.text = UserModel.data!.fullName ?? "Name"
        if let path = UserModel.data!.profilePic, !path.isEmpty {
            self.mProfile.setImage(
                imageKey: path,
                placeholder: "profile-placeholder",
                width: 150,
                height: 150,
                shouldShowAnimationPlaceholder: true
            )
        }

        DispatchQueue.main.async {
            self.loadUI()
        }
    }

    func loadUI() {
        if let profileLink = UserModel.data!.profileURL, !profileLink.isEmpty {
            self.loadQRCode(profileLink: profileLink)
        } else {
            createDeepLinkForUserProfile(userModel: UserModel.data!, completion: { url, error in
                if let url = url {
                    UserModel.data!.profileURL = url
                    self.loadQRCode(profileLink: url)
                    FirebaseStoreManager.db.collection(Collections.USERS.rawValue).document(FirebaseStoreManager.auth.currentUser!.uid)
                        .setData(["profileURL": url], merge: true)
                } else {
                    if let error = error {
                        print("CREATE DEEP LINK ERROR " + error.localizedDescription)
                    }
                }
            })
        }
    }

    func loadQRCode(profileLink: String) {
        let image = self.generateQRCode(from: profileLink)
        self.qrImage.image = image
        let smallLogo = UIImage(named: "roundicon")
        smallLogo?.addToCenter(of: self.qrImage)
    }

    @IBAction func copyLinkClicked(_: Any) {
        let link = UserModel.data!.profileURL ?? ""

        if UIPasteboard.general.string == link {
            return
        }
        UIPasteboard.general.string = link
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        showSnack(messages: "Link has copied.")
    }

    @objc func backViewClicked() {
        dismiss(animated: true)
    }

    @IBAction func shareClicked(_: Any) {
        if let image = preparePostScreenshot(view: mView) {
            var imagesToShare = [AnyObject]()
            imagesToShare.append(image)

            let activityViewController = UIActivityViewController(
                activityItems: imagesToShare,
                applicationActivities: nil
            )
            activityViewController.popoverPresentationController?.sourceView = view
            present(activityViewController, animated: true, completion: nil)
        }
    }

    @IBAction func scanClicked(_: Any) {
        performSegue(withIdentifier: "scanQRSeg", sender: nil)
    }

    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")

            guard let qrImage = filter.outputImage else {
                return nil
            }
            let scaleX = self.qrImage.frame.size.width / qrImage.extent.size.width
            let scaleY = self.qrImage.frame.size.height / qrImage.extent.size.height
            let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
}
