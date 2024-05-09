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
        self.montView.layer.cornerRadius = 8
        self.yearView.layer.cornerRadius = 8
        self.lifetimeView.layer.cornerRadius = 8

        self.startFreeBtn.layer.cornerRadius = 8

        self.mostPopularView.layer.cornerRadius = 6

        self.montView.isUserInteractionEnabled = true
        self.yearView.isUserInteractionEnabled = true
        self.lifetimeView.isUserInteractionEnabled = true

        self.montView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.monthClicked)))
        self.montView.dropShadow()

        self.yearView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.yearClicked)))
        self.yearView.dropShadow()

        self.lifetimeView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.lifetimeClicked)
        ))
        self.lifetimeView.dropShadow()

        self.termsOfUse.isUserInteractionEnabled = true
        self.termsOfUse.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.termsOfUseClicked)
        ))

        self.privacyPolicy.isUserInteractionEnabled = true
        self.privacyPolicy.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.privacyPolicyClicked)
        ))

        self.backView.isUserInteractionEnabled = true
        self.backView.dropShadow()
        self.backView.layer.cornerRadius = 8
        self.backView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.backBtnClicked)
        ))

        self.crown.isUserInteractionEnabled = true
        self.crown.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.crownClicked)))
    }

    func showDropIn(clientTokenOrTokenizationKey: String, planID: PriceID) {
        let request = BTDropInRequest()

        let dropIn = BTDropInController(
            authorization: clientTokenOrTokenizationKey,
            request: request
        ) { controller, result, error in
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
        present(dropIn!, animated: true, completion: nil)
    }

    func handlePaymentMethodSelected(_ paymentMethod: BTPaymentMethodNonce, planID: PriceID) {
        self.ProgressHUDShow(text: "")
        self.handleSubscriptionCreation(paymentMethodNonce: paymentMethod.nonce, planId: planID)
    }
            
    func handleSubscriptionCreation(paymentMethodNonce: String, planId: PriceID) {
    
        self.callCreateSubscriptionFunction(nonce: paymentMethodNonce, planId: planId.rawValue) { success, error in
            if let error = error {
                self.ProgressHUDHide()
                self.showError(error)
            } else {
                self.ProgressHUDHide()
                
                UserModel.data?.isFreeTrial = true
                UserModel.data?.isDuringTrial = true
                UserModel.data?.daysLeft = 3
                UserModel.data?.status = "active"
                UserModel.data?.isAccountActive = true
                UserModel.data?.planID = planId.rawValue
                
                self.performSegue(withIdentifier: "successSeg", sender: nil)
            }
        }
    }

    @objc func crownClicked() {
        performSegue(withIdentifier: "vipCodeSeg", sender: nil)
    }

  
    @objc func backBtnClicked(){
        self.dismiss(animated: true)
    }

    @objc func termsOfUseClicked() {
        guard let url = URL(string: "https://mymink.com.au/terms-of-use/") else {
            return
        }
        UIApplication.shared.open(url)
    }

    @objc func privacyPolicyClicked() {
        guard let url = URL(string: "https://mymink.com.au/privacy-policy/") else {
            return
        }
        UIApplication.shared.open(url)
    }

    @objc func monthClicked() {
        self.setChecks(type: .MONTH)
    }

    @objc func yearClicked() {
        self.setChecks(type: .YEAR)
    }

    @objc func lifetimeClicked() {
        self.setChecks(type: .LIFETIME)
    }

    func setChecks(type: PriceID) {
        self.membershipType = type
        self.monthCheck.isSelected = false
        self.yearCheck.isSelected = false
        self.lifetimeCheck.isSelected = false

        if type == .MONTH {
            self.monthCheck.isSelected = true
        } else if type == .YEAR {
            self.yearCheck.isSelected = true
        } else if type == .LIFETIME {
            self.lifetimeCheck.isSelected = true
        }
    }

    @IBAction func startFreeTrialClicked(_: Any) {
        if self.membershipType == nil {
            showSnack(messages: "Select membership")
        } else {
            self.brainTreePaymentProcess()
        }
    }

    func gotoSuccessPage() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "successSeg", sender: nil)
        }
    }

    func brainTreePaymentProcess() {
       
            self.showDropIn(
                clientTokenOrTokenizationKey: ENV.ClientTokenOrTokenizationKey,
                planID: self.membershipType!
            )
        
    }
}

// MARK: - PriceID

enum PriceID: String {
    case MONTH = "ID_MONTHLY"
    case YEAR = "ID_YEARLY"
    case LIFETIME = "ID_LIFETIME"
}
