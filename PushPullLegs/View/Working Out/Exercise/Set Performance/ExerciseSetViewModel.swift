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
    private let countdown = PPLDefaults.instance.countdown()
    @Published private(set) var setBegan = false
    
    override init() {
        state = .notStarted
        super.init()
        stopWatch = PPLStopWatch(withHandler: { [weak self] (seconds) in
            guard let self = self else { return }
            self.timerDelegate?.timerUpdate(String.format(seconds: self.currentTime(seconds)))
        })
    }
    
    func startSetWithWeight(_ weight: Double) {
        do {
            try setState(.inProgress)
        } catch {
            print("invalid state error")
            return
        }
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
}
