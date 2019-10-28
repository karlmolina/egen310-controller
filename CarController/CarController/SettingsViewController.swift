//
//  SettingsViewController.swift
//  CarController
//
//  Created by Samuel Behrens on 10/27/19.
//  Copyright © 2019 Samuel Behrens. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var leftMotorPinLabel: UILabel!
    @IBOutlet weak var rightMotorPinLabel: UILabel!
    @IBOutlet weak var leftMotorPinStepper: UIStepper!
    @IBOutlet weak var rightMotorPinStepper: UIStepper!
    @IBOutlet weak var leftDirectionControl: UISegmentedControl!
    @IBOutlet weak var rightDirectionControl: UISegmentedControl!
    
    var leftMotorPin: Int!
    var rightMotorPin: Int!
    var leftDirectionIndex: Int!
    var rightDirectionIndex: Int!
    
    weak var settingsDelegate: SettingsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        leftMotorPinStepper.value = Double(leftMotorPin)
        rightMotorPinStepper.value = Double(rightMotorPin)
        
        leftDirectionControl.selectedSegmentIndex = leftDirectionIndex
        rightDirectionControl.selectedSegmentIndex = rightDirectionIndex
        
        leftMotorPinLabel.text = String(Int(leftMotorPinStepper.value))
        rightMotorPinLabel.text = String(Int(rightMotorPinStepper.value))
    }
    
    @IBAction func onDoneButtonPress(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion:nil)
    }
    
    @IBAction func onLeftMotorPinValueChanged(_ sender: UIStepper) {
        print(sender.value)
        let leftMotorPin = Int(sender.value)
        leftMotorPinLabel.text = String(leftMotorPin)
        settingsDelegate?.onLeftMotorPinChange(pin: leftMotorPin)
    }
    @IBAction func onRightMotorPinValueChanged(_ sender: UIStepper) {
        print(sender.value)
        let rightMotorPin = Int(sender.value)
        rightMotorPinLabel.text = String(rightMotorPin)
        settingsDelegate?.onRightMotorPinChange(pin: rightMotorPin)
    }
    @IBAction func onLeftDirectionChanged(_ sender: UISegmentedControl) {
        print(sender.selectedSegmentIndex)
        var direction = 1
        if sender.selectedSegmentIndex == 1 {
            direction = -1
        }
        settingsDelegate?.onLeftDirectionChange(direction: direction)
    }
    @IBAction func onRightDirectionChanged(_ sender: UISegmentedControl) {
        print(sender.selectedSegmentIndex)
        var direction = 1
        if sender.selectedSegmentIndex == 1 {
            direction = -1
        }
        settingsDelegate?.onRightDirectionChange(direction: direction)
    }
}
