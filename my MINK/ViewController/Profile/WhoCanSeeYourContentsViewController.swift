// Copyright © 2023 SOFTMENT. All rights reserved.

import UIKit

class WhoCanSeeYourContentsViewController: UIViewController {
    @IBOutlet var backView: UIView!

    @IBOutlet var topView: UIView!

    @IBOutlet var mView: UIView!

    @IBOutlet var mSwitch: UISwitch!

    override func viewDidLoad() {
        self.mView.clipsToBounds = true
        self.mView.layer.cornerRadius = 20
        self.mView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        self.topView.isUserInteractionEnabled = true
        self.topView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backViewClicked)))

        self.backView.layer.cornerRadius = 8
        self.backView.dropShadow()
        self.backView.isUserInteractionEnabled = true
        self.backView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.backViewClicked)
        ))

        if let isAccountPrivate = UserModel.data!.isAccountPrivate, isAccountPrivate {
            self.mSwitch.isOn = true
        }
    }

    @IBAction func statusChanged(_ sender: UISwitch) {
        UserModel.data!.isAccountPrivate = sender.isOn
        FirebaseStoreManager.db.collection("Users").document(FirebaseStoreManager.auth.currentUser!.uid)
            .setData(["isAccountPrivate": sender.isOn], merge: true)
    }

    @objc func backViewClicked() {
        dismiss(animated: true)
    }
}
