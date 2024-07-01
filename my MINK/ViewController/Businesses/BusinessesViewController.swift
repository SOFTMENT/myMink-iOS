//
//  BusinessesViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 05/06/24.
//

import UIKit

class BusinessesViewController : UIViewController {
    
    @IBOutlet weak var myBusinessBtn: UIButton!
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var no_business_available: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBtn: UIView!
    var businessModels = Array<BusinessModel>()
    var useBusinessModels = Array<BusinessModel>()
    override func viewDidLoad() {
        
        myBusinessBtn.layer.cornerRadius = 8
        
        searchTF.delegate = self
        
        backView.layer.cornerRadius = 8
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        
        searchBtn.layer.cornerRadius = 8
        searchBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(searchBtnClicked)))
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        
        backView.dropShadow()
        
        ProgressHUDShow(text: "")
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadBusinesses()
    }
    
    func loadBusinesses(){
        
        self.getAllBusinesses { businesses, error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error)
            }
            else {
                
                self.businessModels.removeAll()
                self.useBusinessModels.removeAll()
                
                self.useBusinessModels.append(contentsOf: businesses ?? [])
                self.businessModels.append(contentsOf: businesses ?? [])
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func businessBtnClicked(_ sender: Any) {
        self.ProgressHUDShow(text: "")
        
        self.getBusinessesBy(FirebaseStoreManager.auth.currentUser!.uid) { businessModel, error in
            self.ProgressHUDHide()
            if let businessModel = businessModel {
                self.performSegue(withIdentifier: "showBusinessProfile", sender: businessModel)
            }
            else {
                self.performSegue(withIdentifier: "addBusinessSeg", sender: nil)
            }
        }
        
    }
    
    @objc func searchBtnClicked(){
        if let searchText = searchTF.text, !searchText.isEmpty {
            self.searchEvents(searchText: searchText)
        }
    }
    
    func searchEvents(searchText : String){
        ProgressHUDShow(text: "Searching...")
        algoliaSearch(searchText: searchText, indexName: .POSTS, filters: "isActive:true") { models in
            
            DispatchQueue.main.async {
                self.ProgressHUDHide()
                
                self.useBusinessModels.removeAll()
                self.useBusinessModels.append(contentsOf: models as? [BusinessModel] ?? [])
                self.tableView.reloadData()
                
            }
            
            
        }
    }
    
    
    
    @objc func backBtnClicked(){
        self.dismiss(animated: true)
    }
    @objc func shareBusinessBtnClicked(myGes : MyGesture){
        let businessModel = self.businessModels[myGes.index]
        
        if let shareURL = businessModel.shareLink, !shareURL.isEmpty {
            self.shareImageAndVideo(postCell: nil, link: shareURL, postId: nil)
        }
        
    }
    
    @objc func businessClicked(value : MyGesture){
        let businessModel = useBusinessModels[value.index]
        performSegue(withIdentifier: "showBusinessProfile", sender: businessModel)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBusinessProfile" {
            if let VC = segue.destination as? ShowBusinessProfileViewController {
                if let eventModel = sender as? BusinessModel {
                    VC.businessModel = eventModel
                }
            }
        }
        if segue.identifier == "addBusinessSeg" {
            if let VC = segue.destination as? AddBusinessProfileViewController {
                VC.delegate = self
            }
        }
        
    }
}

extension BusinessesViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.no_business_available.isHidden = useBusinessModels.count > 0 ? true : false
        return useBusinessModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "businessCell", for: indexPath) as? BusinessTableViewCell {
            
            let businessModel = self.useBusinessModels[indexPath.row]
            
            cell.mView.layer.cornerRadius  = 12
            cell.mView.dropShadow()
            cell.mImage.layer.cornerRadius = 8
            
            cell.mView.isUserInteractionEnabled = true
            let mGest = MyGesture(target: self, action: #selector(businessClicked(value: )))
            mGest.index = indexPath.row
            cell.mView.addGestureRecognizer(mGest)
            
            if let image = businessModel.profilePicture, !image.isEmpty {
                cell.mImage.setImage(imageKey: image, placeholder: "profile-placeholder",width: 100, height: 100,shouldShowAnimationPlaceholder: true)
            }
            
            
            //Share Event
            cell.mShare.isUserInteractionEnabled = true
            let myGes = MyGesture(target: self, action: #selector(shareBusinessBtnClicked(myGes:)))
            myGes.index = indexPath.row
            cell.mShare.addGestureRecognizer(myGes)
            
            cell.mName.text = businessModel.name ?? ""
            cell.mWebsite.text = businessModel.website ?? ""
            cell.mCategory.text = businessModel.businessCategory ?? ""
            
            
            
            return cell
        }
        
        return BusinessTableViewCell()
        
    }
    
}
extension BusinessesViewController : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Get the current text, assuming it is a Swift string
        let currentText = textField.text ?? ""
        
        // Calculate the new text string after the change
        guard let stringRange = Range(range, in: currentText) else {
            return false
        }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        // Check if the updated text is empty
        if updatedText.isEmpty {
            self.useBusinessModels.removeAll()
            self.useBusinessModels.append(contentsOf: self.businessModels)
            self.tableView.reloadData()
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchTF {
            if let searchText = textField.text, !searchText.isEmpty {
                self.searchEvents(searchText: searchText)
            }
            else {
                self.useBusinessModels.removeAll()
                self.useBusinessModels.append(contentsOf: self.businessModels)
                self.tableView.reloadData()
            }
            
        }
        return true
    }
}

extension BusinessesViewController : ReloadTableViewDelegate {
    func reloadTableView() {
        loadBusinesses()
    }
    
}
