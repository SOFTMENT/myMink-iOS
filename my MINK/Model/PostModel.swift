// Copyright © 2023 SOFTMENT. All rights reserved.

import AVFoundation
import UIKit

class PostModel: NSObject, Codable {
  
    var postID: String?
    var postCreateDate: Date?
    var postType: String?
    var postImages: [String]?
    var postImagesOrientations: [CGFloat]?
    var postVideo: String?
    var postVideoRatio: CGFloat?
    var videoImage: String?
    var caption: String?
    var likes: Int?
    var comment: Int?
    var shares: Int?
    var uid: String?
    var bid : String?
    var notificationToken: String?
    var userModel: UserModel?
    var businessModel: BusinessModel?
    var isLiveStream: Bool?
    var watchCount: Int?
    var isActive : Bool?
    var shareURL: String?
    var isPromoted : Bool?
    
}
