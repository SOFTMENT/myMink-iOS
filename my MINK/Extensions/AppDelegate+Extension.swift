//
//  AppDelegate+Extension.swift
//  my MINK
//
//  Created by Vijay Rathore on 15/07/24.
//

import Foundation
import PushKit
import CallKit
import UIKit

extension AppDelegate: PKPushRegistryDelegate, CXProviderDelegate {
    func providerDidReset(_: CXProvider) {
        //
    }

    /// Handle updated push credentials
    func pushRegistry(_: PKPushRegistry, didUpdate credentials: PKPushCredentials, for _: PKPushType) {
        let deviceToken = credentials.token.map { String(format: "%02x", $0) }.joined()
        if let user = FirebaseStoreManager.auth.currentUser {
            FirebaseStoreManager.db.collection(Collections.users.rawValue).document(user.uid)
                .setData(["deviceToken": deviceToken], merge: true)
            
            self.getBusinessesBy(user.uid) { businessModel, error in
                if let businessModel = businessModel {
                    FirebaseStoreManager.db.collection(Collections.businesses.rawValue).document(businessModel.businessId ?? "123")
                        .setData(["deviceToken":deviceToken], merge: true)
                }
            }
        }
    }

    func pushRegistry(_: PKPushRegistry, didInvalidatePushTokenFor _: PKPushType) {
        print("pushRegistry:didInvalidatePushTokenForType:")
    }

    func pushRegistry(
        _: PKPushRegistry,
        didReceiveIncomingPushWith payload: PKPushPayload,
        for _: PKPushType,
        completion _: @escaping () -> Void
    ) {
        self.handlePushPayload(payload)
    }

    func handlePushPayload(_ payload: PKPushPayload) {
        if FirebaseStoreManager.auth.currentUser != nil {
            let myPayload = payload.dictionaryPayload

            if let hasCallEndedByLocal = myPayload["callEnd"] as? Bool, hasCallEndedByLocal {
                let callUUID = UUID(uuidString: myPayload["callUUID"] as! String)!
                let endCallAction = CXEndCallAction(call: callUUID)
                let transaction = CXTransaction(action: endCallAction)
                let callController = CXCallController()
                callController.request(transaction) { error in
                    if let error = error {
                        print("Error ending call: \(error)")
                    }
                }
            } else {
                Constants.token = myPayload["token"] as! String
                Constants.channelName = myPayload["channelName"] as! String
                Constants.callUUID = UUID(uuidString: myPayload["callUUID"] as! String)!
                CallManager.shared.reportIncomingCall(
                    id: Constants.callUUID,
                    channelName: myPayload["channelName"] as! String,
                    token: myPayload["token"] as! String,
                    handle: myPayload["messageFrom"] as! String,
                    appDeletegate: self
                )
            }
        }
    }

    
    func provider(_: CXProvider, perform action: CXAnswerCallAction) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let rootVC = UIStoryboard(name: StoryBoard.tabBar.rawValue, bundle: nil)
                .instantiateViewController(withIdentifier: "videoVC") as! VideoCallViewController

            rootVC.channelName = Constants.channelName
            rootVC.token = Constants.token
            let window = UIApplication
                .shared
                .connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }

            rootVC.view.frame = window!.bounds

            UIView.transition(with: window!, duration: 0.5, options: .transitionCrossDissolve, animations: {
                window!.rootViewController = rootVC
            }, completion: nil)
            action.fulfill()
        }
    }

    func provider(_: CXProvider, perform action: CXEndCallAction) {
        let callDeniedModel = CallDeniedModel()
        callDeniedModel.date = Date()
        callDeniedModel.callDenied = true

        try? FirebaseStoreManager.db.collection("CallDenied").document(action.callUUID.uuidString)
            .setData(from: callDeniedModel, merge: true)
        action.fulfill()
    }

    func provider(_: CXProvider, perform _: CXStartCallAction) {}
}
