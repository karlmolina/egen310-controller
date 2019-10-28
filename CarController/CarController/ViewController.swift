//
//  ViewController.swift
//  CarController
//
//  Created by Samuel Behrens on 10/14/19.
//  Copyright © 2019 Samuel Behrens. All rights reserved.
//

import UIKit
import CoreBluetooth

let serviceCBUUID = CBUUID(string: "b848f29a-7089-407c-8d73-22461900c71d")
let characteristicCBUUID = CBUUID(string: "4b55ae61-a529-4b2c-85f9-82c7401db550")

class ViewController: UIViewController {
    
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var speedSlider: UISlider!
    @IBOutlet weak var leftAdjustmentLabel: UILabel!
    @IBOutlet weak var leftAdjuster: UIStepper!
    @IBOutlet weak var rightAdjuster: UIStepper!
    @IBOutlet weak var rightAdjustmentLabel: UILabel!
    
    var centralManager: CBCentralManager!
    var carPeripheral: CBPeripheral!
    var speedCharacteristic: CBCharacteristic!
    
    var leftSpeed: Int = 0
    var rightSpeed: Int = 0
    var speedChange: Int = 100
    var leftAdjustment: Int = 0
    var rightAdjustment: Int = 0
    var leftMotorPin = 1
    var rightMotorPin = 2
    var leftMotorDirection = 1
    var rightMotorDirection = 1
    
    var sendSpeedTask: DispatchWorkItem!
    var speedSent = false
    
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeSavedValues()
        
        speedLabel.text = "\(speedChange)"
        speedSlider.value = Float(speedChange)
        
        rightAdjustmentLabel.text = "\(rightAdjustment)"
        rightAdjuster.value = Double(rightAdjustment)
        
        leftAdjustmentLabel.text = "\(leftAdjustment)"
        leftAdjuster.value = Double(leftAdjustment)

        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func initializeSavedValues() {
        let savedSpeed = defaults.integer(forKey: "speedChange")
        speedChange = savedSpeed
        
        leftAdjustment = defaults.integer(forKey: "leftAdjustment")
        
        rightAdjustment = defaults.integer(forKey: "rightAdjustment")
        
        let savedLeftMotorPin = defaults.integer(forKey: "leftMotorPin")
        if savedLeftMotorPin != 0 {
            leftMotorPin = savedLeftMotorPin
        }
        
        let savedRightMotorPin = defaults.integer(forKey: "rightMotorPin")
        if savedRightMotorPin != 0 {
            rightMotorPin = savedRightMotorPin
        }
        
        let savedLeftMotorDirection = defaults.integer(forKey: "leftMotorDirection")
        if savedLeftMotorDirection != 0 {
            leftMotorDirection = savedLeftMotorDirection
        }
        
        let savedRightMotorDirection = defaults.integer(forKey: "rightMotorDirection")
        if savedRightMotorDirection != 0 {
            rightMotorDirection = savedRightMotorDirection
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationViewController = segue.destination as? UINavigationController
        let settingsViewController = navigationViewController?.viewControllers.first as! SettingsViewController
        
        settingsViewController.settingsDelegate = self
        settingsViewController.leftMotorPin = leftMotorPin
        settingsViewController.rightMotorPin = rightMotorPin
        settingsViewController.leftDirectionIndex = leftMotorDirection == 1 ? 0 : 1
        settingsViewController.rightDirectionIndex = rightMotorDirection == 1 ? 0 : 1
    }
    
    func onConnectionChanged(_ value: Bool) {
        counterLabel.text = "\(value)"
        print("Connection changed to: \(value)")
    }
    
    func sendSpeed() {
        var leftSpeedString = String(leftSpeed * (speedChange + leftAdjustment) * leftMotorDirection)
        var rightSpeedString = String(rightSpeed * (speedChange + rightAdjustment) * rightMotorDirection)
        
        leftSpeedString = leftSpeedString.padding(toLength: 4, withPad: " ", startingAt: 0)
        rightSpeedString = rightSpeedString.padding(toLength: 4, withPad: " ", startingAt: 0)
        
        print("leftSpeedString \(leftSpeedString)")
        print("rightSpeedString) \(rightSpeedString)")
        print("data sent: \(leftSpeedString)\(rightSpeedString)\(leftMotorPin)\(rightMotorPin)")
        
        writeData(data: "\(leftSpeedString)\(rightSpeedString)\(leftMotorPin)\(rightMotorPin)".data(using: .utf8)!)
    }
    
    func resetBluetoothConnection() {
        if (carPeripheral != nil) {
            centralManager.cancelPeripheralConnection(carPeripheral)
            centralManager.connect(carPeripheral)
        }
    }
    
    @IBAction func onReconnectPress(_ sender: Any) {
        resetBluetoothConnection()
    }
    
    @IBAction func onSpeedChange(_ sender: UISlider) {
        speedChange = Int(sender.value)
        
        // Check if send speed async call exists and cancel if so
        if !speedSent {
            // Set new send speed task
            speedSent = true
            sendSpeedTask = DispatchWorkItem { self.sendSpeed(); self.speedSent = false }
            // Dispatch async send speed call after delay
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2, execute: sendSpeedTask)
        }

        let defaults = UserDefaults.standard
        defaults.set(speedChange, forKey: "speedChange")
            
        speedLabel.text = "\(speedChange)"
    }
    
