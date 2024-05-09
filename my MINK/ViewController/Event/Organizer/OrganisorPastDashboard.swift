//
//  OrganisorPastDashboard.swift
//  my MINK
//
//  Created by Vijay Rathore on 19/05/24.
//

import UIKit

class OrganisorPastDashboard: UIViewController {
    
    @IBOutlet weak var no_past_events_available: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var pastEvents : [Event] = []
    override func viewDidLoad() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 4
    }
    public func notifyAdapter(){
        pastEvents.removeAll()
        pastEvents = Event.datas.filter { event in
            if event.eventStartDate! < Date() {
                return true
            }
            return false
        }
        
        self.tableView.reloadData()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "vieweventdetailsseg" {
            if let vc = segue.destination as? OrganizerViewEventDetails {
                if let event = sender as? Event {
                    vc.event = event
                }
            }
        }
    }
}



extension OrganisorPastDashboard: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if pastEvents.count > 0 {
            no_past_events_available.isHidden = true
        }
        else {
            no_past_events_available.isHidden = false
        }
        return pastEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "organisorticketcell", for: indexPath) as? DashboardTicketTableViewCell {
            
            let event = self.pastEvents[indexPath.row]
            
            cell.priceView.layer.cornerRadius = 12
            cell.priceView.layer.borderColor = UIColor.lightGray.cgColor
            cell.priceView.layer.borderWidth = 1
            cell.soldView.layer.cornerRadius = 12
            cell.soldView.layer.borderColor = UIColor.lightGray.cgColor
            cell.soldView.layer.borderWidth = 1
            cell.totalView.layer.cornerRadius = 12
            cell.totalView.layer.borderColor = UIColor.lightGray.cgColor
            cell.totalView.layer.borderWidth = 1
            cell.progressView.layer.cornerRadius = 12
            cell.progressView.layer.borderColor = UIColor.lightGray.cgColor
            
            cell.progressBar.layer.cornerRadius = 16
            
            cell.progressView.layer.borderWidth = 1
            cell.mView.layer.cornerRadius = 12
            cell.mView.dropShadow()
            cell.event_image.layer.cornerRadius = 8
            
            if let image = event.eventImage1 {
                if image != "" {
                    cell.event_image.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: "placeholder"), options: .continueInBackground, completed: nil)
                }
            }
            
            cell.eventDate.text = self.convertDateForEvent(event.eventStartDate ?? Date())
            cell.eventTitle.text = event.eventTitle ?? ""
            cell.eventLocation.text = event.address ?? ""
            if let isFree = event.isFree, isFree {
                cell.price.text = "Free"
            }
            else {
                cell.price.text = "\(event.ticketPrice!)$"
            }
            
            let ticketSold = event.eventTicketSold ?? 0
            let ticketTotal = event.ticketQuantity ?? 0
            
            cell.sold.text = String(ticketSold)
            cell.total.text = String(ticketTotal)
            cell.progressBar.progress = Float(ticketSold) / Float(ticketTotal)
            
            
            
            return cell
        }
        
        return DashboardTicketTableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "vieweventdetailsseg", sender: pastEvents[indexPath.row])
    }
    
}

