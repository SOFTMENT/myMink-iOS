//
//  ScheduleLiveViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 31/05/24.
//

import UIKit

class ScheduleLiveViewController: UIViewController {
    @IBOutlet var backView: UIView!
    @IBOutlet var topView: UIView!
    @IBOutlet var mView: UIView!
    @IBOutlet var liveUrl: UILabel!
    @IBOutlet var copyBtn: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserModel()
    }

    private func setupUI() {
        mView.clipsToBounds = true
        mView.layer.cornerRadius = 20
        mView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        topView.isUserInteractionEnabled = true
        topView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))

        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(backViewClicked)
        ))

        copyBtn.isUserInteractionEnabled = true
        copyBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(copyBtnClicked)))
    }

    private func loadUserModel() {
        guard let userModel = UserModel.data else {
            dismissViewController()
            return
        }

        liveUrl.text = "\(Constants.myMinkAppDomain)livestram/\(userModel.username ?? "")"
        if let livestreamingURL = userModel.livestreamingURL, !livestreamingURL.isEmpty {
            liveUrl.text = livestreamingURL
        } else {
            createDeepLinkForLivestream(userModel: userModel) { url, error in
                if let url = url, !url.isEmpty {
                    UserModel.data?.livestreamingURL = url
                    self.liveUrl.text = url
                    FirebaseStoreManager.db.collection(Collections.users.rawValue)
                        .document(FirebaseStoreManager.auth.currentUser!.uid)
                        .setData(["livestreamingURL": url], merge: true)
                }
            }
        }
    }

    @objc func backViewClicked() {
        dismiss(animated: true)
    }

    @objc func copyBtnClicked() {
        let url = liveUrl.text ?? ""
        if UIPasteboard.general.string != url {
            UIPasteboard.general.string = url
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            showSnack(messages: "Copied.")
        }
    }

    private func dismissViewController() {
        DispatchQueue.main.async {
            self.dismiss(animated: true)
        }
    }
}