    @IBAction func onLeftAdjustmentChange(_ sender: UIStepper) {
        leftAdjustment = Int(sender.value)
        
        let defaults = UserDefaults.standard
        defaults.set(leftAdjustment, forKey: "leftAdjustment")
            
        leftAdjustmentLabel.text = "\(leftAdjustment)"
    }
    @IBAction func onRightAdjustmentChange(_ sender: UIStepper) {
        rightAdjustment = Int(sender.value)
        
        let defaults = UserDefaults.standard
        defaults.set(rightAdjustment, forKey: "rightAdjustment")
            
        rightAdjustmentLabel.text = "\(rightAdjustment)"
    }
    
    @IBAction func onLeftForwardPress(_ sender: Any) {
        leftSpeed = 1
        sendSpeed()
    }
    @IBAction func onLeftForwardTouchUpInside(_ sender: Any) {
        leftSpeed = 0
        sendSpeed()
    }
    @IBAction func onLeftForwardTouchUpOutside(_ sender: Any) {
        leftSpeed = 0
        sendSpeed()
    }
    
    @IBAction func onLeftBackPress(_ sender: Any) {
        leftSpeed = -1
        sendSpeed()
    }
    @IBAction func onLeftBackTouchUpInside(_ sender: Any) {
        leftSpeed = 0
        sendSpeed()
    }
    @IBAction func onLeftBackTouchUpOutside(_ sender: Any) {
        leftSpeed = 0
        sendSpeed()
    }
    
    @IBAction func onRightForwardPress(_ sender: Any) {
        rightSpeed = 1
        sendSpeed()
    }
    @IBAction func onRightForwardTouchUpInside(_ sender: Any) {
        rightSpeed = 0
        sendSpeed()
    }
    @IBAction func onRightForwardTouchUpOutside(_ sender: Any) {
        rightSpeed = 0
        sendSpeed()
    }
    
    @IBAction func onRightBackPress(_ sender: Any) {
        rightSpeed = -1
        sendSpeed()
    }
    @IBAction func onRightBackTouchUpInside(_ sender: Any) {
        rightSpeed = 0
        sendSpeed()
    }
    @IBAction func onRightBackTouchUpOutside(_ sender: Any) {
        rightSpeed = 0
        sendSpeed()
    }
}

extension ViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
            centralManager.scanForPeripherals(withServices: [serviceCBUUID])
        default:
            print("default case")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                      advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral)
        carPeripheral = peripheral
        carPeripheral.delegate = self
        centralManager.stopScan()
        centralManager.connect(carPeripheral)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!")
        carPeripheral.discoverServices([serviceCBUUID])
        onConnectionChanged(true)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        onConnectionChanged(false)
    }
}

extension ViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            print(service)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }

        for characteristic in characteristics {
            print(characteristic)

            if characteristic.properties.contains(.read) {
                print("\(characteristic.uuid): properties contains .read")
//                peripheral.readValue(for: characteristic)
            }
            if characteristic.properties.contains(.notify) {
                print("\(characteristic.uuid): properties contains .notify")
//                peripheral.setNotifyValue(true, for: characteristic)
            }
            if characteristic.properties.contains(.write) {
                print("\(characteristic.uuid): properties contains .write")
//                peripheral.setNotifyValue(true, for: characteristic)
                speedCharacteristic = characteristic
            }
        }
    }

//    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//        switch characteristic.uuid {
//        case characteristicCBUUID:
//            let characteristicValue = getCharacteristicValue(from: characteristic)
//            onConnectionChanged(characteristicValue)
//            speedCharacteristic = characteristic
//        default:
//            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
//        }
//    }
  
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        if error != nil {
            print("Problem writing data")
            print(error!)
        }
        else {
            print("Wrote data \(String(describing: descriptor.characteristic.value))")
        }
    }
  
    func writeData(data: Data) {
        if speedCharacteristic == nil {
            print("No speed characteristic found")
            return
        }

        carPeripheral.writeValue(data, for: speedCharacteristic, type: CBCharacteristicWriteType.withResponse)
    }

    private func getCharacteristicValue(from characteristic: CBCharacteristic) -> Int {
        guard let characteristicData = characteristic.value else { return -1 }
        let byteArray = [UInt8](characteristicData)
        print("Characteristic value: \(byteArray)")
    
        return Int(byteArray[0])
    }
}

extension ViewController: SettingsDelegate {
    func onLeftMotorPinChange(pin: Int) {
        print("leftMotorPin changed to \(pin)")
        leftMotorPin = pin
        
        defaults.set(leftMotorPin, forKey: "leftMotorPin")
    }
    
    func onRightMotorPinChange(pin: Int) {
        print("rightMotorPin changed to \(pin)")
        rightMotorPin = pin
        
        defaults.set(rightMotorPin, forKey: "rightMotorPin")
    }
    
    func onLeftDirectionChange(direction: Int) {
        print("leftDirection changed to \(direction)")
        leftMotorDirection = direction
        
        defaults.set(leftMotorDirection, forKey: "leftMotorDirection")
    }
    
    func onRightDirectionChange(direction: Int) {
        print("rightDirection changed to \(direction)")
        rightMotorDirection = direction
        
        defaults.set(rightMotorDirection, forKey: "rightMotorDirection")
    }
}
