//
//  GraphViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 8/3/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

@objc protocol GraphViewResponse {
    func display(date: Date, volume: Int)
}

class GraphViewController: UIViewController, GraphViewResponse {

    weak var graphView: GraphView!
    weak var dateLabel: UILabel!
    weak var volumeLabel: UILabel!
    private let formatter = DateFormatter()
    var isInteractive = true
    var dates = [Date]()
    var volumes = [
        1,1,1,1,2,2,3,3,3,4,6,6,6,5,6,7,7,8,8,9,9,9,9,9,9,8,8,8,9,10,10,10
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for _ in 0..<volumes.count {
            dates.append(Date())
        }
        let frame = view.frame
        let containerView = UIView(frame: frame)
        view.addSubview(containerView)
        let graph = GraphView(frame: CGRect(x: view.frame.width * 0.05, y: view.frame.height * 0.245, width: frame.width * 0.95, height: view.frame.height * 0.695))
        graph.responder = self
        containerView.addSubview(graph)
        containerView.backgroundColor = PPLColor.textBlue
        graph.xValues = dates
        graph.yValues = volumes
        view.addSubview(graph)
        graphView = graph
        graph.backgroundColor = PPLColor.textBlue
        let p = UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:)))
        graph.addGestureRecognizer(p)
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGesture(_:)))
        graph.addGestureRecognizer(tap)
        self.dateLabel = label(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 100))
        self.volumeLabel = label(frame: CGRect(x: 0, y: 100, width: view.frame.width, height: 100))
        formatter.dateFormat = "MM/dd/YY"
    }
    
    @objc func panGesture(_ gr: UIPanGestureRecognizer) {
        if gr.state != .cancelled {
            graphView.drawCircle(gr.location(in: graphView))
        } else if gr.state == .ended {
            graphView.eraseCircle()
        }
    }
    
    @objc func tapGesture(_ gr: UITapGestureRecognizer) {
        graphView.drawCircle(gr.location(in: graphView))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func addGraphView() {
        
    }
    
    func display(date: Date, volume: Int) {
        dateLabel.text = formatter.string(from: date)
        volumeLabel.text = "volume: \(volume)"
    }
    
    func label(frame: CGRect) -> UILabel {
        let label = UILabel(frame: frame)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 32, weight: .medium)
        view.addSubview(label)
        label.numberOfLines = 1
        label.textColor = .white
        return label
    }

}

class GraphView: UIView {
    var xValues = [Date]()
    var yValues = [Int]()
    var circle = CAShapeLayer()
    var circleLine = CAShapeLayer()
    let circleRadius: CGFloat = 10.0
    var drawingCircle = false
    var linePoints = [CGPoint]()
    weak var responder: GraphViewResponse!
    
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
    
    func drawCircle(_ point: CGPoint) {
        circle.removeAllAnimations()
        var closestPoint = linePoints.first!
        var index = 0
        for point1 in linePoints {
            if closestPoint.equalTo(point1) { continue }
            if closestPoint.x.distance(to: point.x) > point.x.distance(to: point1.x) {
                closestPoint = point1
                index = linePoints.firstIndex(of: point1)!
            }
        }
        responder.display(date: xValues[index], volume: Int(closestPoint.y))
        circle.frame = CGRect(x: closestPoint.x - circleRadius, y: closestPoint.y - circleRadius, width: circleRadius * 2, height: circleRadius * 2)
        circle.cornerRadius = circle.frame.height / 2
        circleLine.frame = CGRect(x: point.x, y: 0, width: 2.0, height: frame.height)
        circleLine.strokeColor = UIColor.black.cgColor
    }
    
    func eraseCircle() {
        circle.frame = .zero
        circleLine.strokeColor = UIColor.clear.cgColor
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
        axesLayer.lineWidth = 8.0
        axesLayer.fillColor = UIColor.clear.cgColor
    }
    
    func drawLine() {
        let xSpacing = (frame.width * 0.95) / CGFloat(xValues.count)
        let biggestY = yValues.max()!
        let normalizedYs = yValues.map { (y) -> CGFloat in
            CGFloat(y) / CGFloat(biggestY)
        }
        let path = UIBezierPath()
        let lineLayer = CAShapeLayer()
        lineLayer.frame = layer.bounds
        layer.addSublayer(lineLayer)
        var point = CGPoint(x: frame.width * 0.025, y: CGFloat( (frame.height * 0.975) - normalizedYs[0] * (frame.height * 0.95)) )
        path.move(to: point)
        linePoints.append(point)
        for index in 1..<xValues.count {
            let x = frame.width * 0.025 + xSpacing * CGFloat(index)
            point = CGPoint(x: x, y: CGFloat((frame.height * 0.975) - normalizedYs[index] * (frame.height * 0.95)))
            path.addLine(to: point)
            linePoints.append(point)
        }
        lineLayer.path = path.cgPath
        lineLayer.strokeColor = UIColor.white.cgColor
        lineLayer.lineWidth = 6.0
        lineLayer.fillColor = UIColor.clear.cgColor
    }
}
