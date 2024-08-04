// Copyright © 2023 SOFTMENT. All rights reserved.

import UIKit

// MARK: - UserSearchResultsViewController

class UserSearchResultsViewController: UIViewController {
    @IBOutlet var no_results_found: UILabel!
    @IBOutlet var tableView: UITableView!
    var userModels = [UserModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
    }

    func notifyAdapter(userModels: [UserModel]) {
        self.userModels = userModels
        tableView.reloadData()
    }

    @objc func showUserProfile(value: MyGesture) {
        if let userModel = value.userModel {
            performSegue(withIdentifier: "searchViewUserProfileSeg", sender: userModel)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchViewUserProfileSeg", let vc = segue.destination as? ViewUserProfileController, let user = sender as? UserModel {
            vc.user = user
        }
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource

extension UserSearchResultsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        no_results_found.isHidden = !userModels.isEmpty
        return userModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as? UserTableViewCell else {
            return UserTableViewCell()
        }
        
        let userModel = userModels[indexPath.row]
        configureCell(cell, with: userModel)
        return cell
    }

    private func configureCell(_ cell: UserTableViewCell, with userModel: UserModel) {
        cell.mView.layer.cornerRadius = 8
        cell.mProfile.layer.cornerRadius = 6

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
        let gest = MyGesture(target: self, action: #selector(showUserProfile))
        gest.userModel = userModel
        cell.mView.addGestureRecognizer(gest)
    }
}
