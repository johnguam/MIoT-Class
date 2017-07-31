//
//  TruckDetailViewController.swift
//  foodTruckFinder
//
//  Created by Lee, John on 7/16/17.
//  Copyright © 2017 Silver Lining. All rights reserved.
//

import UIKit
import MapKit

class TruckDetailViewController: UIViewController {
    
    enum Constant {
        static let photoCollectionCellIdentifer = "PhotoCollectionCell"
        static let regionRadius: CLLocationDistance = 1000
    }
    
    var currentFoodTruck: FoodTruck?
    let mobileEatsService = MobileEatsService()
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var phoneButton: UIButton!
    @IBOutlet var addressButton: UIButton!
    
    var urls = [URL]()
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        guard var currentFoodTruck = self.currentFoodTruck else {
            return
        }
        
        nameLabel?.text = currentFoodTruck.title
        
        phoneButton.setTitle(currentFoodTruck.displayPhone, for: .normal)
        //addressButton.setTitle(currentFoodTruck.subtitle, for: .normal)
        
        navigationItem.title = currentFoodTruck.title
        
        mobileEatsService.getFoodTruckDetails(foodTruck: currentFoodTruck) { results, errorMessage in
            if let results = results {
                self.currentFoodTruck = results
                self.collectionView.reloadData()
            }
            
            if !errorMessage.isEmpty { print("Search error: " + errorMessage) }
        }
    }
    
    @IBAction func callPhoneNumber(_ sender: UIButton) {
        guard let currentFoodTruck = self.currentFoodTruck, let phoneNumber = currentFoodTruck.phone else {
            return
        }
        
        if let url = URL(string: "tel://\(phoneNumber)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func openMap(_ sender: UIButton) {
        guard let currentFoodTruck = self.currentFoodTruck else {
            return
        }
        
        let regionSpan = MKCoordinateRegionMakeWithDistance(currentFoodTruck.coordinate, Constant.regionRadius, Constant.regionRadius)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: currentFoodTruck.coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = currentFoodTruck.title
        mapItem.openInMaps(launchOptions: options)
    }
    
}

extension TruckDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let photos = self.currentFoodTruck?.additionalDetails?.photos {
            return photos.count
        } else {
            return 1
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.photoCollectionCellIdentifer, for: indexPath)
        let imageView = UIImageView()

        cell.contentView.addSubview(imageView)
       
        // Set imageView constraints
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: cell.contentView.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor).isActive = true
        
        if let photos = self.currentFoodTruck?.additionalDetails?.photos {
            imageView.sd_setImage(with: photos[indexPath.row], placeholderImage: UIImage(named: "truck.png"))
        } else {
            imageView.sd_setImage(with: currentFoodTruck?.imageURL, placeholderImage: UIImage(named: "truck.png"))
        }
    
        return cell
    }
}

extension TruckDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt sizeForItemAtIndexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
}
