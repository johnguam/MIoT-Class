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
    typealias TruckDetailsResult = (FoodTruck?, String) -> ()
    
    enum Constant {
        static let statusCodeOK = 200
        static let searchBaseURL = "https://jirv8u2ell.execute-api.us-west-1.amazonaws.com/dev/foodtrucks/search"
        static let detailsBaseURL = "https://jirv8u2ell.execute-api.us-west-1.amazonaws.com/dev/foodtrucks"
        static let authHeader = "Bearer UOG4x25kRFF6bWtb-Sq8wP2J3mD9NZfSKbKdweHWO0nC7C-A5-ROuVH30RQ7_2tQrYpIAvOuIjI9OBtON8BtUb49la3UGXmc0B_tgTddC14pp0ceMTSHY_xxnyhtWXYx"
        static let metersPerMile: Double = 1609.344
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
            var displayPhone: String? = nil
            var phone: String? = nil
            var distance: Double? = nil
            var imageURL: URL? = nil
            var rating: Double? = nil
            var reviewCount: Int? = nil
            var displayAddressLine1: String? = nil
            var displayAddressLine2: String? = nil
            var subtitle: String? = nil
            
            if let foodTruckDictionary = foodTruckDictionary as? JSONDictionary,
                let id = foodTruckDictionary["id"] as? String,
                let coordinates = foodTruckDictionary["coordinates"] as? [String: Any],
                let latitude = coordinates["latitude"] as? Double,
                let longitude = coordinates["longitude"] as? Double,
                let name = foodTruckDictionary["name"] as? String,
                let location = foodTruckDictionary["location"] as? [String: Any] {
                
                let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
                
                if let imageURLString = foodTruckDictionary["image_url"] as? String {
                    imageURL = URL(string: imageURLString)
                }
                
                displayPhone = foodTruckDictionary["display_phone"] as? String
                phone = foodTruckDictionary["phone"] as? String
                distance = foodTruckDictionary["distance"] as? Double
                rating = foodTruckDictionary["rating"] as? Double
                reviewCount = foodTruckDictionary["review_count"] as? Int
                
                // Display address
                if let displayAddress = location["display_address"] as? [Any],
                    displayAddress.count >= 1 {
                    displayAddressLine1 = displayAddress[0] as? String
                    if displayAddress.count >= 2 {
                        displayAddressLine2 = displayAddress[1] as? String
                    }
                }
                
                // Distance to miles
                if let distance = distance {
                    let distanceMiles = distance / Constant.metersPerMile
                    subtitle = String(format:"%.2f", distanceMiles) + " mi"
                }
                
                let foodTruck = FoodTruck(displayPhone: displayPhone, phone: phone, displayAddressLine1: displayAddressLine1, displayAddressLine2: displayAddressLine2, distance: distance, id: id, imageURL: imageURL, rating: rating, reviewCount: reviewCount, coordinate: coordinate, title: name, subtitle: subtitle)
                foodTrucks.append(foodTruck)
                
            } else {
                throw ServiceError(message: "Problem parsing foodTruckDictionary\n")
            }
        }
        
        return foodTrucks
    }
    
    func getFoodTruckDetails(foodTruck: FoodTruck, completion: @escaping TruckDetailsResult) {
        
        let urlString = Constant.detailsBaseURL + "/" + foodTruck.id
        
        guard let url = URL(string: urlString) else {
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.addValue(Constant.authHeader, forHTTPHeaderField: "Authorization")
        
        let dataTask = defaultSession.dataTask(with: urlRequest) {
            (data, response, error) in
            if let error = error {
                completion(nil, "DataTask error: " + error.localizedDescription + "\n")
                return
            }
            
            if let data = data, let response = response as? HTTPURLResponse, response.statusCode == Constant.statusCodeOK {
                let errorMessage: String
                var updatedFoodTruck = foodTruck
                
                do {
                    updatedFoodTruck = try self.updateFoodTruckDetails(data, foodTruck: foodTruck)
                    errorMessage = ""
                } catch let error {
                    if let serviceError = error as? ServiceError {
                        errorMessage = serviceError.message
                    } else {
                        errorMessage = "unknown error"
                    }
                }
                
                DispatchQueue.main.async {
                    completion(updatedFoodTruck, errorMessage)
                }
            }
        }
        
        dataTask.resume()
    }
    
    func updateFoodTruckDetails(_ data: Data, foodTruck: FoodTruck) throws -> FoodTruck {
        var response: JSONDictionary?
        let currentFoodTruck = foodTruck
        var photos: [URL]? = nil
        var displayPhone: String? = nil
        
        do {
            response = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
        } catch let parseError as NSError {
            throw ServiceError(message: "JSONSerialization error: \(parseError.localizedDescription)\n")
        }
        
        guard let foodTruckDictionary = response?["body"] as? JSONDictionary else {
            throw ServiceError(message: "Empty JSON")
        }
    
        displayPhone = foodTruckDictionary["display_phone"] as? String
        
        if let photosStrings = foodTruckDictionary["photos"] as? [String] {
            photos = photosStrings.map {
                return URL(string: $0)!
            }
        }
        
        let additionalDetails = FoodTruckAdditionalDetails(photos: photos)
        currentFoodTruck.additionalDetails = additionalDetails
        
        return currentFoodTruck
    }
}
