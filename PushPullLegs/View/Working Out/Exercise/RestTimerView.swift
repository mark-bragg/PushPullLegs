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
    override var frame: CGRect {
        willSet {
            if newValue.width == 0 {
                timerLabel.transform = timerLabel.transform.scaledBy(x:0.1, y:0.1)
            } else {
                timerLabel.transform = timerLabel.transform.scaledBy(x:10, y:10)
            }
            timerLabel.center = CGPoint(x: newValue.width/2, y: newValue.height/2)
            layer.cornerRadius = newValue.height/2
        }
    }
    
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
        layer.backgroundColor = PPLColor.secondary.cgColor
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1.5
        layer.cornerRadius = frame.height/2
    }
    
    func setupTimerLabel() {
        timerLabel.adjustsFontSizeToFitWidth = true
        timerLabel.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        timerLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 40, weight: .semibold)
        timerLabel.textColor = .white
        addSubview(timerLabel)
        timerLabel.textAlignment = .center
        timerLabel.backgroundColor = .clear
        timerLabel.center = CGPoint(x: frame.width/2, y: frame.height/2)
    }
}
