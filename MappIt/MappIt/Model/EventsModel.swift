// Nelly Shieh
// nichunsh@usc.edu
//
//  EventsModel.swift
//  MappIt
//
//  Created by Nelly Shieh on 4/15/20.
//  Copyright © 2020 Nelly Shieh. All rights reserved.
//

import Foundation

// Event Model is the main list of events that the user saved in the app
class EventsModel: NSObject {
    // List of event organized into days
    private var events = [Days]()
    
    // where the list of events are saved
    private var eventsFileLocation: URL!
    
    // initialize the list of events if the file exists.
    override init() {
        super.init()
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        eventsFileLocation = documentsDirectory?.appendingPathComponent("events.json")
        
        print(eventsFileLocation.path)
        
        if FileManager.default.fileExists(atPath: eventsFileLocation.path){
            load()
            // cleans out events before yesterday
            clearPastEvents()
        }
    }
    
    // function to load the events saved in local storage
    private func load() {
        do{
            
            // get the events from the local json file
            let decoder = JSONDecoder()
            let data = try Data(contentsOf: eventsFileLocation)
            let EVENTS = try decoder.decode([Event].self, from: data)
            
            // data manipulation to organize the events into days
            for event in EVENTS {
                
                // there is no date (returned as Date(timeIntervalSince1970: 0) && event.getLocalDate() == "")
                if event.getDate() == Date(timeIntervalSince1970: 0) && event.getLocalDate() == "" {
                    // if there are no days in the list add the No Date day
                    if events.isEmpty{
                        events.append(Days(day: "No Date", event: event))
                        
                    // if the No date day list exists, simply insert it into the list
                    } else {
                        events[0].insertEvent(event)
                    }
                // if it has a date (returned with a date or returned as Date(timeIntervalSince1970: 0) && event.getLocalDate() != ""))
                } else if event.getDate() != Date(timeIntervalSince1970: 0) || (event.getDate() == Date(timeIntervalSince1970: 0) && event.getLocalDate() != "") {
                    
                    // format dates, whether as Date or as String
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MMMM dd', 'yyyy' 'EEEE"
                    
                    // string to store the formatted "Day" which is in the form of "MMMM dd', 'yyyy' 'EEEE"
                    var day : String
                    
                    // if ther is no Date date, format the String version to "MMMM dd', 'yyyy' 'EEEE"
                    if event.getDate() == Date(timeIntervalSince1970: 0){
                        day = event.getLocalDate().dateToDay()
                        
                    // format the Date to String
                    } else {
                        day = dateFormatter.string(from: event.getDate())
                    }
                    
                    var i = 0
                    // if there are no days in the list add the day
                    if events.isEmpty {
                        events.append(Days(day: day, event: event))
                        
                    // if not check if the day already exists in the list
                    } else {
                        while day != "" && i<events.count {
                            if events[i].getDay() == day {
                                events[i].insertEvent(event)
                                day = ""
                            } else {
                                i += 1
                            }
                        }
                        
                        // if day is not in the list, make a new day
                        if i == events.count {
                            events.append(Days(day: day, event: event))
                        }
                    }
                    
                }
            }
        } catch {
            print("err \(error)")
        }
    }
    
    private func save() {
        do{
            // save the event list in order
            let encoder = JSONEncoder()
            var sEvents = [Event]()
            
            // for all the day in the event days
            for day in events {
                // put the event into the list to be saved
                sEvents.append(contentsOf: day.getEvents())
            }
            
            // try to save the event list
            let data = try encoder.encode(sEvents)
            let jsonString = String(data: data, encoding: .utf8)
            try jsonString?.write(to: eventsFileLocation, atomically: true, encoding: .utf8)
        } catch {
            print("err \(error)")
        }
    }
    
    // singleton for access on multiple views
    static let sharedInstance = EventsModel()
    
    // returns number of days
    func numberOfDays() -> Int {
        return events.count
    }
    
    // returns total number of events
//    func numberOfEvents() -> Int {
//        var sum = 0
//        for day in events {
//            sum += day.numberOfEvents()
//        }
//        return sum
//    }
    
