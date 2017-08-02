//
//  ListViewController.swift
//  foodTruckFinder
//
//  Created by Lee, John on 7/16/17.
//  Copyright © 2017 Silver Lining. All rights reserved.
//

import UIKit
import SDWebImage
import CoreLocation

class ListViewController: UIViewController {

    enum Constant {
        //static let latitude = 37.3533530886479
        //static let longitude = -122.013784749846
        static let radius = 500
        static let showTruckDetailViewIdentifer = "ShowTruckDetailView"
    }
    
    fileprivate var locationManager = CLLocationManager()
    var currentCoordinate: CLLocationCoordinate2D?

    @IBOutlet var tableView: UITableView!
    var searchResults: [FoodTruck] = []
    let mobileEatsService = MobileEatsService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        tableView.dataSource = self
        tableView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - UITableView

extension ListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TruckTableViewCell(style: .subtitle, reuseIdentifier: nil)
        
        let foodTruck = searchResults[indexPath.row]
        cell.textLabel?.text = foodTruck.title
        cell.detailTextLabel?.text = foodTruck.subtitle
        cell.imageView?.sd_setImage(with: foodTruck.imageURL, placeholderImage: UIImage(named: "truck.png"))

        return cell
    }
  
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Constant.showTruckDetailViewIdentifer, sender: self)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constant.showTruckDetailViewIdentifer,
            let truckDetailVC = segue.destination as? TruckDetailViewController,
            let indexPath = tableView.indexPathForSelectedRow {
            let foodTruck = searchResults[indexPath.row]
            truckDetailVC.currentFoodTruck = foodTruck
        }
    }
}

extension ListViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
            break
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Only get location once
        manager.stopUpdatingLocation()
        
        if let currentLocation = locations.last {
            self.currentCoordinate = currentLocation.coordinate
            
            guard let currentCoordinate = self.currentCoordinate else {
                return
            }
            
            mobileEatsService.getSearchResults(latitude: currentCoordinate.latitude, longitude: currentCoordinate.longitude, radius: Constant.radius) { results, errorMessage in
                
                if let results = results {
                    self.searchResults = results
                    self.tableView.reloadData()
                    self.tableView.setContentOffset(CGPoint.zero, animated: false)
                }
                
                if !errorMessage.isEmpty { print("Search error: " + errorMessage) }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error)")
    }
}


