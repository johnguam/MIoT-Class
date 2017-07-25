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
    
    let distance: Double?
    let id: String?
    let imageURL: URL?
    let rating: Double?
    let reviewCount: Int?

    // MKAnnotation properties
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?

    init(distance: Double, id: String, imageURL: URL, rating: Double, reviewCount: Int, coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.distance = distance
        self.id = id
        self.imageURL = imageURL
        self.rating = rating
        self.reviewCount = reviewCount
        
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}
