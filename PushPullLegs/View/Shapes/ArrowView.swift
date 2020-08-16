//
//  ArrowView.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 8/15/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

class ArrowView: UIView {
    
    static let height: CGFloat = 107
    static let width: CGFloat = 47
    static private let rectHeight: CGFloat = 65.0
    static let rectWidth: CGFloat = 16.0
    static private let triangleHeight: CGFloat = 42.0
    static private let triangleWidth: CGFloat = 47.0
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    
    
    override func draw(_ rect: CGRect) {
        addRectangle()
        addTriangle()
        backgroundColor = UIColor.clear
    }
    
    fileprivate func styleArrowComponent(_ component: CAShapeLayer) {
        component.fillColor = PPLColor.offWhite!.cgColor
    }
    
    fileprivate func addRectangle() {
        let rectangle = CAShapeLayer()
        rectangle.frame = CGRect(x: (ArrowView.width - ArrowView.rectWidth) / 2, y: 0, width: ArrowView.rectWidth, height: ArrowView.rectHeight)
        rectangle.path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: ArrowView.rectWidth, height: ArrowView.rectHeight)).cgPath
        styleArrowComponent(rectangle)
        layer.addSublayer(rectangle)
    }
    
    fileprivate func addTriangle() {
        let triangle = CAShapeLayer()
        triangle.frame = CGRect(x: 0, y: ArrowView.rectHeight, width: ArrowView.triangleWidth, height: ArrowView.triangleHeight)
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: ArrowView.triangleWidth / 2, y: ArrowView.triangleHeight))
        path.addLine(to: CGPoint(x: ArrowView.triangleWidth, y: 0))
        path.close()
        triangle.path = path.cgPath
        styleArrowComponent(triangle)
        layer.addSublayer(triangle)
    }

}
