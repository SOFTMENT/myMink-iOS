//
//  EventHomeViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 27/01/24.
//

import UIKit

class EventHomeViewController: UIViewController {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var createEventBtn: UIButton!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var noEventsAvailable: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBtn: UIView!
    
    var eventModels = [Event]()
    var useEventModels = [Event]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        fetchAllEvents()
    }
    
    private func setupUI() {
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
    }
    @objc func shareEventClicked(value : MyGesture) {
        if let shareURL = useEventModels[value.index].eventURL, !shareURL.isEmpty {
            let items: [Any] = [shareURL]
            let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
            if let popoverController = activityViewController.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
            self.present(activityViewController, animated: true)
        } else {
            self.showSnack(messages: "Share URL not found.")
        }
    }
    private func fetchAllEvents() {
        ProgressHUDShow(text: "")
        
        getAllEvents(countryCode: getCountryCode()) { [weak self] events, error in
            guard let self = self else { return }
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error)
            } else {
                self.eventModels = events ?? []
                self.useEventModels = self.eventModels
                self.tableView.reloadData()
            }
        }
    }
    
    @objc private func searchBtnClicked() {
        if let searchText = searchTF.text, !searchText.isEmpty {
            searchEvents(searchText: searchText)
        }
    }
    
    private func searchEvents(searchText: String) {
        ProgressHUDShow(text: "Searching...")
        algoliaSearch(searchText: searchText, indexName: .events, filters: "isActive:true AND countryCode:\(getCountryCode())") { [weak self] models in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.ProgressHUDHide()
                self.useEventModels = models as? [Event] ?? []
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction private func createEventClicked(_ sender: Any) {
        performSegue(withIdentifier: "organizerSeg", sender: nil)
    }
    
    @objc private func backBtnClicked() {
        dismiss(animated: true)
    }
    
  
    
    @objc private func eventClicked(value: MyGesture) {
        let eventModel = useEventModels[value.index]
        performSegue(withIdentifier: "showEventSeg", sender: eventModel)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEventSeg", let VC = segue.destination as? ShowEventViewController, let eventModel = sender as? Event {
            VC.event = eventModel
        }
    }
}

extension EventHomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noEventsAvailable.isHidden = !useEventModels.isEmpty
        return useEventModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "eventviewcell", for: indexPath) as? EventTableViewCell else {
            return EventTableViewCell()
        }
        
        cell.eventShare.isUserInteractionEnabled = true
        let gest = MyGesture(target: self, action: #selector(self.shareEventClicked))
        gest.index = indexPath.row
        cell.eventShare.addGestureRecognizer(gest)
        
        let event = useEventModels[indexPath.row]
        
        cell.eventView.layer.cornerRadius = 12
        cell.eventView.dropShadow()
        cell.eventImage.layer.cornerRadius = 8
        
        cell.eventView.isUserInteractionEnabled = true
        let mGest = MyGesture(target: self, action: #selector(eventClicked(value:)))
        mGest.index = indexPath.row
        cell.eventView.addGestureRecognizer(mGest)
        
        if let image = event.eventImage1, !image.isEmpty {
            cell.eventImage.setImage(imageKey: image, placeholder: "placeholder", width: 120, height: 120, shouldShowAnimationPlaceholder: true)
        }
        
       
        
        cell.eventDate.text = convertDateForEvent(event.eventStartDate ?? Date())
        cell.eventTitle.text = event.eventTitle ?? "Something Went Wrong"
        cell.eventType.text = event.address
        
        return cell
    }
}

extension EventHomeViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        if updatedText.isEmpty {
            useEventModels = eventModels
            tableView.reloadData()
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchTF {
            if let searchText = textField.text, !searchText.isEmpty {
                searchEvents(searchText: searchText)
            } else {
                useEventModels = eventModels
                tableView.reloadData()
            }
        }
        return true
    }
}
