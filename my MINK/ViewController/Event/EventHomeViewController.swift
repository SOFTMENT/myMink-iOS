//
//  EventHomeViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 27/01/24.
//

import UIKit

class EventHomeViewController : UIViewController {
    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var createEventBtn: UIButton!
    
    @IBOutlet weak var searchTF: UITextField!
    
    @IBOutlet weak var noEventsAvailable: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBtn: UIView!
    var eventModels = Array<Event>()
    var useEventModels = Array<Event>()
    override func viewDidLoad() {
    
        
        searchTF.delegate = self
        
        backView.layer.cornerRadius = 8
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        createEventBtn.layer.cornerRadius = 6
        
        searchBtn.layer.cornerRadius = 8
        searchBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(searchBtnClicked)))
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        
        backView.dropShadow()
      
        
      
       ProgressHUDShow(text: "")
        self.getAllEvents { events, error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error)
            }
            else {
               
                self.eventModels.removeAll()
                self.useEventModels.removeAll()
                
                self.useEventModels.append(contentsOf: events ?? [])
                self.eventModels.append(contentsOf: events ?? [])
                self.tableView.reloadData()
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
        algoliaSearch(searchText: searchText, indexName: .POSTS, filters: "isActive:true OR countryCode:\(getCountryCode())") { models in
            
            DispatchQueue.main.async {
                self.ProgressHUDHide()
                
                self.useEventModels.removeAll()
                self.useEventModels.append(contentsOf: models as? [Event] ?? [])
                self.tableView.reloadData()
                
            }
            
            
        }
    }
   
    @IBAction func createEventClicked(_ sender: Any) {
        performSegue(withIdentifier: "organizerSeg", sender: nil)
    }
    
    @objc func backBtnClicked(){
        self.dismiss(animated: true)
    }
    @objc func shareEventBtnClicked(myGes : MyGesture){
     
    }
    
    @objc func eventClicked(value : MyGesture){
        let eventModel = useEventModels[value.index]
        performSegue(withIdentifier: "showEventSeg", sender: eventModel)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEventSeg" {
            if let VC = segue.destination as? ShowEventViewController {
                if let eventModel = sender as? Event {
                    VC.event = eventModel
                }
            }
        }
    }
}

extension EventHomeViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.noEventsAvailable.isHidden = useEventModels.count > 0 ? true : false
        return useEventModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "eventviewcell", for: indexPath) as? EventTableViewCell {
            
            let event = self.useEventModels[indexPath.row]
            
            cell.eventView.layer.cornerRadius  = 12
            cell.eventView.dropShadow()
            cell.eventImage.layer.cornerRadius = 8
            
            cell.eventView.isUserInteractionEnabled = true
            let mGest = MyGesture(target: self, action: #selector(eventClicked(value: )))
            mGest.index = indexPath.row
            cell.eventView.addGestureRecognizer(mGest)
         
            if let image = event.eventImage1, !image.isEmpty {
                cell.eventImage.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: "placeholder"), options: .continueInBackground, completed: nil)
            }
            
            
            //Share Event
            cell.eventShare.isUserInteractionEnabled = true
            let myGes = MyGesture(target: self, action: #selector(shareEventBtnClicked(myGes:)))
            myGes.index = indexPath.row
            cell.eventShare.addGestureRecognizer(myGes)
            
            cell.eventDate.text = self.convertDateForEvent(event.eventStartDate ?? Date())
            cell.eventTitle.text = event.eventTitle ?? "Something Went Wrong"
          
                if let address = event.addressName {
                    cell.eventType.text = address
                }
       
            

            return cell
        }
        
        return EventTableViewCell()
    
    }
    
}
extension EventHomeViewController : UITextFieldDelegate {
    
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
            self.useEventModels.removeAll()
            self.useEventModels.append(contentsOf: self.eventModels)
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
                    self.useEventModels.removeAll()
                    self.useEventModels.append(contentsOf: self.eventModels)
                    self.tableView.reloadData()
                }
               
            }
            return true
        }
}
