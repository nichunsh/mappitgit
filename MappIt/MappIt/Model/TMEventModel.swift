// Nelly Shieh
// nichunsh@usc.edu
//
//  TMEventModel.swift
//  MappIt
//
//  Created by Nelly Shieh on 4/15/20.
//  Copyright © 2020 Nelly Shieh. All rights reserved.
//

import Foundation

// for data processing of the ticketmaster event and API
class TMEventModel {
    private let ACCESS_KEY = "FWiHVRr8Y7ptBozAjTGnYuScGSXNaGTl"
    private let BASE_URL = "https://app.ticketmaster.com"
    private let SORT = "date,asc"
    
    var keyword: String?
    var city: String?
    var startDatetime: String?
    var endDateTime: String?
    
    private var message = "Load More..."
    private var links: TMLink?
    private var tmEvents: [TMEvent] = []
    
    // so that the TM events can be accessed in multiple views
    static let sharedInstance = TMEventModel()
    
    // formats and runs the API, input checking, etc, for the ticketmaster search of events
    func getEvents(onSuccess: @escaping ([TMEvent])->Void) {
        var k = ""
        var c = ""
        var s = ""
        var e = ""
        
        if var a = keyword {
            if a != "" {
                if a.last == " "
                {
                    a.remove(at: a.index(before: a.endIndex))
                }
                let p = a.replacingOccurrences(of: " ", with: "%20")
                k = "&keyword=\(p)"
            }
        }
        
        if var a = city {
            if a != "" {
                if a.last == " "
                {
                    a.remove(at: a.index(before: a.endIndex))
                }
                let p = a.replacingOccurrences(of: " ", with: "%20")
                c = "&city=\(p)"
            }
        }
        
        if let a = startDatetime {
            if a != "" {
                s = "&startDateTime=\(a)"
            }
        }
        
        if let a = endDateTime {
            if a != "" {
                e = "&endDateTime=\(a)"
            }
        }
        
        
        if let url = URL(string: "https://app.ticketmaster.com/discovery/v2/events?apikey=FWiHVRr8Y7ptBozAjTGnYuScGSXNaGTl\(k)&locale=*\(s)\(e)\(c)&sort=\(SORT)") {
            URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
                if let data = data {
                    do{
                        let tm = try JSONDecoder().decode(TM.self, from: data)
                        self.links = tm._links
                        if let x = tm._embedded {
                            self.tmEvents = x.events
                            if self.tmEvents.count < 20{
                                self.message = "All Results Loaded"
                            }
                        } else {
                            self.message = "No Events."
                        }
                        onSuccess(self.tmEvents)
                    } catch {
                        print(error)
                        exit(1)
                    }
                }
            }.resume()
        }
    }
    

    // run API for more events from the links that the previous API provided and checks if it is the last page of events
    func getMoreEvents(onSuccess: @escaping ([TMEvent]) -> Void) {
        if let link = links {
            guard let next = link.next else { return }
            guard let last = link.last else { return }
            guard !next.href.isEmpty else { return }
            if last.href == next.href {
                message = "All Results Loaded"
            }
            
            if let url = URL(string: "\(BASE_URL)\(next.href)&apikey=\(ACCESS_KEY)") {
                URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
                    if let data = data {
                        do{
                            let tm = try JSONDecoder().decode(TM.self, from: data)
                            self.links = tm._links
                            if let x = tm._embedded {
                                self.tmEvents.append(contentsOf: x.events)
                            }
                            onSuccess(self.tmEvents)
                        } catch {
                            print(error)
                            exit(1)
                        }
                    }
                }.resume()
            }
            
            
        }
        
    }
    
    func reset() {
        tmEvents.removeAll()
        keyword = ""
        city = ""
        startDatetime = ""
        endDateTime = ""
        message = "Load More..."
        
        
    }
    
    func numberOfTMEvents() -> Int {
        return tmEvents.count
    }
    
    func getMessage() -> String {
        return message
    }
    
    func tmEvent(at index: Int) -> TMEvent? {
        if index < tmEvents.count && index >= 0 {
            return tmEvents[index]
        }
        return nil
    }
    
    func updateTMEventImages(img: [TMImages], at index: Int) {
        if index < tmEvents.count && index >= 0 {
            tmEvents[index].images = img
        }
    }
}
