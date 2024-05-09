// Copyright © 2023 SOFTMENT. All rights reserved.

import Lottie
import UIKit

class SuccessViewController: UIViewController {
    @IBOutlet var lottieAnimation: LottieAnimationView!

    override func viewDidLoad() {
        self.lottieAnimation.loopMode = .loop
        self.lottieAnimation.play()

        let seconds = 2.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            self.getUserData(uid: FirebaseStoreManager.auth.currentUser!.uid, showProgress: false)
        }
    }
}
