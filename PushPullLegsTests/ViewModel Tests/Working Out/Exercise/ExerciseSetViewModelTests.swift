//
//  ExerciseSetViewModelTests.swift
//  PushPullLegsTests
//
//  Created by Mark Bragg on 4/23/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import XCTest
import Combine
@testable import PushPullLegs

class ExerciseSetViewModelTests: XCTestCase, ExerciseSetViewModelDelegate, ExerciseSetCollector {
    
    var sut: ExerciseSetViewModel!
    static var firstSetup = true
    var timerDelegateExpectations = [XCTestExpectation]()
    var vmStartedExpectation: XCTestExpectation?
    var vmStoppedTimerExpectation: XCTestExpectation?
    var vmFinishedSetExpectation: XCTestExpectation?
    var vmCanceledSetExpectation: XCTestExpectation?
    var collectSetExpectation: XCTestExpectation?
    var setBeganObservers = [AnyCancellable]()
    var shouldHaveBegunAlready = false
    var testingCountdown = false
    var testingClearCountdown = false
    var countdown = 0
    var expectationsCount = 0
    var setBeganCount = 10
    var testingShouldHaveBegunAlready = true
    
    override func setUp() {
        testingShouldHaveBegunAlready = true
        PPLDefaults.instance.setCountdown(countdown)
        sut = ExerciseSetViewModel()
        sut.stopWatch = PPLStopWatch(withHandler: { (seconds) in
            self.timerUpdate(String.format(seconds: self.sut.currentTime(seconds ?? 0)))
        })
        if ExerciseSetViewModelTests.firstSetup {
            ExerciseSetViewModelTests.firstSetup = false
            sut.$setBegan.sink { [weak self] (began) in
                guard let began = began, let self = self, self.testingShouldHaveBegunAlready else { return }
                XCTAssert(began == self.shouldHaveBegunAlready, "expected \(began)\nactual \(self.shouldHaveBegunAlready)")
            }
            .store(in: &setBeganObservers)
        }
        XCTAssert(!sut.completedExerciseSet)
    }

    func testStartSetWithWeight_delegatesCalled() {
        vmStartedExpectation = XCTestExpectation(description: "ExerciseSetViewModelDelegate exerciseSetViewModelStartedSet(_:)")
        var expectations = [vmStartedExpectation!]
        for i in 0...8 {
            let ex = XCTestExpectation(description: "ExerciseSetTimerDelegate timerUpdate(_:) \(i)")
            timerDelegateExpectations.append(ex)
            expectations.append(ex)
        }
        expectationsCount = 9
        sut.delegate = self
        sut.willStartSetWithWeight(10)
        shouldHaveBegunAlready = true
        sut.startSet()
        XCTAssert(!sut.completedExerciseSet)
        wait(for: expectations, timeout: 9)
    }
    
    func testStopTimer_delegateCalled() {
        sut.delegate = self
        shouldHaveBegunAlready = true
        sut.willStartSetWithWeight(10)
        sut.startSet()
        XCTAssert(!sut.completedExerciseSet)
        vmStoppedTimerExpectation = XCTestExpectation(description: "timer stopped expectation")
        sut.stopTimer()
        XCTAssert(!sut.completedExerciseSet)
        wait(for: [vmStoppedTimerExpectation!], timeout: 1)
    }
    
    func testFinishSetWithReps_delegateCalled_setDataCorrect() {
        sut.setCollector = self
        sut.delegate = self
        collectSetExpectation = XCTestExpectation(description: "ExerciseSetCollector collectSet(duration:weight:reps:)")
        vmFinishedSetExpectation = XCTestExpectation(description: "ExerciseSetViewModelDelegate func exerciseSetViewModelStoppedTimer(_:)")
        shouldHaveBegunAlready = true
        sut.willStartSetWithWeight(10)
        sut.startSet()
        XCTAssert(!sut.completedExerciseSet)
        sleep(5)
        sut.stopTimer()
        XCTAssert(!sut.completedExerciseSet)
        sut.finishSetWithReps(20)
        XCTAssert(sut.completedExerciseSet)
        wait(for: [collectSetExpectation!, vmFinishedSetExpectation!], timeout: 6)
    }
    
