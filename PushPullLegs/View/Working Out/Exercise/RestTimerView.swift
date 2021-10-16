//
//  RestTimerView.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 10/26/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

class RestTimerView: UIView {
    private var text: String? {
        willSet {
            timerLabel.text = newValue
        }
    }
    private var timerLabel = UILabel()
    private var stopWatch: PPLStopWatch!
    private var topLine: UIView {
        if let v = viewWithTag(topLineTag) {
            return v
        }
        return insertTopLine()
    }
    private let topLineTag = 83629
    
    private func insertTopLine() -> UIView {
        let tl = UIView()
        tl.translatesAutoresizingMaskIntoConstraints = false
        tl.tag = topLineTag
        addSubview(tl)
        tl.topAnchor.constraint(equalTo: topAnchor).isActive = true
        tl.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        tl.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        tl.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.0125).isActive = true
        return tl
    }
    
    func restartTimer() {
        timerLabel.removeFromSuperview()
        timerLabel = UILabel()
        setupTimerLabel()
        stopWatch = PPLStopWatch(withHandler: { [weak self] (seconds) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.text = String.format(seconds: seconds ?? 0)
            }
        })
        stopWatch.start()
    }
    
    override func layoutSubviews() {
        layer.backgroundColor = PPLColor.primary.cgColor
        topLine.backgroundColor = .white
    }
    
    private func setupTimerLabel() {
        addSubview(timerLabel)
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        timerLabel.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        timerLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        timerLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        timerLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 24, weight: .semibold)
        timerLabel.textColor = .white
        timerLabel.textAlignment = .center
        timerLabel.backgroundColor = .clear
    }
    
    @objc func getDragAndDropView() -> UIView {
        self
    }
}
