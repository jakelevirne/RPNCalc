//
//  ViewController.swift
//  RPNCalc
//
//  Created by Jake Levirne on 5/12/16.
//  Copyright © 2016 Jake Levirne. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let c = Calculator()

    private var isTypingDigits = false
    private var hasDecimalPoint = false
    
    private var displayValue: Double? {
        get {
            if let displayText = display.text {
                return Double(displayText)
            } else {
                return nil
            }
        }
        set {
            display.text = String(newValue)
        }
    }

    
    // Do any additional setup after loading the view, typically from a nib.
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    // Append the digit (or decimal point) of the button to the display string
    @IBAction func digitPressed(sender: UIButton) {
        if let buttonText = sender.currentTitle {
            print("button pressed \(buttonText)")
            //Append the button's symbol to the input string and check if it's a valid Double.
            if isTypingDigits {
                display!.text = display!.text! + buttonText
            } else {
                display!.text = buttonText
            }
        }
        isTypingDigits = true
    }
    
    
    @IBAction func operatorPressed(sender: UIButton) {
        isTypingDigits = false
        let op = Double(display.text!)
        
        //If casting the display.text to a Double failed and the display.text was not empty, then somebody input an illegal number, like 1.1.1
        if op == nil && display.text! != " " {
            display.text = display.text! + "<-ERR"
        } else {
            //Call the Calculator to perform the operation with the optional operand.  Op will only contain a value if the display.text wasn't empty.  This way, pressing an operator button when there's a number in the display.text acts like hitting enter to add that 
            if let operatorText  = sender.currentTitle {
                print("operator pressed \(operatorText)")
                c.performOperation(operatorText, operand: op)
                updateDisplay()
             }
        }
        
    }
    
    func updateDisplay() {
        let returnStack = c.result
        let equationStack = c.equation
        
        if let s1=returnStack.peek(1) {
            stack1.text = String(s1)
        } else {
            stack1.text = " "
        }
        
        if let s2=returnStack.peek(2) {
            stack2.text = String(s2)
        } else {
            stack2.text = " "
        }
        
        if let s3=returnStack.peek(3) {
            stack3.text = String(s3)
        } else {
            stack3.text = " "
        }
        
        if let eq=equationStack.peek(1) {
            equation.text = String(eq)
        } else {
            equation.text = " "
        }
        
        display!.text = " "

    }

    var savedProgram: Calculator.PropertyList?
    
    @IBAction func save() {
        savedProgram = c.program
    }
    
    @IBAction func run() {
        if savedProgram != nil {
            c.program = savedProgram!
            updateDisplay()
        }
    }
    
    @IBAction func getVariable(sender: UIButton) {
        c.setOperandFromVariable(sender.currentTitle!)
        updateDisplay()
    }

    @IBOutlet weak var display: UILabel!

    @IBOutlet weak var stack3: UILabel!
    
    @IBOutlet weak var stack2: UILabel!
    
    @IBOutlet weak var stack1: UILabel!
    
    @IBOutlet weak var equation: UILabel!
    
}

