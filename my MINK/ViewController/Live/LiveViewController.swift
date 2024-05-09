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
        self.startBtn.layer.cornerRadius = 8
        self.searchBtn.layer.cornerRadius = 8

        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        let flowLayout = UICollectionViewFlowLayout()
        let width = self.collectionView.bounds.width

        flowLayout.itemSize = CGSize(width: (width / 2) - 5, height: (width / 2) - 5)
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.vertical
        flowLayout.minimumInteritemSpacing = 0
        self.collectionView.collectionViewLayout = flowLayout

        FirebaseStoreManager.db.collection("LiveStreamings").order(by: "date", descending: true)
            .whereField("isOnline", isEqualTo: true)
            .addSnapshotListener { snapshot, error in

                if let error = error {
                    print(error.localizedDescription)
                } else {
                    self.liveStreamingModels.removeAll()

                    if let snapshot = snapshot, !snapshot.isEmpty {
                        for qdr in snapshot.documents {
                            if let liveModel = try? qdr.data(as: LiveStreamingModel.self) {
                                if liveModel.uid != FirebaseStoreManager.auth.currentUser!.uid {
                                    self.liveStreamingModels.append(liveModel)
                                }
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
        if segue.identifier == "joinLiveStreamSeg" {
            if let VC = segue.destination as? JoinLiveStreamViewController {
                if let liveModel = sender as? LiveStreamingModel {
                    VC.token = liveModel.token

                    VC.channelName = liveModel.uid
                    VC.sName = liveModel.fullName
                    VC.sProfilePic = liveModel.profilePic
                    VC.agoraUID = liveModel.agoraUID
                }
            }
        }
    }

    @objc func postClicked(value: MyGesture) {
        performSegue(withIdentifier: "joinLiveStreamSeg", sender: self.liveStreamingModels[value.index])
    }
}

extension LiveViewController: UICollectionViewDelegate, UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout
{
    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        let width = self.collectionView.bounds.width
        return CGSize(width: (width / 2) - 5, height: (width / 2) - 5)
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        self.noLiveStreamingsAvailable.isHidden = self.liveStreamingModels.count > 0 ? true : false
        return self.liveStreamingModels.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "liveStreamingCell",
            for: indexPath
        ) as? LiveStreamingCollectionViewCell {
            let liveModel = self.liveStreamingModels[indexPath.row]

            cell.mProfile.layer.cornerRadius = 8
            let myGest = MyGesture(target: self, action: #selector(self.postClicked))
            myGest.index = indexPath.row
            cell.mView.isUserInteractionEnabled = true
            cell.mView.addGestureRecognizer(myGest)
            cell.fullName.text = liveModel.fullName ?? ""
            cell.fullNameView.layer.cornerRadius = 4
            cell.countView.layer.cornerRadius = 4

            // cell.count.text = "\(liveModel.count ?? 0)"

            if let postImage = liveModel.profilePic, !postImage.isEmpty {
                cell.mProfile.setImage(
                    imageKey: postImage,
                    placeholder: "profile-placeholder",
                    shouldShowAnimationPlaceholder: true
                )
            }

            return cell
        }

        return ProfilePosCollectionViewCell()
    }
}
