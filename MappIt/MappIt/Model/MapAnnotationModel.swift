// Nelly Shieh
// nichunsh@usc.edu
//
//  MapAnnotationModel.swift
//  MappIt
//
//  Created by Nelly Shieh on 4/27/20.
//  Copyright © 2020 Nelly Shieh. All rights reserved.
//

import Foundation
import MapKit

// adapted from apple source code
class MapAnnotationModel {
    private var annotations = [Annotation] ()
    private var dateless = [DatelessAnnotation]()
    
    init() {
        
    }
    
    // to retrieve all items to annotate
    func getEventAnnotations() -> [MKAnnotation] {
        return annotations + dateless
    }
    
    // to get the coordinates of the most recent event for centering the map around it
    func getMostRecentCoordinates() -> CLLocationCoordinate2D? {
        if annotations.count != 0 {
            for a in annotations{
                if a.order == 0{
                    return a.coordinate
                }
            }
            
        } else if dateless.count != 0 {
            return dateless.randomElement()?.coordinate
        }
        
        return nil
    }
    
    // to delete all annotations from the current view
    func clearAnnotations() {
        annotations.removeAll()
        dateless.removeAll()
    }
    
    // load the new set of annotations
    func loadEvents(events: [Event], completion: @escaping(_ success: [MKAnnotation]) -> Void) {
        clearAnnotations()
        // so that map updates only after all the information is retreieved
        DispatchQueue.global(qos: .userInitiated).async {
            let group = DispatchGroup()
            var count = 0
            
            // for all events to annotate
            for e in events{
                
                // it has to have a location
                if let c = e.getLocation(){
                    
                    // get the coordinates
                    let coord = CLLocationCoordinate2D(latitude:c.latitude , longitude: c.longitude)
                    
                    // formats date and time
                    let dateF = DateFormatter()
                    dateF.dateFormat = "yyyy-MM-dd"
                    
                    let timeF = DateFormatter()
                    timeF.dateFormat = "HH:mm"
                    
                    // either Date(timeIntervalSince1970: 0) or an actural date Date
                    let date = e.getDate()
                    
                    // initialize variables for subtitle string
                    var day = ""
                    var time = ""
                    var weather = ""
                    
                    // DT is datetime, T is both, F is date, nil is no date
                    // if it has a date
                    if let type = e.getDT(){
                        // get today's date as a string
                        let td = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
                        let today = dateF.string(from: td)
                        
                        // if there is a date
                        if date != Date(timeIntervalSince1970: 0){
                            // if it is a datetime item
                            if type {
                                day = dateF.string(from: date)
                                time = timeF.string(from: date)
                                
                            //if it is a date item
                            } else {
                                day = dateF.string(from: date)
                                time = ""
                            }
                        // if there is only string date
                        } else {
                            //will return "" if there is no date or time
                            day = e.getLocalDate()
                            time = e.getLocalTime()
                        }
                        
                        // if the event happens today
                        if day == today{
                            group.enter()
                            
                            // get the current weather, the count is used to help keep the chronological order of events
                            self.getCurrentWeather(lat: c.latitude, long: c.longitude, o: count) { (today, o) in
                                
                                // for the weather description
                                var ww = [String]()
                                for x in today.weather {
                                    ww.append(x.main)
                                }
                                
                                // in a single string
                                weather = "\(today.temp)˚F \(ww.joined(separator: ", "))"
                                
                                // add it to annotations
                                self.annotations.append(Annotation(c: coord, e: e.getEventName(), dw: weather, o: o))
                                
                                // makes sure it is done before updating map
                                group.leave()
                            }
                            
                            // this gets run on main thread,
                            count += 1
                        } else {
                        
                        group.enter()
                            
                            // get future weather for specific date
                            self.getWeather(lat: c.latitude, long: c.longitude, d: day, o: count) { (w, o) in
                            var ww = [String]()
                            for x in w.weather {
                                ww.append(x.main)
                            }
                            weather = "\(w.temp.min)~\(w.temp.max)˚F \(ww.joined(separator: ", "))"
                            
                            // add it to annotations
                            self.annotations.append(Annotation(c: coord, e: e.getEventName(), dw: "\(day) | \(time)\n\(weather)", o: o ))
                            group.leave()
                            
                            
                            }
                            count += 1
                        }
                    } else {
                        group.enter()
                        // for dateless events, get current weather at location
                        self.getCurrentWeather(lat: c.latitude, long: c.longitude) { (today, o) in
                            var ww = [String]()
                            for x in today.weather {
                                ww.append(x.main)
                            }
                            
                            weather = "\(today.temp)˚F \(ww.joined(separator: ", "))"
                            self.dateless.append(DatelessAnnotation(c: coord, e: e.getEventName(), dw: weather))
                            group.leave()
                        }
                    }
                }
            }
            // wait for all events and weather data t be retreived
            group.wait()
            
            // pass the annotations upon completion
            DispatchQueue.main.async {
                completion(self.annotations + self.dateless)
            }
        }
    }
    
    // filters for weather forecast
    func getWeather(lat: Double, long: Double, d: String, o:Int = 11,  onSuccess: @escaping (Daily, Int)->Void) {
        if let url = URL(string: "https://api.openweathermap.org/data/2.5/onecall?lat=\(lat)&lon=\(long)&units=imperial&appid=9479dd67eb9ce8e26d86dbe9b9b2557d" ) {
            URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
                if let data = data {
                    do{
                        let w = try JSONDecoder().decode(W.self, from: data)
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        
                        for day in w.daily {
                            let date = Date(timeIntervalSince1970: TimeInterval(day.dt))
                            
                            if dateFormatter.string(from: date) == d {
                                onSuccess(day, o)
                            }
                        }
                        
                        return
                        
                    } catch {
                        print(error)
                        exit(1)
                    }
                }
            }.resume()
        }
    }
    
    
    // gets current weather
    func getCurrentWeather(lat: Double, long: Double, o:Int = 11, onSuccess: @escaping (Current, Int)->Void) {
        if let url = URL(string: "https://api.openweathermap.org/data/2.5/onecall?lat=\(lat)&lon=\(long)&units=imperial&appid=9479dd67eb9ce8e26d86dbe9b9b2557d") {
            URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
                if let data = data {
                    do{
                        let w = try JSONDecoder().decode(W.self, from: data)
                        onSuccess(w.current, o)
                    } catch {
                        print(error)
                    }
                }
            }.resume()
        }
    }
}

