// Copyright © 2023 SOFTMENT. All rights reserved.

import UIKit

class WhoCanSeeYourContentsViewController: UIViewController {
    @IBOutlet var backView: UIView!
    @IBOutlet var topView: UIView!
    @IBOutlet var mView: UIView!
    @IBOutlet var mSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
        setupGestureRecognizers()
        updateSwitchState()
    }

    private func configureViews() {
        mView.clipsToBounds = true
        mView.layer.cornerRadius = 20
        mView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        backView.layer.cornerRadius = 8
        backView.dropShadow()
    }

    private func setupGestureRecognizers() {
        let backViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(backViewClicked))
        topView.addGestureRecognizer(backViewTapGesture)
        backView.addGestureRecognizer(backViewTapGesture)
        topView.isUserInteractionEnabled = true
        backView.isUserInteractionEnabled = true
    }

    private func updateSwitchState() {
        guard let isAccountPrivate = UserModel.data?.isAccountPrivate else {
            mSwitch.isOn = false
            return
        }
        mSwitch.isOn = isAccountPrivate
    }

    @IBAction func statusChanged(_ sender: UISwitch) {
        guard let userId = FirebaseStoreManager.auth.currentUser?.uid else { return }
        UserModel.data?.isAccountPrivate = sender.isOn
        FirebaseStoreManager.db.collection(Collections.users.rawValue).document(userId)
            .setData(["isAccountPrivate": sender.isOn], merge: true)
    }

    @objc func backViewClicked() {
        dismiss(animated: true)
    }
}
