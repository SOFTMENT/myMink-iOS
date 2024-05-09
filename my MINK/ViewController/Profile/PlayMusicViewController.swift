// Copyright © 2023 SOFTMENT. All rights reserved.

import Firebase
import FirebaseFirestoreSwift
import UIKit
import AVFoundation

class PlayMusicViewController: UIViewController {
   
    @IBOutlet var backView: UIView!

    @IBOutlet var musicImage: UIImageView!

    @IBOutlet var musicName: UILabel!

    @IBOutlet var endTime: UILabel!
    @IBOutlet var startTime: UILabel!

    @IBOutlet var progressbar: UISlider!

    @IBOutlet var artist: UILabel!

    @IBOutlet var previous: UIImageView!
    @IBOutlet var playPause: UIImageView!

    @IBOutlet var nextBtn: UIImageView!

    var items: [Result]?
    var position: Int = 0
    var isPlaying = true
    var playbackTimer: Timer?
    var x = 0
    var player: AVPlayer?
    var currentPlayingItem: AVPlayerItem?
    var currentPlayingURL: String?
    override func viewDidLoad() {
        guard self.items != nil else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        self.musicImage.layer.cornerRadius = 8
        self.backView.layer.cornerRadius = 8
        self.backView.dropShadow()
        self.backView.isUserInteractionEnabled = true
        self.backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backBtnClicked)))

        self.playPause.isUserInteractionEnabled = true
        self.playPause.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.playPauseBtnClicked)
        ))

        self.loadUI(position: self.position)

        self.nextBtn.isUserInteractionEnabled = true
        self.nextBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.nextBtnClicked)))

        self.previous.isUserInteractionEnabled = true
        self.previous.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.previousBtnClicked)
        ))
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error {
            print("Audio session error: \(error.localizedDescription)")
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        self.isPlaying = true
        self.playPause.image = UIImage(systemName: "pause.circle.fill")
        playTrack(result: self.items![position])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.isPlaying = false
        self.playPause.image = UIImage(systemName: "play.circle.fill")
        pauseTrack()
        
    }
    
    @objc func playPauseBtnClicked() {
        if self.isPlaying {
            self.isPlaying = false
            self.playPause.image = UIImage(systemName: "play.circle.fill")

            self.pauseTrack()
        } else {
            self.isPlaying = true
            self.playPause.image = UIImage(systemName: "pause.circle.fill")
            self.playTrack(result: items![self.position])
        }
    }

    func playTrack(result: Result) {
        guard let urlString = result.downloadURL?[3].link else {
            print("Invalid URL or downloadURL array")
            return
        }

        // Check if the new song is the same as the currently playing song
        if currentPlayingURL != urlString {
            // It's a new song, update the currentPlayingURL and player
            currentPlayingURL = urlString
            if let url = URL(string: urlString) {
                let playerItem = AVPlayerItem(url: url)
                player = AVPlayer(playerItem: playerItem)
            }
        }

        // Play or resume the track
        player?.play()
    }

    
    @IBAction func progresBarValueChange(_ sender: UISlider) {
        
        self.x  = Int(sender.value * Float(Int(self.items![position].duration!)!))
        let targetTime = CMTime(seconds: Double(self.x), preferredTimescale: 1)

            player?.seek(to: targetTime, completionHandler: { finished in
                if finished {
                    // The seek operation has completed
                    print("Player is now at 30 seconds")
                }
            })
    }
    
    

    func pauseTrack() {
        player?.pause() // To pause the song
    }

    @objc func backBtnClicked() {
        self.dismiss(animated: true)
    }

    @objc func nextBtnClicked() {
        if self.position >= 49 {
            position = -1
        }
        self.position = self.position + 1
        self.loadUI(position: self.position)
        self.playTrack(result: self.items![position])
    }

    @objc func previousBtnClicked() {
        if self.position > 0 {
            self.position = self.position - 1
            self.loadUI(position: self.position)
            self.playTrack(result: self.items![position])
        }
    }

    func loadUI(position: Int) {
        self.isPlaying = true

        self.x = 0

        let item = self.items![position]
        
        self.playbackTimer?.invalidate()
        self.playbackTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.updatePlaybackPosition(totalTrackDuration: Int(item.duration ?? "0")!)
        }
        self.playPause.image = UIImage(systemName: "pause.circle.fill")
        if let images = item.image {
            self.musicImage.sd_setImage(with: URL(string: images[2].link!), placeholderImage: UIImage(named: "placeholder"))
        }

        self.musicName.text = item.name!
        self.artist.text = item.primaryArtists!

        self.startTime.text = "0:0"
        self.progressbar.value = 0
        self.progressbar.maximumValue = 1
        self.endTime.text = convertSecondstoMinAndSec(totalSeconds:  Int(item.duration ?? "0")!)
    }

    func updatePlaybackPosition(totalTrackDuration: Int) {
        if self.isPlaying {
            DispatchQueue.main.async {
                self.x = self.x + 1
                if self.x >= totalTrackDuration {
                    self.playbackTimer?.invalidate()
                    if self.position >= 49 {
                        self.position = -1
                    }
                    self.loadUI(position: self.position + 1)
                    self.playTrack(result: self.items![self.position])
                } else {
                    self.startTime.text = self.convertSecondstoMinAndSec(totalSeconds: self.x)
                    self.progressbar.value = Float(self.x) / Float(totalTrackDuration)
                }
            }
        }
      
    }
}
