// Nelly Shieh
// nichunsh@usc.edu
//
//  File.swift
//  MappIt
//
//  Created by Nelly Shieh on 4/27/20.
//  Copyright © 2020 Nelly Shieh. All rights reserved.
//

import Foundation

// This is the structure of the json from openWeather API

struct W: Decodable {
    var daily: [Daily]
    var current: Current
}

struct Daily:Decodable {
    var dt: Int
    var temp: Temperature
    var weather: [Weather]
}

struct Temperature: Decodable {
    var min: Double
    var max: Double
    
}

struct Weather: Decodable {
    var main: String
}

struct Current: Decodable {
    var temp: Double
    var weather: [Weather]
}
