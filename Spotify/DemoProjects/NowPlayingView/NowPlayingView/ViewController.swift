// Copyright © 2023 SOFTMENT. All rights reserved.

import StoreKit
import UIKit

class ViewController: UIViewController {
    // MARK: - IBOutlets

    @IBOutlet var trackNameLabel: UILabel!
    @IBOutlet var buttons: [UIButton]!

    @IBOutlet var skipBackward15Button: UIButton!
    @IBOutlet var prevButton: UIButton!
    @IBOutlet var playPauseButton: UIButton!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var skipForward15Button: UIButton!

    @IBOutlet var podcastSpeedButton: UIButton!
    @IBOutlet var playRadioButton: UIButton!

    @IBOutlet var playerStateSubscriptionButton: UIButton!
    @IBOutlet var onDemandCapabilitiesLabel: UILabel!
    @IBOutlet var capabilitiesSubscriptionButton: UIButton!

    @IBOutlet var shuffleModeLabel: UILabel!
    @IBOutlet var toggleShuffleButton: UIButton!
    @IBOutlet var repeatModeLabel: UILabel!
    @IBOutlet var toggleRepeatModeButton: UIButton!
    @IBOutlet var albumArtImageView: UIImageView!

    // MARK: - Variables

    private let playURI = "spotify:album:1htHMnxonxmyHdKE2uDFMR"
    private let trackIdentifier = "spotify:track:32ftxJzxMPgUFCM6Km9WTS"
    private let name = "Now Playing View"

    private var currentPodcastSpeed: SPTAppRemotePodcastPlaybackSpeed?
    private var connectionIndicatorView = ConnectionStatusIndicatorView()
    private var playerState: SPTAppRemotePlayerState?
    private var subscribedToPlayerState: Bool = false
    private var subscribedToCapabilities: Bool = false

    var defaultCallback: SPTAppRemoteCallback {
        return { [weak self] _, error in
            if let error = error {
                self?.displayError(error as NSError)
            }
        }
    }

