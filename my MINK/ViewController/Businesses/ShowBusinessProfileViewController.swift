//
//  ShowBusinessProfileViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 05/06/24.
//

import UIKit
import SDWebImage

class ShowBusinessProfileViewController : UIViewController {
    
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var noPostsAvailable: UILabel!
    
    @IBOutlet weak var postCount: UILabel!
    
    @IBOutlet weak var coverPicture: SDAnimatedImageView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var profilePicture: SDAnimatedImageView!
    @IBOutlet weak var mName: UILabel!
    @IBOutlet weak var mWebsite: UILabel!
    @IBOutlet weak var mCategory: UILabel!
    @IBOutlet weak var mSubscriber: UILabel!
    @IBOutlet weak var messageBtn: UIButton!
    @IBOutlet weak var subscribeBtn: UIButton!
    @IBOutlet weak var editingBtn: UIView!
    @IBOutlet weak var mAbout: UILabel!
    @IBOutlet weak var addPostBtn: UIView!
    @IBOutlet weak var inboxView: UIView!
    var businessModel : BusinessModel?
    @IBOutlet weak var collectionView: UICollectionView!
    var postModels = [PostModel]()
    var usePostModels = [PostModel]()
    override func viewDidLoad() {
        
        guard let businessModel = businessModel, FirebaseStoreManager.auth.currentUser != nil else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
            
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        profilePicture.makeRounded()
        
        editingBtn.isUserInteractionEnabled = true
        editingBtn.layer.cornerRadius = 8
        editingBtn.dropShadow()
        editingBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editingBtnClicked)))
        
        inboxView.isUserInteractionEnabled = true
        inboxView.layer.cornerRadius = 8
        inboxView.dropShadow()
        inboxView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(inboxBtnClicked)))
        
        addPostBtn.isUserInteractionEnabled = true
        addPostBtn.layer.cornerRadius = 8
        addPostBtn.dropShadow()
        addPostBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addPostClicked)))

        self.getCount(for: businessModel.businessId!, countType: "Subscribers") { count, error in
            if let count = count {
                self.mSubscriber.text =  count > 1 ? "\(count) Subscribers" : "\(count) Subscriber"
            }
        }
        
        self.ProgressHUDShow(text: "")
        self.checkCurrentUserSubscribe(bId: businessModel.businessId ?? "123") { isSubscribe in
            self.ProgressHUDHide()
            if isSubscribe {
                self.subscribeBtn.backgroundColor = .lightGray
                self.subscribeBtn.setTitle("Subscribed", for: .normal)
            }
        }
        
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        let flowLayout = UICollectionViewFlowLayout()
        let width = self.collectionView.bounds.width
        flowLayout.itemSize = CGSize(width: (width / 3) - 5, height: (width / 3) - 5)
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.vertical
        flowLayout.minimumInteritemSpacing = 0
        self.collectionView.collectionViewLayout = flowLayout
        
       
        
    }
    
    
    
    func searchBtnClicked(searchText : String){
        ProgressHUDShow(text: "Searching...")
        algoliaSearch(searchText: searchText, indexName: .POSTS, filters: "uid:\(FirebaseStoreManager.auth.currentUser!.uid)") { models in
            
            DispatchQueue.main.async {
                self.ProgressHUDHide()
                
                self.usePostModels.removeAll()
                self.usePostModels.append(contentsOf: models as? [PostModel] ?? [])
                self.collectionView.reloadData()
                
            }
            
            
        }
    }
    @objc func postClicked(value: MyGesture) {
        performSegue(withIdentifier: "postViewSeg", sender: value.index)
    }

    func refreshCollectionViewHeight() {
        let width = self.collectionView.bounds.width
        self.collectionViewHeight
            .constant = CGFloat((width / CGFloat(3)) + 5) * CGFloat((self.usePostModels.count + 2) / 3)
    }
    
    @objc func addPostClicked(){
        performSegue(withIdentifier: "popupCreatePostSeg", sender: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        guard let businessModel = businessModel,let user = FirebaseStoreManager.auth.currentUser else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        editingBtn.isHidden = true
        inboxView.isHidden = true
        addPostBtn.isHidden = true
        
        
        if user.uid == businessModel.uid {
            editingBtn.isHidden = false
            inboxView.isHidden = false
            messageBtn.isHidden = true
            subscribeBtn.isHidden = true
            addPostBtn.isHidden = false
            
        }
        
        mName.text = businessModel.name ?? ""
        mWebsite.text = businessModel.website ?? ""
        mCategory.text = "\(businessModel.businessCategory ?? ""),"
        
        mAbout.text = businessModel.aboutBusiness ?? ""
        
        if let sProfilepicture = businessModel.profilePicture, !sProfilepicture.isEmpty {
           
       
            profilePicture.setImage(imageKey: sProfilepicture, placeholder: "profile-placeholder",width: 400, height: 400,shouldShowAnimationPlaceholder: true)
        }
        
        
        if let sCoverpicture = businessModel.coverPicture, !sCoverpicture.isEmpty {
            coverPicture.setImage(imageKey: sCoverpicture, placeholder: "cover-placeholder",width: 800, height: 500,shouldShowAnimationPlaceholder: true)
        }
        
        
        getPostsBy(uid: self.businessModel!.businessId ?? "", accountType: .BUSINESS) { pModels, error in

            if let error = error {
                self.showError(error)
            } else {
                self.usePostModels.removeAll()
                self.postModels.removeAll()
                if let pModels = pModels, !pModels.isEmpty {
                    self.postModels.append(contentsOf: pModels)
                    self.usePostModels.append(contentsOf: pModels)
                }
                self.collectionView.reloadData()
            }
        }
    }
    
    
    
    @objc func editingBtnClicked(){
        self.performSegue(withIdentifier: "updateBusinessSeg", sender: businessModel)
    }
    
    @objc func backViewClicked(){
        self.dismiss(animated: true)
    }
    
    @IBAction func subscribeBtnClicked(_ sender: Any) {
        checkCurrentUserSubscribe(bId: businessModel!.businessId ?? "123") { isSubscribe in
            if isSubscribe {
                
                
                
                self.deleteSubscribe(bId: self.businessModel!.businessId ?? "123") {
                    self.getCount(for: self.businessModel!.businessId!, countType: "Subscribers") { count, error in
                        if let count = count {
                            self.mSubscriber.text = count > 1 ? "\(count) Subscribers" : "\(count) Subscriber"
                        }
                    }
                    
                }
                
                self.subscribeBtn.backgroundColor = UIColor(red: 210/255, green: 0/1, blue: 1/255, alpha: 1)
                self.subscribeBtn.setTitle("Subscribe", for: .normal)
            }
            else {
                
                self.subscribeBtn.backgroundColor = .lightGray
                self.subscribeBtn.setTitle("Subscribed", for: .normal)
                
                self.addSubscribe(self.businessModel!.businessId ?? "123") {
                    self.getCount(for: self.businessModel!.businessId!, countType: "Subscribers") { count, error in
                        if let count = count {
                            self.mSubscriber.text = count > 1 ? "\(count) Subscribers" : "\(count) Subscriber"
                        }
                    }
                    
                }
            }
        }
    }
    
    @IBAction func messageBtnClicked(_ sender: Any) {

        
        performSegue(withIdentifier: "showChatSeg", sender: nil)
    }
    
    
    @objc func inboxBtnClicked(){
        performSegue(withIdentifier: "showChatHistorySeg", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        if segue.identifier == "updateBusinessSeg" {
            if let VC = segue.destination as? EditBusinessProfileViewController {
                if let businessModel = sender as? BusinessModel {
                  
                    VC.businessModel = businessModel
                    VC.delegate = self
                }
              
            }
        }
        else if segue.identifier == "showChatSeg" {
            if let vc = segue.destination as? ShowChatViewController {
                let lastModel = LastMessageModel()
                lastModel.senderName = businessModel?.name
                lastModel.senderUid = businessModel?.businessId
                lastModel.senderToken = businessModel?.notificationToken
                lastModel.senderImage = businessModel?.profilePicture
                lastModel.senderDeviceToken = businessModel?.deviceToken
                lastModel.isBusiness = true
                vc.lastMessage = lastModel
 
            }
        }
        else if segue.identifier == "showChatHistorySeg" {
            if let VC = segue.destination as? ChatViewController {
                VC.businessModel = self.businessModel
            }
        }
        else if segue.identifier == "popupCreatePostSeg" {
            if let VC = segue.destination as? CreatePostPopupViewController {
                VC.businessId = self.businessModel!.businessId
            }
        }
        else if segue.identifier == "postViewSeg" {
            if let VC = segue.destination as? PostViewController {
                if let position = sender as? Int {
                    VC.postModels = self.usePostModels
                   
                    VC.businessModel = self.businessModel
                    VC.position = position
                }
              
            }
        }
        
    }
    
    
}


extension ShowBusinessProfileViewController : UICollectionViewDelegate, UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout
{
    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        let width = self.collectionView.bounds.width
        return CGSize(width: (width / 3) - 5, height: (width / 3) - 5)
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        self.postCount.text = self.usePostModels.count > 1 ? "\(self.usePostModels.count) Posts" : "\(self.usePostModels.count) Post"
        self.noPostsAvailable.isHidden = self.usePostModels.count > 0 ? true : false
        return self.usePostModels.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "profilePostCell",
            for: indexPath
        ) as? ProfilePosCollectionViewCell {
            let postModel = self.usePostModels[indexPath.row]

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

            self.refreshCollectionViewHeight()
            cell.layoutIfNeeded()

            return cell
        }

        return ProfilePosCollectionViewCell()
    }
}

extension ShowBusinessProfileViewController : ReloadTableViewDelegate {
    func reloadTableView() {
        self.businessModel = nil
    }
    
    
}
