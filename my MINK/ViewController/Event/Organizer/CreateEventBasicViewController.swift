//
//  CreateEventBasicViewController.swift
//  my MINK
//
//  Created by Vijay Rathore on 19/05/24.
//
import UIKit
import MapKit
import Firebase
import FirebaseFirestoreSwift
import IQKeyboardManagerSwift

class CreateEventBasicViewController: UIViewController {
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var eventTitle: UITextField!
    @IBOutlet weak var eventTags: UITextField!
    @IBOutlet weak var titleCount: UILabel!
    @IBOutlet weak var venueView: UIView!
    @IBOutlet weak var searchForVenue: UITextField!
    @IBOutlet weak var singleEventView: UIView!

    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var eventStart: UITextField!
    @IBOutlet weak var eventEnd: UITextField!
    @IBOutlet weak var startTime: UITextField!
    @IBOutlet weak var endTime: UITextField!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var city: UITextField!
    @IBOutlet weak var state: UITextField!
    @IBOutlet weak var pincode: UITextField!
    @IBOutlet weak var country: UITextField!
    @IBOutlet weak var locationTableView: UITableView!
    @IBOutlet weak var locationTableViewHeight: NSLayoutConstraint!
    var places : [Place] = []
    
    let eventStartDatePicker = UIDatePicker()
    let eventEndDatePicker = UIDatePicker()
    let eventStartTimePicker = UIDatePicker()
    let eventEndTimePicker = UIDatePicker()
    
  

    var mCoordinate : CLLocationCoordinate2D?
    let countriesPicker = UIPickerView()
    var googleAddress : String = ""
    
