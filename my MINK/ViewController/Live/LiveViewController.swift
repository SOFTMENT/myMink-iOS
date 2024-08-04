// Copyright © 2023 SOFTMENT. All rights reserved.

import UIKit

class LiveViewController: UIViewController {
    @IBOutlet var startBtn: UIButton!
    var channelName: String?
    var name: String?
    var profilePic: String?
    var liveStreamingModels = [LiveStreamingModel]()
    @IBOutlet var searchBtn: UIView!
    @IBOutlet var searchTF: UITextField!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var noLiveStreamingsAvailable: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        fetchLiveStreamings()
    }

    private func setupUI() {
        startBtn.layer.cornerRadius = 8
        searchBtn.layer.cornerRadius = 8
    }

    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        let flowLayout = UICollectionViewFlowLayout()
        let width = collectionView.bounds.width
        flowLayout.itemSize = CGSize(width: (width / 2) - 5, height: (width / 2) - 5)
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = 0
        collectionView.collectionViewLayout = flowLayout
    }

    private func fetchLiveStreamings() {
        FirebaseStoreManager.db.collection(Collections.liveStreamings.rawValue)
            .order(by: "date", descending: true)
            .whereField("isOnline", isEqualTo: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    self.liveStreamingModels.removeAll()
                    if let snapshot = snapshot, !snapshot.isEmpty {
                        for document in snapshot.documents {
                            if let liveModel = try? document.data(as: LiveStreamingModel.self),
                               liveModel.uid != FirebaseStoreManager.auth.currentUser!.uid {
                                self.liveStreamingModels.append(liveModel)
                            }
                        }
                    }
                    self.collectionView.reloadData()
                }
            }
    }

    @IBAction func startBtnClicked(_: Any) {
        startLiveStream(shouldShowProgress: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "joinLiveStreamSeg",
           let VC = segue.destination as? JoinLiveStreamViewController,
           let liveModel = sender as? LiveStreamingModel {
            VC.token = liveModel.token
            VC.channelName = liveModel.uid
            VC.sName = liveModel.fullName
            VC.sProfilePic = liveModel.profilePic
            VC.agoraUID = liveModel.agoraUID
        }
    }

    @objc func postClicked(value: MyGesture) {
        performSegue(withIdentifier: "joinLiveStreamSeg", sender: liveStreamingModels[value.index])
    }
}

extension LiveViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        return CGSize(width: (width / 2) - 5, height: (width / 2) - 5)
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        noLiveStreamingsAvailable.isHidden = !liveStreamingModels.isEmpty
        return liveStreamingModels.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "liveStreamingCell",
            for: indexPath
        ) as? LiveStreamingCollectionViewCell else {
            return LiveStreamingCollectionViewCell()
        }

        let liveModel = liveStreamingModels[indexPath.row]
        configureCell(cell, with: liveModel, at: indexPath)
        return cell
    }

    private func configureCell(_ cell: LiveStreamingCollectionViewCell, with liveModel: LiveStreamingModel, at indexPath: IndexPath) {
        cell.mProfile.layer.cornerRadius = 8
        let myGest = MyGesture(target: self, action: #selector(postClicked))
        myGest.index = indexPath.row
        cell.mView.isUserInteractionEnabled = true
        cell.mView.addGestureRecognizer(myGest)
        cell.fullName.text = liveModel.fullName ?? ""
        cell.fullNameView.layer.cornerRadius = 4
        cell.countView.layer.cornerRadius = 4

        if let postImage = liveModel.profilePic, !postImage.isEmpty {
            cell.mProfile.setImage(
                imageKey: postImage,
                placeholder: "profile-placeholder",
                shouldShowAnimationPlaceholder: true
            )
        }
    }
}
