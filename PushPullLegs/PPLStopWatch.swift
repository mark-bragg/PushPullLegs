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
    
    init(withHandler handler: ((Int) -> Void)? = nil) {
        self.handler = handler
    }
    
    func start() {
        queue = DispatchQueue(label: "timer queue")
        startingTime = CFAbsoluteTimeGetCurrent()
        beginUpdating()
    }
    
    func stop() {
        queue?.suspend()
    }
    
    func currentTime() -> Int {
        return Int(CFAbsoluteTimeGetCurrent() - self.startingTime)
    }
    
    private func beginUpdating() {
        queue!.async { [weak self] in
            guard let self = self else { return }
            while let handler = self.handler {
                handler(self.currentTime())
                sleep(self.timeBetweenReadings)
            }
        }
    }
}