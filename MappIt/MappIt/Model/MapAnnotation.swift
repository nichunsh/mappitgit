// Nelly Shieh
// nichunsh@usc.edu
//
//  MapAnnotation.swift
//  MappIt
//
//  Created by Nelly Shieh on 4/27/20.
//  Copyright © 2020 Nelly Shieh. All rights reserved.
//

import Foundation
import MapKit


// this defines the data in each annotation object with date
class Annotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var order: Int

    
    init(c: CLLocationCoordinate2D, e: String, dw: String, o: Int) {
        coordinate = c
        title = e
        subtitle = dw
        order = o
    }
    
}

// this defines the data in each annotation object without date
class DatelessAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(c: CLLocationCoordinate2D, e: String, dw: String) {
        coordinate = c
        title = e
        subtitle = dw
    }
    
}
