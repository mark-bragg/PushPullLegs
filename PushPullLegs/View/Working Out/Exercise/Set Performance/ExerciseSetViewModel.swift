//
//  ExerciseSetViewModel.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/23/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation
import Combine

protocol ExerciseSetCollector: NSObjectProtocol {
    func collectSet(duration: Int, weight: Double, reps: Double)
}

protocol SuperSetCollector: NSObjectProtocol {
    func collectSuperSetSet(duration: Int, weight: Double, reps: Double, _ delegate: ExerciseSetViewModelDelegate?)
}

fileprivate enum ExerciseSetState {
    case notStarted
    case inProgress
    case ending
    case finished
    case canceled
}

protocol ExerciseSetViewModelDelegate: NSObjectProtocol {
    func exerciseSetViewModelWillStartSet(_ viewModel: ExerciseSetViewModel)
    func exerciseSetViewModelStoppedTimer(_ viewModel: ExerciseSetViewModel)
    func exerciseSetViewModelFinishedSet(_ viewModel: ExerciseSetViewModel?)
    func exerciseSetViewModelCanceledSet(_ viewModel: ExerciseSetViewModel)
}

struct ExerciseStateError: Error { }

class ExerciseSetViewModel: NSObject {
    
    weak var delegate: ExerciseSetViewModelDelegate?
    weak var setCollector: ExerciseSetCollector?
    weak var superSetCollector: SuperSetCollector?
    var completedExerciseSet: Bool { state == .finished }
    private(set) var totalTime: Int?
    private(set) var weight: Double?
    private var state: ExerciseSetState
    var stopWatch: PPLStopWatch?
    var countdownValue: Int { PPLDefaults.instance.countdown() }
    private var countdown = PPLDefaults.instance.countdown()
    private var countdownCanceled = false
    @Published private(set) var setBegan: Bool?
    private var cancellables = [AnyCancellable]()
    var defaultWeight: Double?
    
    override init() {
        state = .notStarted
        super.init()
        countdown = countdownValue
        $setBegan.sink { (began) in
            guard PPLDefaults.instance.areTimerSoundsEnabled(), let began = began, began else { return }
            SoundManager.shared.playStartSound()
        }.store(in: &cancellables)
    }
    
    func restartSet() {
        countdown = countdownValue
        stopWatch?.start()
    }
    
    func willStartSetWithWeight(_ weight: Double) {
        self.weight = weight
        delegate?.exerciseSetViewModelWillStartSet(self)
    }
    
    func startSet() {
        setStateForStartSet()
        if PPLDefaults.instance.isWorkoutInProgress() {
            countdown = countdownValue
            stopWatch?.start()
        }
    }
    
    fileprivate func setStateForStartSet() {
        do {
            try setState(.inProgress)
        } catch {
            print("invalid state error")
            return
        }
    }
    
    func stopTimer() {
        do {
            try setState(.ending)
        } catch {
            print("invalid state error")
            return
        }
        stopWatch?.stop()
        totalTime = currentTime()
        delegate?.exerciseSetViewModelStoppedTimer(self)
    }
    
    func collectDuration(_ duration: String) {
        do {
            try setState(.ending)
        } catch {
            print("invalid state error")
            return
        }
        totalTime = String.unformat(minutesAndSeconds: duration)
        delegate?.exerciseSetViewModelStoppedTimer(self)
    }
    
    func currentTime(_ seconds: Int? = nil) -> Int {
        let s = seconds ?? (stopWatch?.currentTime() ?? 0)
        var multiplier = -1
        if countdownCanceled {
            countdownCanceled = false
            countdown = s
        }
        if countingDown(s) {
            multiplier *= -1
            let time = calculateCurrentTime(s, multiplier)
            setBegan = countdown == s
            if let setBegan, time <= 3 && !setBegan && PPLDefaults.instance.areTimerSoundsEnabled() {
                SoundManager.shared.playCountdownSound()
            }
        } else if PPLDefaults.instance.areTimerSoundsEnabled() {
            SoundManager.shared.playTickSound()
        }
        return calculateCurrentTime(s, multiplier)
    }
    
    private func countingDown(_ s: Int) -> Bool {
        return countdown >= s
    }
    
    fileprivate func calculateCurrentTime(_ s: Int, _ multiplier: Int) -> Int {
        return (countdown - s) * multiplier
    }
    
    func finishSetWithReps(_ reps: Double) {
        guard
            let totalTime,
            let weight
        else { return }
        do {
            try setState(.finished)
        } catch {
            print("invalid state error")
            return
        }
        if let superSetCollector {
            superSetCollector.collectSuperSetSet(duration: totalTime, weight: weight, reps: reps, delegate)
        } else {
            setCollector?.collectSet(duration: totalTime, weight: weight, reps: reps)
            delegate?.exerciseSetViewModelFinishedSet(self)
        }
    }
    
    func cancel() {
        state = .canceled
        self.delegate?.exerciseSetViewModelCanceledSet(self)
        stopWatch?.stop()
    }
    
    func revertState() throws {
        switch state {
        case .inProgress:
            state = .notStarted
            stopWatch?.stopTimer()
            setBegan = false
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
        let countdown = countdownValue
        if countdown >= 10 {
            return "0:\(countdown)"
        }
        return "0:0\(countdown)"
    }
    
    func cancelCountdown() {
        countdownCanceled = true
        countdown = countdownValue
    }
    
    func weightCollectionButtonText() -> String {
        PPLDefaults.instance.isWorkoutInProgress() ? "Begin Set" : "Submit"
    }
    
}
