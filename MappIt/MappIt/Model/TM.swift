// Nelly Shieh
// nichunsh@usc.edu
//
//  Page.swift
//  MappIt
//
//  Created by Nelly Shieh on 4/16/20.
//  Copyright © 2020 Nelly Shieh. All rights reserved.
//

import Foundation


// https://jquery.develop-bugs.com/article/11106722/Pulling+data+from+TicketMasters+API+(Swift+4.0+Decodable)

// This is the structure of the json from ticketmaster API

struct TM: Decodable {
    let _embedded: TMEmbedded?
    let _links: TMLink
}

struct TMLink: Decodable{
    let next: TMURL?
    let last: TMURL?

}

struct TMURL: Decodable {
    let href: String
}

struct TMEmbedded: Decodable {
    let events: [TMEvent]
}

struct TMEvent: Decodable {
    let name: String
    let id: String
    //let url: String
    var images: [TMImages]
    let dates: TMDates
    let classifications: [TMClassifications]?
    let _embedded : TMOtherEmbedded?

}

struct TMImages: Decodable {
    let ratio: String?
    let url: String
}

struct TMDates: Decodable {
    let start: TMStart
}

struct TMStart: Decodable {
    let localDate: String // where the event is happening
    let localTime: String? // where the event is happening
    let dateTime: String? // UTC
}

struct TMClassifications: Decodable{
    let segment: TMName
    let genre: TMName?
    let subGenre: TMName?
}

struct TMName: Decodable {
    let name: String
}

struct TMOtherEmbedded: Decodable {
    let venues: [TMVenues]?
}

struct TMVenues: Decodable {
    let name : String
    let postalCode: String?
    let city: TMCity
    let state: TMState?
    let country: TMCountry
    let address: TMAddress?
    let location: TMLocation?

}

struct TMCity: Decodable {
    let name: String
}

struct TMState: Decodable {
    let name: String
    let stateCode: String?
}

struct TMCountry: Decodable {
    let name: String
    let countryCode: String
}

struct TMAddress: Decodable{
    let line1: String
    let line2: String?
}

struct TMLocation: Decodable {
    let longitude: String
    let latitude: String
}
