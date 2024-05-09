// Copyright © 2023 SOFTMENT. All rights reserved.

import Lottie
import UIKit

class SuccessPostViewController: UIViewController {
    @IBOutlet var animationView: LottieAnimationView!

    override func viewDidLoad() {
        self.animationView.loopMode = .loop
        self.animationView.play()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            Constants.selectedTabbarPosition = 0
            self.beRootScreen(storyBoardName: .Tabbar, mIdentifier: .TABBARVIEWCONTROLLER)
        }
    }
}
