//
//  ExerciseSetViewModel.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/23/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation

protocol ExerciseSetTimerDelegate: NSObject {
    func timerUpdate(_ text: String)
}

protocol ExerciseSetCollector: NSObject {
    func collectSet(duration: Int, weight: Double, reps: Int)
}

fileprivate enum ExerciseSetState {
    case notStarted
    case inProgress
    case ending
    case finished
    case canceled
}

protocol ExerciseSetViewModelDelegate: NSObject {
    func exerciseSetViewModelStartedSet(_ viewModel: ExerciseSetViewModel)
    func exerciseSetViewModelStoppedTimer(_ viewModel: ExerciseSetViewModel)
    func exerciseSetViewModelFinishedSet(_ viewModel: ExerciseSetViewModel)
    func exerciseSetViewModelCanceledSet(_ viewModel: ExerciseSetViewModel)
}

struct ExerciseStateError: Error { }

class ExerciseSetViewModel: NSObject {
    
    weak var delegate: ExerciseSetViewModelDelegate?
    weak var timerDelegate: ExerciseSetTimerDelegate?
    weak var setCollector: ExerciseSetCollector!
    var completedExerciseSet: Bool {
        return state == .finished
    }
    private var totalTime: Int!
    private var weight: Double!
    private var state: ExerciseSetState
    private var stopWatch: PPLStopWatch!
    private var countdown = PPLDefaults.instance.countdown()
    private var countdownCanceled = false
    @Published private(set) var setBegan: Bool!
    
    override init() {
        state = .notStarted
        super.init()
        stopWatch = PPLStopWatch(withHandler: { [weak self] (seconds) in
            guard let self = self else { return }
            self.timerDelegate?.timerUpdate(String.format(seconds: self.currentTime(seconds)))
        })
    }
    
    func restartSet() {
        countdown = PPLDefaults.instance.countdown()
        stopWatch.start()
    }
    
    func startSetWithWeight(_ weight: Double) {
        setStateForStartSet()
        fireOffStart(weight)
    }
    
    fileprivate func setStateForStartSet() {
        do {
            try setState(.inProgress)
        } catch {
            print("invalid state error")
            return
        }
    }
    
    fileprivate func fireOffStart(_ weight: Double) {
        stopWatch.start()
        self.weight = weight
        delegate?.exerciseSetViewModelStartedSet(self)
    }
    
    func stopTimer() {
        do {
            try setState(.ending)
        } catch {
            print("invalid state error")
            return
        }
        stopWatch.stop()
        totalTime = currentTime()
        delegate?.exerciseSetViewModelStoppedTimer(self)
    }
    
    private func currentTime(_ seconds: Int? = nil) -> Int {
        let s = seconds ?? stopWatch.currentTime()
        var multiplier = -1
        if countdownCanceled {
            countdownCanceled = false
            countdown = s
        }
        if countdown >= s {
            multiplier *= -1
            setBegan = countdown == s
        }
        return (countdown - s) * multiplier
    }
    
    func finishSetWithReps(_ reps: Int) {
        guard setCollector != nil else { return }
        do {
            try setState(.finished)
        } catch {
            print("invalid state error")
            return
        }
        setCollector.collectSet(duration: totalTime, weight: weight, reps: reps)
        delegate?.exerciseSetViewModelFinishedSet(self)
    }
    
    func cancel() {
        state = .canceled
        self.delegate?.exerciseSetViewModelCanceledSet(self)
    }
    
    func revertState() throws {
        switch state {
        case .inProgress:
            state = .notStarted
        case .ending:
            state = .inProgress
            setBegan = false
            restartSet()
        case .finished:
            state = .ending
        case .notStarted:
            state = .canceled
        default:
            state = .canceled
        }
    }
    
    private func setState(_ newValue: ExerciseSetState) throws {
        switch newValue {
        case .inProgress:
            if state != .notStarted {
                throw ExerciseStateError()
            }
        case .ending:
            if state != .inProgress {
                throw ExerciseStateError()
            }
        case .finished:
            if state != .ending {
                throw ExerciseStateError()
            }
        default:
            throw ExerciseStateError()
        }
        state = newValue
    }
    
    func initialTimerText() -> String {
        let countdown = PPLDefaults.instance.countdown()
        if countdown >= 10 {
            return "0:\(countdown)"
        }
        return "0:0\(countdown)"
    }
    
    func cancelCountdown() {
        countdownCanceled = true
    }
    
}
