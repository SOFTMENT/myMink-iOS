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
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        self.mView.clipsToBounds = true
        self.mView.layer.cornerRadius = 20
        self.mView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        setupGesture(for: disclaimer, action: #selector(self.disclaimerClicked))
        setupGesture(for: licenseAgreement, action: #selector(self.licenseAgreementClicked))
        setupGesture(for: privacyPolicy, action: #selector(self.privacyPolicyClicked))
        setupGesture(for: termsOfUse, action: #selector(self.termsOfUseClicked))
        setupGesture(for: topView, action: #selector(self.backViewClicked))
        setupGesture(for: backView, action: #selector(self.backViewClicked))

        self.backView.layer.cornerRadius = 8
        self.backView.dropShadow()
    }

    private func setupGesture(for view: UIView, action: Selector) {
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: action))
    }

    @objc private func disclaimerClicked() {
        openURL("https://mymink.com.au/disclaimer/")
    }

    @objc private func licenseAgreementClicked() {
        openURL("https://mymink.com.au/eula")
    }

    @objc private func privacyPolicyClicked() {
        openURL("https://mymink.com.au/privacy-policy/")
    }

    @objc private func termsOfUseClicked() {
        openURL("https://mymink.com.au/terms-of-use")
    }

    @objc private func backViewClicked() {
        dismiss(animated: true)
    }

    private func openURL(_ urlString: String) {
        dismiss(animated: true)
        guard let url = URL(string: urlString) else {
            return
        }
        
        // Use the updated open method with options and completion handler
        UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
            if success {
                print("URL was opened successfully.")
            } else {
                print("Failed to open the URL.")
            }
        })
    }
}
