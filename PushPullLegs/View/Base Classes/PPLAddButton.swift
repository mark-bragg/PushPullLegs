//
//  PPLAddButton.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 7/17/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

class PPLAddButton: UIControl {
    
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
        layer.backgroundColor = PPLColor.lightGrey?.cgColor
        layer.cornerRadius = layer.frame.height / 2
    }
    
    private func addPlusSign() {
        if viewWithTag(333) != nil { return }
        let plusSign = UILabel()
        plusSign.text = "+"
        plusSign.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        plusSign.textColor = .white
        plusSign.textAlignment = .center
        plusSign.sizeToFit()
        addSubview(plusSign)
        plusSign.center = CGPoint(x: frame.width/2, y: frame.height/2)
        plusSign.tag = 333
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
        UIView.animate(withDuration: 0.25) { [weak self] in
            guard let self = self else { return }
            self.layer.shadowOffset = .shadowOffsetAddButton
        }
    }
    
    private func addShadow() {
        if layer.shadowOffset == .shadowOffsetAddButton {
            return
        }
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1
        layer.shadowPath = UIBezierPath.init(roundedRect: CGRect(origin: .zero, size: layer.frame.size), cornerRadius: layer.frame.size.height / 2).cgPath
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = .shadowOffsetAddButton
        layer.shadowRadius = 2
        layer.shouldRasterize = true
    }
    
}
