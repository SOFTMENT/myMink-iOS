// Copyright © 2023 SOFTMENT. All rights reserved.

import UIKit

// MARK: - LiveStreamingModel

class LiveStreamingModel: NSObject, Codable {
    var uid: String?
    var fullName: String?
    var profilePic: String?
    var date: Date?
    var token: String?
    var isOnline: Bool?
    var agoraUID: Int?
    var count: Int?
    var likeCount: Int?
}
