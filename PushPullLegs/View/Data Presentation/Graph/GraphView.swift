//
//  GraphView.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 8/6/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation
import UIKit

class GraphView: UIControl, ObservableObject {
    var yValues: [CGFloat]?
    private var circle = CAShapeLayer()
    private var circleLine = CAShapeLayer()
    private let circleRadius: CGFloat = 10.0
    private var lineWidth: CGFloat {
        get {
            return 5.0
        }
    }
    private var drawingCircle = false
    private var linePoints = [CGPoint]()
    private var touchPoint: CGPoint?
    @Published private(set) var index: Int?
    
    func setInteractivity() {
        addTarget(self, action: #selector(touchUp(_:)), for: .touchDragExit)
        addTarget(self, action: #selector(touchUp(_:)), for: .touchUpInside)
        addTarget(self, action: #selector(touchDown(_:with:)), for: .touchDown)
        addTarget(self, action: #selector(drag(_:with:)), for: .touchDragInside)
    }
    
    @objc func touchUp(_ touch: UITouch) {
        editCircle(#selector(eraseCircle))
    }
    
    @objc func eraseCircle() {
        index = nil
        circle.frame = .zero
        circleLine.strokeColor = UIColor.clear.cgColor
    }
    
    @objc func touchDown(_ sender: GraphView, with event: UIEvent) {
        guard let touch = event.touches(for: self)?.first else {
            return
        }
        touchPoint = touch.location(in: self)
        editCircle(#selector(drawCircle))
    }
    
    @objc func drag(_ sender: GraphView, with event: UIEvent) {
        guard let touch = event.touches(for: self)?.first else {
            return
        }
        touchPoint = touch.location(in: self)
        editCircle(#selector(drawCircle))
    }
    
    override func draw(_ rect: CGRect) {
        drawAxes()
        drawLine()
        if !layer.sublayers!.contains(circle) {
            circle.backgroundColor = UIColor.white.cgColor
            circle.borderColor = PPLColor.grey!.cgColor
            circle.borderWidth = 2.5
            layer.addSublayer(circle)
        }
    }

    func addCircleLine() {
        let path = UIBezierPath()
        path.lineWidth = 1.5
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: 0, y: frame.height))
        circleLine.path = path.cgPath
        circleLine.frame = CGRect(x: 0, y: 0, width: 2.0, height: frame.height)
        layer.addSublayer(circleLine)
    }
    
    @objc fileprivate func drawCircle() {
        var closestPoint = linePoints.first!
        var index = 0
        for point in linePoints {
            if closestPoint.equalTo(point) { continue }
            if closestPoint.x.distance(to: touchPoint!.x) > touchPoint!.x.distance(to: point.x) {
                closestPoint = point
                index = linePoints.firstIndex(of: point)!
            }
        }
        self.index = index
        circle.frame = CGRect(x: closestPoint.x - circleRadius, y: closestPoint.y - circleRadius, width: circleRadius * 2, height: circleRadius * 2)
        circle.cornerRadius = circle.frame.height / 2
        circleLine.frame = CGRect(x: touchPoint!.x, y: 0, width: 2.0, height: frame.height)
        circleLine.strokeColor = UIColor.black.cgColor
    }
    
    @objc func editCircle(_ action: Selector) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.perform(action)
        CATransaction.commit()
    }
    
    fileprivate func drawAxes() {
        let axesLayer = CAShapeLayer()
        axesLayer.frame = layer.bounds
        let axesPath = UIBezierPath()
        layer.addSublayer(axesLayer)
        axesPath.move(to: CGPoint(x: frame.width * 0.025, y: frame.height * 0.025))
        axesPath.addLine(to: CGPoint(x: frame.width * 0.025, y: frame.height * 0.975))
        axesPath.addLine(to: CGPoint(x: frame.width * 0.975, y: frame.height * 0.975))
        axesLayer.path = axesPath.cgPath
        axesLayer.strokeColor = UIColor.white.cgColor
        axesLayer.lineWidth = lineWidth
        axesLayer.fillColor = UIColor.clear.cgColor
    }
    
    func drawLine() {
        guard let yValues = yValues else { return }
        let xSpacing = (frame.width * 0.95) / CGFloat(yValues.count)
        let biggestY = yValues.max()!
        let normalizedYs = yValues.map { (y) -> CGFloat in
            CGFloat(y) / CGFloat(biggestY)
        }
        let path = UIBezierPath()
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        let lineLayer = CAShapeLayer()
        lineLayer.frame = layer.bounds
        layer.addSublayer(lineLayer)
        var point = CGPoint(x: frame.width * 0.025, y: frame.height * 0.975)
        path.move(to: point)
        linePoints.append(point)
        for index in 1..<yValues.count {
            let x = frame.width * 0.025 + xSpacing * CGFloat(index)
            point = CGPoint(x: x, y: CGFloat((frame.height * 0.975) - normalizedYs[index] * (frame.height * 0.95)))
            path.addLine(to: point)
            linePoints.append(point)
        }
        lineLayer.path = path.cgPath
        lineLayer.strokeColor = UIColor.white.cgColor
        lineLayer.lineWidth = lineWidth
        lineLayer.fillColor = UIColor.clear.cgColor
    }
}
