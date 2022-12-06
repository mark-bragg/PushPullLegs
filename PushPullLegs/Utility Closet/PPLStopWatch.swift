//
//  PPLStopWatch.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 6/6/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation

class PPLStopWatch: ForegroundObserver {
    private var startingTime: Double?
    var timeBetweenReadings: TimeInterval = 1
    var handler: ((Int?) -> Void)?
    private var running = false
    private weak var timer: Timer?
    private var count = 0
    
    init(withHandler handler: ((Int?) -> Void)? = nil) {
        self.handler = handler
        PPLSceneDelegate.shared?.foregroundObserver = self
    }
    
    func start() {
        startingTime = CFAbsoluteTimeGetCurrent()
        setTimer()
        timer?.fire()
    }
    
    func setTimer() {
        let timer = Timer.scheduledTimer(withTimeInterval: self.timeBetweenReadings, repeats: true) { [weak self] (timer) in
            guard let self = self else { return }
            self.handler?(self.count)
            self.count += 1
        }
        self.timer = timer
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
    
    func stop() {
        running = false
        handler = nil
        timer?.invalidate()
    }
    
    func currentTime() -> Int {
        Int(CFAbsoluteTimeGetCurrent() - (startingTime ?? 0))
    }
    
    func willEnterForeground() {
        count = currentTime()
    }
}

extension Date {
    static var now: Date { Date() }
}
