//
//  SavedViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 29/05/24.
//

import UIKit

class SavedViewController : UIViewController {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    var postModels = [PostModel]()
    @IBOutlet weak var noSavedPostAvailable: UILabel!
    
    override func viewDidLoad() {
        
        guard FirebaseStoreManager.auth.currentUser != nil else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        backView.dropShadow()
        backView.layer.cornerRadius = 8
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        let flowLayout = UICollectionViewFlowLayout()
        let width = self.collectionView.bounds.width
        flowLayout.itemSize = CGSize(width: (width / 3) - 5, height: (width / 3) - 5)
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.vertical
        flowLayout.minimumInteritemSpacing = 0
        self.collectionView.collectionViewLayout = flowLayout

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.ProgressHUDShow(text: "")
        self.getSavedPosts(userID: FirebaseStoreManager.auth.currentUser!.uid) { postModel, error in
            self.ProgressHUDHide()
            self.postModels.removeAll() 
            if let error = error {
                self.showError(error.localizedDescription)
            } else {
              
                if let pModels = postModel, !pModels.isEmpty {
                    self.postModels.append(contentsOf: pModels)
                }
                self.collectionView.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "postViewSeg" {
            if let VC = segue.destination as? PostViewController {
                if let position = sender as? Int {
                    VC.postModels = self.postModels
                    VC.topTitle = "Saved"
                    VC.position = position
                }
            }
        }
    }
    @objc func backViewClicked() {
        self.dismiss(animated: true)
    }
    
    @objc func postClicked(value: MyGesture) {
        performSegue(withIdentifier: "postViewSeg", sender: value.index)
    }
    
}

extension SavedViewController : UICollectionViewDelegate, UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout
{
    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        let width = self.collectionView.bounds.width
        return CGSize(width: (width / 3) - 5, height: (width / 3) - 5)
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        self.noSavedPostAvailable.isHidden = self.postModels.count > 0 ? true : false
        return self.postModels.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "profilePostCell",
            for: indexPath
        ) as? ProfilePosCollectionViewCell {
            let postModel = self.postModels[indexPath.row]

            cell.mImage.layer.cornerRadius = 8
            let myGest = MyGesture(target: self, action: #selector(self.postClicked))
            myGest.index = indexPath.row
            cell.mImage.isUserInteractionEnabled = true
            cell.mImage.addGestureRecognizer(myGest)

            let myGest1 = MyGesture(target: self, action: #selector(self.postClicked))
            myGest1.index = indexPath.row
            cell.captionView.isUserInteractionEnabled = true
            cell.captionView.addGestureRecognizer(myGest1)

            if postModel.postType == "image" {
                cell.captionView.isHidden = true
                if let postImages = postModel.postImages, !postImages.isEmpty {
                    if let sImage = postImages.first, !sImage.isEmpty {
                        cell.mImage.setImage(
                            imageKey: sImage,
                            placeholder: "placeholder",
                            shouldShowAnimationPlaceholder: true
                        )
                    }
                }
            } else if postModel.postType == "video" {
                cell.captionView.isHidden = true
                if let postImage = postModel.videoImage, !postImage.isEmpty {
                    cell.mImage.setImage(
                        imageKey: postImage,
                        placeholder: "placeholder",
                        shouldShowAnimationPlaceholder: true
                    )
                }
            } else if postModel.postType == "text" {
                if let caption = postModel.caption, !caption.isEmpty {
                    cell.captionView.isHidden = false
                    cell.captionView.layer.cornerRadius = 8
                    cell.captionView.layer.borderWidth = 0.2
                    cell.captionView.layer.borderColor = UIColor.lightGray.cgColor
                    cell.captionLabel.text = caption
                }
            }

     
        
            return cell
        }

        return ProfilePosCollectionViewCell()
    }
}
