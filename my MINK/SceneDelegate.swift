// Copyright © 2023 SOFTMENT. All rights reserved.

import BranchSDK
import Firebase
import MBProgressHUD


class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
   

    func scene(
        _ scene: UIScene,
        willConnectTo _: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene
        // `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see
        // `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else {
            return
        }

        if let userActivity = connectionOptions.userActivities.first {
            BranchScene.shared().scene(scene, continue: userActivity)
        } else if !connectionOptions.urlContexts.isEmpty {
            BranchScene.shared().scene(scene, openURLContexts: connectionOptions.urlContexts)
        }
    }

    func sceneDidDisconnect(_: UIScene) {
        NotificationCenter.default.post(name: NSNotification.Name("PauseAVPlayerNotification"), object: nil)
    }

    func sceneDidBecomeActive(_: UIScene) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.

        NotificationCenter.default.post(name: NSNotification.Name("ResumeAVPlayerNotification"), object: nil)
    }

    func sceneWillResignActive(_: UIScene) {
        NotificationCenter.default.post(name: NSNotification.Name("PauseAVPlayerNotification"), object: nil)
    }

    func sceneWillEnterForeground(_: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.

        NotificationCenter.default.post(name: NSNotification.Name("ResumeAVPlayerNotification"), object: nil)
    }

    func sceneDidEnterBackground(_: UIScene) {
        NotificationCenter.default.post(name: NSNotification.Name("PauseAVPlayerNotification"), object: nil)
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        BranchScene.shared().scene(scene, continue: userActivity)
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        BranchScene.shared().scene(scene, openURLContexts: URLContexts)
       
    }
}
