//
//  OrganisorUpcomingDashboard.swift
//  my MINK
//
//  Created by Vijay Rathore on 19/05/24.
//

import UIKit

class OrganisorUpcomingDashboard: UIViewController {
    
    @IBOutlet weak var no_coming_events_available: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var upcomingEvents : [Event] = []
    override func viewDidLoad() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 4
        
    }
    public func notifyAdapter(){
        upcomingEvents.removeAll()
        upcomingEvents = Event.datas.filter { event in
            if event.eventStartDate! >= Date() {
                
                return true
            }
            return false
        }
        
        self.tableView.reloadData()

    }
    
}

extension OrganisorUpcomingDashboard: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if upcomingEvents.count > 0 {
            no_coming_events_available.isHidden = true
        }
        else {
            no_coming_events_available.isHidden = false
        }
       return upcomingEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "organisorticketcell", for: indexPath) as? DashboardTicketTableViewCell{
            
            let event = self.upcomingEvents[indexPath.row]
            
            var uiMenuElement = [UIMenuElement]()
            let delete = UIAction(
                title: "Delete",
                image: UIImage(systemName: "trash.fill")
            ) { _ in
              
                self.ProgressHUDShow(text: "Deleting...")
                self.deleteEvent(eventId: event.eventId ?? "123") { error in
                    self.ProgressHUDHide()
                    self.showSnack(messages: "Event Deleted")
                    self.upcomingEvents.remove(event)
                    self.tableView.reloadData()
                }
            }
          
            uiMenuElement.append(delete)
            cell.moreBtn.isUserInteractionEnabled = true
            cell.moreBtn.showsMenuAsPrimaryAction = true

            cell.moreBtn.menu = UIMenu(title: "", children: uiMenuElement)
            
    
            cell.mView.layer.cornerRadius = 12
            cell.mView.dropShadow()
            cell.event_image.layer.cornerRadius = 8
            
            if let image = event.eventImage1, !image.isEmpty {
               
                cell.event_image.setImage(imageKey: image, placeholder: "placeholder",width: 400,height: 300,shouldShowAnimationPlaceholder: true)
                
            }
            
            cell.eventDate.text = self.convertDateForEvent(event.eventStartDate ?? Date())
            cell.eventTitle.text = event.eventTitle ?? ""
            cell.eventLocation.text = event.address ?? ""
           
        
            
            return cell
        }
        
        return DashboardTicketTableViewCell()
    }
    
    
    
    
}
