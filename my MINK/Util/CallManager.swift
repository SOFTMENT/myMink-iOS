// Copyright © 2023 SOFTMENT. All rights reserved.

import CallKit
import Foundation
import UIKit

final class CallManager: NSObject, CXProviderDelegate {
    // MARK: Lifecycle

    private override init() {
        super.init()
        self.config.iconTemplateImageData = UIImage(named: "logo")!.pngData()
        self.config.includesCallsInRecents = false
        self.config.supportsVideo = true
    }

    // MARK: Internal

    static let shared = CallManager()

    let config = CXProviderConfiguration()
    let callController = CXCallController()

    func reportIncomingCall(
        id: UUID,
        channelName _: String,
        token _: String,
        handle: String,
        appDeletegate: AppDelegate
    ) {
        print("Reporting Call")

        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: handle)
        update.hasVideo = true
        let provider = CXProvider(configuration: config)
        provider.setDelegate(appDeletegate.self, queue: nil)
        provider.reportNewIncomingCall(with: id, update: update) { error in
            if let error = error {
                print(String(describing: error))
            } else {
                print("Call Reported")
            }
        }
    }

    func startCall(id: UUID, handle: String) {
        print("Starting Call")
        let handle = CXHandle(type: .generic, value: handle)
        let action = CXStartCallAction(call: id, handle: handle)
        let transaction = CXTransaction(action: action)
        self.callController.request(transaction) { error in
            if let error = error {
                print(String(describing: error))
            } else {
                print("Call Started")
            }
        }
    }

    func providerDidReset(_: CXProvider) {}
}
