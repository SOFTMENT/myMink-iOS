// Copyright © 2023 SOFTMENT. All rights reserved.

import UIKit
import Lottie
import RevenueCat
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
            
           
            self.beRootScreen(storyBoardName: StoryBoard.tabBar, mIdentifier: Identifier.tabBarViewController)
        }
    }
}