    func testCancelSet_afterStartingSet_delegateCalled() {
        sut.delegate = self
        vmCanceledSetExpectation = XCTestExpectation(description: "ExerciseSetViewModelDelegate exerciseSetViewModelCanceledSet(_:)")
        shouldHaveBegunAlready = true
        sut.willStartSetWithWeight(10)
        sut.startSet()
        XCTAssert(!sut.completedExerciseSet)
        sut.cancel()
        XCTAssert(!sut.completedExerciseSet)
        wait(for: [vmCanceledSetExpectation!], timeout: 1)
    }
    
    func testCancelSet_afterStoppingTimer_delegateCalled() {
        PPLDefaults.instance.setWorkoutInProgress(true)
        sut.delegate = self
        vmCanceledSetExpectation = XCTestExpectation(description: "ExerciseSetViewModelDelegate exerciseSetViewModelCanceledSet(_:)")
        shouldHaveBegunAlready = true
        sut.willStartSetWithWeight(10)
        sut.startSet()
        XCTAssert(!sut.completedExerciseSet)
        sut.stopTimer()
        XCTAssert(!sut.completedExerciseSet)
        sut.cancel()
        XCTAssert(!sut.completedExerciseSet)
        wait(for: [vmCanceledSetExpectation!], timeout: 1)
    }
    
    func testStartSetWithWeight_stopTimer_finishSetWithReps_allDelegatesCalled_setDataCorrect() {
        var expectations = [XCTestExpectation?]()
        for i in 0...8 {
            let ex = XCTestExpectation(description: "ExerciseSetTimerDelegate timerUpdate(_:) \(i)")
            timerDelegateExpectations.append(ex)
            expectations.append(ex)
        }
        vmStartedExpectation = XCTestExpectation(description: "ExerciseSetViewModelDelegate exerciseSetViewModelStartedSet(_:)")
        vmStoppedTimerExpectation = XCTestExpectation(description: "timer stopped expectation")
        collectSetExpectation = XCTestExpectation(description: "ExerciseSetCollector collectSet(duration:weight:reps:)")
        vmFinishedSetExpectation = XCTestExpectation(description: "ExerciseSetViewModelDelegate func exerciseSetViewModelStoppedTimer(_:)")
        for ex in [vmStartedExpectation, vmStoppedTimerExpectation, collectSetExpectation, vmFinishedSetExpectation] {
            expectations.append(ex)
        }
        expectationsCount = 9
        sut.setCollector = self
        sut.delegate = self
        shouldHaveBegunAlready = true
        sut.willStartSetWithWeight(10)
        sut.startSet()
        XCTAssert(!sut.completedExerciseSet)
        sleep(5)
        sut.stopTimer()
        XCTAssert(!sut.completedExerciseSet)
        sut.finishSetWithReps(20)
        XCTAssert(sut.completedExerciseSet)
        wait(for: [collectSetExpectation!, vmFinishedSetExpectation!], timeout: 20)
    }
    
    func testInitialTimerText() {
        PPLDefaults.instance.setCountdown(5)
        XCTAssert(sut.initialTimerText() == "0:05")
        PPLDefaults.instance.setCountdown(10)
        XCTAssert(sut.initialTimerText() == "0:10")
        PPLDefaults.instance.setCountdown(15)
        XCTAssert(sut.initialTimerText() == "0:15")
    }
    
    
    
    func testTimerUpdateWithCountdownAndCountUp() {
        countdown = 5
        setUp()
        testingCountdown = true
        PPLDefaults.instance.setCountdown(countdown)
        for i in 0...4 {
            let ex = XCTestExpectation(description: "ExerciseSetTimerDelegate countdown expectation timerUpdate(_:) \(i)")
            timerDelegateExpectations.append(ex)
        }
        for i in 0...5 {
            let ex = XCTestExpectation(description: "ExerciseSetTimerDelegate countup expectation timerUpdate(_:) \(i)")
            timerDelegateExpectations.append(ex)
        }
        expectationsCount = 11
        shouldHaveBegunAlready = true
        sut.willStartSetWithWeight(10)
        sut.startSet()
        wait(for: timerDelegateExpectations, timeout: 15)
    }
    
