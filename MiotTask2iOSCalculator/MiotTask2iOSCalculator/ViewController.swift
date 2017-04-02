//
//  ViewController.swift
//  MiotTask2iOSCalculator
//
//  Created by Lee, John on 4/1/17.
//  Copyright © 2017 John Lee. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    @IBOutlet private weak var display: UILabel!
    
    private var calcModel = CalculatorModel()
    private var decimalIsPresent = false
    private var userIsInTheMiddleOfTyping = false
    
    @IBAction private func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            calcModel.setOperand(operand: displayValue)
            userIsInTheMiddleOfTyping = false
            decimalIsPresent = false
        }
        if let calcSymbol = sender.currentTitle {
            calcModel.performOperation(symbol: calcSymbol)
        }
        displayValue = calcModel.result
    }
    
    @IBAction private func touchDecimal(_ sender: UIButton) {
        if !decimalIsPresent {
            if userIsInTheMiddleOfTyping {
                let textCurrentlyInDisplay = display.text!
                display.text = textCurrentlyInDisplay + "."
            } else {
                display.text = "0."
            }
            userIsInTheMiddleOfTyping = true
            decimalIsPresent = true
        }
    }

    @IBAction private func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + digit
        } else {
            display.text = digit
        }
        userIsInTheMiddleOfTyping = true
    }
}

