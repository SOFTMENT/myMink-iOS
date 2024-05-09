// Copyright © 2023 SOFTMENT. All rights reserved.

import AVFoundation

class CustomPlayerItem: AVPlayerItem {
    var videoPostID: String?

    // Initialize with additional videoPostID parameter
    init(url: URL, videoPostID: String) {
        self.videoPostID = videoPostID
        super.init(asset: AVAsset(url: url), automaticallyLoadedAssetKeys: nil)
    }
}
