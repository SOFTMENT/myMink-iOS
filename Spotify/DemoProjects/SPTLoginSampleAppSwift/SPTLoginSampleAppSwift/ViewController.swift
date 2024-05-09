// Copyright © 2023 SOFTMENT. All rights reserved.

import UIKit

class ViewController: UIViewController, SPTSessionManagerDelegate, SPTAppRemoteDelegate,
    SPTAppRemotePlayerStateDelegate
{
    private let SpotifyClientID = "<#ClientID#>"
    private let SpotifyRedirectURI = URL(string: "spotify-login-sdk-test-app://spotify-login-callback")!

    lazy var configuration: SPTConfiguration = {
        let configuration = SPTConfiguration(clientID: SpotifyClientID, redirectURL: SpotifyRedirectURI)
        // Set the playURI to a non-nil value so that Spotify plays music after authenticating and App Remote can
        // connect
        // otherwise another app switch will be required
        configuration.playURI = ""

        // Set these url's to your backend which contains the secret to exchange for an access token
        // You can use the provided ruby script spotify_token_swap.rb for testing purposes
        configuration.tokenSwapURL = URL(string: "http://localhost:1234/swap")
        configuration.tokenRefreshURL = URL(string: "http://localhost:1234/refresh")
        return configuration
    }()

    lazy var sessionManager: SPTSessionManager = {
        let manager = SPTSessionManager(configuration: configuration, delegate: self)
        return manager
    }()

    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.delegate = self
        return appRemote
    }()

    private var lastPlayerState: SPTAppRemotePlayerState?

    // MARK: - Subviews

    private lazy var connectLabel: UILabel = {
        let label = UILabel()
        label.text = "Connect your Spotify account"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var connectButton = ConnectButton(title: "CONNECT")
    private lazy var disconnectButton = ConnectButton(title: "DISCONNECT")

    private lazy var pauseAndPlayButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(self.didTapPauseOrPlay), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var trackLabel: UILabel = {
        let trackLabel = UILabel()
        trackLabel.translatesAutoresizingMaskIntoConstraints = false
        trackLabel.textAlignment = .center
        return trackLabel
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white

        view.addSubview(self.connectLabel)
        view.addSubview(self.connectButton)
        view.addSubview(self.disconnectButton)
        view.addSubview(self.imageView)
        view.addSubview(self.trackLabel)
        view.addSubview(self.pauseAndPlayButton)

        let constant: CGFloat = 16.0

        self.connectButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.connectButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        self.disconnectButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.disconnectButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true

        self.connectLabel.centerXAnchor.constraint(equalTo: self.connectButton.centerXAnchor).isActive = true
        self.connectLabel.bottomAnchor.constraint(equalTo: self.connectButton.topAnchor, constant: -constant)
            .isActive = true

        self.imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 64).isActive = true
        self.imageView.bottomAnchor.constraint(equalTo: self.trackLabel.topAnchor, constant: -constant).isActive = true

        self.trackLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.trackLabel.topAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: constant).isActive = true
        self.trackLabel.bottomAnchor.constraint(equalTo: self.connectLabel.topAnchor, constant: -constant)
            .isActive = true

        self.pauseAndPlayButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.pauseAndPlayButton.topAnchor.constraint(equalTo: self.trackLabel.bottomAnchor, constant: constant)
            .isActive = true
        self.pauseAndPlayButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        self.pauseAndPlayButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.pauseAndPlayButton.sizeToFit()

        self.connectButton.sizeToFit()
        self.disconnectButton.sizeToFit()

        self.connectButton.addTarget(self, action: #selector(self.didTapConnect(_:)), for: .touchUpInside)
        self.disconnectButton.addTarget(self, action: #selector(self.didTapDisconnect(_:)), for: .touchUpInside)

        self.updateViewBasedOnConnected()
    }

    func update(playerState: SPTAppRemotePlayerState) {
        if self.lastPlayerState?.track.uri != playerState.track.uri {
            self.fetchArtwork(for: playerState.track)
        }
        self.lastPlayerState = playerState
        self.trackLabel.text = playerState.track.name
        if playerState.isPaused {
            self.pauseAndPlayButton.setImage(UIImage(named: "play"), for: .normal)
        } else {
            self.pauseAndPlayButton.setImage(UIImage(named: "pause"), for: .normal)
        }
    }

    func updateViewBasedOnConnected() {
        if self.appRemote.isConnected {
            self.connectButton.isHidden = true
            self.disconnectButton.isHidden = false
            self.connectLabel.isHidden = true
            self.imageView.isHidden = false
            self.trackLabel.isHidden = false
            self.pauseAndPlayButton.isHidden = false
        } else {
            self.disconnectButton.isHidden = true
            self.connectButton.isHidden = false
            self.connectLabel.isHidden = false
            self.imageView.isHidden = true
            self.trackLabel.isHidden = true
            self.pauseAndPlayButton.isHidden = true
        }
    }

    func fetchArtwork(for track: SPTAppRemoteTrack) {
        self.appRemote.imageAPI?.fetchImage(forItem: track, with: CGSize.zero, callback: { [weak self] image, error in
            if let error = error {
                print("Error fetching track image: " + error.localizedDescription)
            } else if let image = image as? UIImage {
                self?.imageView.image = image
            }
        })
    }

    func fetchPlayerState() {
        self.appRemote.playerAPI?.getPlayerState { [weak self] playerState, error in
            if let error = error {
                print("Error getting player state:" + error.localizedDescription)
            } else if let playerState = playerState as? SPTAppRemotePlayerState {
                self?.update(playerState: playerState)
            }
        }
    }

    // MARK: - Actions

    @objc func didTapPauseOrPlay(_: UIButton) {
        if let lastPlayerState = lastPlayerState, lastPlayerState.isPaused {
            self.appRemote.playerAPI?.resume(nil)
        } else {
            self.appRemote.playerAPI?.pause(nil)
        }
    }

    @objc func didTapDisconnect(_: UIButton) {
        if self.appRemote.isConnected {
            self.appRemote.disconnect()
        }
    }

    @objc func didTapConnect(_: UIButton) {
        /*
         Scopes let you specify exactly what types of data your application wants to
         access, and the set of scopes you pass in your call determines what access
         permissions the user is asked to grant.
         For more information, see https://developer.spotify.com/web-api/using-scopes/.
         */
        let scope: SPTScope = [.appRemoteControl, .playlistReadPrivate]

        if #available(iOS 11, *) {
            // Use this on iOS 11 and above to take advantage of SFAuthenticationSession
            sessionManager.initiateSession(with: scope, options: .clientOnly)
        } else {
            // Use this on iOS versions < 11 to use SFSafariViewController
            self.sessionManager.initiateSession(with: scope, options: .clientOnly, presenting: self)
        }
    }

    // MARK: - SPTSessionManagerDelegate

    func sessionManager(manager _: SPTSessionManager, didFailWith error: Error) {
        self.presentAlertController(
            title: "Authorization Failed",
            message: error.localizedDescription,
            buttonTitle: "Bummer"
        )
    }

    func sessionManager(manager _: SPTSessionManager, didRenew session: SPTSession) {
        self.presentAlertController(title: "Session Renewed", message: session.description, buttonTitle: "Sweet")
    }

    func sessionManager(manager _: SPTSessionManager, didInitiate session: SPTSession) {
        self.appRemote.connectionParameters.accessToken = session.accessToken
        self.appRemote.connect()
    }

    // MARK: - SPTAppRemoteDelegate

    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        self.updateViewBasedOnConnected()
        appRemote.playerAPI?.delegate = self
        appRemote.playerAPI?.subscribe(toPlayerState: { _, error in
            if let error = error {
                print("Error subscribing to player state:" + error.localizedDescription)
            }
        })
        self.fetchPlayerState()
    }

    func appRemote(_: SPTAppRemote, didDisconnectWithError _: Error?) {
        self.updateViewBasedOnConnected()
        self.lastPlayerState = nil
    }

    func appRemote(_: SPTAppRemote, didFailConnectionAttemptWithError _: Error?) {
        self.updateViewBasedOnConnected()
        self.lastPlayerState = nil
    }

    // MARK: - SPTAppRemotePlayerAPIDelegate

    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        self.update(playerState: playerState)
    }

    // MARK: - Private Helpers

    private func presentAlertController(title: String, message: String, buttonTitle: String) {
        DispatchQueue.main.async {
            let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: buttonTitle, style: .default, handler: nil)
            controller.addAction(action)
            self.present(controller, animated: true)
        }
    }
}
