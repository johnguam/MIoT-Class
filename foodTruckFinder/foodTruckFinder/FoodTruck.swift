//
//  FoodTruck.swift
//  foodTruckFinder
//
//  Created by Lee, John on 7/23/17.
//  Copyright © 2017 Silver Lining. All rights reserved.
//

import Foundation
import MapKit

class FoodTruck: NSObject, MKAnnotation {
    
    let displayPhone: String?
    let phone: String?
    let distance: Double?
    let id: String
    let imageURL: URL?
    let rating: Double?
    let reviewCount: Int?

    // MKAnnotation properties
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    
    var additionalDetails: FoodTruckAdditionalDetails?

    init(displayPhone: String?, phone: String?, distance: Double?, id: String, imageURL: URL?, rating: Double?, reviewCount: Int?, coordinate: CLLocationCoordinate2D, title: String, subtitle: String?) {
        self.phone = phone
        self.displayPhone = displayPhone
        self.distance = distance
        self.id = id
        self.imageURL = imageURL
        self.rating = rating
        self.reviewCount = reviewCount
        
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        
        self.additionalDetails = nil
    }
}

class FoodTruckAdditionalDetails {
    let photos: [URL]?
//    let startHours: Int?
//    let endHours: Int?
//    let phone: Int?
//    let displayPhone: String?
    
    init(photos: [URL]?) {//, startHours: Int, endHours: Int, phone: Int, displayPhone: String) {
        self.photos = photos
        //        self.startHours = startHours
//        self.endHours = endHours
//        self.phone = phone
    }
}
