// Copyright © 2023 SOFTMENT. All rights reserved.

import UIKit

class WelcomeViewController: UIViewController {
    let userDefaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.handleFirstTimeAppLaunch()
        self.navigateToNextScreen()
        
     
    }

    private func handleFirstTimeAppLaunch() {
        if self.userDefaults.value(forKey: "appFirstTimeOpend") == nil {
            self.userDefaults.setValue(true, forKey: "appFirstTimeOpend")
           
            self.signOutUser()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "phoneVerificationSeg" {
            if let VC = segue.destination as? PhoneNumberVerificationController {
                if let value = sender as? String {
                    VC.verificationID = FirebaseStoreManager.auth.currentUser!.uid
                    VC.phoneNumber  = value
                    
                }
            }
        }
    }

    private func navigateToNextScreen() {
        if let currentUser = FirebaseStoreManager.auth.currentUser {
//            self.getUser2FAInfo(for: currentUser.uid) { is2FA, phoneNumber in
//                
//                if is2FA, let phoneNumber = phoneNumber {
//                    self.sendTwilioVerification(to: phoneNumber) { error in
//                        DispatchQueue.main.async {
//                            self.ProgressHUDHide()
//                            if let error = error {
//                                self.showError(error)
//                            } else {
//                                
//                                self.performSegue(
//                                    withIdentifier: "phoneVerificationSeg",
//                                    sender: phoneNumber)
//                                
//                            }
//                                        
//                                        
//                        }
//                        
//                    }
//                }
//                else {
//                    self.getUserData(uid: currentUser.uid, showProgress: false)
//                }
//            }
            self.getUserData(uid: currentUser.uid, showProgress: false)
        } else {
            self.goToSignInViewController()
        }
    }

    private func signOutUser() {
        do {
            try FirebaseStoreManager.auth.signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }

    private func goToSignInViewController() {
        DispatchQueue.main.async {
            self.beRootScreen(storyBoardName: .accountSetup, mIdentifier: .entryViewController)
        }
    }
}
