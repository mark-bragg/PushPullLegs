//
//  TimeLabel.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 1/2/23.
//  Copyright © 2023 Mark Bragg. All rights reserved.
//

import UIKit

class TimeLabel: UIView, UIKeyInput {
    var characters = ["", "", "", ""]
    let labelTag = 473
    var label: UILabel? { viewWithTag(labelTag) as? UILabel }
    override var canBecomeFirstResponder: Bool { true }
    var keyboardType: UIKeyboardType = .numberPad
    
    override func layoutSubviews() {
        guard label == nil
        else { return }
        
        addLabel()
        constrainLabel()
        styleLabel()
        let tappy = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        addGestureRecognizer(tappy)
        isUserInteractionEnabled = true
    }
    
    private func addLabel() {
        let label = UILabel()
        label.tag = labelTag
        addSubview(label)
    }
    
    private func constrainLabel() {
        guard let label = label else { return }
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        label.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
    }
    
    private func styleLabel() {
        guard let label = label else { return }
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 48, weight: .regular)
        label.textAlignment = .center
        label.text = "00:00"
    }
    
    @objc func tapped(_ sender: Any?) {
        becomeFirstResponder()
    }
    
    public var hasText: Bool {
        characters.contains(where: { $0 != "" })
    }
    
    public var isFullUp: Bool {
        characters.allSatisfy({ $0 != "" })
    }
    
    public func insertText(_ text: String) {
        if !hasText && text == "0" {
            return
        }
        guard !isFullUp else { return }
        updateText(text)
    }
    
    func updateText(_ text: String) {
        guard text.allSatisfy({ $0.isNumber }) else { return }
        for i in (1..<characters.count) {
            characters[i - 1] = characters[i]
        }
        characters[characters.count - 1] = text
        updateLabel()
    }
    
    public func deleteBackward() {
        guard hasText else { return }
        if isFullUp {
            characters[characters.count - 1] = ""
        }
        for i in (1..<characters.count).reversed() {
            characters[i] = characters[i - 1]
            if characters[i] == "" { break }
            if i == 1 {
                characters[0] = ""
            }
        }
        
        updateLabel()
    }
    
    func updateLabel() {
        let first = characters[0] == "" ? "0" : characters[0]
        let second = characters[1] == "" ? "0" : characters[1]
        let third = characters[2] == "" ? "0" : characters[2]
        let fourth = characters[3] == "" ? "0" : characters[3]
        label?.text = "\(first)\(second):\(third)\(fourth)"
    }
    
}
