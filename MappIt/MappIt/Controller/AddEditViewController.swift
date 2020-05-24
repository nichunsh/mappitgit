// Nelly Shieh
// nichunsh@usc.edu
//
//  AddEditViewController.swift
//  MappIt
//
//  Created by Nelly Shieh on 4/15/20.
//  Copyright © 2020 Nelly Shieh. All rights reserved.
//

import UIKit
import CoreLocation

// Layout constrain error of keyboard which i cannot fix
// https://forums.developer.apple.com/thread/126344
// https://github.com/hackiftekhar/IQKeyboardManager/issues/1616

class AddEditViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    var delegate: isAbleToUpdateIndex?
    
    private let savedEvents = EventsModel.sharedInstance
    var dayIndex: Int?
    var eventIndex: Int?
    var instuction: String = ""
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    
    @IBOutlet weak var dateSC: UISegmentedControl!
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var eventNameTF: UITextField!
    
    @IBOutlet weak var dateTimeDP: UIDatePicker!
    
    @IBOutlet weak var detailsTV: UITextView!
    
    @IBOutlet weak var venueNameTF: UITextField!
    
    @IBOutlet weak var adLine1TF: UITextField!
    
    @IBOutlet weak var adLine2TF: UITextField!
    
    @IBOutlet weak var stateTF: UITextField!
    
    @IBOutlet weak var countryTF: UITextField!
    
    @IBOutlet weak var cityTF: UITextField!
    
    @IBOutlet weak var pcTF: UITextField!
    
    @IBOutlet weak var dpView: UIView!
    
    var activeField: UIView?
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var navBarItem: UINavigationItem!
    
    // makes sures event name is entered
    func enableSaveButton(_ text:String) {
        saveBarButton.isEnabled = text.count>0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    // return moves on to next textbox
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            detailsTV.resignFirstResponder()
            return false
        }
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventNameTF.delegate = self
        detailsTV.delegate = self
        venueNameTF.delegate = self
        adLine1TF.delegate = self
        adLine2TF.delegate = self
        cityTF.delegate = self
        stateTF.delegate = self
        pcTF.delegate = self
        countryTF.delegate = self
        saveBarButton.isEnabled = false
        navBarItem.title = instuction
        
        // to input above keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: AddEditViewController.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: AddEditViewController.keyboardWillHideNotification, object: nil)
        // Do any additional setup after loading the view.
        
        // if it is for editing, load information
        if let dI = dayIndex, let eI = eventIndex {
            if let event = savedEvents.day(at: dI)?.event(at: eI){
                eventNameTF.text = event.getEventName()
                
                dateSC.selectedSegmentIndex = 2
                dateTimeDP.isHidden = true
                dpView.alpha = 0
                
                if let type = event.getDT(){
                    
                    if event.getDate() == Date(timeIntervalSince1970: 0){
                        if event.getLocalTime() != "" {
                            dateSC.selectedSegmentIndex = 0
                            dateTimeDP.isHidden = false
                            dpView.alpha = 1
                            dateTimeDP.datePickerMode = UIDatePicker.Mode.dateAndTime
                            dateTimeDP.setDate(NSDate(stringDate: "\(event.getLocalDate())T\(event.getLocalTime()):00Z") as Date, animated: true)
                        } else {
                            dateSC.selectedSegmentIndex = 1
                            dateTimeDP.isHidden = false
                            dpView.alpha = 1
                            dateTimeDP.datePickerMode = UIDatePicker.Mode.date
                            dateTimeDP.setDate(NSDate(strDate: event.getLocalDate()) as Date, animated: true)
                        }
                    }else{
                        
                        if type {
                            dateSC.selectedSegmentIndex = 0
                            dateTimeDP.isHidden = false
                            dpView.alpha = 1
                            dateTimeDP.datePickerMode = UIDatePicker.Mode.dateAndTime
                        } else {
                            dateSC.selectedSegmentIndex = 1
                            dateTimeDP.isHidden = false
                            dpView.alpha = 1
                            dateTimeDP.datePickerMode = UIDatePicker.Mode.date
                        }
                        
                        dateTimeDP.setDate(event.getDate(), animated: true)
                    }
                }
                
                
                
                
                detailsTV.text = event.getDetails()
                venueNameTF.text = event.getVenue().name
                if event.getVenue().address.contains("|") {
                    let add = event.getVenue().address.split(separator: "|")
                    adLine1TF.text = String(add[0])
                    adLine2TF.text = String(add[1])
                } else {
                    if event.getVenue().address != "No Address" {
                        adLine1TF.text = event.getVenue().address
                    }
                }
                
                cityTF.text = event.getVenue().city
                stateTF.text = event.getVenue().state
                pcTF.text = event.getVenue().postalCode
                countryTF.text = event.getVenue().country
                
                imageView.image = #imageLiteral(resourceName: "default")
                if let path = documentsURL?.appendingPathComponent("\(event.getEventName().replacingOccurrences(of: "/", with: "")).png"){
                    if let image = UIImage(contentsOfFile: path.path){
                        imageView.image = image
                    }
                }
                
            }
        }
        
        enableSaveButton(eventNameTF.text ?? "")
    }
    
    @objc func keyboardWasShown(notification: Notification) {
        if let aF = activeField {
            let info = notification.userInfo
            if let i = info{
                let kbSize =  (i[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect).size
                
                let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: kbSize.height, right: 0.0);
                mainScrollView.contentInset = contentInsets
                mainScrollView.scrollIndicatorInsets = contentInsets
                
                // If active text field is hidden by keyboard, scroll it so it's visible
                // Your app might not need or want this behavior.
                var aRect = self.view.frame
                aRect.size.height -= kbSize.height
                if (aRect.contains(aF.frame.origin) ) {
                    self.mainScrollView.scrollRectToVisible(aF.frame, animated: true)
                }
            }
        }
        
        
    }
    
    @objc func keyboardWillBeHidden(notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        mainScrollView.contentInset = contentInsets
        mainScrollView.scrollIndicatorInsets = contentInsets
    }
    
    // clear all inputs
    func clear() {
        eventNameTF.text = ""
        dateSC.selectedSegmentIndex = 0
        dateTimeDP.setDate(Date(), animated: false)
        detailsTV.text = ""
        venueNameTF.text = ""
        adLine1TF.text = ""
        adLine2TF.text = ""
        cityTF.text = ""
        stateTF.text = ""
        pcTF.text = ""
        countryTF.text = ""
        saveBarButton.isEnabled = false
        
        
    }
    
    // change active field
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeField = textView
    }
    
    // change active field
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }
    
    // where return/continue moves the screen/keyboard location
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == eventNameTF ||  textField == countryTF {
            textField.resignFirstResponder()
            activeField = nil
        } else if textField == venueNameTF {
            textField.resignFirstResponder()
            adLine1TF.becomeFirstResponder()
            activeField = adLine1TF
        } else if textField == adLine1TF {
            textField.resignFirstResponder()
            adLine2TF.becomeFirstResponder()
            activeField = adLine2TF
        } else if textField == adLine2TF {
            textField.resignFirstResponder()
            cityTF.becomeFirstResponder()
            activeField = cityTF
        } else if textField == cityTF {
            textField.resignFirstResponder()
            stateTF.becomeFirstResponder()
            activeField = stateTF
        } else if textField == stateTF{
            textField.resignFirstResponder()
            pcTF.becomeFirstResponder()
            activeField = pcTF
        } else if textField == pcTF {
            textField.resignFirstResponder()
            countryTF.becomeFirstResponder()
            activeField=countryTF
        }
        
        return true
    }
    
    // toggle enable save with each keystroke
    @IBAction func editingChanged(_ sender: UITextField) {
        enableSaveButton(eventNameTF.text ?? "")
    }
    
    // date setting
    @IBAction func dateSCDidChange(_ sender: Any) {
        if dateSC.selectedSegmentIndex == 0 {
            dateTimeDP.datePickerMode = UIDatePicker.Mode.dateAndTime
            if dateTimeDP.isHidden {
                dateTimeDP.isHidden = false
                fadeIn()
            }
        } else if dateSC.selectedSegmentIndex == 1 {
            dateTimeDP.datePickerMode = UIDatePicker.Mode.date
            if dateTimeDP.isHidden {
                dateTimeDP.isHidden = false
                fadeIn()
            }
        } else {
            fadeOut()
            dateTimeDP.isHidden = true
        }
    }
    
    //dismiss keyboard
    @IBAction func backgroundDidTapped(_ sender: UITapGestureRecognizer) {
        eventNameTF.resignFirstResponder()
        detailsTV.resignFirstResponder()
        venueNameTF.resignFirstResponder()
        adLine1TF.resignFirstResponder()
        adLine2TF.resignFirstResponder()
        cityTF.resignFirstResponder()
        stateTF.resignFirstResponder()
        countryTF.resignFirstResponder()
        pcTF.resignFirstResponder()
        activeField = nil
    }
    
    // animation
    func fadeIn() {
        let fade = UIViewPropertyAnimator(duration: 1, curve: .easeIn) {
            self.dpView.alpha = 1
        }
        fade.startAnimation()
    }
    
    // animation
    func fadeOut() {
        let fade = UIViewPropertyAnimator(duration: 1, curve: .easeIn) {
            self.dpView.alpha = 0
        }
        fade.startAnimation()
    }
    
    // cancel edit or creating event
    @IBAction func cancelButtonDidTapped(_ sender: UIBarButtonItem) {
        
        eventNameTF.resignFirstResponder()
        detailsTV.resignFirstResponder()
        venueNameTF.resignFirstResponder()
        adLine1TF.resignFirstResponder()
        adLine2TF.resignFirstResponder()
        cityTF.resignFirstResponder()
        stateTF.resignFirstResponder()
        countryTF.resignFirstResponder()
        pcTF.resignFirstResponder()
        activeField = nil
        
        navigationController?.dismiss(animated: true, completion: nil)
        
    }
    
    
    func getCoordinate( addressString : String,
                        completionHandler: @escaping(CLLocationCoordinate2D, NSError?) -> Void ) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressString) { (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?[0] {
                    let location = placemark.location!
                    
                    completionHandler(location.coordinate, nil)
                    return
                }
            }
            
            completionHandler(kCLLocationCoordinate2DInvalid, error as NSError?)
        }
    }
    
    @IBAction func saveButtonDidTapped(_ sender: UIBarButtonItem) {
        var loc: Coordinate?
        var ven: Venue
        var dt: Bool?
        var date: Date?
        
        guard let eventName = eventNameTF.text?.dropLastSpace() else {
            let alertController = UIAlertController(title: "Warning",
            message: "Event needs a name", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        if let dI = dayIndex, let eI = eventIndex {
            if let event = savedEvents.day(at: dI)?.event(at: eI){
                
                var add = "\(adLine1TF.text?.dropLastSpace() ?? "")|\(adLine2TF.text?.dropLastSpace() ?? "")"
                
                if adLine1TF.text != "" && adLine2TF.text == ""{
                    add = adLine1TF.text?.dropLastSpace() ?? ""
                }
                
                if dateSC.selectedSegmentIndex == 2 {
                    dt = nil
                    date = nil
                } else if dateSC.selectedSegmentIndex == 1 {
                    dt = false
                    date = dateTimeDP.date
                } else {
                    dt = true
                    date = dateTimeDP.date
                }
                
                if event.getVenue().address != add || event.getVenue().city != cityTF.text || event.getVenue().state != stateTF.text || event.getVenue().country != countryTF.text || event.getVenue().postalCode != pcTF.text {
                    
                    
                    if add == "|" {
                        add = "No Address"
                        loc = nil
                        ven = Venue(name: venueNameTF.text?.dropLastSpace() ?? "", postalCode: "", city: "", state: "", country: "", address: add)
                        
                        let toSave = Event(name: eventName, location: loc, localDate: "", localTime: "", date: date, details: detailsTV.text.dropLastSpace(), venue: ven, dateTime: dt)
                        
                        savedEvents.removeEvent(day: dI, event: eI)
                        
                        filterEvent(event: toSave)
                        
                        
                        
                    } else {
                        ven = Venue(name: venueNameTF.text?.dropLastSpace() ?? "", postalCode: pcTF.text?.dropLastSpace() ?? "", city: cityTF.text?.dropLastSpace() ?? "", state: stateTF.text?.dropLastSpace() ?? "", country: countryTF.text?.dropLastSpace() ?? "", address: add)
                        let address = "\(ven.address.replacingOccurrences(of: "|", with: " ")), \(ven.city), \(ven.state) \(ven.postalCode), \(ven.country)"
                        
                        getCoordinate(addressString: address) { (coordinate, error) in
                            if error == nil {
                                loc = Coordinate(latitude: coordinate.latitude, longitude: coordinate.longitude)
                            }
                            
                            let toSave = Event(name: eventName, location: loc, localDate: "", localTime: "", date: date, details: self.detailsTV.text.dropLastSpace(), venue: ven, dateTime: dt)
                            
                            self.savedEvents.removeEvent(day: dI, event: eI)
                            
                            self.filterEvent(event: toSave)
                            
                        }
                    }
                } else {
                    // no change in address
                    let toSave = Event(name: eventName, location: event.getLocation(), localDate: "", localTime: "", date: date, details: detailsTV.text.dropLastSpace(), venue: event.getVenue(), dateTime: dt)
                    
                    savedEvents.removeEvent(day: dI, event: eI)
                    
                    
                    filterEvent(event: toSave)
                }
            }
        } else {
            
            guard !savedEvents.checkEventName(name: eventName) else{
                let alertController = UIAlertController(title: "Warning",
                message: "The event name you have entered already exists, try a new event name", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                eventNameTF.text = ""
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            if dateSC.selectedSegmentIndex == 2 {
                dt = nil
                date = nil
            } else if dateSC.selectedSegmentIndex == 1 {
                dt = false
                date = dateTimeDP.date
            } else {
                dt = true
                date = dateTimeDP.date
            }
            
            var add = "\(adLine1TF.text ?? "")|\(adLine2TF.text ?? "")"
            if adLine1TF.text != "" && adLine2TF.text == ""{
                add = adLine1TF.text ?? ""
            }
            
            if add == "|" {
                add = "No Address"
                loc = nil
                ven = Venue(name: venueNameTF.text?.dropLastSpace() ?? "", postalCode: "", city: "", state: "", country: "", address: add)
                
                let toSave = Event(name: eventName, location: loc, localDate: "", localTime: "", date: date, details: detailsTV.text.dropLastSpace(), venue: ven, dateTime: dt)
                
                filterEvent(event: toSave)
                
                
                
            } else {
                ven = Venue(name: venueNameTF.text?.dropLastSpace() ?? "", postalCode: pcTF.text?.dropLastSpace() ?? "", city: cityTF.text?.dropLastSpace() ?? "", state: stateTF.text?.dropLastSpace() ?? "", country: countryTF.text?.dropLastSpace() ?? "", address: add)
                let address = "\(ven.address.replacingOccurrences(of: "|", with: " ")), \(ven.city), \(ven.state) \(ven.postalCode), \(ven.country)"
                
                getCoordinate(addressString: address) { (coordinate, error) in
                    if error == nil {
                        loc = Coordinate(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    }
                    
                    let toSave = Event(name: eventName, location: loc, localDate: "", localTime: "", date: date, details: self.detailsTV.text.dropLastSpace(), venue: ven, dateTime: dt)
                    
                    self.filterEvent(event: toSave)
                    
                }
            }
            
        }
    }
    
    func filterEvent(event: Event) {
        var e: Int?
        var d: Int?
        
        if event.getDate() == Date(timeIntervalSince1970: 0) {
            if self.savedEvents.day(at: 0)?.getDay() == "No Date"{
                e = self.savedEvents.addEvent(d: 0, e: event)
                d = 0
            } else {
                self.savedEvents.insertNoDate(Days(day: "No Date", event: event))
                d = 0
                e = 0
            }
            
            
        } else {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            
            var day = dateFormatter.string(from: event.getDate()).localToDay()
            
            var i = 0
            if self.savedEvents.numberOfDays() == 0{
                d = self.savedEvents.insertDay(Days(day: day, event: event))
                e = 0
            } else {
                
                
                while day != "" && i<self.savedEvents.numberOfDays() {
                    if self.savedEvents.day(at: i)?.getDay() == day {
                        e = self.savedEvents.addEvent(d: i, e: event)
                        d = i
                        day = ""
                    } else {
                        i += 1
                    }
                }
                
                
                //if day not found
                if i == self.savedEvents.numberOfDays() {
                    d = self.savedEvents.insertDay(Days(day: day, event: event))
                    e = 0
                }
            }
        }
        
        
        
        navigationController?.dismiss(animated: true, completion: nil)
        
        if let _ = dayIndex, let _ = eventIndex{
            if let delegate = self.delegate {
                delegate.pass(d: d, e: e)
            }
//            if let details = presentingViewController as? DetailsViewController{
//                details.dayIndex = d
//                details.eventIndex = e
//            }
        }
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
        
     }
     
    */

}
