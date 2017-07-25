//
//  MobileEatsService.swift
//  foodTruckFinder
//
//  Created by Lee, John on 7/22/17.
//  Copyright © 2017 Silver Lining. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

struct ServiceError: Error {
    let message: String
}

class MobileEatsService {
    typealias JSONDictionary = [String: Any]
    typealias MobileEatsResult = ([FoodTruck]?, String) -> ()
    
    enum Constant {
        static let statusCodeOK = 200
        static let searchBaseURL = "https://jirv8u2ell.execute-api.us-west-1.amazonaws.com/dev/foodtrucks/search"
        static let authHeader = "Bearer UOG4x25kRFF6bWtb-Sq8wP2J3mD9NZfSKbKdweHWO0nC7C-A5-ROuVH30RQ7_2tQrYpIAvOuIjI9OBtON8BtUb49la3UGXmc0B_tgTddC14pp0ceMTSHY_xxnyhtWXYx"
    }
    
    let defaultSession = URLSession(configuration: .default)
    
    func getSearchResults(latitude: Double, longitude: Double, radius: Int, completion: @escaping MobileEatsResult) {
        var urlComponents = URLComponents(string: Constant.searchBaseURL)
        let queryItemLatitude = URLQueryItem(name: "latitude", value: String(latitude))
        let queryItemLongitude = URLQueryItem(name: "longitude", value: String(longitude))
        let queryItemRadius = URLQueryItem(name: "radius_filter", value: String(radius))
        
        urlComponents?.queryItems = [queryItemLatitude, queryItemLongitude, queryItemRadius]

        guard let url = urlComponents?.url else { return }
        
        var urlRequest = URLRequest(url: url)

        urlRequest.addValue(Constant.authHeader, forHTTPHeaderField: "Authorization")
        
        let dataTask = defaultSession.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                completion([], "DataTask error: " + error.localizedDescription + "\n")
                return
            }
            
            if let data = data, let response = response as? HTTPURLResponse, response.statusCode == Constant.statusCodeOK {
                let foodTrucks: [FoodTruck]
                let errorMessage: String
                
                do {
                    foodTrucks = try self.updateSearchResults(data)
                    errorMessage = ""
                } catch let error {
                    foodTrucks = []
                    if let serviceError = error as? ServiceError {
                        errorMessage = serviceError.message
                    } else {
                        errorMessage = "unknown error"
                    }
                }
                
                DispatchQueue.main.async {
                    completion(foodTrucks, errorMessage)
                }
            }
        }

        dataTask.resume()
    }
    
    func updateSearchResults(_ data: Data) throws -> [FoodTruck] {
        var response: JSONDictionary?
        
        do {
            response = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
        } catch let parseError as NSError {
            throw ServiceError(message: "JSONSerialization error: \(parseError.localizedDescription)\n")
        }
        
        guard let body = response?["body"] as? [String: Any], let array = body["businesses"] as? [Any] else {
            throw ServiceError(message: "Empty JSON")
        }
        
        var foodTrucks: [FoodTruck] = []
        
        for foodTruckDictionary in array {
            if let foodTruckDictionary = foodTruckDictionary as? JSONDictionary,
                let distance = foodTruckDictionary["distance"] as? Double,
                let id = foodTruckDictionary["id"] as? String,
                let imageURLString = foodTruckDictionary["image_url"] as? String,
                let imageURL = URL(string: imageURLString),
                let coordinates = foodTruckDictionary["coordinates"] as? [String: Any],
                let latitude = coordinates["latitude"] as? Double,
                let longitude = coordinates["longitude"] as? Double,
                let name = foodTruckDictionary["name"] as? String,
                let rating = foodTruckDictionary["rating"] as? Double,
                let reviewCount = foodTruckDictionary["review_count"] as? Int,
                let location = foodTruckDictionary["location"] as? [String: Any],
                let displayAddress = location["display_address"] as? [Any],
                displayAddress.count >= 1,
                let displayAddressLine1 = displayAddress[0] as? String {
                
                let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
                let foodTruck = FoodTruck(distance: distance, id: id, imageURL: imageURL, rating: rating, reviewCount: reviewCount, coordinate: coordinate, title: name, subtitle: displayAddressLine1)
                foodTrucks.append(foodTruck)
                
            } else {
                throw ServiceError(message: "Problem parsing foodTruckDictionary\n")
            }
        }
        
        return foodTrucks
    }
}
