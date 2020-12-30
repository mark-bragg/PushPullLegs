//
//  PPLStopWatch.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 6/6/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation

class PPLStopWatch {
    weak var timerDelegate: ExerciseSetTimerDelegate?
    private var startingTime: Double!
    private var queue: DispatchQueue?
    var timeBetweenReadings: UInt32 = 1
    var handler: ((Int) -> Void)?
    private var running = false
    
    init(withHandler handler: ((Int) -> Void)? = nil) {
        self.handler = handler
    }
    
    func start() {
        if queue == nil {
            queue = DispatchQueue(label: "timer queue")
        } else {
            queue?.activate()
        }
        startingTime = CFAbsoluteTimeGetCurrent()
        beginUpdating()
    }
    
    func stop() {
        running = false
        queue?.suspend()
    }
    
    func currentTime() -> Int {
        return Int(CFAbsoluteTimeGetCurrent() - self.startingTime)
    }
    
    private func beginUpdating() {
        running = true
        queue!.async { [weak self] in
            guard let self = self, self.running else { return }
            while let handler = self.handler {
                handler(self.currentTime())
                sleep(self.timeBetweenReadings)
            }
        }
    }
    
    func isRunning() -> Bool {
        return running
    }
}
