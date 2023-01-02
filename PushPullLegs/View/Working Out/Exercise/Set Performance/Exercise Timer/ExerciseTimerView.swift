//
//  ExerciseTimerView.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 1/2/23.
//  Copyright © 2023 Mark Bragg. All rights reserved.
//

import UIKit

class ExerciseTimerView: UIView {
    // MARK: stackView
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [UIView(), timerLabel, finishButton, UIView()])
        addSubview(stack)
        styleStackView(stack)
        return stack
    }()
    private func constrainStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 20).isActive = true
        stackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: 300).isActive = true
    }
    private func styleStackView(_ stackView: UIStackView) {
        stackView.alignment = UIStackView.Alignment.center
        stackView.axis = NSLayoutConstraint.Axis.vertical
        stackView.distribution = UIStackView.Distribution.equalCentering
        stackView.spacing = 14
    }
    
    // MARK: timerLabel
    lazy var timerLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "00:00"
        styleTimerLabel(lbl)
        return lbl
    }()
    private func styleTimerLabel(_ timerLabel: UILabel) {
        timerLabel.layer.borderColor = PPLColor.tertiary.cgColor
        timerLabel.layer.backgroundColor = PPLColor.quaternary.cgColor
        timerLabel.textColor = PPLColor.text
        timerLabel.layer.borderWidth = 1.5
        timerLabel.layer.cornerRadius = timerLabel.frame.height / 12
        timerLabel.font = .monospacedDigitSystemFont(ofSize: 56, weight: UIFont.Weight.regular)
    }
    
    // MARK: finishButton
    lazy var finishButton: UIButton = {
        let btn = UIButton(configuration: buttonConfig())
        btn.backgroundColor = .primary
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btn.setTitle("Finish Set", for: .normal)
        return btn
    }()
    private func buttonConfig() -> UIButton.Configuration {
        var config = UIButton.Configuration.borderedProminent()
        config.baseBackgroundColor = .black
        config.buttonSize = UIButton.Configuration.Size.large
        return config
    }
    
    // MARK: bannerContainerView
    lazy var bannerContainerView: UIView = {
        let v = UIView()
        addSubview(v)
        constrainBannerContainerView(v)
        return v
    }()
    private func constrainBannerContainerView(_ v: UIView) {
        v.translatesAutoresizingMaskIntoConstraints = false
        v.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -safeAreaInsets.bottom).isActive = true
        v.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        v.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        let height = v.heightAnchor.constraint(equalToConstant: 0)
        height.identifier = "height"
        height.isActive = true
    }
    
    // MARK: startLabel
    private(set) weak var startLabel: StartExerciseLabel?
    func showStartText() {
        let startLabel = StartExerciseLabel(diameter: frame.width * 0.75, centerConstraints: (finishButton.centerXAnchor, finishButton.centerYAnchor))
        addSubview(startLabel)
        startLabel.animate()
        timerLabel.isUserInteractionEnabled = false
        self.startLabel = startLabel
    }
    
    // MARK: layout
    override func layoutSubviews() {
        backgroundColor = .primary
        if stackView.constraints.isEmpty {
            constrainStackView()
        }
    }
}
