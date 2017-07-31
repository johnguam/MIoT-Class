//
//  TruckTableViewCell.swift
//  foodTruckFinder
//
//  Created by Lee, John on 7/29/17.
//  Copyright © 2017 Silver Lining. All rights reserved.
//

import UIKit

class TruckTableViewCell: UITableViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.imageView?.frame = CGRect(x: 5, y: 5, width: 40, height: 32.5)
        let imageWidth = self.imageView?.image?.size.width
        
        guard let textLabel = self.textLabel else {
            return
        }
        guard let detailTextLabel = self.detailTextLabel else {
            return
        }
        if Double(imageWidth!) > 0.0 {
            textLabel.frame = CGRect(x: 55, y: textLabel.frame.origin.y, width: textLabel.frame.size.width, height: textLabel.frame.size.height)
            detailTextLabel.frame = CGRect(x: 55, y: detailTextLabel.frame.origin.y, width: detailTextLabel.frame.size.width, height: detailTextLabel.frame.size.height)
        }
    }
}
