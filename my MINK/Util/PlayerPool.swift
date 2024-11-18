// Copyright © 2023 SOFTMENT. All rights reserved.

import AVFoundation
import Firebase
class PlayerPool {
    // MARK: Lifecycle

    let className : String?
    init(playerCount: Int, className: String?) {
        self.className = className
        self.loadPlayers(playerCount: playerCount)
       
    }

    // MARK: Internal

    var availablePlayers: [AVPlayer] = []

    func loadPlayers(playerCount: Int) {
        for _ in 0 ..< playerCount {
            let player = AVPlayer()
            self.availablePlayers.append(player)
        }
    }

    func getPlayer() -> AVPlayer? {
        let avplayer = self.availablePlayers.popLast()
        avplayer?.pause()
        return avplayer
        
    }

    func returnPlayer(_ player: AVPlayer?) {
        if let player = player {
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
            self.availablePlayers.append(player)
        }
    }

    func observePlayer(_ player: AVPlayer) {
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { [weak self] _ in
            self?.playerDidFinishPlaying(player: player)
        }
    }

    @objc private func playerDidFinishPlaying(player: AVPlayer) {
        if let playerItem = player.currentItem as? CustomPlayerItem {
            if className != "search" {
                self.increaseWatchCount(id: playerItem.videoPostID)
            }

            player.seek(to: CMTime.zero)
            player.play()
        }
    }

    func increaseWatchCount(id: String?) {
        
        guard let id = id else {
            return
        }

        FirebaseStoreManager.db.collection(Collections.posts.rawValue).document(id)
            .setData(["watchCount": FieldValue.increment(Int64(1))], merge: true)
    }
}
