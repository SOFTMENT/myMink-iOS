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
    var pastEvents: [Event] = []

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
        pastEvents = Event.datas.filter { $0.eventEndDate ?? Date() < Date() }
        tableView.reloadData()
        no_past_events_available.isHidden = !pastEvents.isEmpty
    }
}

extension OrganisorPastDashboard: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pastEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "organisorticketcell", for: indexPath) as? DashboardTicketTableViewCell else {
            return DashboardTicketTableViewCell()
        }
        
        let event = pastEvents[indexPath.row]
        configureCell(cell, with: event)
        
        return cell
    }

    private func configureCell(_ cell: DashboardTicketTableViewCell, with event: Event) {
        cell.mView.layer.cornerRadius = 12
        cell.mView.dropShadow()
        cell.event_image.layer.cornerRadius = 8
        
        if let image = event.eventImage1, !image.isEmpty {
            cell.event_image.setImage(imageKey: image, placeholder: "placeholder", width: 400, height: 300, shouldShowAnimationPlaceholder: true)
        }
        
        cell.eventDate.text = convertDateForEvent(event.eventStartDate ?? Date())
        cell.eventTitle.text = event.eventTitle ?? ""
        cell.eventLocation.text = event.address ?? ""
    }
}
