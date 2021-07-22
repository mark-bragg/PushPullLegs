//
//  PPLStopWatch.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 6/6/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation

class PPLStopWatch {
    private var startingTime: Double!
    var timeBetweenReadings: TimeInterval = 1
    var handler: ((Int?) -> Void)?
    private var running = false
    private weak var timer: Timer?
    private var count = 0
    
    init(withHandler handler: ((Int?) -> Void)? = nil) {
        self.handler = handler
    }
    
    func start() {
        startingTime = CFAbsoluteTimeGetCurrent()
        let timer = Timer.scheduledTimer(withTimeInterval: self.timeBetweenReadings, repeats: true) { [weak self] (timer) in
            guard let self = self else { return }
            self.handler?(self.count)
            self.count += 1
        }
        timer.fire()
        self.timer = timer
    }
    
    func stop() {
        running = false
        handler = nil
        timer?.invalidate()
    }
    
    func currentTime() -> Int {
        return Int(CFAbsoluteTimeGetCurrent() - self.startingTime)
    }
}

extension Date {
    static var now: Date { Date() }
}
