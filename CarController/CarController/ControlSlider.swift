//
//  ControlSlider.swift
//  CarController
//
//  Created by Samuel Behrens on 10/28/19.
//  Copyright © 2019 Samuel Behrens. All rights reserved.
//

import Foundation
import UIKit

class ControlSlider: UIControl {
    var maximumValue: CGFloat = 10
    var minimumValue: CGFloat = -10
    var value: CGFloat = 0
    
    private let trackLayer = CALayer()
    private let thumbLayer = CALayer()
    
    private var previousLocation = CGPoint()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
      
        trackLayer.backgroundColor = UIColor.blue.cgColor
        layer.addSublayer(trackLayer)
      
        thumbLayer.backgroundColor = UIColor.green.cgColor
        layer.addSublayer(thumbLayer)
        
        updateLayerFrames()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateLayerFrames() {
        trackLayer.frame = bounds
        trackLayer.setNeedsDisplay()
        thumbLayer.frame = CGRect(origin: thumbOriginForValue(value),
                                  size: CGSize(width: bounds.size.width, height: 5.0))
    }
    
    func positionForValue(_ value: CGFloat) -> CGFloat {
        let minimumRatio = minimumValue/controlLength()
        return -minimumRatio * bounds.height + minimumRatio * value
    }
    
    private func thumbOriginForValue(_ value: CGFloat) -> CGPoint {
        let y = positionForValue(value) - thumbLayer.frame.size.height / 2.0
        return CGPoint(x: (bounds.width - thumbLayer.frame.size.width) / 2.0, y: y)
    }
    
    func controlLength() -> CGFloat {
        return abs(maximumValue - minimumValue)
    }
    
    override var frame: CGRect {
        didSet {
            updateLayerFrames()
        }
    }
}

extension ControlSlider {
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
    
        let deltaLocation = location.y - previousLocation.y
        print("dl \(deltaLocation)")
        let deltaValue = controlLength() * deltaLocation / bounds.height
        print("dv \(deltaValue)")
        
        previousLocation = location
    
        value += deltaValue
//        value = boundValue(value, toLowerValue: minimumValue, upperValue: maximumValue)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        updateLayerFrames()
        
        CATransaction.commit()
        
        return true
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
      
        let deltaLocation = location.y - previousLocation.y
        let deltaValue = controlLength() * deltaLocation / bounds.height
        print(deltaLocation)
        print(deltaValue)
      
        previousLocation = location
      
        value += deltaValue
//        value = boundValue(value, toLowerValue: minimumValue, upperValue: maximumValue)
      
        CATransaction.begin()
        CATransaction.setDisableActions(true)
      
        updateLayerFrames()
      
        CATransaction.commit()
      
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        value = 0.0
    }

    private func boundValue(_ value: CGFloat, toLowerValue lowerValue: CGFloat,
                            upperValue: CGFloat) -> CGFloat {
        return min(max(value, lowerValue), upperValue)
    }
}
