// Copyright © 2023 SOFTMENT. All rights reserved.

import UIKit
import Lottie
class SuccessViewController: UIViewController {
    @IBOutlet var lottieAnimation: LottieAnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLottieAnimation()
        navigateAfterDelay(seconds: 2.0)
    }
    
    private func setupLottieAnimation() {
        lottieAnimation.loopMode = .loop
        lottieAnimation.play()
    }
    
    private func navigateAfterDelay(seconds: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            guard let userID = FirebaseStoreManager.auth.currentUser?.uid else {
                // Handle the case where user ID is not available
                self.showError("User ID not available")
                return
            }
            self.getUserData(uid: userID, showProgress: false)
        }
    }
}
