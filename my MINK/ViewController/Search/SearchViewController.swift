// Copyright © 2023 SOFTMENT. All rights reserved.

import UIKit

class SearchViewController: UIViewController {
    @IBOutlet var showAll: UILabel!
    @IBOutlet var searchBtn: UIView!
    @IBOutlet var searchTF: UITextField!
    @IBOutlet var postContainer: UIView!
    @IBOutlet var userContainer: UIView!
    var postResultsVC: PostSearchResultsViewController?
    var userResultsVC: UserSearchResultsViewController?

    var allPosts = [PostModel]()
    var userModels = [UserModel]()

    override func viewDidLoad() {
        setupViews()
        loadInitialData()
    }

    private func setupViews() {
        searchTF.delegate = self

        searchBtn.isUserInteractionEnabled = true
        searchBtn.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.searchBtnClicked)
        ))
        searchBtn.layer.cornerRadius = 8

        showAll.isUserInteractionEnabled = true
        showAll.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.showAllClicked)))

        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UISegmentedControl.appearance().setTitleTextAttributes(titleTextAttributes, for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes(titleTextAttributes, for: .normal)
    }

    private func loadInitialData() {
        ProgressHUDShow(text: "")
        getLatest100Posts { posts, error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error)
            } else {
                self.allPosts = posts ?? []
                self.postResultsVC?.notifyAdapter(postModels: self.allPosts)
            }
        }
        getLastest100Users { userModels, error in
            if let error = error {
                self.showError(error)
            } else {
                self.userModels = userModels ?? []
                self.userResultsVC?.notifyAdapter(userModels: self.userModels)
            }
        }
    }

    @objc func showAllClicked() {
        searchTF.text = ""
        postResultsVC?.notifyAdapter(postModels: allPosts)
        userResultsVC?.notifyAdapter(userModels: userModels)
    }

    @objc func searchBtnClicked() {
        guard let searchText = searchTF.text?.trimmingCharacters(in: .whitespacesAndNewlines), !searchText.isEmpty else {
            showAllClicked()
            return
        }
        searchStart(searchText: searchText)
    }

     func searchStart(searchText: String) {
        ProgressHUDShow(text: "Searching...".localized())
        algoliaSearch(searchText: searchText, indexName: .posts, filters: "postType:video OR postType:image") { models in
            DispatchQueue.main.async {
                self.ProgressHUDHide()
                self.postResultsVC?.notifyAdapter(postModels: models as? [PostModel] ?? [])
                self.searchTF.text = searchText
            }
        }

        algoliaSearch(searchText: searchText, indexName: .users, filters: "isAccountActive:true") { models in
            DispatchQueue.main.async {
                self.userResultsVC?.notifyAdapter(userModels: models as? [UserModel] ?? [])
            }
        }
    }

    @IBAction func segmentClicked(_ sender: UISegmentedControl) {
        postContainer.isHidden = sender.selectedSegmentIndex != 0
        userContainer.isHidden = sender.selectedSegmentIndex == 0
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let postVC = segue.destination as? PostSearchResultsViewController {
            self.postResultsVC = postVC
        } else if let userVC = segue.destination as? UserSearchResultsViewController {
            self.userResultsVC = userVC
        }
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchTF {
            searchBtnClicked()
        }
        return true
    }
}
