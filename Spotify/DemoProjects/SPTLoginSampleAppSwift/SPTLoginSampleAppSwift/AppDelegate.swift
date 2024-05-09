// Copyright © 2023 SOFTMENT. All rights reserved.

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    lazy var rootViewController = ViewController()

    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = self.rootViewController
        self.window?.makeKeyAndVisible()
        return true
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        self.rootViewController.sessionManager.application(app, open: url, options: options)
        return true
    }

    func applicationWillResignActive(_: UIApplication) {
        if self.rootViewController.appRemote.isConnected {
            self.rootViewController.appRemote.disconnect()
        }
    }

    func applicationDidBecomeActive(_: UIApplication) {
        if let _ = rootViewController.appRemote.connectionParameters.accessToken {
            self.rootViewController.appRemote.connect()
        }
    }
}
