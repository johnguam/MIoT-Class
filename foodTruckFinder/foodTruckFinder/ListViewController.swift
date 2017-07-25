//
//  ListViewController.swift
//  foodTruckFinder
//
//  Created by Lee, John on 7/16/17.
//  Copyright © 2017 Silver Lining. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {

    enum Constant {
        static let latitude = 37.3533530886479
        static let longitude = -122.013784749846
        static let radius = 500
    }

    @IBOutlet private var tableView: UITableView!
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
        
        //TODO: For Use Later
        //performSegue(withIdentifier: "ShowTruckDetailView", sender: self)
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
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        
        let foodTruck = searchResults[indexPath.row]
        cell.textLabel?.text = foodTruck.title
        cell.detailTextLabel?.text = foodTruck.subtitle
        
        // TODO: Set Image for Cell
        return cell
    }
  
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let foodTruck = searchResults[indexPath.row]
        // Launch food truck detail page view

    }
}

