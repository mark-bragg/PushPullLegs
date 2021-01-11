//
//  Shadows.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 1/11/21.
//  Copyright © 2021 Mark Bragg. All rights reserved.
//

import UIKit

extension CGSize {
    static let shadowOffset = CGSize(width: 0, height: 5)
    static let shadowOffsetCell = CGSize(width: 0, height: 17)
    static let shadowOffsetAddButton = CGSize(width: 0, height: 8)
    static let shadowOffsetTableHeader = CGSize(width: 0, height: 17)
}

extension UIView {
    func addShadow(_ offset: CGSize = .shadowOffset) {
        removeShadow()
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.shadowPath = CGPath(rect: CGRect(x: 2.5, y: 0, width: bounds.width - 5, height: bounds.height), transform: nil)
        layer.shadowOffset = offset
        if layer.cornerRadius > 0 {
            layer.shadowRadius = layer.cornerRadius
        }
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 1.0
    }
    
    @objc func addSimpleShadow(_ offset: CGSize = .shadowOffset) {
        layer.shadowPath = CGPath(roundedRect: layer.bounds, cornerWidth: layer.cornerRadius, cornerHeight: layer.cornerRadius, transform: nil)
        layer.shadowOffset = offset
        layer.shadowOpacity = 1.0
    }
    
    func removeShadow() {
        self.layer.shadowPath = nil
        self.layer.shadowOffset = .zero
        layer.shadowOpacity = .zero
    }
}
