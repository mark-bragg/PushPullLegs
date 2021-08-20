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
    var yValues: [CGFloat]? {
        didSet {
            setNeedsDisplay()
        }
    }
    private var circle = CAShapeLayer()
    private var circleLine = CAGradientLayer()
    private let circleRadius: CGFloat = 5.0
    private var lineWidth: CGFloat {
        get {
            return smallDisplay ? 1.0 : 2.0
        }
    }
    private var drawingCircle = false
    private var linePoints = [CGPoint]()
    private var touchPoint: CGPoint?
    @Published private(set) var index: Int?
    private var firstLoad = true
    private weak var lineLayer: CAShapeLayer!
    private weak var axesLayer: CALayer?
    private var noDataView: NoDataGraphView!
    private let singlePointCircleDiameter: CGFloat = 5
    var smallDisplay = false
    var circleLineY: CGFloat = 0.0
    var topGraphY: CGFloat = 0.0
    
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
        circleLine.frame = .zero
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
    
    override func layoutSubviews() {
        if hasData() {
            removeNoDataView()
        } else {
            showNoDataView()
        }
    }
    
    override func draw(_ rect: CGRect) {
        if firstLoad {
            firstLoad = false
            circle.backgroundColor = UIColor.white.cgColor
            circle.borderColor = PPLColor.quaternary.cgColor
            circle.borderWidth = 2.5
            layer.addSublayer(circle)
            layer.addSublayer(circleLine)
        } else {
            eraseLine()
        }
        drawAxes()
        drawLine()
    }
    
    func hasData() -> Bool {
        guard let vals = yValues, vals.count > 0 else { return false }
        return true
    }
    
    @objc fileprivate func drawCircle() {
        guard linePoints.count > 0 else { return }
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
        drawCircleLine(closestPoint)
        bringCircleToFront()
    }
    
    private func drawCircleLine(_ closestPoint: CGPoint) {
        circleLine.frame = CGRect(x: closestPoint.x - 1, y: circleLineY, width: 2, height: frame.height - circleLineY)
        circleLine.colors = [PPLColor.primary.cgColor, PPLColor.quaternary.cgColor, PPLColor.primary.cgColor]
        let highlight = (closestPoint.y - 1) / frame.height as NSNumber
        circleLine.locations = [0.05, highlight, 0.95]
    }
    
    private func bringCircleToFront() {
        guard let maxZ = layer.sublayers?.max(by: { (layer1, layer2) -> Bool in
            return layer1.zPosition > layer2.zPosition
        })?.zPosition else { return }
        circle.zPosition = maxZ + 1
    }
    
    @objc func editCircle(_ action: Selector) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.perform(action)
        CATransaction.commit()
    }
    
    private func lineStrokeColor() -> CGColor {
        PPLColor.white.cgColor
    }
    
    func eraseLine() {
        if let lineLayer = lineLayer, let sublayers = layer.sublayers, sublayers.contains(lineLayer) {
            lineLayer.removeFromSuperlayer()
        }
    }
    
    func drawLine() {
        let lineLayer = CAShapeLayer()
        lineLayer.frame = layer.bounds
        layer.addSublayer(lineLayer)
        self.lineLayer = lineLayer
        lineLayer.path = getPath()
        lineLayer.lineJoin = .round
        lineLayer.lineCap = .round
        lineLayer.strokeColor = lineStrokeColor()
        lineLayer.lineWidth = lineWidth
        lineLayer.fillColor = isSinglePoint() ? PPLColor.primary.cgColor : UIColor.clear.cgColor
    }
    
    func getPath() -> CGPath {
        guard let yValues = yValues else { return CGPath(ellipseIn: .zero, transform: nil) }
        if isSinglePoint() {
            return singlePointPath()
        }
        return multiplePointPath(yValues)
    }
    
    private func isSinglePoint() -> Bool {
        guard let y = yValues else { return false }
        return y.count == 1
    }
    
    private func singlePointPath() -> CGPath {
        linePoints = [lowestPoint()]
        return UIBezierPath.init(ovalIn: CGRect(x: linePoints[0].x - singlePointCircleDiameter / 2, y: linePoints[0].y - singlePointCircleDiameter / 2, width: singlePointCircleDiameter, height: singlePointCircleDiameter)).cgPath
    }
    
    private func multiplePointPath(_ yValues: [CGFloat]) -> CGPath {
        let xSpacing = (frame.width * 0.95) / CGFloat(yValues.count)
        let biggestY = yValues.max()!
        let normalizedYs = yValues.map { (y) -> CGFloat in
            CGFloat(y) / CGFloat(biggestY)
        }
        let path = UIBezierPath()
        func x (index: Int) -> CGFloat{
            return self.frame.width * 0.05 + xSpacing * CGFloat(index)
        }
        let yShift = convertToGraphY(normalizedYs.min()!) - lowestPoint().y
        var y = convertToGraphY(normalizedYs[0]) - yShift
        var point = CGPoint(x: lowestPoint().x, y: y)
        path.move(to: point)
        linePoints.append(point)
        for index in 1..<yValues.count {
            y = convertToGraphY(normalizedYs[index]) - yShift
            point = CGPoint(x: x(index: index), y: y)
            path.addLine(to: point)
            linePoints.append(point)
        }
        return path.cgPath
    }
    
    func convertToGraphY(_ oldY: CGFloat) -> CGFloat {
        return CGFloat(frame.height * 0.95) - CGFloat(oldY) * CGFloat(frame.height * 0.9)
    }
    
    private func origin() -> CGPoint {
        CGPoint(x: frame.width * 0.025, y: frame.height * 0.975)
    }
    
    private func lowestPoint() -> CGPoint {
        CGPoint(x: origin().x + frame.width * 0.05, y: origin().y - frame.height * 0.05)
    }
    
    func showNoDataView() {
        eraseLine()
        eraseAxes()
        if noDataView == nil {
            noDataView = NoDataGraphView()
//            noDataView.whiteBackground = smallDisplay
        }
        if subviews.contains(noDataView) {
            return
        }
        noDataView.frame = bounds
        addSubview(noDataView)
    }
    
    fileprivate func drawAxes() {
        eraseAxes()
        let axesLayer = CAShapeLayer()
        axesLayer.frame = layer.bounds
        let axesPath = UIBezierPath()
        layer.addSublayer(axesLayer)
        axesPath.move(to: CGPoint(x: frame.width * 0.025, y: frame.height * 0.025))
        axesPath.addLine(to: origin())
        axesPath.addLine(to: CGPoint(x: frame.width * 0.975, y: frame.height * 0.975))
        axesLayer.path = axesPath.cgPath
        axesLayer.strokeColor = lineStrokeColor()
        axesLayer.lineWidth = lineWidth
        axesLayer.fillColor = UIColor.clear.cgColor
        self.axesLayer = axesLayer
    }
    
    fileprivate func eraseAxes() {
        if let axes = axesLayer {
            axes.removeFromSuperlayer()
        }
    }
    
    func removeNoDataView() {
        if let ndv = noDataView, subviews.contains(ndv) {
            noDataView.removeFromSuperview()
            setNeedsDisplay()
        }
    }
}
