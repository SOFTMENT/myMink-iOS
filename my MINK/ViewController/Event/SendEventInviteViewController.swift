import UIKit
import SDWebImage

class SendEventInviteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var followings = [FollowModel]() // Array of followings (just uid)
    var users = [UserModel]() // Array of detailed user info
    var useUsers = [UserModel]()
    
    var selectedUsers = [String: Bool]() // To track selected users
    var selectedTokenUsers = [String: String]() // To track selected users
    
  
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var selectAll: UILabel!
 
    @IBOutlet weak var sendInviteBtn: UIButton!
    var eventModel : Event?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if eventModel == nil {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        searchTF.setLeftIcons(icon: UIImage(systemName: "magnifyingglass")!)
        searchTF.delegate = self
       
        sendInviteBtn.layer.cornerRadius = 8
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let selectAllTapGesture = UITapGestureRecognizer(target: self, action: #selector(selectAllTapped))
           selectAll.isUserInteractionEnabled = true
           selectAll.addGestureRecognizer(selectAllTapGesture)
        
        // Fetch the followings for the current user
        getFollowings()
    }
    
    @objc func selectAllTapped() {
     
       
        for user in users {
            if let uid = user.uid {
                selectedUsers[uid] = true // Set all users to selected/unselected
                selectedTokenUsers[uid] = user.notificationToken
                
            }
        }
        self.showSnack(messages: "Selected All")
        tableView.reloadData() // Reload table view to reflect changes
    }
    
    // Fetch following users by UID
    func getFollowings() {
      

        guard let user = FirebaseStoreManager.auth.currentUser else {
            
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
     
        self.ProgressHUDShow(text: "")
        getFollowingByUid(uid: user.uid) { [weak self] followModels in
            guard let self = self, let followModels = followModels else { return }
            self.followings = followModels
           
            // Fetch full user data for each following
            self.fetchUsersData()
        }
    }
    
    // Fetch user data for each following UID
    func fetchUsersData() {
        let dispatchGroup = DispatchGroup()
        
        for following in followings {
            guard let uid = following.uid else { continue }
            
            dispatchGroup.enter()
            getUserDataByID(uid: uid) { [weak self] (userModel, error) in
                if let user = userModel {
                  
                    self?.users.append(user)
                    self?.useUsers.append(user)
                    self?.selectedUsers[user.uid ?? ""] = false // Initially all unselected
                }
                dispatchGroup.leave()
            }
        }
        
        // Once all user data is fetched, sort and reload the table view
        dispatchGroup.notify(queue: .main) {
            self.users.sort { $0.fullName ?? "" < $1.fullName ?? "" } // Sort by full name in ascending order
            self.useUsers.sort { $0.fullName ?? "" < $1.fullName ?? "" } // Sort by full name in ascending order
            self.ProgressHUDHide()
            self.tableView.reloadData()
        }
    }

    
    // MARK: - TableView DataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return useUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "inviteCell", for: indexPath) as! SendEventInviteTableViewCell
        let user = useUsers[indexPath.row]
        
        cell.mView.layer.cornerRadius = 8
    
        // Set user details in the cell
        cell.fullname.text = user.fullName
        cell.username.text = user.username
        cell.mProfile.layer.cornerRadius = cell.mProfile.bounds.width / 2
        if let profileImageUrl = user.profilePic {
            cell.mProfile.setImage(imageKey: profileImageUrl, placeholder: "profile-placeholder",width: 200, height: 200, shouldShowAnimationPlaceholder: true)
        } else {
            cell.mProfile.image = UIImage(named: "profile-placeholder")
        }
        
        // Checkmark button state
        let isSelected = selectedUsers[user.uid ?? ""] ?? false
        cell.checkmark.isSelected = isSelected
        
        // Handle checkmark button tap
        cell.checkmark.tag = indexPath.row
        cell.checkmark.addTarget(self, action: #selector(handleCheckmarkTapped(_:)), for: .touchUpInside)
        
        return cell
    }
    
    // Handle checkmark button tap
    @objc func handleCheckmarkTapped(_ sender: UIButton) {
        let user = useUsers[sender.tag]
        if let uid = user.uid {
            selectedUsers[uid] = !(selectedUsers[uid] ?? false)
        }
        
        // Reload the specific row
        tableView.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .none)
    }
    
    @IBAction func sendInviteButtonTapped(_ sender: Any) {
        
        // Get the selected users
        let selectedUserIds = useUsers.filter { selectedUsers[$0.uid ?? ""] == true }.map { $0.uid ?? "" }
        
        // Send invites to selected users
        sendInvites(to: selectedUserIds)
    }
    
    
    // Function to send invites
    func sendInvites(to userIds: [String]) {
       
        
        for uid in userIds {
            if uid != eventModel?.eventOrganizerUid {
                
                self.addNotification(to: eventModel!.eventId!, userId: uid ,  type: Notifications.event.rawValue)
                
                PushNotificationSender().sendPushNotification(
                    title: "Event Invite".localized(),
                    body: String(format: "%@ sent you an invite to %@".localized(), UserModel.data?.fullName ?? "", eventModel?.eventTitle ?? ""),
                    topic: selectedTokenUsers[uid] ?? ""
                )
            }

        }
        
        self.ProgressHUDHide()
        self.showSnack(messages: "Invitations sent successfully".localized())
        self.ProgressHUDHide()
    }
}
// MARK: - UITextFieldDelegate

extension SendEventInviteViewController : UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let searchText = textField.text?.lowercased(), !searchText.isEmpty else {
            useUsers = users
            tableView.reloadData()
            return
        }

        useUsers = users.filter { user in
            let nameMatches = user.fullName?.lowercased().contains(searchText) ?? false
            let symbolMatches = user.username?.lowercased().contains(searchText) ?? false
            return nameMatches || symbolMatches
        }
        tableView.reloadData()
    }
}
