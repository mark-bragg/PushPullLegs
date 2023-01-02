//
//  DurationCollectionView.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 1/2/23.
//  Copyright © 2023 Mark Bragg. All rights reserved.
//

import UIKit

class DurationCollectionView: UIView {
    // MARK: stackView
    lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [UIView(), timeLabel, button, UIView()])
        addSubview(stack)
        styleStackView(stack)
        return stack
    }()
    private func styleStackView(_ stack: UIStackView) {
        stack.alignment = UIStackView.Alignment.center
        stack.axis = NSLayoutConstraint.Axis.vertical
        stack.distribution = UIStackView.Distribution.equalCentering
        stack.spacing = 14
    }
    lazy var timeLabel: TimeLabel = {
        TimeLabel(frame: CGRect(x: 0, y: 0, width: 374, height: 150))
    }()
    lazy var button: UIButton = {
        let btn = UIButton(configuration: buttonConfig)
        btn.backgroundColor = .primary
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        return btn
    }()
    private var buttonConfig: UIButton.Configuration {
        var config = UIButton.Configuration.borderedProminent()
        config.baseBackgroundColor = .black
        config.buttonSize = UIButton.Configuration.Size.large
        return config
    }
    
    override func layoutSubviews() {
        constrainStackView()
    }
    
    private func constrainStackView() {
        guard stackView.constraints.isEmpty else { return }
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        stackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: 300).isActive = true
    }
}
