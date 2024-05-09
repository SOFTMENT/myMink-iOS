//
//  UsersListViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 13/03/24.
//

import UIKit

// MARK: - UserSearchResultsViewController

class UsersListViewController : UIViewController {
    
    @IBOutlet weak var topHeadingLbl: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var no_likes_available: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var userModels = [UserModel]()
    var userModelsIDs : Array<String>?
    var headTitle : String?
    override func viewDidLoad() {
        
        guard let userModelsIDs = self.userModelsIDs, 
        let title = headTitle else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        topHeadingLbl.text = title
        
        no_likes_available.text = "No \(title.lowercased()) available"
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.showsVerticalScrollIndicator = false
        
        self.ProgressHUDShow(text: "")
        fetchUsers(userIds: userModelsIDs) { userModels, error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error.localizedDescription)
            }
            else {
                self.userModels.removeAll()
                self.userModels.append(contentsOf: userModels ?? [])
                self.tableView.reloadData()
            }
        }
        
        
        backView.isUserInteractionEnabled = true
        backView.dropShadow()
        backView.layer.cornerRadius = 8
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
    }
    
    @objc func backViewClicked(){
        self.dismiss(animated: true)
    }

 
    @objc func followBtnClicked(value : MyGesture){
        if !value.userListCell.followBtn.isSelected {
            value.userListCell.followBtn.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
            value.userListCell.followBtn.isSelected = true
            value.userListCell.followBtn.setTitleColor(.black, for: .selected)
            value.userListCell.followBtn.setTitle("Following", for: .normal)
            addFollow(mUser: UserModel.data!, fUser: self.userModels[value.index])
           
            PushNotificationSender().sendPushNotification(
                title: "Good News",
                body: "\(UserModel.data!.fullName ?? "123") is following you.",
                topic: self.userModels[value.index].notificationToken ?? "123"
            )
        } else {
            value.userListCell.followBtn.backgroundColor = UIColor(red: 210 / 255, green: 0, blue: 1 / 255, alpha: 1)
            value.userListCell.followBtn.isSelected = false
            value.userListCell.followBtn.setTitleColor(.white, for: .normal)
            value.userListCell.followBtn.setTitle("Follow", for: .normal)
          
            
            
            self.deleteFollow(mainUserId: FirebaseStoreManager.auth.currentUser!.uid, followerUserId: self.userModels[value.index].uid ?? "123") { error in
                if error != nil {
                    value.userListCell.followBtn.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
                    value.userListCell.followBtn.isSelected = true
                    value.userListCell.followBtn.setTitleColor(.black, for: .selected)
                    value.userListCell.followBtn.setTitle("Following", for: .normal)
                }
            }

        }
        
    }

    @objc func showUserProfile(value: MyGesture) {
        if let userModel = value.userModel {
            performSegue(withIdentifier: "searchViewUserProfileSeg", sender: userModel)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchViewUserProfileSeg" {
            if let vc = segue.destination as? ViewUserProfileController {
                if let user = sender as? UserModel {
                    vc.user = user
                }
            }
        }
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource

extension UsersListViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        self.no_likes_available.isHidden = self.userModels.count > 0 ? true : false
        return self.userModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as? UserTableViewCell {
            cell.mView.layer.cornerRadius = 8
            cell.mProfile.layer.cornerRadius = cell.mProfile.bounds.height / 2

            let userModel = self.userModels[indexPath.row]
            if let path = userModel.profilePic, !path.isEmpty {
                cell.mProfile.setImage(
                    imageKey: path,
                    placeholder: "profile-placeholder",
                    width: 100,
                    height: 100,
                    shouldShowAnimationPlaceholder: true
                )
            }
            
            cell.followBtn.isHidden = false
            if userModel.uid == FirebaseStoreManager.auth.currentUser!.uid {
                cell.followBtn.isHidden = true
            }
        
            
            
            self.isUserFollowed(currentUserId: FirebaseStoreManager.auth.currentUser!.uid, otherUserId: userModel.uid ?? "") { isFollow in
                if isFollow {
                    cell.followBtn.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
                    cell.followBtn.isSelected = true
                    cell.followBtn.setTitleColor(.black, for: .selected)
                    cell.followBtn.setTitle("Following", for: .normal)
                }
                else {
                    cell.followBtn.backgroundColor = UIColor(red: 210 / 255, green: 0, blue: 1 / 255, alpha: 1)
                    cell.followBtn.isSelected = false
                    cell.followBtn.setTitleColor(.white, for: .normal)
                    cell.followBtn.setTitle("Follow", for: .normal)
                }
            }
            
            cell.followBtn.layer.cornerRadius = 8
            cell.followBtn.isUserInteractionEnabled = true
            let followGest = MyGesture(target: self, action: #selector(followBtnClicked))
            followGest.index = indexPath.row
            followGest.id = userModel.uid ?? ""
            followGest.userListCell = cell
            cell.followBtn.addGestureRecognizer(followGest)
            
            cell.mView.layer.cornerRadius = 8
        
            
            cell.fullName.text = userModel.fullName ?? ""
            cell.username.text = "@\(userModel.username ?? "")"

            cell.mView.isUserInteractionEnabled = true
            let gest = MyGesture(target: self, action: #selector(self.showUserProfile))
            gest.userModel = userModel
            cell.mView.addGestureRecognizer(gest)

            return cell
        }
        return UserTableViewCell()
    }
}