    func testCancelCountdown() {
        countdown = 5
        setUp()
        testingCountdown = true
        testingClearCountdown = true
        PPLDefaults.instance.setCountdown(countdown)
        let ex = XCTestExpectation(description: "ExerciseSetTimerDelegate countdown expectation timerUpdate(_:) \(0)")
        timerDelegateExpectations.append(ex)
        for i in 0...5 {
            let ex = XCTestExpectation(description: "ExerciseSetTimerDelegate countup expectation timerUpdate(_:) \(i)")
            timerDelegateExpectations.append(ex)
        }
        expectationsCount = 6
        shouldHaveBegunAlready = true
        PPLDefaults.instance.setWorkoutInProgress(true)
        sut.willStartSetWithWeight(10)
        sut.startSet()
        wait(for: timerDelegateExpectations, timeout: 15)
    }
    
    func testRevertState_stateReverted() {
        sut.willStartSetWithWeight(90)
        do {
            try sut.revertState()
        } catch {
            XCTFail()
        }
        sut.willStartSetWithWeight(90)
        sut.startSet()
        sut.finishSetWithReps(10)
        do {
            try sut.revertState()
        } catch {
            XCTFail()
        }
        sut.finishSetWithReps(10)
    }
    
    func testRevertStateDuringRepCollection_timerStateIsValid() {
        self.testingShouldHaveBegunAlready = false
        PPLDefaults.instance.setWorkoutInProgress(true)
        sut.willStartSetWithWeight(50)
        sut.startSet()
        sut.stopTimer()
        do {
            try sut.revertState()
        } catch {
            XCTFail()
        }
    }
    
    func testAAAAAAAA_setBegan() {
        sut = nil
        setBeganObservers.removeAll()
        for _ in 0...9 {
            setUp()
            sut.$setBegan.sink { (didBegin) in
                if let begun = didBegin {
                    XCTAssert(begun)
                }
            }.store(in: &setBeganObservers)
            sut.willStartSetWithWeight(1)
            sut.startSet()
            sut.cancel()
        }
    }
    
    func timerUpdate(_ text: String) {
        guard timerDelegateExpectations.count > 0 else {
            return
        }
        if testingCountdown {
            if testingClearCountdown {
                testingCountdown = false
                sut.cancelCountdown()
            }
            assertCountdownText(text)
        } else {
            XCTAssert(text == "0:0\(expectationsCount-timerDelegateExpectations.count)", "\nexpected: 0:0\(expectationsCount-timerDelegateExpectations.count)\nactual:\(text)")
            timerDelegateExpectations.removeLast().fulfill()
        }
    }
    
    func assertCountdownText(_ text: String) {
        let exp = timerDelegateExpectations.removeLast()
        if countdown == -1 {
            XCTAssert(text == "0:0\(PPLDefaults.instance.countdown() - timerDelegateExpectations.count)", "\nexpected: 0:0\(PPLDefaults.instance.countdown() - timerDelegateExpectations.count)\nactual: \(text)")
        } else {
            XCTAssert(text == "0:0\(countdown)", "\nexpected: 0:0\(countdown)\nactual: \(text)")
            countdown -= 1
        }
        exp.fulfill()
    }
    
    func collectSet(duration: Int, weight: Double, reps: Double) {
        collectSetExpectation?.fulfill()
        XCTAssert(duration == 5)
        XCTAssert(weight == 10)
        XCTAssert(reps == 20)
    }
    
    func exerciseSetViewModelWillStartSet(_ viewModel: ExerciseSetViewModel) {
        vmStartedExpectation?.fulfill()
    }
    
    func exerciseSetViewModelStoppedTimer(_ viewModel: ExerciseSetViewModel) {
        vmStoppedTimerExpectation?.fulfill()
    }
    
    func exerciseSetViewModelFinishedSet(_ viewModel: ExerciseSetViewModel) {
        vmFinishedSetExpectation?.fulfill()
    }
    
    func exerciseSetViewModelCanceledSet(_ viewModel: ExerciseSetViewModel) {
        vmCanceledSetExpectation?.fulfill()
    }
    
}
