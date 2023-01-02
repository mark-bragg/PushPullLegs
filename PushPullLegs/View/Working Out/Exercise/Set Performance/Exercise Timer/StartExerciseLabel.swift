//
//  StartExerciseLabel.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 1/2/23.
//  Copyright © 2023 Mark Bragg. All rights reserved.
//

import UIKit

class StartExerciseLabel: UILabel {
    
    let diameter: CGFloat
    let centerConstraints: (x: NSLayoutXAxisAnchor, y: NSLayoutYAxisAnchor)
    
    init(diameter: CGFloat, centerConstraints: (NSLayoutXAxisAnchor, NSLayoutYAxisAnchor)) {
        self.diameter = diameter
        self.centerConstraints = centerConstraints
        super.init(frame: .zero)
        style()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func style() {
        colorize()
        shadowize()
        textualize()
        layer.cornerRadius = diameter / 2
    }
    
    private func colorize() {
        let color = PPLColor.tertiary.cgColor
        layer.backgroundColor = color
        layer.shadowColor = color
    }
    
    private func shadowize() {
        layer.shadowPath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: diameter, height: diameter)).cgPath
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 10
    }
    
    private func textualize() {
        font = UIFont.systemFont(ofSize: 72, weight: .bold)
        text = "Start!"
        textColor = .primary
        textAlignment = .center
    }
    
    func animate() {
        UIView.animate(withDuration: 0.2, delay: 0.7, options: .curveEaseOut, animations: invisiblize, completion: removeFromSuperview)
    }
    
    private func invisiblize() {
        alpha = 0
    }
    
    func removeFromSuperview(_ finished: Bool) {
        constraints.forEach { $0.isActive = false }
        super.removeFromSuperview()
    }
    
    override func layoutSubviews() {
        constrain()
    }
    
    private func constrain() {
        guard constraints.isEmpty else { return }
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: diameter).isActive = true
        heightAnchor.constraint(equalToConstant: diameter).isActive = true
        centerXAnchor.constraint(equalTo: centerConstraints.x).isActive = true
        centerYAnchor.constraint(equalTo: centerConstraints.y).isActive = true
    }
}
