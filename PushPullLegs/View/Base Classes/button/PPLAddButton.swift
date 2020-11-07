//
//  PPLAddButton.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 7/17/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

class PPLAddButton: UIControl {
    
    private let plusSignLayerName = "PLUS_SIGN"
    private weak var gradient: CAGradientLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addTargets()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addTargets()
    }
    
    private func addTargets() {
        addTarget(self, action: #selector(addAction(_:)), for: .touchUpInside)
        addTarget(self, action: #selector(addTouchDown(_:)), for: .touchDown)
        addTarget(self, action: #selector(addRelease), for: .touchUpOutside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        style()
        addPlusSign()
    }
    
    private func style() {
        clipsToBounds = false
        layer.backgroundColor = PPLColor.textBlue?.cgColor
        layer.cornerRadius = layer.frame.height / 2
        let gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.locations = [
            NSNumber(value: 0.7),
            NSNumber(value: 0.8),
            NSNumber(value: 0.97),
            NSNumber(value: 1)
        ]
        gradientLayer.type = .radial
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor(white: 1.0, alpha: 0.25).cgColor,
            UIColor(white: 1.0, alpha: 0.45).cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.frame = layer.bounds
        gradientLayer.cornerRadius = layer.cornerRadius
        layer.addSublayer(gradientLayer)
        gradient = gradientLayer
    }
    
    private func addPlusSign() {
        if let layers = layer.sublayers, layers.contains(where: { $0.name == plusSignLayerName } ) {
            return
        }
        addPlusLayer()
    }
    
    private func addPlusLayer() {
        let plusLayer = CALayer()
        plusLayer.frame = layer.bounds
        layer.addSublayer(plusLayer)
        drawPlusSign(plusLayer)
    }
    
    private func drawPlusSign(_ plusLayer: CALayer) {
        let horizontal = CAShapeLayer()
        let vertical = CAShapeLayer()
        horizontal.frame = plusLayer.bounds
        vertical.frame = plusLayer.bounds
        horizontal.path = horizontalRectangle()
        horizontal.fillColor = UIColor(white: 0.85, alpha: 1.0).cgColor
        vertical.path = verticalRectangle()
        vertical.fillColor = UIColor(white: 0.85, alpha: 1.0).cgColor
        plusLayer.addSublayer(horizontal)
        plusLayer.addSublayer(vertical)
        plusLayer.name = plusSignLayerName
    }
    
    private func horizontalRectangle() -> CGPath {
        return UIBezierPath(roundedRect: CGRect(x: frame.width/3, y: frame.height/2 - 3.75, width: frame.width/3, height: 7.5), byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 5, height: 5)).cgPath
    }
    
    private func verticalRectangle() -> CGPath {
        return UIBezierPath(roundedRect: CGRect(x: frame.width/2 - 3.75, y: frame.height/3, width: 7.5, height: frame.height/3), byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 5, height: 5)).cgPath
    }
    
    @objc func addAction(_ sender: Any) {
        addRelease(sender)
    }
    
    @objc private func addTouchDown(_ sender: Any) {
        UIView.animate(withDuration: 0.25) { [weak self] in
            guard let self = self else { return }
            self.gradient.isHidden = true
        }
    }
    
    @objc private func addRelease(_ sender: Any) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            UIView.animate(withDuration: 0.25) { [weak self] in
                guard let self = self else { return }
                self.gradient.isHidden = false
            }
        }
    }
    
}