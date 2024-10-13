// Copyright © 2023 SOFTMENT. All rights reserved.

import UIKit

class NotificationViewController: UIViewController {
    @IBOutlet weak var statusBarHeight: NSLayoutConstraint!
    let refreshControl = UIRefreshControl()
    @IBOutlet weak var noNotificationsAvailable: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var notificationModels = Array<NotificationModel>()
    override func viewDidLoad() {
        
        guard let currentUser = FirebaseStoreManager.auth.currentUser else {
            DispatchQueue.main.async {
                self.logoutPlease()
            }
            return
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //get all notifications
        self.getAllNotifications(uid: currentUser.uid) { notifications, error in
            self.notificationModels.removeAll()
            self.notificationModels.append(contentsOf: notifications ?? [])
            self.tableView.reloadData()
        }
      
    }
    
    
    
    @objc func cellViewClicked(value : MyGesture){
        let position = value.index
        let notificationModel = notificationModels[position]
        if notificationModel.type == Notifications.like.rawValue || notificationModel.type == Notifications.comment.rawValue {
            guard let pid = notificationModel.id, !pid.isEmpty else {
              return
            }
            
            self.ProgressHUDShow(text: "")
            self.getPostBy(postId: pid) { postModel, error in
                self.ProgressHUDHide()
                if let postModel = postModel {
                    self.performSegue(withIdentifier: "postViewSeg", sender: postModel)
                }
            }

        }
        
        else if notificationModel.type == Notifications.following.rawValue {
            guard let uid  = notificationModel.uid, !uid.isEmpty else {
                return
            }
            self.ProgressHUDShow(text: "")
            self.getUserDataByID(uid: uid) { userModel, error in
                self.ProgressHUDHide()
                if let userModel = userModel {
                    self.performSegue(withIdentifier: "viewUserProfileSeg", sender: userModel)
                }
            }
        }
        else if notificationModel.type == Notifications.event.rawValue {
            guard let eventId  = notificationModel.id, !eventId.isEmpty else {
                return
            }
            
            self.ProgressHUDShow(text: "")
            self.getEvent(by: eventId) { event in
                self.ProgressHUDHide()
                if let event = event {
                    self.performSegue(withIdentifier: "showEventSeg", sender: event)
                }
            }
           
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "postViewSeg" {
            if let vc = segue.destination as? PostViewController {
                if let postModel = sender as? PostModel {
                    var postModels = Array<PostModel>()
                    postModels.append(postModel)
                    vc.position = 0
                    vc.postModels = postModels
                }
            }
        }
        else if segue.identifier == "viewUserProfileSeg" {
            if let vc = segue.destination as? ViewUserProfileController {
                if let userModel = sender as? UserModel {
                    vc.user = userModel
                }
            }
        }
        else if segue.identifier == "showEventSeg" {
            if let VC = segue.destination as? ShowEventViewController {
                if let eventModel = sender as? Event {
                    VC.event = eventModel
                }
            }
        }
    }
}

extension NotificationViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noNotificationsAvailable.isHidden = notificationModels.count > 0 ? true : false
        return notificationModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as? NotificationsTableViewCell {
            
            let notificationModel = notificationModels[indexPath.row]
            
            cell.mProfile.layer.cornerRadius = cell.mProfile.bounds.width / 2
            cell.postImg.layer.cornerRadius = 8
            
            cell.date.text = convertDateFormaterWithoutDash(notificationModel.date ?? Date())
            cell.time.text = "| \(convertDateIntoTime(notificationModel.date ?? Date()))"
            
            cell.comment.isHidden = true
            
            switch notificationModel.type!  {
            case Notifications.comment.rawValue :
                cell.mMessage.text = "commented: "
                cell.comment.text = notificationModel.comment ?? ""
                cell.comment.isHidden = false
                break
                
            case Notifications.like.rawValue :
                cell.mMessage.text = "liked your post."
                break
                

            case Notifications.following.rawValue :
                cell.mMessage.text = "started following you."
                break
                
            case Notifications.event.rawValue :
                cell.mMessage.text = "invited for an event."
                
                break
                
            default:
                print("NIL Notification")
            }
            
            cell.mView.isUserInteractionEnabled = true
            let gest = MyGesture(target: self, action: #selector(cellViewClicked(value: )))
            gest.index = indexPath.row
            cell.mView.addGestureRecognizer(gest)
            
            cell.postImg.isHidden = true
            
            if notificationModel.type! == Notifications.like.rawValue ||
                notificationModel.type! == Notifications.comment.rawValue {
                
                self.getPostBy(postId: notificationModel.id ?? "123") { postModel, error in
                    if let postModel = postModel {
                        if let type = postModel.postType {
                            if type == "image" {
                                cell.postImg.isHidden = false
                                cell.postImg.setImage(imageKey: postModel.postImages!.first!, placeholder: "placeholder",shouldShowAnimationPlaceholder: true)
                            }
                            else if type == "video" {
                                cell.postImg.isHidden = false
                                cell.postImg.setImage(imageKey: postModel.videoImage!, placeholder: "placeholder",shouldShowAnimationPlaceholder: true)
                            }
                        }
                      
                       
                    }
                    else {
                        self.deleteNotification(notificationId: notificationModel.notificationId!) {
                            self.notificationModels.remove(notificationModel)
                           
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
    
                        }
                       
                    }
                }
            }
            
            getUserDataByID(uid: notificationModel.uid ?? "123") { userModel, error in
                if let userModel = userModel {
                    if let pic = userModel.profilePic, !pic.isEmpty {
                        cell.mProfile.setImage(imageKey: pic, placeholder: "profile-placeholder",shouldShowAnimationPlaceholder: true)
                    }
                    cell.mName.text = userModel.fullName ?? "ERROR"

                }
                else {
                    self.deleteNotification(notificationId: notificationModel.notificationId!) {
                        self.notificationModels.remove(notificationModel)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
            }
            
            
            return cell
        }
        return NotificationsTableViewCell()
    }
    
}
