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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func restartTimer() {
        stopWatch = PPLStopWatch(withHandler: { [weak self] (seconds) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.text = String.format(seconds: seconds ?? 0)
            }
        })
        stopWatch.start()
    }
    
    override func layoutSubviews() {
        if !subviews.contains(timerLabel) {
            setupTimerLabel()
        }
        layer.backgroundColor = UIColor.systemRed.cgColor
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1.5
        layer.cornerRadius = frame.height/2
        addSimpleShadow(.shadowOffsetAddButton)
    }
    
    func setupTimerLabel() {
        timerLabel.frame = CGRect(x: 20, y: 10, width: frame.width - 40, height: frame.height - 20)
        timerLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 40, weight: .semibold)
        timerLabel.textColor = .white
        addSubview(timerLabel)
        timerLabel.textAlignment = .center
        timerLabel.backgroundColor = .clear
    }
}
