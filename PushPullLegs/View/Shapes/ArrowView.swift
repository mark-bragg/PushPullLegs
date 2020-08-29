//
//  ArrowView.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 8/15/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

protocol ArrowViewDimensions {
    var height: CGFloat { get }
    var width: CGFloat { get }
    var rectHeight: CGFloat { get }
    var rectWidth: CGFloat { get }
    var triangleHeight: CGFloat { get }
    var triangleWidth: CGFloat { get }
    var triangleFrame: CGRect { get }
    var rectangleFrame: CGRect { get }
    var trianglePath: CGPath { get }
    var rectanglePath: CGPath { get }
}

struct VerticalArrowViewDimensions: ArrowViewDimensions {
    var height: CGFloat { return 107 }
    var width: CGFloat { return 47 }
    var rectHeight: CGFloat { return 65.0 }
    var rectWidth: CGFloat { return 16.0 }
    var triangleHeight: CGFloat { return 42.0 }
    var triangleWidth: CGFloat { return 47.0 }
    var triangleFrame: CGRect {
        return CGRect(x: 0, y: self.rectHeight, width: self.triangleWidth, height: self.triangleHeight)
    }
    var rectangleFrame: CGRect {
        return CGRect(x: (self.width - self.rectWidth) / 2, y: 0, width: self.rectWidth, height: self.rectHeight)
    }
    var trianglePath: CGPath {
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: self.triangleWidth / 2, y: self.triangleHeight))
        path.addLine(to: CGPoint(x: self.triangleWidth, y: 0))
        path.close()
        return path.cgPath
    }
    var rectanglePath: CGPath {
        return UIBezierPath(rect: CGRect(x: 0, y: 0, width: self.rectWidth, height: self.rectHeight)).cgPath
    }
}

struct HorizontalArrowViewDimensions: ArrowViewDimensions {
    private let vavd = VerticalArrowViewDimensions()
    var height: CGFloat { return vavd.width }
    var width: CGFloat { return vavd.height }
    var rectHeight: CGFloat { return vavd.rectWidth }
    var rectWidth: CGFloat { return vavd.rectHeight }
    var triangleHeight: CGFloat { return vavd.triangleHeight }
    var triangleWidth: CGFloat { return vavd.triangleWidth }
    var triangleFrame: CGRect {
        return CGRect(x: 0, y: self.rectHeight, width: self.triangleWidth, height: self.triangleHeight)
    }
    var rectangleFrame: CGRect {
        return CGRect(x: (self.width - self.rectWidth) / 2, y: 0, width: self.rectWidth, height: self.rectHeight)
    }
    var trianglePath: CGPath {
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: self.triangleWidth / 2, y: self.triangleHeight))
        path.addLine(to: CGPoint(x: self.triangleWidth, y: 0))
        path.close()
        return path.cgPath
    }
    var rectanglePath: CGPath {
        return UIBezierPath(rect: CGRect(x: 0, y: 0, width: self.rectWidth, height: self.rectHeight)).cgPath
    }
}

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
        component.fillColor = PPLColor.offWhite!.cgColor
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
