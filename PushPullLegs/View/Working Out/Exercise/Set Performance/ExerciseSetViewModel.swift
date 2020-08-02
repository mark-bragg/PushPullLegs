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
    
    override init() {
        state = .notStarted
        super.init()
        weak var weakSelf = self
        stopWatch = PPLStopWatch(withHandler: { (seconds) in
            guard let strongSelf = weakSelf else { return }
            strongSelf.timerDelegate?.timerUpdate(String.format(seconds: seconds))
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
        totalTime = Int(stopWatch.currentTime())
        delegate?.exerciseSetViewModelStoppedTimer(self)
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
}
