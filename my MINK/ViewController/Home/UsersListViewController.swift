//  UsersListViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 13/03/24.

import UIKit

// MARK: - UserSearchResultsViewController

class UsersListViewController: UIViewController {
    
    @IBOutlet weak var topHeadingLbl: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var no_likes_available: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var userModels = [UserModel]()
    var userModelsIDs: [String]?
    var headTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let userModelsIDs = self.userModelsIDs, let title = headTitle else {
            dismiss(animated: true)
            return
        }
        
        setupViews(title: title)
        loadUserModels(userModelsIDs: userModelsIDs)
    }
    
    private func setupViews(title: String) {
        topHeadingLbl.text = title
        no_likes_available.text = "No \(title.lowercased()) available"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        
        backView.isUserInteractionEnabled = true
        backView.dropShadow()
        backView.layer.cornerRadius = 8
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
    }
    
    private func loadUserModels(userModelsIDs: [String]) {
        ProgressHUDShow(text: "")
        fetchUsers(userIds: userModelsIDs) { userModels, error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error.localizedDescription)
            } else {
                self.userModels = userModels ?? []
                self.tableView.reloadData()
            }
        }
    }
    
    @objc private func backViewClicked() {
        dismiss(animated: true)
    }
    
    @objc private func followBtnClicked(value: MyGesture) {
        guard let userModel = self.userModels[safe: value.index], let currentUserID = FirebaseStoreManager.auth.currentUser?.uid else { return }
        
        if let followBtn = value.userListCell.followBtn {
            if followBtn.isSelected {
                unfollowUser(followBtn: followBtn, userModel: userModel, currentUserID: currentUserID)
            } else {
                followUser(followBtn: followBtn, userModel: userModel)
            }
        }
    
    }
    
    private func followUser(followBtn: UIButton, userModel: UserModel) {
        followBtn.configureAsFollowing()
        addFollow(mUser: UserModel.data!, fUser: userModel)
        
        PushNotificationSender().sendPushNotification(
            title: "Good News",
            body: "\(UserModel.data?.fullName ?? "Someone") is following you.",
            topic: userModel.notificationToken ?? ""
        )
    }
    
    private func unfollowUser(followBtn: UIButton, userModel: UserModel, currentUserID: String) {
        followBtn.configureAsNotFollowing()
        
        deleteFollow(mainUserId: currentUserID, followerUserId: userModel.uid ?? "") { error in
            if let error = error {
                self.showError(error)
                followBtn.configureAsFollowing()
            }
        }
    }
    
    @objc private func showUserProfile(value: MyGesture) {
        guard let userModel = value.userModel else { return }
        performSegue(withIdentifier: "searchViewUserProfileSeg", sender: userModel)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchViewUserProfileSeg",
           let vc = segue.destination as? ViewUserProfileController,
           let user = sender as? UserModel {
            vc.user = user
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension UsersListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        no_likes_available.isHidden = !userModels.isEmpty
        return userModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as? UserTableViewCell else {
            return UserTableViewCell()
        }
        
        let userModel = userModels[indexPath.row]
        configureCell(cell, with: userModel, at: indexPath)
        
        return cell
    }
    
    private func configureCell(_ cell: UserTableViewCell, with userModel: UserModel, at indexPath: IndexPath) {
        cell.mView.layer.cornerRadius = 8
        cell.mProfile.layer.cornerRadius = cell.mProfile.bounds.height / 2
        
        if let path = userModel.profilePic, !path.isEmpty {
            cell.mProfile.setImage(
                imageKey: path,
                placeholder: "profile-placeholder",
                width: 100,
                height: 100,
                shouldShowAnimationPlaceholder: true
            )
        }
        
        configureFollowButton(for: cell, with: userModel, at: indexPath)
        
        cell.fullName.text = userModel.fullName
        cell.username.text = "@\(userModel.username ?? "")"
        
        cell.mView.isUserInteractionEnabled = true
        let gest = MyGesture(target: self, action: #selector(self.showUserProfile))
        gest.userModel = userModel
        cell.mView.addGestureRecognizer(gest)
    }
    
    private func configureFollowButton(for cell: UserTableViewCell, with userModel: UserModel, at indexPath: IndexPath) {
        guard let currentUserID = FirebaseStoreManager.auth.currentUser?.uid else { return }
        
        cell.followBtn.isHidden = userModel.uid == currentUserID
        cell.followBtn.layer.cornerRadius = 8
        
        isUserFollowed(currentUserId: currentUserID, otherUserId: userModel.uid ?? "") { isFollow in
            if isFollow {
                cell.followBtn.configureAsFollowing()
            } else {
                cell.followBtn.configureAsNotFollowing()
            }
        }
        
        let followGest = MyGesture(target: self, action: #selector(followBtnClicked))
        followGest.index = indexPath.row
        followGest.userListCell = cell
        cell.followBtn.addGestureRecognizer(followGest)
    }
}

// MARK: - Extensions

extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension UIButton {
    func configureAsFollowing() {
        backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        isSelected = true
        setTitleColor(.black, for: .selected)
        setTitle("Following", for: .normal)
    }
    
    func configureAsNotFollowing() {
        backgroundColor = UIColor(red: 210 / 255, green: 0, blue: 1 / 255, alpha: 1)
        isSelected = false
        setTitleColor(.white, for: .normal)
        setTitle("Follow", for: .normal)
    }
}
