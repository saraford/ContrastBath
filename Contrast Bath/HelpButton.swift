//
//  HelpButton.swift
//  Contrast Bath Timer
//
//  Created by Sara Ford on 7/15/15.
//  Copyright (c) 2015 Sara Ford. All rights reserved.
//

import UIKit

class HelpButton: UIButton {
    
    let π:CGFloat = CGFloat(M_PI)
    @IBInspectable var outlineColor: UIColor = UIColor.blueColor()
    @IBInspectable var outlineSize: CGFloat = 2
    
    override func drawRect(rect: CGRect) {
        
        let center = CGPoint(x:bounds.width/2, y: bounds.height/2)
        let radius: CGFloat = max(bounds.width, bounds.height)
        
        let arcWidth: CGFloat = outlineSize
        let startAngle: CGFloat = 0.0
        let endAngle: CGFloat = 2 * π
        
        var path = UIBezierPath(arcCenter: center,
            radius: radius/2 - arcWidth/2,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true)
        
        path.lineWidth = arcWidth
        outlineColor.setStroke()
        path.stroke()
    }
}
