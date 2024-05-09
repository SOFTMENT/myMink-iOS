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
      

        
        searchTF.delegate = self
        
        self.searchBtn.isUserInteractionEnabled = true
        self.searchBtn.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.searchBtnClicked)
        ))
        self.searchBtn.layer.cornerRadius = 8

        self.showAll.isUserInteractionEnabled = true
        self.showAll.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.showAllClicked)))

        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UISegmentedControl.appearance().setTitleTextAttributes(titleTextAttributes, for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes(titleTextAttributes, for: .normal)

        ProgressHUDShow(text: "")
        getLatest100Posts { posts, error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error)
            } else {
                self.allPosts.removeAll()
                self.allPosts.append(contentsOf: posts ?? [])
                self.postResultsVC?.notifyAdapter(postModels: self.allPosts)
            }
        }
        getLastest100Users { userModels, error in
            if let error = error {
                self.showError(error)
            } else {
                self.userModels.removeAll()
                self.userModels.append(contentsOf: userModels ?? [])
                self.userResultsVC?.notifyAdapter(userModels: self.userModels)
            }
        }
    }

    @objc func showAllClicked() {
        self.searchTF.text = ""
        self.postResultsVC?.notifyAdapter(postModels: self.allPosts)
        self.userResultsVC?.notifyAdapter(userModels: self.userModels)
    }

    @objc func searchBtnClicked() {
        let searchText = self.searchTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if searchText != "" {
            self.searchStart(searchText: searchText!)
        } else {
            self.showAllClicked()
        }
    }

    func searchStart(searchText: String) {
        ProgressHUDShow(text: "Searching...")
        algoliaSearch(searchText: searchText, indexName: .POSTS, filters: "postType:video OR postType:image") { models in
            
            DispatchQueue.main.async {
                self.ProgressHUDHide()
                
              
                self.postResultsVC?.notifyAdapter(postModels: models as? [PostModel] ?? [] )
                self.searchTF.text = searchText
                
            }
            
            
        }
        
        algoliaSearch(searchText: searchText, indexName: .USERS, filters: "isAccountActive:true") { models in
            
            DispatchQueue.main.async {
                
                self.userResultsVC?.notifyAdapter(userModels: models as? [UserModel] ?? [])
                
            }
            
        }
    }

    @IBAction func segmentClicked(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.postContainer.isHidden = false
            self.userContainer.isHidden = true
        } else {
            self.postContainer.isHidden = true
            self.userContainer.isHidden = false
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if let postVC = segue.destination as? PostSearchResultsViewController {
            self.postResultsVC = postVC
        }
        if let userVC = segue.destination as? UserSearchResultsViewController {
            self.userResultsVC = userVC
        }
    }
}


extension SearchViewController : UITextFieldDelegate {
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            if textField == searchTF {
                self.searchBtnClicked()
            }
            return true
        }
}
