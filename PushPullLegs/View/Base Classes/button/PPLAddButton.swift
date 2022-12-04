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
    private weak var gradient: CAGradientLayer?
    private weak var darkGradient: CAGradientLayer?
    
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
        layer.backgroundColor = PPLColor.primary.cgColor
        layer.cornerRadius = layer.frame.height / 2
        addLightGradientLayer()
        addDarkGradientLayer()
    }
    
    private func addLightGradientLayer() {
        let lightGradientLayer = gradientLayer(frame: CGRect(x: -1, y: -1, width: layer.bounds.width + 2, height: layer.bounds.height + 2), dark: false)
        layer.addSublayer(lightGradientLayer)
        self.gradient = lightGradientLayer
    }
    
    private func addDarkGradientLayer() {
        let darkGradient = gradientLayer(frame: layer.bounds, dark: true)
        layer.addSublayer(darkGradient)
        self.darkGradient = darkGradient
        darkGradient.isHidden = true
    }
    
    private func gradientLayer(frame: CGRect, dark: Bool) -> CAGradientLayer {
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
            UIColor(white: dark ? 0.0 : 1, alpha: 0.25).cgColor,
            UIColor(white: dark ? 0.0 : 1, alpha: 0.45).cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.frame = frame
        gradientLayer.cornerRadius = layer.cornerRadius
        return gradientLayer
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
        let horizontal = CALayer()
        let vertical = CALayer()
        horizontal.frame = CGRect(x: plusLayer.bounds.width/3, y: plusLayer.bounds.height/2 - 3.75, width: plusLayer.bounds.width/3, height: 7.5)
        vertical.frame = CGRect(x: plusLayer.bounds.width/2 - 3.75, y: plusLayer.bounds.height/3, width: 7.5, height: plusLayer.bounds.height/3)
        for layer in [horizontal, vertical] {
            layer.backgroundColor = PPLColor.readyStatePlusSign.cgColor
            layer.cornerRadius = 5
            plusLayer.addSublayer(layer)
        }
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
            self.gradient?.isHidden = true
            self.darkGradient?.isHidden = false
            self.updatePlusSignColor(PPLColor.pressedStatePlusSign)
        }
    }
    
    @objc private func addRelease(_ sender: Any) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            UIView.animate(withDuration: 0.25) { [weak self] in
                guard let self = self else { return }
                self.gradient?.isHidden = false
                self.darkGradient?.isHidden = true
                self.updatePlusSignColor(PPLColor.readyStatePlusSign)
            }
        }
    }
    
    func updatePlusSignColor(_ color: PPLColor) {
        if let sublayers = self.layer.sublayers?.first(where: {$0.name == self.plusSignLayerName})?.sublayers {
            for layer in sublayers {
                layer.backgroundColor = color.cgColor
            }
        }
    }
    
}
