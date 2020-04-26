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

struct ExerciseStateError: Error {
    
}

class ExerciseSetViewModel: NSObject {
    
    weak var delegate: ExerciseSetViewModelDelegate?
    weak var timerDelegate: ExerciseSetTimerDelegate?
    weak var setCollector: ExerciseSetCollector!
    var completedExerciseSet: Bool {
        return state == .finished
    }
    // TODO: maybe we need this
//    var canceledExerciseSet: Bool {
//        return self.state == .canceled
//    }
    private var startingTime: Date!
    private var totalTime: Int!
    private var queue: DispatchQueue?
    private var weight: Double!
    private var state: ExerciseSetState
    
    override init() {
        queue = DispatchQueue(label: "timer queue")
        state = .notStarted
        super.init()
    }
    
    deinit {
        queue = nil
    }
    
    func startSetWithWeight(_ weight: Double) {
        do {
            try setState(.inProgress)
        } catch {
            print("invalid state error")
            return
        }
        self.weight = weight
        startingTime = Date()
        delegate?.exerciseSetViewModelStartedSet(self)
        beginTimerTextUpdates()
    }
    
    func stopTimer() {
        do {
            try setState(.ending)
        } catch {
            print("invalid state error")
            return
        }
        delegate?.exerciseSetViewModelStoppedTimer(self)
        queue = nil
        totalTime = Int(self.startingTime.timeIntervalSinceNow * -1)
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
    
    private func beginTimerTextUpdates() {
        queue!.async { [weak self] in
            guard let self = self else { return }
            while self.state == .inProgress {
                let interval = Int(self.startingTime.timeIntervalSinceNow * -1)
                let minutes = interval / 60
                let seconds = interval % 60
                self.timerDelegate?.timerUpdate(String(format: "%01d:%02d", minutes, seconds))
                sleep(1)
            }
        }
    }
}
