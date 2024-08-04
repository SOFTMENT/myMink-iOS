// Copyright © 2023 SOFTMENT. All rights reserved.

import Braintree
import BraintreeDropIn
import UIKit

// MARK: - MembershipViewController

class MembershipViewController: UIViewController {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet var crown: UIImageView!
    @IBOutlet var montView: UIView!
    @IBOutlet var yearView: UIView!
    @IBOutlet var lifetimeView: UIView!
    @IBOutlet weak var monthPrice: UILabel!
    @IBOutlet weak var yearlyPrice: UILabel!
    @IBOutlet weak var lifetimePrice: UILabel!
    @IBOutlet var monthCheck: UIButton!
    @IBOutlet var yearCheck: UIButton!
    @IBOutlet var lifetimeCheck: UIButton!
    @IBOutlet var mostPopularView: UIButton!
    @IBOutlet var privacyPolicy: UILabel!
    @IBOutlet var termsOfUse: UILabel!
    @IBOutlet var startFreeBtn: UIButton!
    
    var membershipType: PriceID?
    
    override var prefersStatusBarHidden: Bool {
        true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fetchSubscriptionInfo()
    }

    private func setupViews() {
        [montView, yearView, lifetimeView, startFreeBtn, mostPopularView].forEach {
            $0?.layer.cornerRadius = 8
        }
        mostPopularView.layer.cornerRadius = 6
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        
        [montView, yearView, lifetimeView].forEach {
            $0?.isUserInteractionEnabled = true
            $0?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePlanSelection(_:))))
            $0?.dropShadow()
        }

        termsOfUse.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(termsOfUseClicked)))
        privacyPolicy.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(privacyPolicyClicked)))
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        crown.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(crownClicked)))

        [termsOfUse, privacyPolicy, backView, crown].forEach {
            $0?.isUserInteractionEnabled = true
        }
    }

    private func fetchSubscriptionInfo() {
        ProgressHUDShow(text: "")
        
        getSubscriptionInfo(planID: PriceID.month.rawValue) { [weak self] price, isActive in
            guard let self = self else { return }
            self.ProgressHUDHide()
            self.montView.isHidden = !isActive
            self.monthPrice.text = "$\(price) per month"
        }
        
        getSubscriptionInfo(planID: PriceID.year.rawValue) { [weak self] price, isActive in
            guard let self = self else { return }
            self.yearView.isHidden = !isActive
            self.yearlyPrice.text = "$\(price) per year"
        }
        
        getSubscriptionInfo(planID: PriceID.lifetime.rawValue) { [weak self] price, isActive in
            guard let self = self else { return }
            self.lifetimeView.isHidden = !isActive
            self.lifetimePrice.text = "$\(price)"
        }
    }

    private func showDropIn(clientTokenOrTokenizationKey: String, planID: PriceID) {
        let request = BTDropInRequest()
        let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request) { controller, result, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.showError(error.localizedDescription)
                }
            } else if result?.isCanceled == true {
                print("CANCELED")
            } else if let result = result, let paymentMethod = result.paymentMethod {
                self.handlePaymentMethodSelected(paymentMethod, planID: planID)
            }
            controller.dismiss(animated: true, completion: nil)
        }
        if let dropInController = dropIn {
            present(dropInController, animated: true, completion: nil)
        }
    }

    private func handlePaymentMethodSelected(_ paymentMethod: BTPaymentMethodNonce, planID: PriceID) {
        ProgressHUDShow(text: "")
        handleSubscriptionCreation(paymentMethodNonce: paymentMethod.nonce, planId: planID)
    }
    
    private func handleSubscriptionCreation(paymentMethodNonce: String, planId: PriceID) {
        callCreateSubscriptionFunction(nonce: paymentMethodNonce, planId: planId.rawValue) { [weak self] success, error in
            guard let self = self else { return }
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error)
            } else {
                self.updateUserModel(planId: planId)
                self.gotoSuccessPage()
            }
        }
    }

    private func updateUserModel(planId: PriceID) {
        UserModel.data?.isFreeTrial = true
        UserModel.data?.isDuringTrial = true
        UserModel.data?.daysLeft = 3
        UserModel.data?.status = "active"
        UserModel.data?.isAccountActive = true
        UserModel.data?.planID = planId.rawValue
    }
    
    private func gotoSuccessPage() {
        performSegue(withIdentifier: "successSeg", sender: nil)
    }

    @objc private func crownClicked() {
        performSegue(withIdentifier: "vipCodeSeg", sender: nil)
    }

    @objc private func backBtnClicked() {
        dismiss(animated: true)
    }

    @objc private func termsOfUseClicked() {
        if let url = URL(string: "https://mymink.com.au/terms-of-use/") {
            UIApplication.shared.open(url)
        }
    }

    @objc private func privacyPolicyClicked() {
        if let url = URL(string: "https://mymink.com.au/privacy-policy/") {
            UIApplication.shared.open(url)
        }
    }

    @objc private func handlePlanSelection(_ sender: UITapGestureRecognizer) {
        if sender.view == montView {
            setChecks(type: .month)
        } else if sender.view == yearView {
            setChecks(type: .year)
        } else if sender.view == lifetimeView {
            setChecks(type: .lifetime)
        }
    }

    private func setChecks(type: PriceID) {
        membershipType = type
        monthCheck.isSelected = (type == .month)
        yearCheck.isSelected = (type == .year)
        lifetimeCheck.isSelected = (type == .lifetime)
    }

    @IBAction private func startFreeTrialClicked(_ sender: Any) {
        guard let membershipType = membershipType else {
            showSnack(messages: "Select membership")
            return
        }
        brainTreePaymentProcess(for: membershipType)
    }

    private func brainTreePaymentProcess(for planID: PriceID) {
        showDropIn(clientTokenOrTokenizationKey: ENV.ClientTokenOrTokenizationKey, planID: planID)
    }
}