    override func viewDidLoad() {
        
        if Auth.auth().currentUser == nil {
            self.logoutPlease()
            return
        }
        
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        eventTitle.layer.cornerRadius = 8
        
        eventTags.layer.cornerRadius = 8
        
        eventTitle.delegate = self

        eventTags.delegate = self
        
        
        
        
        
      
        countriesPicker.delegate = self
        countriesPicker.dataSource = self
        
    
     
        
        // ToolBar
        let countriestoolBar = UIToolbar()
        countriestoolBar.barStyle = .default
        countriestoolBar.isTranslucent = true
        countriestoolBar.tintColor = .link
        countriestoolBar.sizeToFit()

        // Adding Button ToolBar
        let countriesDoneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(countriesDoneClicked))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let countriesCancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(countriesCancelClicked))
        countriestoolBar.setItems([countriesCancelButton, spaceButton, countriesDoneButton], animated: false)
        countriestoolBar.isUserInteractionEnabled = true
        country.inputAccessoryView = countriestoolBar
        country.inputView = countriesPicker

        
    
        
       
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hidekeyboard)))
        
        
        searchForVenue.layer.cornerRadius = 8
        searchForVenue.delegate = self
        searchForVenue.addTarget(self, action: #selector(CreateEventBasicViewController.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        
        
        eventStart.layer.cornerRadius = 8
        startTime.layer.cornerRadius = 8
        eventEnd.layer.cornerRadius = 8
        endTime.layer.cornerRadius = 8
        
        eventStart.delegate = self
        startTime.delegate = self
        eventEnd.delegate = self
        endTime.delegate = self
        
      
        
        continueBtn.layer.cornerRadius = 8
        
        mapView.isHidden = true
        mapView.delegate = self
        
        addressView.isHidden = true
        
        address.layer.cornerRadius = 8
        city.layer.cornerRadius = 8
        state.layer.cornerRadius = 8
        pincode.layer.cornerRadius = 8
        country.layer.cornerRadius = 8
        
       
    
        
        address.delegate = self
        city.delegate = self
        state.delegate = self
        pincode.delegate = self
        country.delegate = self
        country.setRightIcons(icon: UIImage(named: "down-arrow")!)
        
        locationTableView.delegate = self
        locationTableView.dataSource = self
        locationTableView.isScrollEnabled = false
        locationTableView.contentInsetAdjustmentBehavior = .never

        self.locationTableView.rowHeight = UITableView.automaticDimension
        self.locationTableView.estimatedRowHeight = 44
        locationTableView.isHidden = true
        
        createEventStartDatePicker()
        createEventEndDatePicker()
        createEventStartTimePicker()
        createEventEndTimePicker()
      
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hidekeyboard)))
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = true
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    @objc func backViewClicked(){
        self.dismiss(animated: true)
    }
    
    @objc func countriesDoneClicked(){
       country.resignFirstResponder()
        let row = countriesPicker.selectedRow(inComponent: 0)
        country.text = Constants.allCountriesName[row]
    }
    
    @objc func countriesCancelClicked(){
        country.resignFirstResponder()
    }
    
    
    func createEventStartDatePicker() {
        if #available(iOS 13.4, *) {
            eventStartDatePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
      
        
      
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(eventStartDateDoneBtnTapped))
        toolbar.setItems([done], animated: true)
      
        eventStart.inputAccessoryView = toolbar

        eventStartDatePicker.datePickerMode = .date
        eventStartDatePicker.minimumDate = Date()
        eventStart.inputView = eventStartDatePicker
    }
    
    @objc func eventStartDateDoneBtnTapped() {
        view.endEditing(true)
        let date = eventStartDatePicker.date
        eventStart.text = convertDateFormater(date)
    }
    
    
    
    func createEventEndDatePicker() {
        if #available(iOS 13.4, *) {
            eventEndDatePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
  
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(eventEndDateDoneBtnTapped))
        toolbar.setItems([done], animated: true)
      
        eventEnd.inputAccessoryView = toolbar

        eventEndDatePicker.datePickerMode = .date
        eventEndDatePicker.minimumDate = Date()
        eventEnd.inputView = eventEndDatePicker
    }
    
    @objc func eventEndDateDoneBtnTapped() {
        view.endEditing(true)
        let date = eventEndDatePicker.date
       
        print(date)
        eventEnd.text = convertDateFormater(date)
    }
    
    
    func createEventStartTimePicker() {
        if #available(iOS 13.4, *) {
            eventStartTimePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
      
        
      
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(eventStartTimeDoneBtnTapped))
        toolbar.setItems([done], animated: true)
      
        startTime.inputAccessoryView = toolbar

        eventStartTimePicker.datePickerMode = .time
      
        startTime.inputView = eventStartTimePicker
    }
    
    @objc func eventStartTimeDoneBtnTapped() {
        view.endEditing(true)
        let date = eventStartTimePicker.date
        startTime.text = convertTimeFormater(date)
    
    }
    
    
    
    func createEventEndTimePicker() {
        if #available(iOS 13.4, *) {
            eventEndTimePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
  
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(eventEndTimeDoneBtnTapped))
        toolbar.setItems([done], animated: true)
      
        endTime.inputAccessoryView = toolbar

        eventEndTimePicker.datePickerMode = .time
       
        endTime.inputView = eventEndTimePicker
    }
    
    @objc func eventEndTimeDoneBtnTapped() {
        view.endEditing(true)
        let date = eventEndTimePicker.date
       
        endTime.text = convertTimeFormater(date)
    }
    
    
    @objc func textFieldDidChange(textField : UITextField){
        guard let query = textField.text, !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            self.places.removeAll()
            self.locationTableView.reloadData()
            return
        }
        
      
        GooglePlacesManager.shared.findPlaces(query: query ) { result in
            switch result {
            case .success(let places) :
                self.places = places
                self.locationTableView.reloadData()
                break
            case .failure(let error) :
                print(error)
            }
        }
    }
    
    @objc func hidekeyboard() {
        view.endEditing(true)
    }
    

    
    
    @IBAction func continueBtnClicked(_ sender: Any) {
        
        let sEventTitle = eventTitle.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let sTag = eventTags.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let sAddress = address.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let sCity = city.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let sState = state.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let sPostalCode = pincode.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let sCountry = country.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let sEventStartDate = eventStart.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let sEventStartTime = startTime.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let sEventEndDate = eventEnd.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let sEventEndTime = endTime.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let event = Event()
        
        if sEventTitle == "" {
            self.showSnack(messages: "Enter Event Title")
            return
        }
        else  if sTag == "" {
            self.showSnack(messages: "Enter Atleast 1 Tag")
            return
        }
        
        
        if sAddress == "" {
            self.showSnack(messages: "Enter Address")
            return
        }
        else if sCity == "" {
            self.showSnack(messages: "Enter City")
            return
        }
        else if sState == "" {
            self.showSnack(messages: "Enter State")
            return
        }
        else if sPostalCode == "" {
            self.showSnack(messages: "Enter Postal Code")
            return
        }
        else if sCountry == "" {
            self.showSnack(messages: "Select Country")
            return
        }
        
        event.latitude = mCoordinate?.latitude
        event.longitude = mCoordinate?.longitude
        event.address = sAddress
        event.city = sCity
        event.state = sState
        event.postal = sPostalCode
        event.country = sCountry
        event.isFree = true
        
      
            event.countryCode = getCountryCode()
      
        
            event.addressName = googleAddress
            
          
                if sEventStartDate == "" {
                    self.showSnack(messages: "Select Event Start Date")
                    return
                }
                else if sEventStartTime == "" {
                    self.showSnack(messages: "Select Event Start Time")
                    return
                }
                else if sEventEndDate == "" {
                    self.showSnack(messages: "Select Event End Date")
                    return
                }
                else if sEventEndTime == "" {
                    self.showSnack(messages: "Select Event End Time")
                    return
                }
                else {
                        
                    var startDate = eventStartDatePicker.date
                    var endDate =   eventEndDatePicker.date
                    let startTime = eventStartTimePicker.date
                    let endTime = eventEndTimePicker.date
                    
                    let shour = Calendar.current.component(.hour, from: startTime)
                    let smin = Calendar.current.component(.minute, from: startTime)
                    startDate = startDate.setTime(hour: shour, min: smin) ?? Date()
                    let ehour = Calendar.current.component(.hour, from: endTime)
                    let emin = Calendar.current.component(.minute, from: endTime)
                    endDate = endDate.setTime(hour: ehour, min: emin) ?? Date()
                 
                    event.eventStartDate = startDate
                    event.eventEndDate = endDate
                    
                    
                }
            
    
        
        let docucmentRef =  FirebaseStoreManager.db.collection(Collections.EVENTS.rawValue).document()
        
        event.eventId = docucmentRef.documentID
    
        event.eventOrganizerUid =  Auth.auth().currentUser!.uid
        event.eventTitle = sEventTitle

        event.tags = sTag
    
        performSegue(withIdentifier: "eventimageseg", sender: event)
 
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "eventimageseg" {
            if let dest = segue.destination as? CreateEventMainEventImage {
                if let mEvent = sender as? Event {
                    dest.event = mEvent
                }
            }
        }
    }

    public func updateTableViewHeight(){
        self.locationTableViewHeight.constant = self.locationTableView.contentSize.height
        self.locationTableView.layoutIfNeeded()
    }
    

    @objc func locationCellClicked(myGesture : MyGesture){
        locationTableView.isHidden = true
        view.endEditing(true)
        mapView.isHidden = false
        addressView.isHidden = false
      
        
        let place = places[myGesture.index]
        searchForVenue.text = place.name ?? ""
        
        if let placeName = place.name, placeName != "" {
            let placeArr =  placeName.components(separatedBy: ",")
            if !placeArr.isEmpty {
                self.googleAddress = placeArr[0]
            }
           
        }
        
        address.text = ""
        city.text = ""
        state.text = ""
        pincode.text = ""
        country.text = ""
        
        GooglePlacesManager.shared.resolveLocation(for: place) { result in
            switch result {
            case .success(let coordinates) :
                self.setCoordinatesOnMap(with: coordinates)
                break
            case .failure(let error) :
                print(error)
        
            }
        }
    }
    
    
    func setCoordinatesOnMap(with coordinates : CLLocationCoordinate2D) {
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        self.mCoordinate = coordinates
        let anonation = mapView.annotations
        mapView.removeAnnotations(anonation)
        
        mapView.addAnnotation(pin)
        mapView.setRegion(MKCoordinateRegion(
                            center: coordinates,
                            span: MKCoordinateSpan(
                                latitudeDelta: 0.02,
                                longitudeDelta: 0.02)),
                            animated: true)
        mapView.isScrollEnabled = false
        
        
    }
    
   
    
}

