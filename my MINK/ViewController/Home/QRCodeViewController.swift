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
        super.viewDidLoad()
        setupUI()
        DispatchQueue.main.async {
            self.loadUI()
        }
    }

    private func setupUI() {
        mProfile.makeRounded()
        [qrView, backView].forEach { view in
            view?.layer.cornerRadius = 8
            view?.dropShadow()
        }
        [shareBtn, copyLinkBtn, scanQr].forEach { button in
            button?.layer.cornerRadius = 8
        }

        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.backViewClicked)
        ))

        mName.text = UserModel.data?.fullName ?? "Name".localized()
        if let path = UserModel.data?.profilePic, !path.isEmpty {
            mProfile.setImage(
                imageKey: path,
                placeholder: "profile-placeholder",
                width: 150,
                height: 150,
                shouldShowAnimationPlaceholder: true
            )
        }
    }

    private func loadUI() {
        if let profileLink = UserModel.data?.profileURL, !profileLink.isEmpty {
            loadQRCode(profileLink: profileLink)
        } else {
            createDeepLinkForUserProfile(userModel: UserModel.data!) { url, error in
                if let url = url {
                    UserModel.data?.profileURL = url
                    self.loadQRCode(profileLink: url)
                    FirebaseStoreManager.db.collection(Collections.users.rawValue).document(FirebaseStoreManager.auth.currentUser!.uid)
                        .setData(["profileURL": url], merge: true)
                } else if let error = error {
                    print("CREATE DEEP LINK ERROR " + error.localizedDescription)
                }
            }
        }
    }

    private func loadQRCode(profileLink: String) {
        if let image = generateQRCode(from: profileLink) {
            qrImage.image = image
            let smallLogo = UIImage(named: "roundicon")
            smallLogo?.addToCenter(of: qrImage)
        }
    }

    @IBAction func copyLinkClicked(_: Any) {
        guard let link = UserModel.data?.profileURL, UIPasteboard.general.string != link else { return }
        UIPasteboard.general.string = link
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        showSnack(messages: "Link has copied.".localized())
    }

    @objc private func backViewClicked() {
        dismiss(animated: true)
    }

    @IBAction func shareClicked(_: Any) {
        if let image = preparePostScreenshot(view: mView) {
            let activityViewController = UIActivityViewController(
                activityItems: [image],
                applicationActivities: nil
            )
            activityViewController.popoverPresentationController?.sourceView = view
            present(activityViewController, animated: true)
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
