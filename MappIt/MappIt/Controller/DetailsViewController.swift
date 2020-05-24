// Nelly Shieh
// nichunsh@usc.edu
//
//  DetailsViewController.swift
//  MappIt
//
//  Created by Nelly Shieh on 4/15/20.
//  Copyright © 2020 Nelly Shieh. All rights reserved.
//

import UIKit
import CoreLocation

// so that the details page updates correctly
protocol isAbleToUpdateIndex {
    func pass(d: Int?, e:Int?)
}

class DetailsViewController: UIViewController, isAbleToUpdateIndex {
    
    // sets the new index path if item was edited
    func pass(d: Int?, e: Int?) {
        dayIndex = d
        eventIndex = e
    }
    
    var selectedEvent: TMEvent?
    var dayIndex: Int?
    var eventIndex:Int?
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    
    private let savedEvents = EventsModel.sharedInstance
    var fromResults: Bool = true
    
    
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var rBarButton: UIBarButtonItem!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var locationNameLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // if event has been edited, need to update to new location of event
        if !fromResults {
            if let dI = dayIndex, let eI = eventIndex {
                if let event = savedEvents.day(at: dI)?.event(at: eI) {
                    loadData(from: event)
                }
            }
        }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load from search results
        if fromResults {
            guard let e = selectedEvent else {
                return
            }
            eventNameLabel.text = e.name.replacingOccurrences(of: "|", with: "1")
            imgView.image = #imageLiteral(resourceName: "default")
            
            if let link = URL(string: "\(e.images[0].url)") {
                let data = try? Data(contentsOf: link)
                if let imgdata = data{
                    imgView.image = UIImage(data: imgdata)
                }
            }
            
            let date: String
            let time: String
            
            if let dateTime = e.dates.start.dateTime {
                let dT = dateTime.UTCTolocal()
                date = dT.localToDate()
                time = "  &  " + dT.localToTime()
                dateTimeLabel.textColor = UIColor.black
            } else {
                date = e.dates.start.localDate
                if let t = e.dates.start.localTime {
                    time = "  &  \(t)"
                } else {
                    time = ""
                }
                
                dateTimeLabel.textColor = UIColor.systemPink
            }
            
            dateTimeLabel.text = "\(date)\(time)"
            
            var address = "No Address"
            
            locationNameLabel.text = ""
            
            if let venues = e._embedded {
                if let v = venues.venues {
                    let venue = v[0]
                    
                    locationNameLabel.text = venue.name
                    
                    let line2: String
                    let line1: String
                    if let ad = venue.address{
                        line1 = ad.line1 + "\n"
                        
                        if let line = ad.line2 {
                            line2 = line + "\n"
                        } else {
                            line2 = ""
                        }
                    } else {
                        line1 = ""
                        line2 = ""
                    }
                    
                    let state: String
                    if let s = venue.state{
                        if let sc = s.stateCode{
                            state = ", \(sc)"
                        } else {
                            state = ", \(s.name)"
                        }
                    } else {
                        state = ""
                    }
                    
                    let postalCode: String
                    if let pc = venue.postalCode {
                        postalCode = pc
                    } else {
                        postalCode = ""
                    }
                    
                    address = "\(line1)\(line2)\(venue.city.name)\(state) \(postalCode)\n\(venue.country.name)"
                }
            }
            
            addressLabel.text = address
            
            var genre = "No Details"
            var segment = ""
            
            
            
            if let detail = e.classifications{
                let details = detail[0]
                
                if details.segment.name != "Undefined" {
                    genre = ""
                    if let g = details.genre{
                        if g.name != "Undefined" {
                            genre = g.name
                        }
                        
                        if let subGenre = details.subGenre {
                            if subGenre.name != "Undefined" && genre != subGenre.name{
                                genre = subGenre.name + " " + genre
                            }
                        }
                        
                        if genre != "" {
                            genre = " - " + genre
                        }
                    }
                    segment = details.segment.name
                }
                
            }
            
            
            
            
            detailsLabel.text = "\(segment)\(genre)"
            
        // load from local event list
        } else {
            
            guard let dI = dayIndex, let eI = eventIndex else {
                return
                
            }
            
            guard let event = savedEvents.day(at: dI)?.event(at: eI) else {
                return
            }
            
            loadData(from: event)
            
            
        }
        
        
    }
    
    // to load the event
    func loadData(from event: Event){
        eventNameLabel.text = event.getEventName().replacingOccurrences(of: "|", with: "1")
        imgView.image = #imageLiteral(resourceName: "default")
        if let path = documentsURL?.appendingPathComponent("\(event.getEventName().replacingOccurrences(of: "/", with: "")).png"){
            if let image = UIImage(contentsOfFile: path.path){
                imgView.image = image
            }
        }
        
        var date = ""
        var time = ""
        
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        
        if let type = event.getDT() {
            if type {
                if event.getDate() != Date(timeIntervalSince1970: 0){
                    let dateTime = dateformatter.string(from: event.getDate())
                    date = dateTime.localToDate()
                    time = "  &  " + dateTime.localToTime()
                    dateTimeLabel.textColor = UIColor.black
                } else {
                    date = event.getLocalDate()
                    if event.getLocalTime() != "" {
                        time = "  &  \(event.getLocalTime())"
                    } else {
                        time = event.getLocalTime()
                    }
                    
                    dateTimeLabel.textColor = UIColor.systemPink
                }
            } else {
                date = dateformatter.string(from: event.getDate()).localToDate()
                
            }
        }
        
        dateTimeLabel.text = "\(date)\(time)"
        
        locationNameLabel.text = event.getVenue().name
        
        if event.getVenue().address == "No Address" {
            addressLabel.text = event.getVenue().address
        } else {
            addressLabel.text = "\(event.getVenue().address.replacingOccurrences(of: "|", with: "\n"))\n\(event.getVenue().city), \(event.getVenue().state) \(event.getVenue().postalCode)\n\(event.getVenue().country)"
        }
        
        if event.getDetails() == "" {
            detailsLabel.text = "No Details"
        } else {
            detailsLabel.text = event.getDetails()
        }
    }
    
    // to get coordinates if some address was provided
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
    
    // for search results, event can be added to local list
    @IBAction func addButtonDidTapped(_ sender: UIBarButtonItem) {
        if rBarButton.tag == 0 {
            var loc: Coordinate?
            var address: String = ""
            var ven: Venue
            
            if let e = selectedEvent{
                
                ven = Venue(name: "", postalCode: "", city: "", state: "", country: "", address: "No Address")
                
                if let venues = e._embedded{
                    if let vx = venues.venues {
                        let v = vx[0]
                        
                        var add = addressLabel.text ?? ""
                        
                        let d: Date?
                        if let date = e.dates.start.dateTime {
                            d = NSDate(stringDate: date) as Date
                            
                        } else {
                            d = nil
                        }
                        
                        var fileURL: URL! = nil
                        
                        if let link = URL(string: "\(e.images[0].url)") {
                            let data = try? Data(contentsOf: link)
                            if let imgdata = data{
                                if let image = UIImage(data: imgdata){
                                    if let jData = image.jpegData(compressionQuality: 0.5) {
                                        fileURL = documentsURL?.appendingPathComponent("\(e.name.replacingOccurrences(of: "/", with: "")).png")
                                        try? jData.write(to: fileURL)
                                    }
                                }
                            }
                        }
                        
                        if add != "No Address" {
                            add = v.address?.line2 ?? ""
                            if add != "" {
                                add = "|" + add
                            }
                            
                            ven = Venue(name: v.name, postalCode: v.postalCode ?? "", city: v.city.name, state: v.state?.name ?? "", country: v.country.name, address: v.address?.line1 ?? "" + add )
                        } else {
                            ven.name = v.name
                        }
                        
                        
                        if ven.address != "No Address" {
                            
                            address = "\(ven.address.replacingOccurrences(of: "|", with: " ")), \(ven.city), \(ven.state) \(ven.postalCode), \(ven.country)"
                            
                            getCoordinate(addressString: address) { (coordinate, error) in
                                if error == nil {
                                    loc = Coordinate(latitude: coordinate.latitude, longitude: coordinate.longitude)
                                } else {
                                    loc = nil
                                    print (error!)
                                }
                                
                                if let location = v.location {
                                    loc = Coordinate(latitude: (location.latitude as NSString).doubleValue, longitude: (location.longitude as NSString).doubleValue)
                                }
                                
                                let event = Event(name: e.name, location: loc, localDate: e.dates.start.localDate, localTime: e.dates.start.localTime ?? "", date: d, details: self.detailsLabel.text ?? "", venue: ven, dateTime: true)
                                
                                self.filterEvent(event: event)
                                
                                
                            }
                        } else {
                            let event = Event(name: e.name, location: loc, localDate: e.dates.start.localDate, localTime: e.dates.start.localTime ?? "", date: d, details: self.detailsLabel.text ?? "", venue: ven, dateTime: true)
                            
                            self.filterEvent(event: event)
                        }
                        
                    }
                    
                }
            }
        // for local event list, can edit event
        } else if rBarButton.tag == 1{
            performSegue(withIdentifier: "Editing", sender: sender)
        }
    }
    
    // categorizes event to be saved in event list
    func filterEvent(event: Event) {
        if event.getDate() == Date(timeIntervalSince1970: 0) && event.getLocalDate() == "" {
            if self.savedEvents.day(at: 0)?.getDay() == "No Date"{
                _ = self.savedEvents.day(at: 0)?.addEvent(event)
            } else {
                self.savedEvents.insertNoDate(Days(day: "No Date", event: event))
            }
            
            
        } else if event.getDate() != Date(timeIntervalSince1970: 0) || (event.getDate() == Date(timeIntervalSince1970: 0) && event.getLocalDate() != ""){
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            
            var day: String
            
            if event.getDate() == Date(timeIntervalSince1970: 0) {
                day = event.getLocalDate().dateToDay()
            } else {
                day = dateFormatter.string(from: event.getDate()).localToDay()
            }
            
            
            var i = 0
            if self.savedEvents.numberOfDays() == 0{
                _ = self.savedEvents.insertDay(Days(day: day, event: event))
            } else {
                
                
                while day != "" && i<self.savedEvents.numberOfDays() {
                    if self.savedEvents.day(at: i)?.getDay() == day {
                        _ = self.savedEvents.day(at: i)?.addEvent(event)
                        day = ""
                    } else {
                        i += 1
                    }
                }
                
                //if day not found
                if i == self.savedEvents.numberOfDays() {
                    _ = self.savedEvents.insertDay(Days(day: day, event: event))
                }
            }
        }
        
        let alertController = UIAlertController(title: "Event Saved", message: "\(event.getEventName()) has been saved to your event list", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if let addEditViewController = (segue.destination as? UINavigationController)?.topViewController as? AddEditViewController {
            if segue.identifier == "Editing"{
                addEditViewController.dayIndex = dayIndex
                addEditViewController.eventIndex = eventIndex
                addEditViewController.instuction = "Edit Your Event"
                addEditViewController.delegate = self
            }
        }
    }
    
    
}
