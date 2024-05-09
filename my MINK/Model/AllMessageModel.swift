// Copyright © 2023 SOFTMENT. All rights reserved.

import UIKit

class AllMessageModel: NSObject, Codable {
    // MARK: Lifecycle

    override init() {}

    // MARK: Internal

    var senderUid: String?
    var message: String?
    var messageID: String?
    var date: Date?
}