    var appRemote: SPTAppRemote? {
        return (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.appRemote
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.connectionIndicatorView)
        self.connectionIndicatorView.frame = CGRect(origin: CGPoint(), size: CGSize(width: 20, height: 20))

        self.playPauseButton.setTitle("", for: UIControl.State.normal)
        self.playPauseButton.setImage(PlaybackButtonGraphics.playButtonImage(), for: UIControl.State.normal)
        self.playPauseButton.setImage(PlaybackButtonGraphics.playButtonImage(), for: UIControl.State.highlighted)

        self.nextButton.setTitle("", for: UIControl.State.normal)
        self.nextButton.setImage(PlaybackButtonGraphics.nextButtonImage(), for: UIControl.State.normal)
        self.nextButton.setImage(PlaybackButtonGraphics.nextButtonImage(), for: UIControl.State.highlighted)

        self.prevButton.setTitle("", for: UIControl.State.normal)
        self.prevButton.setImage(PlaybackButtonGraphics.previousButtonImage(), for: UIControl.State.normal)
        self.prevButton.setImage(PlaybackButtonGraphics.previousButtonImage(), for: UIControl.State.highlighted)

        self.skipBackward15Button.setImage(
            self.skipBackward15Button.imageView?.image?.withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        self.skipForward15Button.setImage(
            self.skipForward15Button.imageView?.image?.withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        self.skipBackward15Button.isHidden = true
        self.skipForward15Button.isHidden = true
    }

    // MARK: - View

    private func updateViewWithPlayerState(_ playerState: SPTAppRemotePlayerState) {
        self.updatePlayPauseButtonState(playerState.isPaused)
        self.updateRepeatModeLabel(playerState.playbackOptions.repeatMode)
        self.updateShuffleLabel(playerState.playbackOptions.isShuffling)
        self.trackNameLabel.text = playerState.track.name + " - " + playerState.track.artist.name
        self.fetchAlbumArtForTrack(playerState.track) { image in
            self.updateAlbumArtWithImage(image)
        }
        self.updateViewWithRestrictions(playerState.playbackRestrictions)
        self.updateInterfaceForPodcast(playerState: playerState)
    }

    private func updateViewWithRestrictions(_ restrictions: SPTAppRemotePlaybackRestrictions) {
        self.nextButton.isEnabled = restrictions.canSkipNext
        self.prevButton.isEnabled = restrictions.canSkipPrevious
        self.toggleShuffleButton.isEnabled = restrictions.canToggleShuffle
        self.toggleRepeatModeButton.isEnabled = restrictions.canRepeatContext || restrictions.canRepeatTrack
    }

    private func enableInterface(_ enabled: Bool = true) {
        self.buttons.forEach { button in
            button.isEnabled = enabled
        }

        if !enabled {
            self.albumArtImageView.image = nil
            self.updatePlayPauseButtonState(true)
        }
    }

    // MARK: Podcast Support

    private func updateInterfaceForPodcast(playerState: SPTAppRemotePlayerState) {
        self.skipForward15Button.isHidden = !playerState.track.isEpisode
        self.skipBackward15Button.isHidden = !playerState.track.isEpisode
        self.podcastSpeedButton.isHidden = !playerState.track.isPodcast
        self.nextButton.isHidden = !self.skipForward15Button.isHidden
        self.prevButton.isHidden = !self.skipBackward15Button.isHidden
        self.getCurrentPodcastSpeed()
    }

    private func updatePodcastSpeed(speed: SPTAppRemotePodcastPlaybackSpeed) {
        self.currentPodcastSpeed = speed
        self.podcastSpeedButton.setTitle(String(format: "%0.1fx", speed.value.floatValue), for: .normal)
    }

    // MARK: Player State

    private func updatePlayPauseButtonState(_ paused: Bool) {
        let playPauseButtonImage = paused ? PlaybackButtonGraphics.playButtonImage() : PlaybackButtonGraphics
            .pauseButtonImage()
        self.playPauseButton.setImage(playPauseButtonImage, for: UIControl.State())
        self.playPauseButton.setImage(playPauseButtonImage, for: .highlighted)
    }

    private func updatePlayerStateSubscriptionButtonState() {
        let playerStateSubscriptionButtonTitle = self.subscribedToPlayerState ? "Unsubscribe" : "Subscribe"
        self.playerStateSubscriptionButton.setTitle(playerStateSubscriptionButtonTitle, for: UIControl.State())
    }

    // MARK: Capabilities

    private func updateViewWithCapabilities(_ capabilities: SPTAppRemoteUserCapabilities) {
        self.onDemandCapabilitiesLabel.text = "Can play on demand: " + (capabilities.canPlayOnDemand ? "Yes" : "No")
    }

    private func updateCapabilitiesSubscriptionButtonState() {
        let capabilitiesSubscriptionButtonTitle = self.subscribedToCapabilities ? "Unsubscribe" : "Subscribe"
        self.capabilitiesSubscriptionButton.setTitle(capabilitiesSubscriptionButtonTitle, for: UIControl.State())
    }

    // MARK: Shuffle

    private func updateShuffleLabel(_ isShuffling: Bool) {
        self.shuffleModeLabel.text = "Shuffle mode: " + (isShuffling ? "On" : "Off")
    }

    // MARK: Repeat Mode

    private func updateRepeatModeLabel(_ repeatMode: SPTAppRemotePlaybackOptionsRepeatMode) {
        self.repeatModeLabel.text = "Repeat mode: " + {
            switch repeatMode {
            case .off: return "Off"
            case .track: return "Track"
            case .context: return "Context"
            default: return "Off"
            }
        }()
    }

    // MARK: Album Art

    private func updateAlbumArtWithImage(_ image: UIImage) {
        self.albumArtImageView.image = image
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.fade
        self.albumArtImageView.layer.add(transition, forKey: "transition")
    }

    // MARK: - Player actions

    private func seekForward15Seconds() {
        self.appRemote?.playerAPI?.seekForward15Seconds(self.defaultCallback)
    }

    private func seekBackward15Seconds() {
        self.appRemote?.playerAPI?.seekBackward15Seconds(self.defaultCallback)
    }

    private func pickPodcastSpeed() {
        self.appRemote?.playerAPI?.getAvailablePodcastPlaybackSpeeds { speeds, error in
            if error == nil, let speeds = speeds as? [SPTAppRemotePodcastPlaybackSpeed],
               let current = self.currentPodcastSpeed
            {
                let vc = SpeedPickerViewController(podcastSpeeds: speeds, selectedSpeed: current)
                vc.delegate = self
                let nav = UINavigationController(rootViewController: vc)
                self.present(nav, animated: true, completion: nil)
            }
        }
    }

    private func skipNext() {
        self.appRemote?.playerAPI?.skip(toNext: self.defaultCallback)
    }

    private func skipPrevious() {
        self.appRemote?.playerAPI?.skip(toPrevious: self.defaultCallback)
    }

    private func startPlayback() {
        self.appRemote?.playerAPI?.resume(self.defaultCallback)
    }

    private func pausePlayback() {
        self.appRemote?.playerAPI?.pause(self.defaultCallback)
    }

    private func playTrack() {
        self.appRemote?.playerAPI?.play(self.trackIdentifier, callback: self.defaultCallback)
    }

    private func enqueueTrack() {
        self.appRemote?.playerAPI?.enqueueTrackUri(self.trackIdentifier, callback: self.defaultCallback)
    }

    private func toggleShuffle() {
        guard let playerState = playerState else { return }
        self.appRemote?.playerAPI?.setShuffle(!playerState.playbackOptions.isShuffling, callback: self.defaultCallback)
    }

    private func getPlayerState() {
        self.appRemote?.playerAPI?.getPlayerState { result, error in
            guard error == nil else { return }

            let playerState = result as! SPTAppRemotePlayerState
            self.updateViewWithPlayerState(playerState)
        }
    }

    private func getCurrentPodcastSpeed() {
        self.appRemote?.playerAPI?.getCurrentPodcastPlaybackSpeed { speed, error in
            guard error == nil, let speed = speed as? SPTAppRemotePodcastPlaybackSpeed else { return }
            self.updatePodcastSpeed(speed: speed)
        }
    }

    private func playTrackWithIdentifier(_ identifier: String) {
        self.appRemote?.playerAPI?.play(identifier, callback: self.defaultCallback)
    }

    private func subscribeToPlayerState() {
        guard !self.subscribedToPlayerState else { return }
        self.appRemote?.playerAPI!.delegate = self
        self.appRemote?.playerAPI?.subscribe { _, error in
            guard error == nil else { return }
            self.subscribedToPlayerState = true
            self.updatePlayerStateSubscriptionButtonState()
        }
    }

    private func unsubscribeFromPlayerState() {
        guard self.subscribedToPlayerState else { return }
        self.appRemote?.playerAPI?.unsubscribe { _, error in
            guard error == nil else { return }
            self.subscribedToPlayerState = false
            self.updatePlayerStateSubscriptionButtonState()
        }
    }

    private func toggleRepeatMode() {
        guard let playerState = playerState else { return }
        let repeatMode: SPTAppRemotePlaybackOptionsRepeatMode = {
            switch playerState.playbackOptions.repeatMode {
            case .off: return .track
            case .track: return .context
            case .context: return .off
            default: return .off
            }
        }()

        self.appRemote?.playerAPI?.setRepeatMode(repeatMode, callback: self.defaultCallback)
    }

    // MARK: - Image API

    private func fetchAlbumArtForTrack(_ track: SPTAppRemoteTrack, callback: @escaping (UIImage) -> Void) {
        self.appRemote?.imageAPI?.fetchImage(
            forItem: track,
            with: CGSize(width: 1000, height: 1000),
            callback: { image, error in
                guard error == nil else { return }

                let image = image as! UIImage
                callback(image)
            }
        )
    }

    // MARK: - User API

    private func fetchUserCapabilities() {
        self.appRemote?.userAPI?.fetchCapabilities(callback: { capabilities, error in
            guard error == nil else { return }

            let capabilities = capabilities as! SPTAppRemoteUserCapabilities
            self.updateViewWithCapabilities(capabilities)
        })
    }

    private func subscribeToCapabilityChanges() {
        guard !self.subscribedToCapabilities else { return }
        self.appRemote?.userAPI?.delegate = self
        self.appRemote?.userAPI?.subscribe(toCapabilityChanges: { _, error in
            guard error == nil else { return }

            self.subscribedToCapabilities = true
            self.updateCapabilitiesSubscriptionButtonState()
        })
    }

    private func unsubscribeFromCapabilityChanges() {
        guard self.subscribedToCapabilities else { return }
        self.appRemote?.userAPI?.unsubscribe(toCapabilityChanges: { _, error in
            guard error == nil else { return }

            self.subscribedToCapabilities = false
            self.updateCapabilitiesSubscriptionButtonState()
        })
    }

    // MARK: - AppRemote

    func appRemoteConnecting() {
        self.connectionIndicatorView.state = .connecting
    }

    func appRemoteConnected() {
        self.connectionIndicatorView.state = .connected
        self.subscribeToPlayerState()
        self.subscribeToCapabilityChanges()
        self.getPlayerState()

        self.enableInterface(true)
    }

    func appRemoteDisconnect() {
        self.connectionIndicatorView.state = .disconnected
        self.subscribedToPlayerState = false
        self.subscribedToCapabilities = false
        self.enableInterface(false)
    }

    // MARK: - Error & Alert

    func showError(_ errorDescription: String) {
        let alert = UIAlertController(
            title: "Error!",
            message: errorDescription,
            preferredStyle: UIAlertController.Style.alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    private func displayError(_ error: NSError?) {
        if let error = error {
            self.presentAlert(title: "Error", message: error.description)
        }
    }

    private func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - IBActions

    @IBAction func didPressPlayPauseButton(_: AnyObject) {
        if self.appRemote?.isConnected == false {
            if self.appRemote?.authorizeAndPlayURI(self.playURI) == false {
                // The Spotify app is not installed, present the user with an App Store page
                showAppStoreInstall()
            }
        } else if self.playerState == nil || self.playerState!.isPaused {
            self.startPlayback()
        } else {
            self.pausePlayback()
        }
    }

    @IBAction func didPressPreviousButton(_: AnyObject) {
        self.skipPrevious()
    }

    @IBAction func didPressNextButton(_: AnyObject) {
        self.skipNext()
    }

    @IBAction func didPressPlayTrackButton(_: AnyObject) {
        self.playTrack()
    }

    @IBAction func didPressSkipForward15Button(_: UIButton) {
        self.seekForward15Seconds()
    }

    @IBAction func didPressSkipBackward15Button(_: UIButton) {
        self.seekBackward15Seconds()
    }

    @IBAction func didPressChangePodcastPlaybackSpeedButton(_: UIButton) {
        self.pickPodcastSpeed()
    }

    @IBAction func didPressEnqueueTrackButton(_: AnyObject) {
        self.enqueueTrack()
    }

    @IBAction func didPressGetPlayerStateButton(_: AnyObject) {
        self.getPlayerState()
    }

    @IBAction func didPressPlayerStateSubscriptionButton(_: AnyObject) {
        if self.subscribedToPlayerState {
            self.unsubscribeFromPlayerState()
        } else {
            self.subscribeToPlayerState()
        }
    }

    @IBAction func didPressGetCapabilitiesButton(_: AnyObject) {
        self.fetchUserCapabilities()
    }

    @IBAction func didPressCapabilitiesSubscriptionButton(_: AnyObject) {
        if self.subscribedToCapabilities {
            self.unsubscribeFromCapabilityChanges()
        } else {
            self.subscribeToCapabilityChanges()
        }
    }

    @IBAction func didPressToggleShuffleButton(_: AnyObject) {
        self.toggleShuffle()
    }

    @IBAction func didPressToggleRepeatModeButton(_: AnyObject) {
        self.toggleRepeatMode()
    }

    @IBAction func playRadioTapped(_: Any) {
        if self.appRemote?.isConnected == false && self.appRemote?.playerAPI != nil {
            if self.appRemote?.authorizeAndPlayURI(self.trackIdentifier, asRadio: true) == false {
                // The Spotify app is not installed, present the user with an App Store page
                showAppStoreInstall()
            }
        } else {
            var trackUri = self.trackIdentifier
            self.appRemote?.playerAPI?.getPlayerState { result, _ in
                if let currentTrack = (result as? SPTAppRemotePlayerState)?.track.uri {
                    trackUri = currentTrack
                }

                self.appRemote?.playerAPI?.play(trackUri, asRadio: true, callback: self.defaultCallback)
            }
        }
    }
}

// MARK: - SpeedPickerViewControllerDelegate

extension ViewController: SpeedPickerViewControllerDelegate {
    func speedPickerDidCancel(viewController: SpeedPickerViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }

    func speedPicker(viewController: SpeedPickerViewController, didChoose speed: SPTAppRemotePodcastPlaybackSpeed) {
        self.appRemote?.playerAPI?.setPodcastPlaybackSpeed(speed, callback: { _, error in
            guard error == nil else {
                return
            }
            self.updatePodcastSpeed(speed: speed)
        })
        viewController.dismiss(animated: true, completion: nil)
    }
}

// MARK: - SPTAppRemotePlayerStateDelegate

extension ViewController: SPTAppRemotePlayerStateDelegate {
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        self.playerState = playerState
        self.updateViewWithPlayerState(playerState)
    }
}

// MARK: - SPTAppRemoteUserAPIDelegate

extension ViewController: SPTAppRemoteUserAPIDelegate {
    func userAPI(_: SPTAppRemoteUserAPI, didReceive capabilities: SPTAppRemoteUserCapabilities) {
        self.updateViewWithCapabilities(capabilities)
    }
}

// MARK: SKStoreProductViewControllerDelegate

extension ViewController: SKStoreProductViewControllerDelegate {
    private func showAppStoreInstall() {
        if TARGET_OS_SIMULATOR != 0 {
            self.presentAlert(
                title: "Simulator In Use",
                message: "The App Store is not available in the iOS simulator, please test this feature on a physical device."
            )
        } else {
            let loadingView = UIActivityIndicatorView(frame: view.bounds)
            view.addSubview(loadingView)
            loadingView.startAnimating()
            loadingView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
            let storeProductViewController = SKStoreProductViewController()
            storeProductViewController.delegate = self
            storeProductViewController.loadProduct(
                withParameters: [
                    SKStoreProductParameterITunesItemIdentifier: SPTAppRemote
                        .spotifyItunesItemIdentifier()
                ],
                completionBlock: { _, error in
                    loadingView.removeFromSuperview()
                    if let error = error {
                        self.presentAlert(
                            title: "Error accessing App Store",
                            message: error.localizedDescription
                        )
                    } else {
                        self.present(storeProductViewController, animated: true, completion: nil)
                    }
                }
            )
        }
    }

    public func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}
