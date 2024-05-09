// Copyright © 2023 SOFTMENT. All rights reserved.

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate,
    SPTAppRemoteDelegate
{
    private static let kAccessTokenKey = "access-token-key"
    private let redirectUri = URL(string: "comspotifytestsdk://")!
    private let clientIdentifier = "<#ClientID#>"

    var window: UIWindow?

    lazy var appRemote: SPTAppRemote = {
        let configuration = SPTConfiguration(clientID: self.clientIdentifier, redirectURL: self.redirectUri)
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.connectionParameters.accessToken = self.accessToken
        appRemote.delegate = self
        return appRemote
    }()

    var accessToken = UserDefaults.standard.string(forKey: kAccessTokenKey) {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(self.accessToken, forKey: SceneDelegate.kAccessTokenKey)
        }
    }

    func scene(_: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }

        let parameters = self.appRemote.authorizationParameters(from: url)

        if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
            self.appRemote.connectionParameters.accessToken = access_token
            self.accessToken = access_token
        } else if let errorDescription = parameters?[SPTAppRemoteErrorDescriptionKey] {
            self.playerViewController.showError(errorDescription)
        }
    }

    func sceneDidBecomeActive(_: UIScene) {
        self.connect()
    }

    func sceneWillResignActive(_: UIScene) {
        self.playerViewController.appRemoteDisconnect()
        self.appRemote.disconnect()
    }

    func connect() {
        self.playerViewController.appRemoteConnecting()
        self.appRemote.connect()
    }

    // MARK: AppRemoteDelegate

    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        self.appRemote = appRemote
        self.playerViewController.appRemoteConnected()
    }

    func appRemote(_: SPTAppRemote, didFailConnectionAttemptWithError _: Error?) {
        print("didFailConnectionAttemptWithError")
        self.playerViewController.appRemoteDisconnect()
    }

    func appRemote(_: SPTAppRemote, didDisconnectWithError _: Error?) {
        print("didDisconnectWithError")
        self.playerViewController.appRemoteDisconnect()
    }

    var playerViewController: ViewController {
        let navController = self.window?.rootViewController?.children[0] as! UINavigationController
        return navController.topViewController as! ViewController
    }
}
