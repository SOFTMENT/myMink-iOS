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
        super.viewDidLoad()
        
        guard let _ = items else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        setupUI()
        setupActions()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error {
            print("Audio session error: \(error.localizedDescription)")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isPlaying = true
        playPause.image = UIImage(systemName: "pause.circle.fill")
        playTrack(result: items?[position])
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isPlaying = false
        playPause.image = UIImage(systemName: "play.circle.fill")
        pauseTrack()
    }

    private func setupUI() {
        musicImage.layer.cornerRadius = 8
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        loadUI(position: position)
    }

    private func setupActions() {
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))

        playPause.isUserInteractionEnabled = true
        playPause.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(playPauseBtnClicked)
        ))

        nextBtn.isUserInteractionEnabled = true
        nextBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(nextBtnClicked)))

        previous.isUserInteractionEnabled = true
        previous.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(previousBtnClicked)
        ))
    }

    @objc func playPauseBtnClicked() {
        if isPlaying {
            isPlaying = false
            playPause.image = UIImage(systemName: "play.circle.fill")
            pauseTrack()
        } else {
            isPlaying = true
            playPause.image = UIImage(systemName: "pause.circle.fill")
            playTrack(result: items?[position])
        }
    }

    func playTrack(result: Result?) {
        guard let urlString = result?.downloadURL?[3].link, currentPlayingURL != urlString else {
            print("Invalid URL or downloadURL array")
            return
        }

        currentPlayingURL = urlString
        if let url = URL(string: urlString) {
            let playerItem = AVPlayerItem(url: url)
            player = AVPlayer(playerItem: playerItem)
        }

        player?.play()
    }

    @IBAction func progressBarValueChanged(_ sender: UISlider) {
        guard let duration = items?[position].duration, let durationInt = Int(duration) else {
            return
        }

        x = Int(sender.value * Float(durationInt))
        let targetTime = CMTime(seconds: Double(x), preferredTimescale: 1)

        player?.seek(to: targetTime, completionHandler: { finished in
            if finished {
                print("Player is now at \(self.x) seconds")
            }
        })
    }

    func pauseTrack() {
        player?.pause()
    }

    @objc func backBtnClicked() {
        dismiss(animated: true)
    }

    @objc func nextBtnClicked() {
        position = (position >= 49) ? -1 : position + 1
        loadUI(position: position)
        playTrack(result: items?[position])
    }

    @objc func previousBtnClicked() {
        if position > 0 {
            position -= 1
            loadUI(position: position)
            playTrack(result: items?[position])
        }
    }

    func loadUI(position: Int) {
        isPlaying = true
        x = 0
        guard let item = items?[position] else { return }

        playbackTimer?.invalidate()
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.updatePlaybackPosition(totalTrackDuration: Int(item.duration ?? "0") ?? 0)
        }
        playPause.image = UIImage(systemName: "pause.circle.fill")
        if let images = item.image, images.count > 2 {
            musicImage.sd_setImage(with: URL(string: images[2].link ?? ""), placeholderImage: UIImage(named: "placeholder"))
        }
        musicName.text = item.name
        artist.text = item.primaryArtists
        startTime.text = "0:0"
        progressbar.value = 0
        progressbar.maximumValue = 1
        endTime.text = convertSecondsToMinAndSec(totalSeconds: Int(item.duration ?? "0") ?? 0)
    }

    func updatePlaybackPosition(totalTrackDuration: Int) {
        if isPlaying {
            DispatchQueue.main.async {
                self.x += 1
                if self.x >= totalTrackDuration {
                    self.playbackTimer?.invalidate()
                    self.position = (self.position >= 49) ? -1 : self.position + 1
                    self.loadUI(position: self.position)
                    self.playTrack(result: self.items?[self.position])
                } else {
                    self.startTime.text = self.convertSecondsToMinAndSec(totalSeconds: self.x)
                    self.progressbar.value = Float(self.x) / Float(totalTrackDuration)
                }
            }
        }
    }

    func convertSecondsToMinAndSec(totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
