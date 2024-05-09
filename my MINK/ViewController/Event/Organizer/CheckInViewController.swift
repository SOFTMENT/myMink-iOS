//
//  CheckInViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 19/05/24.
//


import UIKit

class CheckInViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var no_users_available: UILabel!
    var checkInData : [TicketModel] = []
    @IBOutlet weak var qrcodeBtn: RoundedUIView!
    
    
    override func viewDidLoad() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        
        qrcodeBtn.isUserInteractionEnabled = true
        qrcodeBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(qrCodeBtnClicked)))
        
    }
    
    @objc func qrCodeBtnClicked(){
        performSegue(withIdentifier: "scanseg", sender: nil)
    }
    
    public func notifyAdapter(checkInData : [TicketModel]){
        self.checkInData.removeAll()
        self.checkInData =  checkInData.sorted { $0.userName!.localizedCaseInsensitiveCompare($1.userName!) == ComparisonResult.orderedAscending }
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "attendeeseg" {
            if let vc = segue.destination as? AttendeeDetails {
                if let ticket = sender as? TicketModel {
                    vc.ticket = ticket
                }
            }
        }
    }
    
    
}

extension CheckInViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "checkincell", for: indexPath) as? CheckInTableViewCell {
            
            
            cell.mView.dropShadow()
            let checkIn = checkInData[indexPath.row]
            cell.greenView.isHidden = true
            if let isCheckedIn = checkIn.isCheckedIn, isCheckedIn {
                cell.greenView.isHidden = false
            }
            cell.name.text = checkIn.userName ?? "Something Went Wrong"
            cell.ticketName.text = checkIn.ticketName ?? "Something Went Wrong"
            
            return cell
        }
        
        return CheckInTableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if checkInData.count > 0 {
            no_users_available.isHidden = true
        }
        else {
            no_users_available.isHidden = false
        }
        
        return checkInData.count
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "attendeeseg", sender: checkInData[indexPath.row])
    }
    
    
}
