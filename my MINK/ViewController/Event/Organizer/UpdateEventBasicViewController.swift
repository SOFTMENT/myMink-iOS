import UIKit
import MapKit
import Firebase
import FirebaseFirestoreSwift
import IQKeyboardManagerSwift

class UpdateEventBasicViewController: UIViewController {
    
    // MARK: - Outlets
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
    
    // MARK: - Properties
    var places: [Place] = []
    var mCoordinate: CLLocationCoordinate2D?
    var googleAddress: String = ""
    var event: Event?
    
    let eventStartDatePicker = UIDatePicker()
    let eventEndDatePicker = UIDatePicker()
    let eventStartTimePicker = UIDatePicker()
    let eventEndTimePicker = UIDatePicker()
    let countriesPicker = UIPickerView()

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let event = event else {
            self.dismiss(animated: true)
            return
        }
        
        guard Auth.auth().currentUser != nil else {
            self.logoutPlease()
            return
        }
        
        setupUI(event: event)
        configureDatePickers()
        configurePickers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = true
    }
    
    // MARK: - Setup Methods
    private func setupUI(event : Event) {
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        [eventTitle, eventTags, searchForVenue, eventStart, startTime, eventEnd, endTime, address, city, state, pincode, country].forEach {
            $0?.layer.cornerRadius = 8
        }
        
        [eventTitle, eventTags, searchForVenue, eventStart, startTime, eventEnd, endTime, address, city, state, pincode, country].forEach {
            $0?.delegate = self
        }
        
        eventTitle.text = event.eventTitle ?? ""
        eventTags.text = event.tags ?? ""
        
        mapView.isHidden = false
        addressView.isHidden = false
        eventStart.text = convertDateFormater(event.eventStartDate ?? Date())
        eventEnd.text = convertDateFormater(event.eventEndDate ?? Date())
      
        startTime.text = convertTimeFormater(event.eventStartDate ?? Date())
        endTime.text = convertTimeFormater(event.eventEndDate ?? Date())
        
        address.text = event.address ?? ""
        city.text = event.state ?? ""
        state.text = event.state ?? ""
        pincode.text = event.postal ?? ""
        country.text = event.country ?? ""
        let coordinates = CLLocationCoordinate2D(latitude: event.latitude ?? 0.0, longitude: event.longitude ?? 0.0)
        self.setCoordinatesOnMap(with: coordinates)
        
        searchForVenue.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        
        continueBtn.layer.cornerRadius = 8
        
        country.setRightIcons(icon: UIImage(named: "down-arrow")!)
        
        locationTableView.delegate = self
        locationTableView.dataSource = self
        locationTableView.isScrollEnabled = false
        locationTableView.contentInsetAdjustmentBehavior = .never
        locationTableView.rowHeight = UITableView.automaticDimension
        locationTableView.estimatedRowHeight = 44
        locationTableView.isHidden = true
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    private func configureDatePickers() {
        createDatePicker(eventStartDatePicker, for: eventStart, selector: #selector(eventStartDateDoneBtnTapped))
        createDatePicker(eventEndDatePicker, for: eventEnd, selector: #selector(eventEndDateDoneBtnTapped))
        createTimePicker(eventStartTimePicker, for: startTime, selector: #selector(eventStartTimeDoneBtnTapped))
        createTimePicker(eventEndTimePicker, for: endTime, selector: #selector(eventEndTimeDoneBtnTapped))
    }
    
    private func configurePickers() {
        countriesPicker.delegate = self
        countriesPicker.dataSource = self
        
        let toolbar = createToolbar(doneSelector: #selector(countriesDoneClicked), cancelSelector: #selector(countriesCancelClicked))
        country.inputAccessoryView = toolbar
        country.inputView = countriesPicker
    }
    
    private func createDatePicker(_ picker: UIDatePicker, for textField: UITextField, selector: Selector) {
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        }
        
        let toolbar = createToolbar(doneSelector: selector, cancelSelector: nil)
        textField.inputAccessoryView = toolbar
        textField.inputView = picker
        picker.datePickerMode = .date
        picker.minimumDate = Date()
    }
    
    private func createTimePicker(_ picker: UIDatePicker, for textField: UITextField, selector: Selector) {
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        }
        
        let toolbar = createToolbar(doneSelector: selector, cancelSelector: nil)
        textField.inputAccessoryView = toolbar
        textField.inputView = picker
        picker.datePickerMode = .time
    }
    
    private func createToolbar(doneSelector: Selector, cancelSelector: Selector?) -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done".localized(), style: .plain, target: nil, action: doneSelector)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        var items = [spaceButton, doneButton]
        if let cancelSelector = cancelSelector {
            let cancelButton = UIBarButtonItem(title: "Cancel".localized(), style: .plain, target: nil, action: cancelSelector)
            items.insert(cancelButton, at: 0)
        }
        toolbar.setItems(items, animated: true)
        return toolbar
    }
    
   
    
    // MARK: - Actions
    @objc private func backViewClicked() {
        self.dismiss(animated: true)
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func countriesDoneClicked() {
        country.resignFirstResponder()
        let row = countriesPicker.selectedRow(inComponent: 0)
        country.text = Constants.allCountriesName[row]
    }
    
    @objc private func countriesCancelClicked() {
        country.resignFirstResponder()
    }
    
    @objc private func eventStartDateDoneBtnTapped() {
        eventStart.text = convertDateFormater(eventStartDatePicker.date)
        view.endEditing(true)
    }
    
    @objc private func eventEndDateDoneBtnTapped() {
        eventEnd.text = convertDateFormater(eventEndDatePicker.date)
        view.endEditing(true)
    }
    
    @objc private func eventStartTimeDoneBtnTapped() {
        startTime.text = convertTimeFormater(eventStartTimePicker.date)
        view.endEditing(true)
    }
    
    @objc private func eventEndTimeDoneBtnTapped() {
        endTime.text = convertTimeFormater(eventEndTimePicker.date)
        view.endEditing(true)
    }
    
    @objc private func textFieldDidChange(textField: UITextField) {
        guard let query = textField.text, !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            self.places.removeAll()
            self.locationTableView.reloadData()
            return
        }
        
        GooglePlacesManager.shared.findPlaces(query: query) { result in
            switch result {
            case .success(let places):
                self.places = places
                self.locationTableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @IBAction func continueBtnClicked(_ sender: Any) {
        guard let sEventTitle = eventTitle.text?.trimmingCharacters(in: .whitespacesAndNewlines), !sEventTitle.isEmpty else {
            showSnack(messages: "Please fill in the event title".localized())
            return
        }
        guard let sTag = eventTags.text?.trimmingCharacters(in: .whitespacesAndNewlines), !sTag.isEmpty else {
            showSnack(messages: "Please fill in the event tags".localized())
            return
        }
        guard let sAddress = address.text?.trimmingCharacters(in: .whitespacesAndNewlines), !sAddress.isEmpty else {
            showSnack(messages: "Please fill in the address".localized())
            return
        }
        guard let sCity = city.text?.trimmingCharacters(in: .whitespacesAndNewlines), !sCity.isEmpty else {
            showSnack(messages: "Please fill in the city".localized())
            return
        }
        guard let sState = state.text?.trimmingCharacters(in: .whitespacesAndNewlines), !sState.isEmpty else {
            showSnack(messages: "Please fill in the state".localized())
            return
        }
        guard let sPostalCode = pincode.text?.trimmingCharacters(in: .whitespacesAndNewlines), !sPostalCode.isEmpty else {
            showSnack(messages: "Please fill in the postal code".localized())
            return
        }
        guard let sCountry = country.text?.trimmingCharacters(in: .whitespacesAndNewlines), !sCountry.isEmpty else {
            showSnack(messages: "Please fill in the country".localized())
            return
        }
        guard let sEventStartDate = eventStart.text?.trimmingCharacters(in: .whitespacesAndNewlines), !sEventStartDate.isEmpty else {
            showSnack(messages: "Please fill in the event start date".localized())
            return
        }
        guard let sEventStartTime = startTime.text?.trimmingCharacters(in: .whitespacesAndNewlines), !sEventStartTime.isEmpty else {
            showSnack(messages: "Please fill in the event start time".localized())
            return
        }
        guard let sEventEndDate = eventEnd.text?.trimmingCharacters(in: .whitespacesAndNewlines), !sEventEndDate.isEmpty else {
            showSnack(messages: "Please fill in the event end date".localized())
            return
        }
        guard let sEventEndTime = endTime.text?.trimmingCharacters(in: .whitespacesAndNewlines), !sEventEndTime.isEmpty else {
            showSnack(messages: "Please fill in the event end time".localized())
            return
        }
        
        
        event!.latitude = mCoordinate?.latitude
        event!.longitude = mCoordinate?.longitude
        event!.address = sAddress
        event!.city = sCity
        event!.state = sState
        event!.postal = sPostalCode
        event!.country = sCountry
        
        event!.addressName = googleAddress
        
        var startDate = eventStartDatePicker.date
        var endDate = eventEndDatePicker.date
        let startTime = eventStartTimePicker.date
        let endTime = eventEndTimePicker.date
        
        let shour = Calendar.current.component(.hour, from: startTime)
        let smin = Calendar.current.component(.minute, from: startTime)
        startDate = startDate.setTime(hour: shour, min: smin) ?? Date()
        let ehour = Calendar.current.component(.hour, from: endTime)
        let emin = Calendar.current.component(.minute, from: endTime)
        endDate = endDate.setTime(hour: ehour, min: emin) ?? Date()
        
        event!.eventStartDate = startDate
        event!.eventEndDate = endDate
        
      
        event!.eventOrganizerUid = Auth.auth().currentUser!.uid
        event!.eventTitle = sEventTitle
        event!.tags = sTag
        
        performSegue(withIdentifier: "eventimageseg", sender: event)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "eventimageseg", let dest = segue.destination as? UpdateEventMainEventImage, let mEvent = sender as? Event {
            dest.event = mEvent
        }
    }

    @objc private func locationCellClicked(myGesture: MyGesture) {
        locationTableView.isHidden = true
        view.endEditing(true)
        mapView.isHidden = false
        addressView.isHidden = false
      
        let place = places[myGesture.index]
        searchForVenue.text = place.name ?? ""
        googleAddress = place.name?.components(separatedBy: ",").first ?? ""
        
        address.text = ""
        city.text = ""
        state.text = ""
        pincode.text = ""
        country.text = ""
        
        GooglePlacesManager.shared.resolveLocation(for: place) { result in
            switch result {
            case .success(let coordinates):
                self.setCoordinatesOnMap(with: coordinates)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func setCoordinatesOnMap(with coordinates: CLLocationCoordinate2D) {
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        mCoordinate = coordinates
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(pin)
        mapView.setRegion(MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)), animated: true)
        mapView.isScrollEnabled = false
    }

    private func showOpenMapPopup(latitude: Double, longitude: Double) {
        let alert = UIAlertController(title: "Open in maps".localized(), message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Apple Maps".localized(), style: .default, handler: { _ in
            let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary: nil))
            mapItem.name = "Event Location".localized()
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
        }))
        
        if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) {
            alert.addAction(UIAlertAction(title: "Google Maps".localized(), style: .default, handler: { _ in
                UIApplication.shared.open(URL(string: "comgooglemaps://?center=\(latitude),\(longitude)&zoom=14&views=traffic&q=\(latitude),\(longitude)")!, options: [:], completionHandler: nil)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }

    public func updateTableViewHeight() {
        locationTableViewHeight.constant = locationTableView.contentSize.height
        locationTableView.layoutIfNeeded()
    }
}

// MARK: - UITextFieldDelegate
extension UpdateEventBasicViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == eventTitle {
            let maxLength = 75
            let currentString: NSString = (textField.text ?? "") as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            titleCount.text = "\(newString.length) / \(maxLength)"
            return newString.length <= maxLength
        }
        return true
    }
}

// MARK: - UIPickerViewDataSource & UIPickerViewDelegate
extension UpdateEventBasicViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Constants.allCountriesName.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Constants.allCountriesName[row]
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension UpdateEventBasicViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        locationTableView.isHidden = places.isEmpty
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "placescell", for: indexPath) as? GooglePlacesCell else {
            return GooglePlacesCell()
        }
        
        cell.name.text = places[indexPath.row].name ?? "Something Went Wrong".localized()
        let myGesture = MyGesture(target: self, action: #selector(locationCellClicked(myGesture:)))
        myGesture.index = indexPath.row
        cell.mView.addGestureRecognizer(myGesture)
        
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            DispatchQueue.main.async {
                self.updateTableViewHeight()
            }
        }
        return cell
    }
}

// MARK: - MKMapViewDelegate
extension UpdateEventBasicViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation {
            showOpenMapPopup(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        }
    }
}

