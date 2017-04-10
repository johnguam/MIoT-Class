//
//  CalculatorModel.swift
//  MiotTask2iOSCalculator
//
//  Created by Lee, John on 4/1/17.
//  Copyright © 2017 John Lee. All rights reserved.
//

import Foundation

class CalculatorModel
{
    var result: Double {
        get {
            return accumulator
        }
    }
    
    private var accumulator = 0.0
    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double,Double) -> Double
        var firstOperand: Double
    }
    
    private var operations: Dictionary<String, Operation> = [
        "÷": Operation.BinaryOperation {$0 / $1},
        "×": Operation.BinaryOperation({$0 * $1}),
        "−": Operation.BinaryOperation({$0 - $1}),
        "+": Operation.BinaryOperation({$0 + $1}),
        "C": Operation.Clear,
        "=": Operation.Equals
    ]
    
    private enum Operation {
        case BinaryOperation((Double,Double) -> Double)
        case Clear
        case Equals
    }
    
    func performOperation(symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .BinaryOperation(let function):
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
            case .Clear:
                executeClearOperation()
            case .Equals:
                executePendingBinaryOperation()
            }
        }
    }
    
    func setOperand(operand: Double) {
        accumulator = operand
    }
    

    private func executeClearOperation() {
        accumulator = 0.0
        pending = nil
    }
    
    private func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
}
