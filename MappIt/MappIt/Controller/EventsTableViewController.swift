// Nelly Shieh
// nichunsh@usc.edu
//
//  EventsTableViewController.swift
//  MappIt
//
//  Created by Nelly Shieh on 4/15/20.
//  Copyright © 2020 Nelly Shieh. All rights reserved.
//

import UIKit
import EventKit
import MapKit

//https://www.ioscreator.com/tutorials/add-event-calendar-ios-tutorial

class EventsTableViewController: UITableViewController {
    
    @IBOutlet var myEventsTV: UITableView!
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    
    private let savedEvents = EventsModel.sharedInstance
    var createBarButton: UIBarButtonItem!
    var cancelBarButton: UIBarButtonItem!
    
    var exportBarButton: UIBarButtonItem!
    var exportDBarButton: UIBarButtonItem!
    
    // update the event list with new events
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        myEventsTV.reloadData()
        
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
        
        // set edit button
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        // initialize other barbuttonitems that will be needed
        
        // to allow selection of dated events for export
        exportBarButton = UIBarButtonItem(title: "Export", style: .plain, target: self, action: #selector(exportBarButtonDidTapped))
        
        // exports events to the local calendar app
        exportDBarButton = UIBarButtonItem(title: "EXPORT", style: .done, target: self, action: #selector(exportDBarButtonDidTapped))
        
        // creates new event
        createBarButton = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(createBarButtonDidTapped(sender:)))
        
        // to leave exporting selection setup
        cancelBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelBarButtonDidTapped(_:)))
        
        // set the right bar button
        self.navigationItem.rightBarButtonItem = createBarButton
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return savedEvents.numberOfDays()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let day = savedEvents.day(at: section) {
            return day.numberOfEvents()
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection
        section: Int) -> String? {
        if let day = savedEvents.day(at: section) {
            return day.getDay()
        }
        return "Good Day"
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myEventsTV.dequeueReusableCell(withIdentifier: "Event", for: indexPath) as! EventTableViewCell
        
        if let day = savedEvents.day(at: indexPath.section){
            if let event = day.event(at: indexPath.row) {
                cell.eventNameLabel.text = event.getEventName()
                
                if event.getDate() == Date(timeIntervalSince1970: 0) {
                    cell.eventDateTimeLabel.text = ""
                } else {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                    
                    let time = dateFormatter.string(from: event.getDate()).localToTime()
                    
                    cell.eventDateTimeLabel.text = time
                }
                
                cell.eventImageView.image = #imageLiteral(resourceName: "default")
                if let path = documentsURL?.appendingPathComponent("\(event.getEventName().replacingOccurrences(of: "/", with: "")).png"){
                    if let image = UIImage(contentsOfFile: path.path){
                        cell.eventImageView.image = image
                    }
                }
            }
        }
        
        return cell
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    // changes bar button for different modes
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        // change right button to allow export
        if editing {
            self.navigationItem.rightBarButtonItem = exportBarButton
            
        // if not editing, if cancel was the leftbarbuttonitem, back to allow export execution button
            // else if leftbarbutton is edit, the right barbutton should be create
        } else {
            if self.navigationItem.leftBarButtonItem == cancelBarButton {
                self.navigationItem.rightBarButtonItem = exportDBarButton
            } else {
                self.navigationItem.rightBarButtonItem = createBarButton
            }
        }
    }
    
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // delete event, and section if necessary
        if editingStyle == .delete {
            savedEvents.deleteEvent(day: indexPath.section, event: indexPath.row)
            
            if myEventsTV.numberOfRows(inSection: indexPath.section)>1 {
                tableView.deleteRows(at: [indexPath], with: .fade)
            } else {
                let indexSet = NSMutableIndexSet()
                indexSet.add(indexPath.section)
                myEventsTV.deleteSections(indexSet as IndexSet, with: .fade)
            }
        }
    }
    
    
    // allows multiple selection and changes to the EXPORT button to export
    @objc func exportBarButtonDidTapped(){
        myEventsTV.allowsMultipleSelection = true
        self.navigationItem.leftBarButtonItem = cancelBarButton
        setEditing(false, animated: true)
    }
    
    // export the events in the app out to local Calendar
    @objc func exportDBarButtonDidTapped(){
        let eventStore = EKEventStore()
        if let selectedEvents = myEventsTV.indexPathsForSelectedRows{
            switch EKEventStore.authorizationStatus(for: .event) {
            case .authorized:
                
                var success = true
                
                for indexpath in selectedEvents{
                    if let e = savedEvents.day(at: indexpath.section)?.event(at: indexpath.row) {
                        if !exportEvent(store: eventStore, e: e) {
                            success = false
                        }
                    } else {
                        success = false
                    }
                }
                DispatchQueue.main.async {
                    if success {
                        self.successAlert()
                    } else {
                        self.failAlert()
                    }
                }
                
            case .denied:
                print("Access denied")
                accessAlert()// Alert?
            case .notDetermined:
                eventStore.requestAccess(to: .event, completion:
                    {[weak self] (granted: Bool, error: Error?) -> Void in
                        if granted {
                            DispatchQueue.main.async {
                                
                                var success = true
                                
                                for indexpath in selectedEvents{
                                    if let e = self!.savedEvents.day(at: indexpath.section)?.event(at: indexpath.row) {
                                        if !self!.exportEvent(store: eventStore, e: e){
                                            success = false
                                        }
                                    } else {
                                        success = false
                                    }
                                }
                                
                                if success {
                                    self!.successAlert()
                                } else {
                                    self!.failAlert()
                                }
                            }
                        } else {
                            print("Access denied")
                            DispatchQueue.main.async {
                                self!.accessAlert()
                            }
                            
                        }
                })
            default:
                print("Case default")
            }
        }
        
        // clear the selection color
        if let selection = myEventsTV.indexPathsForSelectedRows {
            for indexPath in selection{
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.contentView.backgroundColor = UIColor.clear
                }
            }
        }
        
        // exit export mode and back to default mode
        self.navigationItem.rightBarButtonItem = createBarButton
        myEventsTV.allowsMultipleSelection = false
        self.navigationItem.leftBarButtonItem = editButtonItem
        setEditing(false, animated: true)
        
        
    }
    
    // prompts user to enable access to Calendar
    func accessAlert() {
        let alertController = UIAlertController(title: "Enable Calendar", message: "To export events, go to Settings > Privacy > Calender. Then turn your calendar on for this app.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // prompts success of export
    func successAlert() {
        let alertController = UIAlertController(title: "Events Exported", message: "Selected events have been exported to local calendar.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // prompts failure of export
    func failAlert() {
        let alertController = UIAlertController(title: "Events Not Exported", message: "Some or all of selected events could not be exported to local calendar.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // function to export event
    func exportEvent(store: EKEventStore, e: Event) -> Bool {
        let calendars = store.calendars(for: .event)
        var index = 0
        var cI = -1
        
        // check if the Mappit calendar exists
        for calendar in calendars {
            if calendar.title == "Mappit" {
                cI = index
            }
            index += 1
        }
        
        let event = EKEvent(eventStore: store)
        
        // if it exists set as calendar
        if cI != -1 {
            event.calendar = calendars[cI]
        // if not create one then set as calendar
        } else {
            let newCalendar = EKCalendar(for: .event, eventStore: store)
            newCalendar.title = "Mappit"
            
            let sourcesInEventStore = store.sources
            newCalendar.source = sourcesInEventStore.filter{
                (source: EKSource) -> Bool in
                source.sourceType.rawValue == EKSourceType.local.rawValue
            }.first!

            do {
                try store.saveCalendar(newCalendar, commit: true)
                UserDefaults.standard.set(newCalendar.calendarIdentifier, forKey: "EventTrackerPrimaryCalendar")
            } catch {
                let alert = UIAlertController(title: "Calendar could not save", message: (error as NSError).localizedDescription, preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(OKAction)
                
                self.present(alert, animated: true, completion: nil)
            }
            
            event.calendar = newCalendar
        }
        
        // access event details
        var d: Date
        event.title = e.getEventName()
        if e.getDate() == Date(timeIntervalSince1970: 0) {
            if e.getLocalTime() != ""{
                d = NSDate(stringDate: "\(e.getLocalDate())T\(e.getLocalTime()):00Z") as Date
                event.startDate = d
                event.endDate = d.addingTimeInterval(1 * 60 * 60)
            }else{
                d = NSDate(strDate: e.getLocalDate()) as Date
                event.isAllDay = true
                event.startDate = d
                event.endDate = d
            }
        } else {
            d = e.getDate()
            event.startDate = d
            event.endDate = d.addingTimeInterval(1 * 60 * 60)
            
            if let timed = e.getDT() {
                if !timed {
                    event.isAllDay = true
                }
            }
        }
        
        if let location = e.getLocation() {
            let loc = EKStructuredLocation()
            if e.getVenue().name != "" {
                loc.title = e.getVenue().name
            }
            loc.geoLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            
            event.structuredLocation = loc
        }
        
        // try to save the event
        do {
            try store.save(event, span: .thisEvent)
            return true
        }
        catch {
            print("Error saving event in calendar")
            return false
        }
        
        
    }
    
    // back to editing mode
    @objc func cancelBarButtonDidTapped(_ sender: UIBarButtonItem) {
        if let selection = myEventsTV.indexPathsForSelectedRows {
            for indexPath in selection{
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.contentView.backgroundColor = UIColor.clear
                }
            }
        }
        
        // set up bar buttons to the right buttons
        self.navigationItem.rightBarButtonItem = exportBarButton
        myEventsTV.allowsMultipleSelection = false
        self.navigationItem.leftBarButtonItem = editButtonItem
        setEditing(true, animated: true)
        
    }
    
    // disallow selection of No Date events when exporting
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if self.navigationItem.rightBarButtonItem == exportDBarButton{
            if savedEvents.day(at: indexPath.section)?.getDay() == "No Date" {
                return nil
            }
        }
        
        return indexPath
    }
    
    // highlight selected items
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.navigationItem.rightBarButtonItem == exportDBarButton{
            if let cell = tableView.cellForRow(at: indexPath) {
                UIView.animate(withDuration: 0.3, animations: {
                    cell.contentView.backgroundColor = UIColor.purple.withAlphaComponent(0.2)
                })
            }
        }
    }
    
    // unhighlight deselected items
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if self.navigationItem.rightBarButtonItem == exportDBarButton{
            if let cell = tableView.cellForRow(at: indexPath) {
                UIView.animate(withDuration: 0.3, animations: {
                    cell.contentView.backgroundColor = UIColor.clear
                })
            }
        }
    }
    
    
    // MARK: - Navigation
    
    // segue to create event
    @objc func createBarButtonDidTapped(sender: UIBarButtonItem) {
        performSegue(withIdentifier: "toCreate", sender: sender)
    }
    
    // make sure segue does not perform if the right barbutton is another button
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if self.navigationItem.rightBarButtonItem != createBarButton {
            return false
        }
        
        return true
    }
    
    // information and path of segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let details  = segue.destination as? DetailsViewController {
            if segue.identifier == "savedDetail" {
                
                details.dayIndex = myEventsTV.indexPathForSelectedRow!.section
                details.eventIndex = myEventsTV.indexPathForSelectedRow!.row
                details.rBarButton.title = "Edit"
                details.rBarButton.tag = 1
                details.fromResults = false
            }
        }
        
        if let addEditViewController = (segue.destination as? UINavigationController)?.topViewController as? AddEditViewController {
            if segue.identifier == "toCreate"{
                addEditViewController.instuction = "Create Your Event"
            }
        }
    }
    
    
}
