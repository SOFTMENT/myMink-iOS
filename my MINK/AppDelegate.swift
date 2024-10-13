// Copyright © 2023 SOFTMENT. All rights reserved.

import Amplify
import AVFAudio
import AWSAPIPlugin
import AWSCognitoAuthPlugin
import AWSDataStorePlugin
import AWSS3StoragePlugin
import Braintree
import BranchSDK
import FBSDKCoreKit
import Firebase
import FirebaseMessaging
import GooglePlaces
import GoogleSignIn
import IQKeyboardManagerSwift
import PushKit
import UIKit
import FirebaseFirestore
import RevenueCat

// MARK: - AppDelegate

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let badgeCountKey = "badgeCountKey"
    let gcmMessageIDKey = "gcm.message_id"
    var body = "message"
    var title = "Title"
  
    func sign(_: GIDSignIn!, didSignInFor _: GIDGoogleUser!, withError error: Error?) {
        if error != nil {
            return
        }
    }

    func sign(_: GIDSignIn!, didDisconnectWith _: GIDGoogleUser!, withError _: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Override point for customization after application launch.

        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        Purchases.configure(withAPIKey: "appl_dOBdJyUAdDOlfPQGlcSkWQRZPzD")
        
        Branch.setUseTestBranchKey(false)
        
        Branch.getInstance().initSession(launchOptions: launchOptions) { params, _ in

            if let data = params as? [String: AnyObject] {
                let isFirstSession = data["+is_first_session"] as? Bool ?? false
                let clickedBranchLink = data["+clicked_branch_link"] as? Bool ?? false
                
                if (isFirstSession || clickedBranchLink) && Constants.deeplinkData == nil {
                    Constants.deeplinkData = data
                    if FirebaseStoreManager.auth.currentUser != nil && UserModel.data != nil {
                        let main = UIStoryboard(name: StoryBoard.tabBar.rawValue, bundle: nil)
                        if let rootController = main
                            .instantiateViewController(
                                withIdentifier: Identifier.tabBarViewController
                                    .rawValue
                            ) as? TabbarViewController
                        {
                            Constants.selectedTabBarPosition = 0
                            UIApplication.shared.windows.first?.rootViewController = rootController
                            UIApplication.shared.windows.first?.makeKeyAndVisible()
                        }
                    }
                }
            }
        }

        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSAPIPlugin())
            try Amplify.add(plugin: AWSS3StoragePlugin())
            try Amplify.add(plugin: AWSDataStorePlugin(modelRegistration: AmplifyModels()))
            try Amplify.configure()
        } catch {
            print("An error occurred setting up Amplify: \(error)")
        }

        if #available(iOS 14.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self

            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { _, _ in }
            )
        } else {
            let settings: UIUserNotificationSettings =
                .init(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }

        GMSPlacesClient.provideAPIKey(ENV.GOOGLE_PLACES_API_KEY)

        application.registerForRemoteNotifications()

        Messaging.messaging().delegate = self
        Messaging.messaging().isAutoInitEnabled = true

        IQKeyboardManager.shared.enable = true
        FirebaseApp.configure()

        Auth.auth().addStateDidChangeListener { _, user in
            if user == nil {
                self.showLoginScreen()
            }
        }

        Auth.auth().currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            if error != nil {
                self.showLoginScreen()
                return
            }
        }

        BTAppContextSwitcher.setReturnURLScheme("in.softment.mymink.payment")
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Reset the badge number when the app becomes active
      

        if Auth.auth().currentUser == nil {
            self.showLoginScreen()
        }
    }

    func showLoginScreen() {
        Constants.selectedTabBarPosition = 0
        UserModel.clearUserData()
        try? Auth.auth().signOut()

        let main = UIStoryboard(name: StoryBoard.accountSetup.rawValue, bundle: nil)
        if let rootController = main
            .instantiateViewController(
                withIdentifier: Identifier.entryViewController
                    .rawValue
            ) as? EntryViewController
        {
            UIApplication.shared.windows.first?.rootViewController = rootController
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
    }

    func observeUserStatus(userId: String) {
        let db = Firestore.firestore()
        db.collection(Collections.users.rawValue).document(userId).addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else { return }
            guard let data = document.data() else { return }
            let isBlocked = data["isBlocked"] as? Bool ?? false
            UserModel.data?.isBlocked = isBlocked
            if isBlocked {
                self.showLoginScreen()
            }
        }
    }

    func voipRegistration() {
        if FirebaseStoreManager.auth.currentUser != nil, UserModel.data != nil {
            let mainQueue = DispatchQueue.main
            let voipRegistry = PKPushRegistry(queue: mainQueue)
            voipRegistry.delegate = self
            voipRegistry.desiredPushTypes = [PKPushType.voIP]
        }
    }

    func application(
        _: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options _: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_: UIApplication, didDiscardSceneSessions _: Set<UISceneSession>) {}

    func application(
        _: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler _: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        Branch.getInstance().continue(userActivity)
        return true
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        Branch.getInstance().application(app, open: url, options: options)
        if url.scheme?.localizedCaseInsensitiveCompare("in.softment.mymink.payment") == .orderedSame {
            return BTAppContextSwitcher.handleOpenURL(url)
        }
        return GIDSignIn.sharedInstance.handle(url)
    }
}

// MARK: MessagingDelegate

extension AppDelegate: MessagingDelegate {
    func messaging(_: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        let dataDict: [String: String] = ["token": fcmToken ?? "123"]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
}

// MARK: UNUserNotificationCenterDelegate

@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    /// Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(
        _: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
            -> Void
    ) {
        let userInfo = notification.request.content.userInfo
        // Increment badge number
        UIApplication.shared.applicationIconBadgeNumber += 1

        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID 1: \(messageID)")
        }

        // Change this to your preferred presentation option
        if #available(iOS 14.0, *) {
            completionHandler([.badge, .sound, .banner])
        } else {
            completionHandler([.alert, .sound])
        }

    }

    func userNotificationCenter(
        _: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        // Increment badge number
        UIApplication.shared.applicationIconBadgeNumber += 1

        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID 2: \(messageID)")
        }

        let aps = userInfo["aps"] as? NSDictionary
        if let aps = aps {
            let alert = aps["alert"] as! NSDictionary
            self.body = alert["body"] as! String
            self.title = alert["title"] as! String
        }

        completionHandler()
    }

    func application(_: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID 3: \(messageID)")
        }
        print(userInfo)
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        // Increment badge number for background notifications
        application.applicationIconBadgeNumber += 1

        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID 4: \(messageID)")
        }

        print(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
}

var ENV: APIKeyable {
    #if DEBUG
    return DebugENV()
    #else
    return ProdENV()
    #endif
}