    // returns a Day with its list of events
    func day(at index: Int) -> Days?{
        if index < numberOfDays() && index >= 0 {
            return events[index]
        }
        return nil
        
    }
    
    //removes an event from the list
    func removeEvent(day dI: Int,event eI: Int ) {
        if dI < numberOfDays() && dI >= 0 {
            events[dI].removeEvent(at: eI)
            if events[dI].numberOfEvents() == 0 {
                events.remove(at: dI)
            }
        }

        save()
    }
    
    // deletes an event from the list, if the Day is empty without event, removes the day too
    func deleteEvent(day dI: Int,event eI: Int ) {
        if dI < numberOfDays() && dI >= 0 {
            events[dI].deleteEvent(at: eI)
            if events[dI].numberOfEvents() == 0 {
                events.remove(at: dI)
            }
        }
        
        save()
    }
    
    // this is used for adding new events to the list
    func insertDay(_ day: Days) -> Int?{
        events.append(day)
        events.sort(by: order)
        save()
        
        var i = 0
        for d in events{
            if d.getDay() == day.getDay() {
                return i
            }
            
            i += 1
            
        }
        
        return nil
    }
    
    // this is for adding a new no date Day to the list
    func insertNoDate(_ day: Days){
        events.insert(day, at: 0)
        save()
    }
    
    // this is for adding an event to the list of events on the Day
    func addEvent(d: Int, e: Event) -> Int? {
        var x: Int? = nil
        if d < numberOfDays() && d >= 0 {
            x = events[d].addEvent(e)
        }
        save()
        
        return x
    }
    
    // this function sorts the Days in chronological order
    func order(_ day1: Days,_ day2: Days) -> Bool {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "MMMM dd', 'yyyy' 'EEEE"
        
        if day1.getDay() != "No Date" && day2.getDay() != "No Date" {
            if let d1 = dateformatter.date(from: day1.getDay()){
                if let d2 = dateformatter.date(from: day2.getDay()) {
                    return d1 < d2
                }
            }
        } else if day1.getDay() == "No Date" {
            
            return true
            
        } else if day2.getDay() == "No Date" {
            
            return false
        }
        
        return true
        
    }
    
    // checks if there is a match in event names?
    // where is this used?
    func checkEventName(name: String) -> Bool {
        for d in events {
            if d.checkEventName(name: name) {
                return true
            }
        }
        
        return false
    }
    
    // gets the list of 10 events with events and locations within the week along with the No Date events with locations
    func getMapEvents() -> [Event] {
        
        var retVal = [Event]()
        var count = 0
        let today = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        let week = Calendar.current.date(byAdding: .day, value: 7, to: today)! as Date
        for d in events{
            if d.getDay() == "No Date"{
                for e in d.getEvents(){
                    if let _ = e.getLocation(){
                        retVal.append(e)
                    }
                }
                
            } else {
                if d.numberOfEvents() < 10-count{
                    
                    for e in d.getEvents(){
                        if let _ = e.getLocation(){
                            if e.getDate() < week{
                                retVal.append(e)
                                count += 1
                            }
                        }
                    }
                    
                } else {
                    var index = 0
                    while count < 10 {
                        if let _ = d.getEvents()[index].getLocation(){
                            if d.getEvents()[index].getDate() < week {
                                retVal.append(d.getEvents()[index])
                                count += 1
                            }
                        }
                        index += 1
                    }
                }
            }
        }
        
        return retVal
    }
    
    // clear events of the past (yesterday and before)
    func clearPastEvents() {
        let yesterday = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())! as Date
        var dI = 0
        for d in events {
            // ignoring events with no date, delete days if it is in the past
            if d.getDay() != "No Date" {
                let date = NSDate(strDate: d.getDay().dayToDate()) as Date
                if date<yesterday {
                    var eI = 0
                    for _ in d.getEvents(){
                        deleteEvent(day: dI, event: eI)
                        eI += 1
                    }
                }
            }
            dI += 1
        }

    }
}
