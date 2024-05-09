// Copyright © 2023 SOFTMENT. All rights reserved.

import UIKit

// MARK: - UserSearchResultsViewController

class UserSearchResultsViewController: UIViewController {
    @IBOutlet var no_results_found: UILabel!
    @IBOutlet var tableView: UITableView!
    var userModels = [UserModel]()

    override func viewDidLoad() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    func notifyAdapter(userModels: [UserModel]) {
        self.userModels.removeAll()
        self.userModels.append(contentsOf: userModels)

        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.reloadData()
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

extension UserSearchResultsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        self.no_results_found.isHidden = self.userModels.count > 0 ? true : false
        return self.userModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as? UserTableViewCell {
            cell.mView.layer.cornerRadius = 8
            cell.mProfile.layer.cornerRadius = 6

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
