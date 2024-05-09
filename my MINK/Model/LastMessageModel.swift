// Copyright © 2023 SOFTMENT. All rights reserved.

import UIKit

class LastMessageModel: NSObject, Codable {
    // MARK: Lifecycle

    override init() {}

    // MARK: Internal

    var senderUid: String?
    var isRead: Bool?
    var date: Date?
    var senderImage: String?
    var senderName: String?
    var senderToken: String?
    var message: String?
    var senderDeviceToken: String?
    var isBusiness : Bool?
}
