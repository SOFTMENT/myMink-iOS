// Copyright © 2023 SOFTMENT. All rights reserved.

import Braintree
import UIKit
import RevenueCat
import StoreKit
import FirebaseFunctions

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
        fetchAvailablePackages()
    }
    
    func fetchAvailablePackages() {
        Purchases.shared.getProducts([PriceID.month.rawValue, PriceID.year.rawValue, PriceID.lifetime.rawValue]) { (products) in
                // Display the products (monthly, yearly, lifetime) to the user
                for product in products {
                    print("Product available: \(product.localizedTitle) - \(product.price)")
                    
                    // If there's a free trial, display the trial info
                    if let introDiscount = product.introductoryDiscount {
                        let trialPeriod = introDiscount.subscriptionPeriod
                        let trialDuration = "\(trialPeriod.value) \(self.unitDescription(for: trialPeriod.unit))"
                        print("Free Trial: \(trialDuration) for \(product.localizedTitle)")
                    }
                }
            }
        }
        
        // Helper function to get the description of the subscription unit
        func unitDescription(for unit: SubscriptionPeriod.Unit) -> String {
            switch unit {
            case .day:
                return "day(s)"
            case .week:
                return "week(s)"
            case .month:
                return "month(s)"
            case .year:
                return "year(s)"
            @unknown default:
                return "unknown unit"
            }
        }
        
      func purchase(productIdentifier: String) {
          self.ProgressHUDShow(text: "Purchasing...")
          Purchases.shared.getProducts([productIdentifier]) { (products) in
              guard let productToPurchase = products.first else {
                  self.showError("Product not found")
                  self.ProgressHUDHide()
                  return
              }
              
              
              // First, get the user’s unique ID (e.g., from FirebaseAuth)
              if let currentUser = FirebaseStoreManager.auth.currentUser {
                  let userId = currentUser.uid  // Use Firebase UID as the App User ID
                  
                  // Log the user in to RevenueCat using their unique user ID
                  Purchases.shared.logIn(userId) { (customerInfo, created, error) in
                      if let error = error {
                          self.ProgressHUDHide()
                          self.showError("Error logging in: \(error.localizedDescription)")
                        
                      } else {
                          Purchases.shared.purchase(product: productToPurchase) { (transaction, purchaserInfo, error, userCancelled) in
                              if let error = error {
                                  self.ProgressHUDHide()
                                  self.showError("Purchase Failed ",error.localizedDescription)
                               
                              }
                              else if let purchaserInfo = purchaserInfo {
                                  // Call unlockPremiumFeatures with the purchaser info
                                  self.unlockPremiumFeatures(for: purchaserInfo)
                              }
                          }
                      }
                  }
              } else {
                  print("User not logged in to Firebase.")
              }

          }
      }
        
    func unlockPremiumFeatures(for purchaserInfo: CustomerInfo) {
        // Check if the user has the "Premium" entitlement active
        if let entitlement = purchaserInfo.entitlements["Premium"], entitlement.isActive {

            
            // Get the active subscription product identifier
            let activeSubscriptions = entitlement.productIdentifier
            
            // Check if the active subscription is monthly, yearly, or lifetime
            if activeSubscriptions.contains("in.softment.monthly") {
            
                self.updateUserModel(planId: .month)
                self.updateSubscriptionInFirestore()
            } else if activeSubscriptions.contains("in.softment.yearly") {
               
                self.updateUserModel(planId: .year)
                self.updateSubscriptionInFirestore()
            } else if activeSubscriptions.contains("in.softment.lifetime") {
              
                self.setLifetimeMembership()
             
            }
           
        }
        else{
            self.ProgressHUDHide()
        }
        
    }
    
    private func setLifetimeMembership() {
      
        UserModel.data?.isAccountActive = true
        UserModel.data?.entitlementStatus = "active"
        UserModel.data?.activeEntitlement = PriceID.lifetime.rawValue
        
        let userUpdates: [String: Any] = [
            "isAccountActive": true,
            "entitlementStatus" : "active",
            "activeEntitlement" : PriceID.lifetime.rawValue
        ]

        FirebaseStoreManager.db.collection(Collections.users.rawValue)
            .document(FirebaseStoreManager.auth.currentUser!.uid)
            .setData(userUpdates, merge: true) { [weak self] error in
                self?.ProgressHUDHide()
                if let error = error {
                    self?.showError(error.localizedDescription)
                } else {
                    self?.gotoSuccessPage()
                }
            }
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
        
        getSubscriptionInfo(planID: "ID_MONTHLY") { [weak self] price, isActive in
            guard let self = self else { return }
            self.ProgressHUDHide()
            self.montView.isHidden = !isActive
            self.monthPrice.text = String(format: "%@ USD per month".localized(), price)
        }
        
        getSubscriptionInfo(planID: "ID_YEARLY") { [weak self] price, isActive in
            guard let self = self else { return }
            self.yearView.isHidden = !isActive
            self.yearlyPrice.text = String(format: "$%@ USD per year".localized(), price)

        }
        
        getSubscriptionInfo(planID: "ID_LIFETIME") { [weak self] price, isActive in
            guard let self = self else { return }
            self.lifetimeView.isHidden = !isActive
            self.lifetimePrice.text = "\(price) USD"
        }
    }

    private func updateUserModel(planId: PriceID) {
        
        UserModel.data?.daysLeft = 3
        UserModel.data?.entitlementStatus = "trialing"
        UserModel.data?.isAccountActive = true
        UserModel.data?.activeEntitlement = planId.rawValue
        
    }
    
    // Function to send userId to Firebase Cloud Function
       func updateSubscriptionInFirestore() {
           guard let userID = FirebaseStoreManager.auth.currentUser?.uid else {
               self.logoutPlease()
               self.ProgressHUDHide()
               return
           }
           
           // Call Firebase Cloud Function with only userId
           let functions = Functions.functions()
           functions.httpsCallable("updateSubscriptionFromClient").call(["userId": userID]) { result, error in
               self.ProgressHUDHide()
               if let error = error {
                  
                   self.showError("Error updating subscription in Firestore: \(error.localizedDescription)")
               } else {
                   self.gotoSuccessPage()
               }
           }
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
            showSnack(messages: "Select membership".localized())
            return
        }
        if membershipType == .month {
            self.purchase(productIdentifier: PriceID.month.rawValue)
        }
        else if membershipType == .year {
            self.purchase(productIdentifier: PriceID.year.rawValue)
        }
        else if membershipType == .lifetime {
            self.purchase(productIdentifier: PriceID.lifetime.rawValue)
        }
        
    }

    
}