extension CreateEventBasicViewController: UITextFieldDelegate {
    
    
    func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
       
        if action == #selector(UIResponderStandardEditActions.paste(_:)) || action == #selector(UIResponderStandardEditActions.copy(_:)) || action == #selector(UIResponderStandardEditActions.cut(_:)){
                return false
            }
           
            return super.canPerformAction(action, withSender: sender)
        }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
       
        
        if textField == eventTitle {
            let maxLength = 75
            let currentString: NSString = (textField.text ?? "") as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
          
            if newString.length <= maxLength {
                titleCount.text = "\(newString.length) / \(maxLength)"
            }
           
            return newString.length <= maxLength
        }
        
        return true
       
       
    }

}


extension CreateEventBasicViewController : UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
       
      
            return Constants.allCountriesName.count
      
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
      
            return Constants.allCountriesName[row]
        
        
        
    }
    
    func showOpenMapPopup(latitude : Double, longitude : Double){
        let alert = UIAlertController(title: "Open in maps", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Apple Maps", style: .default, handler: { action in
            
            let coordinate = CLLocationCoordinate2DMake(latitude,longitude)
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
            mapItem.name = "Event Location"
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
        }))
        
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            
            alert.addAction(UIAlertAction(title: "Google Maps", style: .default, handler: { action in
                
                UIApplication.shared.open(URL(string:"comgooglemaps://?center=\(latitude),\(longitude)&zoom=14&views=traffic&q=\(latitude),\(longitude)")!, options: [:], completionHandler: nil)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
}

extension CreateEventBasicViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if places.count > 0 {
            tableView.isHidden = false
        }
        else {
            tableView.isHidden = true
        }
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "placescell", for: indexPath) as? GooglePlacesCell {
            
           
            cell.name.text = places[indexPath.row].name ?? "Something Went Wrong"
            cell.mView.isUserInteractionEnabled = true
            let myGesture = MyGesture(target: self, action: #selector(locationCellClicked(myGesture:)))
            myGesture.index = indexPath.row
            cell.mView.addGestureRecognizer(myGesture)
            
            let totalRow = tableView.numberOfRows(inSection: indexPath.section)
            if(indexPath.row == totalRow - 1)
                    {
                        DispatchQueue.main.async {
                            self.updateTableViewHeight()
                        }
                    }
            return cell
        }
        
        return GooglePlacesCell()
    }
    
    
    
}

extension CreateEventBasicViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation {
            self.showOpenMapPopup(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
            
        }
        
    }
}
