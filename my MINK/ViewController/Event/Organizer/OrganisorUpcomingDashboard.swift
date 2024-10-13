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
    var upcomingEvents: [Event] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 4
    }

    public func notifyAdapter() {
        upcomingEvents = Event.datas.filter { $0.eventEndDate ?? Date() >= Date() }
        tableView.reloadData()
        no_coming_events_available.isHidden = !upcomingEvents.isEmpty
    }
    
    @objc func cellClicked(value : MyGesture){
        performSegue(withIdentifier: "updateEventSeg", sender: upcomingEvents[value.index])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "updateEventSeg" {
            if let VC = segue.destination as? UpdateEventBasicViewController {
                if let event = sender as? Event {
                    VC.event = event
                }
            }
        }
    }
}

extension OrganisorUpcomingDashboard: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return upcomingEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "organisorticketcell", for: indexPath) as? DashboardTicketTableViewCell else {
            return DashboardTicketTableViewCell()
        }
        
        let event = upcomingEvents[indexPath.row]
        configureCell(cell, indexPath: indexPath, with: event)
        
        return cell
    }

    private func configureCell(_ cell: DashboardTicketTableViewCell, indexPath : IndexPath, with event: Event) {
        cell.moreBtn.isUserInteractionEnabled = true
        cell.moreBtn.showsMenuAsPrimaryAction = true
        cell.moreBtn.menu = createContextMenu(for: event)
        
        cell.mView.layer.cornerRadius = 12
        cell.mView.dropShadow()
        cell.event_image.layer.cornerRadius = 8
        
        let myGest = MyGesture(target: self, action: #selector(cellClicked))
        myGest.index = indexPath.row
        cell.mView.isUserInteractionEnabled = true
        cell.mView.addGestureRecognizer(myGest)
        
        if let image = event.eventImage1, !image.isEmpty {
            cell.event_image.setImage(imageKey: image, placeholder: "placeholder", width: 400, height: 300, shouldShowAnimationPlaceholder: true)
        }
        
        cell.eventDate.text = convertDateForEvent(event.eventStartDate ?? Date())
        cell.eventTitle.text = event.eventTitle ?? ""
        cell.eventLocation.text = event.address ?? ""
    }

    private func createContextMenu(for event: Event) -> UIMenu {
        let deleteAction = UIAction(title: "Delete".localized(), image: UIImage(systemName: "trash.fill")) { _ in
            self.ProgressHUDShow(text: "Deleting...".localized())
            self.deleteEvent(eventId: event.eventId ?? "123") { error in
                self.ProgressHUDHide()
                if error == nil {
                    self.showSnack(messages: "Event Deleted".localized())
                    self.upcomingEvents.removeAll { $0.eventId == event.eventId }
                    self.tableView.reloadData()
                    self.no_coming_events_available.isHidden = !self.upcomingEvents.isEmpty
                }
            }
        }
        return UIMenu(title: "", children: [deleteAction])
    }
}
