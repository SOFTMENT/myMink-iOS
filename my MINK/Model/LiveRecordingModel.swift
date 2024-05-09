// Copyright © 2023 SOFTMENT. All rights reserved.

import UIKit

class LiveRecordingModel: NSObject, Codable {
    var time: Date?
    var thumbnail: String?
    var video: String?
    var channelName: String?
    var ratio: CGFloat?
    var sId: String?
}
