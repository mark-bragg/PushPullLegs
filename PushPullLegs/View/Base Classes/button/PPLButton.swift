//
//  PPLButton.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 8/1/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation
import UIKit

class PPLButton : UIButton {
    
    var radius: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        addTarget(self, action: #selector(touchDown), for: .touchDown)
        addTarget(self, action: #selector(deselection), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        style()
        if isEnabled {
            enable()
        } else {
            disable()
        }
        if isSelected {
            selection()
        } else if isEnabled {
            deselection()
        }
    }
    
    func enable() {
        isEnabled = true
        layer.borderColor = UIColor.white.cgColor
        addShadow()
    }
    
    func disable() {
        isEnabled = false
        layer.borderColor = PPLColor.disabledSaveWhiteColor.cgColor
        removeShadow()
    }
    
    @objc func touchDown() {
        selection()
        NotificationCenter.default.post(name: PPLButton.touchDownNotificationName(), object: self)
    }
    
    @objc func selection() {
        isSelected = true
        layer.borderColor = PPLColor.disabledSaveWhiteColor.cgColor
        removeShadow()
    }
    
    @objc func deselection() {
        isSelected = false
        layer.borderColor = UIColor.white.cgColor
        addShadow()
    }
    
    func style() {
        contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        layer.cornerRadius = radius != 0 ? radius : frame.height/2
        layer.borderWidth = 2.0
        layer.borderColor = UIColor.white.cgColor
        setTitleColor(.disabledSaveWhiteColor, for: .disabled)
        setTitleColor(.textGreen, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 27, weight: .medium)
        backgroundColor = .cellBackgroundBlue
    }
    
    static func touchDownNotificationName() -> NSNotification.Name {
        return NSNotification.Name("PPLButtonTouchUpInside")
    }
}

class ExerciseTypeButton: PPLButton {
    var exerciseType: ExerciseType! = nil
    
    override func deselection() {
        
    }
    
    func releaseButton() {
        super.deselection()
    }
}
