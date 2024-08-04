//
//  SavedViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 29/05/24.
//

import UIKit

class SavedViewController: UIViewController {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noSavedPostAvailable: UILabel!
    
    var postModels = [PostModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadSavedPosts()
    }
    
    private func setupUI() {
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        backView.dropShadow()
        backView.layer.cornerRadius = 8
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        let flowLayout = UICollectionViewFlowLayout()
        let width = collectionView.bounds.width
        flowLayout.itemSize = CGSize(width: (width / 3) - 5, height: (width / 3) - 5)
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = 0
        collectionView.collectionViewLayout = flowLayout
    }
    
    private func loadSavedPosts() {
        guard let currentUser = FirebaseStoreManager.auth.currentUser else {
            dismiss(animated: true)
            return
        }
        
        ProgressHUDShow(text: "")
        getSavedPosts(userID: currentUser.uid) { postModel, error in
            self.ProgressHUDHide()
            self.postModels.removeAll()
            if let error = error {
                self.showError(error.localizedDescription)
            } else if let postModels = postModel, !postModels.isEmpty {
                self.postModels.append(contentsOf: postModels)
            }
            self.collectionView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "postViewSeg", let VC = segue.destination as? PostViewController, let position = sender as? Int {
            VC.postModels = self.postModels
            VC.topTitle = "Saved"
            VC.position = position
        }
    }
    
    @objc func backViewClicked() {
        dismiss(animated: true)
    }
    
    @objc func postClicked(value: MyGesture) {
        performSegue(withIdentifier: "postViewSeg", sender: value.index)
    }
}

extension SavedViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        return CGSize(width: (width / 3) - 5, height: (width / 3) - 5)
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        noSavedPostAvailable.isHidden = postModels.count > 0
        return postModels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profilePostCell", for: indexPath) as? ProfilePosCollectionViewCell else {
            return ProfilePosCollectionViewCell()
        }

        let postModel = postModels[indexPath.row]
        cell.mImage.layer.cornerRadius = 8
        configureCell(cell, with: postModel, at: indexPath.row)
        return cell
    }

    private func configureCell(_ cell: ProfilePosCollectionViewCell, with postModel: PostModel, at index: Int) {
        let myGest = MyGesture(target: self, action: #selector(postClicked))
        myGest.index = index
        cell.mImage.isUserInteractionEnabled = true
        cell.mImage.addGestureRecognizer(myGest)

        let myGest1 = MyGesture(target: self, action: #selector(postClicked))
        myGest1.index = index
        cell.captionView.isUserInteractionEnabled = true
        cell.captionView.addGestureRecognizer(myGest1)

        switch postModel.postType {
        case "image":
            configureImageCell(cell, with: postModel)
        case "video":
            configureVideoCell(cell, with: postModel)
        case "text":
            configureTextCell(cell, with: postModel)
        default:
            break
        }
    }

    private func configureImageCell(_ cell: ProfilePosCollectionViewCell, with postModel: PostModel) {
        cell.captionView.isHidden = true
        if let postImages = postModel.postImages, let sImage = postImages.first, !sImage.isEmpty {
            cell.mImage.setImage(imageKey: sImage, placeholder: "placeholder", shouldShowAnimationPlaceholder: true)
        }
    }

    private func configureVideoCell(_ cell: ProfilePosCollectionViewCell, with postModel: PostModel) {
        cell.captionView.isHidden = true
        if let postImage = postModel.videoImage, !postImage.isEmpty {
            cell.mImage.setImage(imageKey: postImage, placeholder: "placeholder", shouldShowAnimationPlaceholder: true)
        }
    }

    private func configureTextCell(_ cell: ProfilePosCollectionViewCell, with postModel: PostModel) {
        if let caption = postModel.caption, !caption.isEmpty {
            cell.captionView.isHidden = false
            cell.captionView.layer.cornerRadius = 8
            cell.captionView.layer.borderWidth = 0.2
            cell.captionView.layer.borderColor = UIColor.lightGray.cgColor
            cell.captionLabel.text = caption
        }
    }
}
