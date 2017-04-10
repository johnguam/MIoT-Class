//
//  CustomLightViewController.swift
//  MiotTask1
//
//  Created by Lee, John on 3/26/17.
//  Copyright © 2017 John Lee. All rights reserved.
//

import UIKit

class CustomLightViewController: UIViewController {

    var colorWheel: ColorWheel!
    var colorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        colorWheel = ColorWheel(frame: CGRect(x: 0, y: 0, width: 300, height: 300), color: UIColor.red)
        colorLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 205, height: 205))

        addColorWheel()
        addColorLabel()

        colorWheel.delegate = self
    }
    
    func addColorWheel() {

        self.view.addSubview(colorWheel)
        
        // Turning off Autoresizing Mask but you lose width and height from frame data
        colorWheel.translatesAutoresizingMaskIntoConstraints = false
        
        // Manually provide width and height as ColorWheel
        let widthConstraint = NSLayoutConstraint(item: colorWheel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 300)
        let heightConstraint = NSLayoutConstraint(item: colorWheel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 300)
        
        colorWheel.addConstraint(widthConstraint)
        colorWheel.addConstraint(heightConstraint)
        
        colorWheel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        colorWheel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 25.0).isActive = true
    }
    
    func addColorLabel() {
        colorLabel.textAlignment = .center
        self.view.addSubview(colorLabel)
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        colorLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        colorLabel.topAnchor.constraint(equalTo: self.colorWheel.bottomAnchor, constant: 10.0).isActive = true
        
        updateColorLabel()
    }
    
    func updateColorLabel() {
        var rgbRed: CGFloat = 0
        var rgbGreen: CGFloat = 0
        var rgbBlue: CGFloat = 0
        var rgbAlpha: CGFloat = 0
        
        colorWheel.color.getRed(&rgbRed, green: &rgbGreen, blue: &rgbBlue, alpha: &rgbAlpha)
        
        colorLabel.text = "Red: \(Int(rgbRed * 0xff)), Green: \(Int(rgbGreen * 0xff)), Blue: \(Int(rgbBlue * 0xff))"
    }
}

// MARK: ColorWheelDelegate

extension CustomLightViewController: ColorWheelDelegate {
    func hueAndSaturationSelected(_ hue: CGFloat, saturation: CGFloat) {
        updateColorLabel()
    }
}
