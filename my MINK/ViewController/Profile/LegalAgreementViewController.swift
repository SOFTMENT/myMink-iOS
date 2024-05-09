// Copyright © 2023 SOFTMENT. All rights reserved.

import UIKit

class LegalAgreementViewController: UIViewController {
    @IBOutlet var backView: UIView!
    @IBOutlet var disclaimer: UIView!
    @IBOutlet var licenseAgreement: UIView!
    @IBOutlet var privacyPolicy: UIView!
    @IBOutlet var termsOfUse: UIView!
    @IBOutlet var topView: UIView!

    @IBOutlet var mView: UIView!

    override func viewDidLoad() {
        self.mView.clipsToBounds = true
        self.mView.layer.cornerRadius = 20
        self.mView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        self.disclaimer.isUserInteractionEnabled = true
        self.disclaimer.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.disclaimerClicked)
        ))

        self.licenseAgreement.isUserInteractionEnabled = true
        self.licenseAgreement.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.licenseAgreementClicked)
        ))

        self.privacyPolicy.isUserInteractionEnabled = true
        self.privacyPolicy.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.privacyPolicyClicked)
        ))

        self.termsOfUse.isUserInteractionEnabled = true
        self.termsOfUse.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.termsOfUseClicked)
        ))

        self.topView.isUserInteractionEnabled = true
        self.topView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backViewClicked)))

        self.backView.layer.cornerRadius = 8
        self.backView.dropShadow()
        self.backView.isUserInteractionEnabled = true
        self.backView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.backViewClicked)
        ))
    }

    @objc func disclaimerClicked() {
        dismiss(animated: true)
        guard let url = URL(string: "https://mymink.com.au/disclaimer/") else {
            return
        }
        UIApplication.shared.open(url)
    }

    @objc func licenseAgreementClicked() {
        dismiss(animated: true)
        guard let url = URL(string: "https://mymink.com.au/eula") else {
            return
        }
        UIApplication.shared.open(url)
    }

    @objc func privacyPolicyClicked() {
        dismiss(animated: true)
        guard let url = URL(string: "https://mymink.com.au/privacy-policy/") else {
            return
        }
        UIApplication.shared.open(url)
    }

    @objc func termsOfUseClicked() {
        dismiss(animated: true)
        guard let url = URL(string: "https://mymink.com.au/terms-of-use") else {
            return
        }
        UIApplication.shared.open(url)
    }

    @objc func backViewClicked() {
        dismiss(animated: true)
    }
}
