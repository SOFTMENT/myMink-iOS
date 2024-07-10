//
//  AddTicketsViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 19/05/24.
//


import UIKit
import Firebase
import FirebaseFirestoreSwift


class AddTicketsViewController: UIViewController {
    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var paid: UIButton!
    @IBOutlet weak var free: UIButton!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var nameCounter: UILabel!
    @IBOutlet weak var availableQuantity: UITextField!
    @IBOutlet weak var price: UITextField!
   
    
    @IBOutlet weak var salesStart: UITextField!
    @IBOutlet weak var startTime: UITextField!
    @IBOutlet weak var salesEnd: UITextField!
    @IBOutlet weak var endTime: UITextField!
    @IBOutlet weak var discard: UILabel!
    var isFree = false
    var event : Event?
    
    let salesStartDatePicker = UIDatePicker()
    let salesEndDatePicker = UIDatePicker()
    let salesStartTimePicker = UIDatePicker()
    let salesEndTimePicker = UIDatePicker()
    
    
    @IBOutlet weak var publishTicketBtn: UIButton!
    
    
    
    override func viewDidLoad() {
        

        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        paid.layer.cornerRadius = 8
        free.layer.cornerRadius = 8
        
        paid.layer.borderWidth = 1
        free.layer.borderWidth = 1
        
        paid.backgroundColor = UIColor.init(red: 210/255, green: 0/255, blue: 1/255, alpha: 0.1)
        
        paid.setTitleColor(UIColor.init(red: 210/255, green: 0/255, blue: 1/255, alpha: 1), for: .normal)
        
        paid.layer.borderColor = UIColor.init(red: 210/255, green: 0/255, blue: 1/255, alpha: 1).cgColor
        
        free.backgroundColor = .clear
        
        free.setTitleColor(UIColor.init(red: 85/255, green: 85/255, blue: 85/255, alpha: 1), for: .normal)
        
        free.layer.borderColor = UIColor.init(red: 85/255, green: 85/255, blue: 85/255, alpha: 1).cgColor
        
        name.layer.cornerRadius = 8
        name.delegate = self
        
        availableQuantity.layer.cornerRadius = 8
        availableQuantity.delegate = self
        
        price.layer.cornerRadius = 8
        price.delegate = self
        
      
        
        salesStart.layer.cornerRadius = 8
        salesStart.delegate = self
        
        startTime.layer.cornerRadius = 8
        startTime.delegate = self
        
        salesEnd.layer.cornerRadius = 8
        salesEnd.delegate = self
        
        endTime.layer.cornerRadius = 9
        endTime.delegate = self
        
      
        publishTicketBtn.layer.cornerRadius = 8
        
        discard.isUserInteractionEnabled = true
        discard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(discardBtnClicked)))
        
        createSalesStartDatePicker()
        createSalesEndDatePicker()
        createSalesStartTimePicker()
        createSalesEndTimePicker()
    
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
      
      
        
        
    }
    
    @objc func backViewClicked(){
        self.dismiss(animated: true)
    }
    
    
    @objc func showViewDetailsPopup(){
        let mPrice = price.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let mPrice = mPrice, mPrice != "" {
            performSegue(withIdentifier: "showpopupseg", sender: mPrice)
        }
       
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showpopupseg" {
            if let vc = segue.destination as? RevenuePopupViewController {
                if let mPrice = sender as? String {
                    vc.mPrice = Int(mPrice)
                }
            }
        }
    }
    
    
  
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    
    func createSalesStartDatePicker() {
        if #available(iOS 13.4, *) {
            salesStartDatePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
          
        }
        
      
        
      
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(salesStartDateDoneBtnTapped))
        toolbar.setItems([done], animated: true)
      
        salesStart.inputAccessoryView = toolbar

        salesStartDatePicker.datePickerMode = .date
        salesStartDatePicker.minimumDate = Date()
        salesStart.inputView = salesStartDatePicker
    }
    
    @objc func salesStartDateDoneBtnTapped() {
        view.endEditing(true)
        let date = salesStartDatePicker.date
        salesStart.text = convertDateFormater(date)
    }
    
  func createSalesEndDatePicker() {
        if #available(iOS 13.4, *) {
            salesEndDatePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
  
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(salesEndDateDoneBtnTapped))
        toolbar.setItems([done], animated: true)
      
        salesEnd.inputAccessoryView = toolbar

        salesEndDatePicker.datePickerMode = .date
        salesEndDatePicker.minimumDate = Date()
        salesEnd.inputView = salesEndDatePicker
    }
    
    @objc func salesEndDateDoneBtnTapped() {
        view.endEditing(true)
        let date = salesEndDatePicker.date
        salesEnd.text = convertDateFormater(date)
    }
    
    
    func createSalesStartTimePicker() {
        if #available(iOS 13.4, *) {
            salesStartTimePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
      
        
      
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(salesStartTimeDoneBtnTapped))
        toolbar.setItems([done], animated: true)
      
        startTime.inputAccessoryView = toolbar

        salesStartTimePicker.datePickerMode = .time
        startTime.inputView = salesStartTimePicker
    }
    
    @objc func salesStartTimeDoneBtnTapped() {
        view.endEditing(true)
        let date = salesStartTimePicker.date
        startTime.text = convertTimeFormater(date)
    }
    
    
    
    func createSalesEndTimePicker() {
        if #available(iOS 13.4, *) {
            salesEndTimePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
  
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(salesEndTimeDoneBtnTapped))
        toolbar.setItems([done], animated: true)
      
        endTime.inputAccessoryView = toolbar

        salesEndTimePicker.datePickerMode = .time
        endTime.inputView = salesEndTimePicker
    }
    
    @objc func salesEndTimeDoneBtnTapped() {
        view.endEditing(true)
        let date = salesEndTimePicker.date
        endTime.text = convertTimeFormater(date)
    }
    
    @objc func discardBtnClicked(){
        self.beRootScreen(storyBoardName: StoryBoard.Event, mIdentifier: Identifier.ORGANIZERDASHBOARDCONTROLLER)
    }
    
    @IBAction func backBtnClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func paidBtnClicked(_ sender: Any) {
       
        price.text = ""
        price.isEnabled = true
        
        isFree = false
        paid.backgroundColor = UIColor.init(red: 210/255, green: 0/255, blue: 1/255, alpha: 0.1)
        
        paid.setTitleColor(UIColor.init(red: 210/255, green: 0/255, blue: 1/255, alpha: 1), for: .normal)
        
        paid.layer.borderColor = UIColor.init(red: 210/255, green: 0/255, blue: 1/255, alpha: 1).cgColor
        
        free.backgroundColor = .clear
        
        free.setTitleColor(UIColor.init(red: 85/255, green: 85/255, blue: 85/255, alpha: 1), for: .normal)
        
        free.layer.borderColor = UIColor.init(red: 85/255, green: 85/255, blue: 85/255, alpha: 1).cgColor
    }
    
    @IBAction func freeBtnClicked(_ sender: Any) {
        
        price.text = "Free"
        price.isEnabled = false
        
        isFree = true
        free.backgroundColor = UIColor.init(red: 210/255, green: 0/255, blue: 1/255, alpha: 0.1)
        
        free.setTitleColor(UIColor.init(red: 210/255, green: 0/255, blue: 1/255, alpha: 1), for: .normal)
        
        free.layer.borderColor = UIColor.init(red: 210/255, green: 0/255, blue: 1/255, alpha: 1).cgColor
        
        paid.backgroundColor = .clear
        
        paid.setTitleColor(UIColor.init(red: 85/255, green: 85/255, blue: 85/255, alpha: 1), for: .normal)
        
        paid.layer.borderColor = UIColor.init(red: 85/255, green: 85/255, blue: 85/255, alpha: 1).cgColor
    }
    
    
    @IBAction func publishTicketBtnClicked(_ sender: Any) {
        let sName = name.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let sQuantity = availableQuantity.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let sPrice = price.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
       
        
        let sStartDate = salesStart.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let sStartTime = startTime.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let sEndDate = salesEnd.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let sEndTime = endTime.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if sName == "" {
            self.showSnack(messages: "Enter Name")
        }
        else if sQuantity == "" {
            self.showSnack(messages: "Enter Available Quantity")
        }

        else if !isFree && sPrice == "" {
            
            self.showSnack(messages: "Enter Price")
            
        }
        else if Int(sQuantity ?? "0")! <= 0{
            self.showSnack(messages: "Enter Quanity more than 0")
        }
        else if !isFree && Int(sPrice ?? "0")! <= 0{
            self.showSnack(messages: "Enter price more than US$ 0")
        }
        else if sStartDate == "" {
            self.showSnack(messages: "Select Start Date")
        }
        else if sStartTime == "" {
            self.showSnack(messages: "Select Start Time")
        }
        else if sEndDate == "" {
            self.showSnack(messages: "Select End Date")
        }
        else if sEndTime == "" {
            self.showSnack(messages: "Select End Time")
        }
        
        else {
            event!.isFree = isFree
            event!.ticketName = sName
            event!.ticketQuantity = Int(sQuantity ?? "1")
            event!.ticketPrice = Int(sPrice ?? "1")
            event!.isActive = true
            

            var startDate = salesStartDatePicker.date
            var endDate =   salesEndDatePicker.date
            
            let startTime = salesStartTimePicker.date
            let endTime = salesEndTimePicker.date
          
            let shour = Calendar.current.component(.hour, from: startTime)
            let smin = Calendar.current.component(.minute, from: startTime)
            
            startDate = startDate.setTime(hour: shour, min: smin) ?? Date()
            
            let ehour = Calendar.current.component(.hour, from: endTime)
            let emin = Calendar.current.component(.minute, from: endTime)
            
            endDate = endDate.setTime(hour: ehour, min: emin) ?? Date()
            
            
            event!.eventCreateDate = Date()
            self.ProgressHUDShow(text: "Publishing...")
            
            let batch = FirebaseStoreManager.db.batch()
            
         
                let docucmentRef =  FirebaseStoreManager.db.collection(Collections.EVENTS.rawValue).document()
                do {
                   
            
                    try batch.setData(from: event, forDocument:  docucmentRef)
                }
                catch {
                    self.ProgressHUDHide()
                    self.showError(error.localizedDescription)
                }
                
          
            
            batch.commit { error in
                
                self.ProgressHUDHide()
                if error == nil {
                    
                    let alert = UIAlertController(title: "Published", message: "Congrats! Your event has published", preferredStyle: .alert)
                    
                    let okAction = UIAlertAction(title: "Ok",style: .default) { action in
                        self.beRootScreen(storyBoardName: StoryBoard.Event, mIdentifier: Identifier.ORGANIZERDASHBOARDCONTROLLER)
                    }
                    
                    
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
                else {
                    self.showError(error!.localizedDescription)
                    
                }
            }
            
            
        }
       
        
    }
    
}

extension AddTicketsViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if salesStart == textField || textField == startTime || textField == salesEnd || textField == endTime
            {
            return false
        }
        if textField == name {
            let maxLength = 50
            let currentString: NSString = (textField.text ?? "") as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
          
            if newString.length <= maxLength {
                nameCounter.text = "\(newString.length) / \(maxLength)"
            }
           
            return newString.length <= maxLength
        }
       
        return true
        
    }
}
