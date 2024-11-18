// Copyright © 2023 SOFTMENT. All rights reserved.

import UIKit
import AVFoundation
import SDWebImage

// MARK: - PostSearchResultsViewController

class PostSearchResultsViewController: UIViewController {

    var playerPool: PlayerPool!
    var activePlayers: [AVPlayer] = []
    @IBOutlet var no_results_found: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    var postModels = [PostModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        playerPool = PlayerPool(playerCount: 15, className: "search")
    }

    override func viewWillDisappear(_: Bool) {
        pauseAllPlayers()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playAllPlayers()
    }

    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = generateLayout()
    }

    private func generateLayout() -> UICollectionViewLayout {
        let pairMainPhotoSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(2/3), heightDimension: .fractionalHeight(1.0))
        let pairMainPhotoItem = NSCollectionLayoutItem(layoutSize: pairMainPhotoSize)
        pairMainPhotoItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

        let pairSmallPhotoSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1/2))
        let pairSmallPhotoItem = NSCollectionLayoutItem(layoutSize: pairSmallPhotoSize)
        pairSmallPhotoItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

        let stackedSmallPhotoGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1.0)), subitem: pairSmallPhotoItem, count: 2)

        let mainAndSmallPhotoGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1/3)), subitems: [stackedSmallPhotoGroup, pairMainPhotoItem])

        let smallPhotoSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let smallPhotoItem = NSCollectionLayoutItem(layoutSize: smallPhotoSize)
        smallPhotoItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

        let tripleSmallPhotoGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)), subitem: smallPhotoItem, count: 3)

        let stackedTripleSmallPhotoGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1/3)), subitem: tripleSmallPhotoGroup, count: 2)

        let reversedMainAndSmallPhotoGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1/3)), subitems: [pairMainPhotoItem, stackedSmallPhotoGroup])

        let allGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0 + 1/4)), subitems: [mainAndSmallPhotoGroup, stackedTripleSmallPhotoGroup, reversedMainAndSmallPhotoGroup])

        let section = NSCollectionLayoutSection(group: allGroup)
        return UICollectionViewCompositionalLayout(section: section)
    }

    func pauseAllPlayers() {
        activePlayers.forEach { $0.pause() }
    }

    func playAllPlayers() {
        activePlayers.forEach { $0.play() }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }

    public func notifyAdapter(postModels: [PostModel]) {
        self.postModels = postModels
        self.collectionView.reloadData()
    }

    @objc func postClicked(value: MyGesture) {
        performSegue(withIdentifier: "searchpostViewSeg", sender: value.index)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchpostViewSeg", let VC = segue.destination as? PostViewController, let position = sender as? Int {
            VC.postModels = self.postModels
            VC.position = position
        }
    }
}

// MARK: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension PostSearchResultsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let videoCell = cell as? CustomPostCollectionViewCell {
            videoCell.player?.play()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? CustomPostCollectionViewCell, let player = cell.player {
            player.pause()
        }
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        no_results_found.isHidden = !postModels.isEmpty
        return postModels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customPostCell", for: indexPath) as? CustomPostCollectionViewCell else {
            return CustomPostCollectionViewCell()
        }
        
        let postModel = postModels[indexPath.row]
        cell.image.layer.cornerRadius = 8
        let myGest = MyGesture(target: self, action: #selector(postClicked))
        myGest.index = indexPath.row
        cell.videoMainView.isUserInteractionEnabled = true
        cell.videoMainView.addGestureRecognizer(myGest)

        if postModel.postType == "image" {
            if let postImages = postModel.postImages, let sImage = postImages.first, !sImage.isEmpty {
                cell.image.setImage(imageKey: sImage, placeholder: "placeholder", width: 410, height: 410, shouldShowAnimationPlaceholder: true)
            }
        } else if postModel.postType == "video", let postImage = postModel.videoImage, !postImage.isEmpty, let path = postModel.postVideo {
            cell.image.setImage(imageKey: postImage, placeholder: "placeholder", width: 410, height: 410, shouldShowAnimationPlaceholder: true)
            if let player = playerPool.getPlayer() {
                activePlayers.append(player)
                cell.playerLayer?.removeFromSuperlayer()
                cell.playerLayer = nil
                cell.player = player
                cell.returnPlayerDelegate = self
                let videoURL = "\(Constants.awsVideoBaseURL)\(path)"
                if let url = URL(string: videoURL) {
                    if let videoData = SDImageCache.shared.diskImageData(forKey: url.absoluteString) {
                        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        let fileURL = documentsDirectoryURL.appendingPathComponent(url.lastPathComponent)
                        try? videoData.write(to: fileURL, options: .atomic)
                        let playerItem = CustomPlayerItem(url: fileURL, videoPostID: postModel.postID ?? "123")
                        player.replaceCurrentItem(with: playerItem)
                    } else {
                        downloadMP4File(from: url)
                        let playerItem = CustomPlayerItem(url: url, videoPostID: postModel.postID ?? "123")
                        player.replaceCurrentItem(with: playerItem)
                    }
                    playerPool.observePlayer(player)
                    let playerLayer = AVPlayerLayer(player: player)
                    playerLayer.videoGravity = .resizeAspectFill
                    cell.image.layer.addSublayer(playerLayer)
                    cell.playerLayer = playerLayer
                    player.isMuted = true
                    cell.image.layoutIfNeeded()
                }
            }
        }
        return cell
    }
}

extension PostSearchResultsViewController: ReturnPlayerDelegate {
    func returnPlayer(player: AVPlayer) {
        playerPool.returnPlayer(player)
        if let index = activePlayers.firstIndex(of: player) {
            activePlayers.remove(at: index)
        }
    }
}
