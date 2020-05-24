// Nelly Shieh
// nichunsh@usc.edu
//
//  Event.swift
//  MappIt
//
//  Created by Nelly Shieh on 4/15/20.
//  Copyright © 2020 Nelly Shieh. All rights reserved.
//

import Foundation
import CoreLocation


// string extensions for formatting strings
extension String {

    func localToUTC() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        //dateFormatter.calendar = NSCalendar.current
        dateFormatter.timeZone = TimeZone.current
        
        let UTC = dateFormatter.date(from: self)
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        if let x = UTC {
            return dateFormatter.string(from: x)
        }
        
        return self
    }

    func UTCTolocal() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        let local = dateFormatter.date(from: self)
        dateFormatter.timeZone = TimeZone.current

        
        if let x = local {
            return dateFormatter.string(from: x)
        }
        
        return self
        
    }
    
    func localToDay() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        
        let day = dateFormatter.date(from: self)
        dateFormatter.dateFormat = "MMMM dd', 'yyyy' 'EEEE"
        
        if let x = day {
            return dateFormatter.string(from: x)
        }
        
        return self
        
    }
    
    func dateToDay() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let day = dateFormatter.date(from: self)
        dateFormatter.dateFormat = "MMMM dd', 'yyyy' 'EEEE"
        
        if let x = day {
            return dateFormatter.string(from: x)
        }
        
        return self
        
    }
    
    func dayToDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd', 'yyyy' 'EEEE"
        
        let day = dateFormatter.date(from: self)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        
        if let x = day {
            return dateFormatter.string(from: x)
        }
        
        return self
        
    }
    
    
    func localToTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        
        let day = dateFormatter.date(from: self)
        dateFormatter.dateFormat = "HH:mm"
        
        if let x = day {
            return dateFormatter.string(from: x)
        }
        
        return self
        
    }
    
    func localToDate() -> String {
         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
         
         let day = dateFormatter.date(from: self)
         dateFormatter.dateFormat = "yyyy-MM-dd"
         
         if let x = day {
             return dateFormatter.string(from: x)
         }
         
         return self
         
     }
    
    func dropLastSpace() -> String {
        var x = self
        if x != "" {
            if x.last == " "
            {
                x.remove(at: x.index(before: x.endIndex))
                return x
            }

        }
        
        return self
    }
    
}

// extensions for initializing new dates from string
extension NSDate{
    convenience init(stringDate: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        guard let date = dateFormatter.date(from: stringDate) else {
            self.init()
            return
        }
        self.init(timeInterval:0, since:date)
    }
    
    convenience init(strDate: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = dateFormatter.date(from: strDate) else {
            self.init()
            return
        }
        self.init(timeInterval:0, since:date)
    }
    
    convenience init(strTime: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        guard let date = dateFormatter.date(from: strTime) else {
            self.init()
            return
        }
        self.init(timeInterval:0, since:date)
    }
    
}

// Days help organize the event list
class Days {
    private var day: String
    private var events = [Event]()
    
    init(day: String, event:Event?) {
        self.day = day
        if let e = event {
            self.events.append(e)
        }
    }
    
    // gets lists of events happening on that day
    func getEvents() -> [Event] {
        return events
    }
    
    // get the Day string indicating the day of the events
    func getDay() -> String {
        return day
    }
    
    // returns a specific event for the day
    func event(at index: Int) -> Event? {
        if index<events.count && index >= 0{
            return events[index]
        }
        
        return nil
        
    }
    
    // returns the number of events for the day
    func numberOfEvents() -> Int {
        return events.count
    }
    
    // for loading list (it is saved in order, so sorting is unnecessary)
    func insertEvent(_ event: Event) {
        events.append(event)
    }
    
    // for adding event ( when adding a new event to list, need to sort it chronologically) and returns the location of the event
    func addEvent(_ event: Event) -> Int?{
        events.append(event)
        events.sort(by: order)
        
        var i = 0
        for e in events {
            if e == event{
                return i
            }
            
            i += 1
        }
        
        return nil
    }
    
    // for sorting the event in chronological order
    func order(event1: Event, event2: Event) -> Bool {
        
        if let e1 = event1.getDT() {
            if let e2 = event2.getDT() {
                if e1 == e2{
                    return event1.getDate()<event2.getDate()
                } else {
                    return !(event1.getDT() ?? false)
                }
            } else {
                return true
            }
        } else {
            return true
        }
    }
    
    // checks if event name matches
    func checkEventName(name: String) -> Bool {
        for e in events {
            if e.getEventName() == name {
                return true
            }
        }
        
        return false
    }
    
    // deletes an event from the list, including the image that is associated with the event if it exists
    func deleteEvent(at index: Int) {
        
        if index<events.count && index >= 0{
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            if let path = documentsURL?.appendingPathComponent("\(events[index].getEventName().replacingOccurrences(of: "/", with: "")).png").path{
                if FileManager.default.fileExists(atPath: path) {
                    do{
                        try FileManager.default.removeItem(atPath: path)
                        
                    } catch{
                        
                        print("err \(error)")
                    }
                }
            }
            events.remove(at: index)
        }
        
    }
    
    // removes an event from the list
    func removeEvent(at index: Int) {

        if index<events.count && index >= 0{
            events.remove(at: index)
        }

    }
}

// coordinates of the event
struct Coordinate: Equatable, Codable {
    var latitude: Double
    var longitude: Double
}

// address of the event
struct Venue: Equatable, Codable {
    var name: String
    var postalCode: String
    var city: String
    var state: String
    var country: String
    var address: String
}

// information to save about the event
struct Event: Equatable, Codable {
    private var eventName: String
    private var location: Coordinate?
    private var localDate: String
    private var localTime: String
    private var date: Date?
    private var details: String
    private var venue: Venue
    private var dateTime: Bool?
    
    
    init(name: String, location: Coordinate?, localDate: String, localTime: String, date: Date?, details: String, venue:Venue, dateTime: Bool?) {
        self.eventName = name
        self.location = location
        //self.imagePath = imagePath
        self.localDate = localDate
        self.localTime = localTime
        self.date = date
        self.details = details
        self.venue = venue
        self.dateTime = dateTime
    }
    
    // to get name of event
    func getEventName() -> String {
        return eventName
    }
    
    // to get location of event (coordinates
    func getLocation() -> Coordinate? {
        return location
    }
    
    // to get local date if date DNE
    func getLocalDate() -> String {
        return localDate
    }
    
    // if time is specified for the event
    func getLocalTime() -> String {
        return localTime
    }
    
    // if date is specified for the event as Date else returns Date(timeIntervalSince1970: 0)
    func getDate() -> Date {
        if let d = date {
            return d
        }
        
        return Date(timeIntervalSince1970: 0)
    }
    
    // gets a string of details abou the event if application
    func getDetails() -> String {
        return details
    }
    
    // returns the venue of the event
    func getVenue() -> Venue {
        return venue
    }
    
    // returns the state of date of the event dt, date, or none
    func getDT() -> Bool? {
        return dateTime
    }
    
}
