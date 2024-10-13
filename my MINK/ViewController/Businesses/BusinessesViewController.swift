//
//  BusinessesViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 05/06/24.
//

import UIKit

class BusinessesViewController: UIViewController {

    @IBOutlet weak var myBusinessBtn: UIButton!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var noBusinessAvailableLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBtn: UIView!
    
    var businessModels = [BusinessModel]()
    var useBusinessModels = [BusinessModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        ProgressHUDShow(text: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadBusinesses()
    }
    
    private func setupUI() {
        myBusinessBtn.layer.cornerRadius = 8
        searchTF.delegate = self
        backView.layer.cornerRadius = 8
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        searchBtn.layer.cornerRadius = 8
        searchBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(searchBtnClicked)))
        backView.dropShadow()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
    }
    
    private func loadBusinesses() {
        getAllBusinesses { businesses, error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error)
            } else {
                self.businessModels = businesses ?? []
                self.useBusinessModels = self.businessModels
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func businessBtnClicked(_ sender: Any) {
        ProgressHUDShow(text: "")
        getBusinessesBy(FirebaseStoreManager.auth.currentUser!.uid) { businessModel, error in
            self.ProgressHUDHide()
            if let businessModel = businessModel {
                self.performSegue(withIdentifier: "showBusinessProfile", sender: businessModel)
            } else {
                self.performSegue(withIdentifier: "addBusinessSeg", sender: nil)
            }
        }
    }
    
    @objc private func searchBtnClicked() {
        guard let searchText = searchTF.text, !searchText.isEmpty else { return }
        searchBusiness(searchText: searchText)
    }
    
    private func searchBusiness(searchText: String) {
        ProgressHUDShow(text: "Searching...".localized())
        algoliaSearch(searchText: searchText, indexName: .businesses, filters: "isActive:true") { models in
            DispatchQueue.main.async {
                self.ProgressHUDHide()
                self.useBusinessModels = models as? [BusinessModel] ?? []
                self.tableView.reloadData()
            }
        }
    }
    
    @objc private func backBtnClicked() {
        dismiss(animated: true)
    }
    
    @objc private func shareBusinessBtnClicked(myGesture: MyGesture) {
        let businessModel = businessModels[myGesture.index]
        if let shareURL = businessModel.shareLink, !shareURL.isEmpty {
            shareImageAndVideo(postCell: nil, link: shareURL, postId: nil)
        }
    }
    
    @objc private func businessClicked(value: MyGesture) {
        let businessModel = useBusinessModels[value.index]
        performSegue(withIdentifier: "showBusinessProfile", sender: businessModel)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBusinessProfile", let VC = segue.destination as? ShowBusinessProfileViewController, let businessModel = sender as? BusinessModel {
            VC.businessModel = businessModel
        }
        if segue.identifier == "addBusinessSeg", let VC = segue.destination as? AddBusinessProfileViewController {
            VC.delegate = self
        }
    }
}

extension BusinessesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noBusinessAvailableLabel.isHidden = useBusinessModels.count > 0
        return useBusinessModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "businessCell", for: indexPath) as? BusinessTableViewCell else {
            return BusinessTableViewCell()
        }
        
        let businessModel = useBusinessModels[indexPath.row]
        configureCell(cell, with: businessModel, at: indexPath.row)
        
        return cell
    }
    
    private func configureCell(_ cell: BusinessTableViewCell, with businessModel: BusinessModel, at index: Int) {
        cell.mView.layer.cornerRadius = 12
        cell.mView.dropShadow()
        cell.mImage.layer.cornerRadius = 8
        
        let mGest = MyGesture(target: self, action: #selector(businessClicked(value:)))
        mGest.index = index
        cell.mView.addGestureRecognizer(mGest)
        
        if let image = businessModel.profilePicture, !image.isEmpty {
            cell.mImage.setImage(imageKey: image, placeholder: "profile-placeholder", width: 100, height: 100, shouldShowAnimationPlaceholder: true)
        }
        
        cell.mShare.isUserInteractionEnabled = true
        let myGes = MyGesture(target: self, action: #selector(shareBusinessBtnClicked(myGesture:)))
        myGes.index = index
        cell.mShare.addGestureRecognizer(myGes)
        
        cell.mName.text = businessModel.name
        cell.mWebsite.text = businessModel.website
        cell.mCategory.text = businessModel.businessCategory
    }
}

extension BusinessesViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        if updatedText.isEmpty {
            useBusinessModels = businessModels
            tableView.reloadData()
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchTF {
            if let searchText = textField.text, !searchText.isEmpty {
                searchBusiness(searchText: searchText)
            } else {
                useBusinessModels = businessModels
                tableView.reloadData()
            }
        }
        return true
    }
}

extension BusinessesViewController: ReloadTableViewDelegate {
    func reloadTableView() {
        loadBusinesses()
    }
}
