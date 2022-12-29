//
//  PPLButton.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 8/1/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation
import UIKit

@objc protocol PPLButtonDelegate: NSObjectProtocol {
    func buttonReleased(_ sender: Any)
    @objc optional func buttonPressed(_ sender: Any)
}

fileprivate let timerDelay = 250

class PPLButton : UIButton {
    
    var radius: CGFloat = 0
    var delegate: PPLButtonDelegate?
    
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
    
    func style() {
//        configuration = .borderedProminent()
        layer.cornerRadius = radius != 0 ? radius : frame.height/2
        layer.borderWidth = 2.0
        layer.borderColor = UIColor.white.cgColor
        setTitleColor(.disabledSaveWhiteColor, for: .disabled)
        setTitleColor(.text, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 27, weight: .medium)
        backgroundColor = .quaternary
    }
    
    func enable() {
        isEnabled = true
        layer.borderColor = UIColor.white.cgColor
    }
    
    func disable() {
        isEnabled = false
        layer.borderColor = PPLColor.disabledSaveWhiteColor.cgColor
    }
    
    @objc func touchDown() {
        selection()
        guard delegate != nil else {
            return NotificationCenter.default.post(name: PPLButton.touchDownNotificationName(), object: self)
        }
        delegate?.buttonPressed?(self)
        startTimer()
    }
    
    @objc func selection() {
        isSelected = true
        layer.borderColor = PPLColor.disabledSaveWhiteColor.cgColor
        backgroundColor = PPLColor.secondary
    }
    
    private func startTimer() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now().advanced(by: DispatchTimeInterval.milliseconds(timerDelay))) {
            if self.isSelected {
                self.delegate?.buttonReleased(self)
                self.deselection()
            }
        }
    }
    
    @objc func deselection() {
        isSelected = false
        layer.borderColor = UIColor.white.cgColor
        backgroundColor = PPLColor.quaternary
    }
    
    static func touchDownNotificationName() -> NSNotification.Name {
        return NSNotification.Name("PPLButtonTouchDown")
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
