//
//  PPLAddButton.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 7/17/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

class PPLAddButton: UIControl {
    
    private let PLUS_SIGN_NAME = "PLUS_SIGN_NAME"
    
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
        addShadow()
    }
    
    private func style() {
        clipsToBounds = false
        layer.backgroundColor = PPLColor.textBlue?.cgColor
        layer.cornerRadius = layer.frame.height / 2
    }
    
    private func addPlusSign() {
        if let layers = layer.sublayers, layers.contains(where: { $0.name == PLUS_SIGN_NAME } ) {
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
        horizontal.fillColor = UIColor.white.cgColor
        vertical.path = verticalRectangle()
        vertical.fillColor = UIColor.white.cgColor
        plusLayer.addSublayer(horizontal)
        plusLayer.addSublayer(vertical)
        plusLayer.name = PLUS_SIGN_NAME
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
            self.layer.shadowOffset = .shadowOffset
        }
    }
    
    @objc private func addRelease(_ sender: Any) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            UIView.animate(withDuration: 0.25) { [weak self] in
                guard let self = self else { return }
                self.layer.shadowOffset = .shadowOffsetAddButton
            }
        }
    }
    
    private func a1ddShadow() {
        if layer.shadowOffset == .shadowOffsetAddButton {
            return
        }
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 4
        layer.shadowPath = UIBezierPath.init(roundedRect: CGRect(origin: .zero, size: layer.frame.size), cornerRadius: layer.frame.size.height / 2).cgPath
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.55
        layer.shadowOffset = .shadowOffsetAddButton
        layer.shadowRadius = 2
        layer.shouldRasterize = true
    }
    
}
