//
//  Calculator.swift
//  RPNCalc
//
//  Created by Jake Levirne on 5/13/16.
//  Copyright © 2016 Jake Levirne. All rights reserved.
//

import Foundation


public struct Stack<Element> {
    var items = [Element]()
    mutating func push(item: Element) {
        items.append(item)
    }
    
    mutating func pop() -> Element? {
        if items.count > 0 {
            return items.removeLast()
        } else {
            return nil
        }
    }
    
    mutating func clear() {
        items = [Element]()
    }
    
    func peek(depth: Int) -> Element? {
        if items.count < depth {
            return nil
        } else {
            return items[items.count - depth]
        }
    }
}


class Calculator {
    
    private var calcStack = Stack<Double>()
    private var equationStack = Stack<String>()
    private var internalProgram = [AnyObject]()
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get {
            return internalProgram
        }
        set {
            if let arrayOfOps = newValue as? [AnyObject] {
                var pendingOperand: Double?
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        pendingOperand = operand
                    } else if let operation = op as? String {
                        performOperation(operation, operand:pendingOperand)
                        pendingOperand = nil
                    }
                }
            }
            
        }
    }
    
    var result: Stack<Double> {
        get {
            return calcStack
        }
        set {
            calcStack = newValue
        }
    }
    
    var equation: Stack<String> {
        get {
            return equationStack
        }
        set {
            equationStack = newValue
        }
    }
    
    var variableValues: Dictionary<String, Double> = [
        "z" : 27.0
    ]
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Return
        case Clear
    }
    
    private var operations: Dictionary<String,Operation> = [
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "√" : Operation.UnaryOperation(sqrt),
        "cos" : Operation.UnaryOperation(cos),
        "sin" : Operation.UnaryOperation(sin),
        "^2" : Operation.UnaryOperation({ $0 * $0 }),
        "×" : Operation.BinaryOperation({ $0 * $1 }),
        "÷" : Operation.BinaryOperation({ $0 / $1 }),
        "+" : Operation.BinaryOperation({ $0 + $1 }),
        "−" : Operation.BinaryOperation({ $0 - $1 }),
        "mod" : Operation.BinaryOperation({ $0 % $1 }),
        "C" : Operation.Clear,
        "⏎" : Operation.Return
    ]
    
    func clear() {
        calcStack.clear()
        internalProgram.removeAll()
        equationStack.clear()
    }
    
    func setOperandFromVariable(varName: String){
        let val = variableValues[varName]
        calcStack.push(val!)
        equationStack.push(varName)
        
    }

    func performOperation(symbol: String, operand: Double?) {
        print("pre stack: \(calcStack)")
        
        if operand != nil {
            calcStack.push(operand!)
            equationStack.push(String(operand!))
            internalProgram.append(operand!)
        }
        
        if let operation = operations[symbol] {
            internalProgram.append(symbol)
            switch operation {
            case .Constant(let value):
                calcStack.push(value)
                equationStack.push(symbol)
            case .UnaryOperation(let opFunction):
                if let workingOperand = calcStack.pop() {
                    calcStack.push(opFunction(workingOperand))
                    let eqOp = equationStack.pop()!
                    equationStack.push("(\(symbol) \(eqOp))")
                }
                
            case .BinaryOperation(let opFunction):
                if calcStack.peek(2) != nil {
                    let workingOp2 = calcStack.pop()!
                    let workingOp1 = calcStack.pop()!
                    calcStack.push(opFunction(workingOp1,workingOp2))
                    let eqOp2 = equationStack.pop()!
                    let eqOp1 = equationStack.pop()!
                    equationStack.push("(\(eqOp1) \(symbol) \(eqOp2))")
                }
            case .Return:
                break
            case .Clear:
                clear()
            }
        }

        print("post stack: \(calcStack)")
        result = calcStack
    }
    
    
    
}