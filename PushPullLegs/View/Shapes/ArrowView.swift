//
//  ArrowView.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 8/15/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

class ArrowView: UIView {
    var dimensions: ArrowViewDimensions!
    
    override func draw(_ rect: CGRect) {
        addRectangle()
        addTriangle()
        backgroundColor = UIColor.clear
    }
    
    fileprivate func addRectangle() {
        let rectangle = CAShapeLayer()
        rectangle.frame = dimensions.rectangleFrame
        rectangle.path = dimensions.rectanglePath
        styleArrowComponent(rectangle)
        layer.addSublayer(rectangle)
    }
    
    fileprivate func addTriangle() {
        let triangle = CAShapeLayer()
        triangle.frame = dimensions.triangleFrame
        triangle.path = dimensions.trianglePath
        styleArrowComponent(triangle)
        layer.addSublayer(triangle)
    }
    
    fileprivate func styleArrowComponent(_ component: CAShapeLayer) {
        component.fillColor = PPLColor.pplOffWhite!.cgColor
        component.shadowPath = component.path
        component.shadowOffset = CGSize(width: -5, height: 5)
        component.shadowRadius = 5
        component.shadowOpacity = 0.4
    }

}

class DownwardsArrowView: ArrowView {
    override func draw(_ rect: CGRect) {
        dimensions = VerticalArrowViewDimensions()
        super.draw(rect)
    }
}

class SidwaysArrowView: ArrowView {

}
