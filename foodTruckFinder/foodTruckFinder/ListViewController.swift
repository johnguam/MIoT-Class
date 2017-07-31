//
//  ListViewController.swift
//  foodTruckFinder
//
//  Created by Lee, John on 7/16/17.
//  Copyright © 2017 Silver Lining. All rights reserved.
//

import UIKit
import SDWebImage

class ListViewController: UIViewController {

    enum Constant {
        static let latitude = 37.3533530886479
        static let longitude = -122.013784749846
        static let radius = 500
        static let showTruckDetailViewIdentifer = "ShowTruckDetailView"
    }

    @IBOutlet var tableView: UITableView!
    var searchResults: [FoodTruck] = []
    let mobileEatsService = MobileEatsService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        mobileEatsService.getSearchResults(latitude: Constant.latitude, longitude: Constant.longitude, radius: Constant.radius) { results, errorMessage in
            
            if let results = results {
                self.searchResults = results
                self.tableView.reloadData()
                self.tableView.setContentOffset(CGPoint.zero, animated: false)
            }
            
            if !errorMessage.isEmpty { print("Search error: " + errorMessage) }
        }
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

