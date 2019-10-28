//
//  SettingsDelegate.swift
//  CarController
//
//  Created by Samuel Behrens on 10/27/19.
//  Copyright © 2019 Samuel Behrens. All rights reserved.
//

import Foundation

protocol SettingsDelegate: class {
    func onLeftMotorPinChange(pin: Int)
    func onRightMotorPinChange(pin: Int)
    
    func onLeftDirectionChange(direction: Int)
    func onRightDirectionChange(direction: Int)
}
