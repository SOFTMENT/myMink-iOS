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
        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        self.playerPool = PlayerPool(playerCount: 15)
        collectionView.collectionViewLayout = generateLayout()
        
    }
    
    override func viewWillDisappear(_: Bool) {
        self.pauseAllPlayers()
    }
    
    func pauseAllPlayers() {
        for player in self.activePlayers {
            player.pause()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.playAllPlayers()
    }
    func playAllPlayers() {
        for player in self.activePlayers {
            player.play()
        }
    }
    
    private func generateLayout() -> UICollectionViewLayout {
        
        
        // Big photos
        let pairMainPhotoSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(2/3),
            heightDimension: .fractionalHeight(1.0))
        let pairMainPhotoItem = NSCollectionLayoutItem(layoutSize: pairMainPhotoSize)
        pairMainPhotoItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        let pairSmallPhotoSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1/2))
        let pairSmallPhotoItem = NSCollectionLayoutItem(layoutSize: pairSmallPhotoSize)
        pairSmallPhotoItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        let stackedSmallPhotoGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1.0)), subitem: pairSmallPhotoItem, count: 2)
        
        
        let mainAndSmallPhotoGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1/3)), subitems: [stackedSmallPhotoGroup, pairMainPhotoItem])
        
        
        
        
        let smallPhotoSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let smallPhotoItem = NSCollectionLayoutItem(layoutSize: smallPhotoSize)
        smallPhotoItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        let tripleSmallPhotoGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)), subitem: smallPhotoItem, count: 3)
        
        let stackedTripleSmallPhotoGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1/3)), subitem: tripleSmallPhotoGroup, count: 2)
        
        
        
        let reversedMainAndSmallPhotoGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1/3)), subitems: [ pairMainPhotoItem, stackedSmallPhotoGroup])
        
        
        let allGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0 + 1/4)),
            subitems: [
                mainAndSmallPhotoGroup,
                stackedTripleSmallPhotoGroup,
                reversedMainAndSmallPhotoGroup
            ])
        let section = NSCollectionLayoutSection(group: allGroup)
        return UICollectionViewCompositionalLayout(section: section)
    }
}

// MARK: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension PostSearchResultsViewController: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
           // Assuming your cell knows how to handle its players
           guard let videoCell = cell as? CustomPostCollectionViewCell else { return }
           videoCell.player?.play() // Ensure this function manages playing all videos within the cell
       }
    

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? CustomPostCollectionViewCell, let player = cell.player {
            player.pause()
        }
    }
    
    public func notifyAdapter(postModels: [PostModel]) {
        self.postModels.removeAll()
        self.postModels.append(contentsOf: postModels)

        self.collectionView.reloadData()
    }

    @objc func postClicked(value: MyGesture) {
        performSegue(withIdentifier: "searchpostViewSeg", sender: value.index)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchpostViewSeg" {
            if let VC = segue.destination as? PostViewController {
                if let position = sender as? Int {
                    VC.postModels = self.postModels
                    VC.position = position
                }
            }
        }
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        self.no_results_found.isHidden = self.postModels.count > 0 ? true : false
        return self.postModels.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "customPostCell",
            for: indexPath
        ) as? CustomPostCollectionViewCell {
            let postModel = self.postModels[indexPath.row]

            cell.image.layer.cornerRadius = 8
            let myGest = MyGesture(target: self, action: #selector(self.postClicked))
            myGest.index = indexPath.row
            cell.videoMainView.isUserInteractionEnabled = true
            cell.videoMainView.addGestureRecognizer(myGest)

            if postModel.postType == "image" {
                if let postImages = postModel.postImages, !postImages.isEmpty {
                    if let sImage = postImages.first, !sImage.isEmpty {
                        cell.image.setImage(
                            imageKey: sImage,
                            placeholder: "placeholder",
                            width: 410,height: 410,
                            shouldShowAnimationPlaceholder: true
                        )
                    }
                }
           
                
                
                
            } else if postModel.postType == "video" {
                if let postImage = postModel.videoImage, !postImage.isEmpty {
                    cell.image.setImage(
                        imageKey: postImage,
                        placeholder: "placeholder",
                        width: 410,height: 410,
                        shouldShowAnimationPlaceholder: true
                    )
                }
                
                if let path = postModel.postVideo {
                    if let player = playerPool.getPlayer() {
                        self.activePlayers.append(player)
                        cell.playerLayer?.removeFromSuperlayer()
                        cell.playerLayer = nil
                        cell.player = player
                        cell.returnPlayerDelegate = self
                        let videoURL = "\(Constants.AWS_VIDEO_BASE_URL)\(path)"
                        if let url = URL(string: videoURL) {
                            if let videoData = SDImageCache.shared.diskImageData(forKey: url.absoluteString) {
                                let documentsDirectoryURL = FileManager.default.urls(
                                    for: .documentDirectory,
                                    in: .userDomainMask
                                ).first!
                                let fileURL = documentsDirectoryURL.appendingPathComponent(url.lastPathComponent)

                                try? videoData.write(to: fileURL, options: .atomic)

                                let playerItem = CustomPlayerItem(url: fileURL, videoPostID: postModel.postID ?? "123")
                                cell.player!.replaceCurrentItem(with: playerItem)
                                // Setup your player view and play the video.
                            } else {
                                downloadMP4File(from: url)
                                // Continue to play online while downloading for cache
                                let playerItem = CustomPlayerItem(
                                    url: URL(string: videoURL)!,
                                    videoPostID: postModel.postID ?? "123"
                                )
                                cell.player!.replaceCurrentItem(with: playerItem)
                            }

                            self.playerPool.observePlayer(player)

                            let playerLayer = AVPlayerLayer(player: player)
                            playerLayer.videoGravity = .resizeAspectFill

                            cell.image.layer.addSublayer(playerLayer)
                            cell.playerLayer = playerLayer

                            cell.player?.isMuted = true
                            cell.image.layoutIfNeeded()
                          
                        }
                    }
                }
            }
            
            
            
            

            return cell
        }

        return CustomPostCollectionViewCell()
    }
}
extension PostSearchResultsViewController : ReturnPlayerDelegate {
    func returnPlayer(player: AVPlayer) {
        self.playerPool.returnPlayer(player)
        self.activePlayers.remove(player)
    }
}
