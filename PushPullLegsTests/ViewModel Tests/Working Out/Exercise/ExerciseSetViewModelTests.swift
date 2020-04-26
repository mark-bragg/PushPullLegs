//
//  ExerciseSetViewModelTests.swift
//  PushPullLegsTests
//
//  Created by Mark Bragg on 4/23/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import XCTest
@testable import PushPullLegs

class ExerciseSetViewModelTests: XCTestCase, ExerciseSetViewModelDelegate, ExerciseSetTimerDelegate, ExerciseSetCollector {
    
    var sut: ExerciseSetViewModel!
    var timerDelegateExpectations = [XCTestExpectation]()
    var vmStartedExpectation: XCTestExpectation?
    var vmStoppedTimerExpectation: XCTestExpectation?
    var vmFinishedSetExpectation: XCTestExpectation?
    var vmCanceledSetExpectation: XCTestExpectation?
    var collectSetExpectation: XCTestExpectation?
    
    override func setUp() {
        sut = ExerciseSetViewModel()
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
        sut.timerDelegate = self
        sut.delegate = self
        sut.startSetWithWeight(10)
        XCTAssert(!sut.completedExerciseSet)
        wait(for: expectations, timeout: 9)
    }
    
    func testStopTimer_delegateCalled() {
        sut.timerDelegate = self
        sut.delegate = self
        sut.startSetWithWeight(10)
        XCTAssert(!sut.completedExerciseSet)
        vmStoppedTimerExpectation = XCTestExpectation(description: "timer stopped expectation")
        sut.stopTimer()
        XCTAssert(!sut.completedExerciseSet)
        wait(for: [vmStoppedTimerExpectation!], timeout: 1)
    }
    
    func testFinishSetWithReps_delegateCalled_setDataCorrect() {
        sut.setCollector = self
        sut.timerDelegate = self
        sut.delegate = self
        collectSetExpectation = XCTestExpectation(description: "ExerciseSetCollector collectSet(duration:weight:reps:)")
        vmFinishedSetExpectation = XCTestExpectation(description: "ExerciseSetViewModelDelegate func exerciseSetViewModelStoppedTimer(_:)")
        sut.startSetWithWeight(10)
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
        sut.startSetWithWeight(10)
        XCTAssert(!sut.completedExerciseSet)
        sut.cancel()
        XCTAssert(!sut.completedExerciseSet)
        wait(for: [vmCanceledSetExpectation!], timeout: 1)
    }
    
    func testCancelSet_afterStoppingTimer_delegateCalled() {
        sut.delegate = self
        vmCanceledSetExpectation = XCTestExpectation(description: "ExerciseSetViewModelDelegate exerciseSetViewModelCanceledSet(_:)")
        sut.startSetWithWeight(10)
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
        sut.setCollector = self
        sut.timerDelegate = self
        sut.delegate = self
        sut.startSetWithWeight(10)
        XCTAssert(!sut.completedExerciseSet)
        sleep(5)
        sut.stopTimer()
        XCTAssert(!sut.completedExerciseSet)
        sut.finishSetWithReps(20)
        XCTAssert(sut.completedExerciseSet)
        wait(for: [collectSetExpectation!, vmFinishedSetExpectation!], timeout: 20)
    }
    
    func timerUpdate(_ text: String) {
        guard timerDelegateExpectations.count > 0 else {
            return
        }
        XCTAssert(text == "0:0\(9-timerDelegateExpectations.count)", "\nexpected: 0:0\(9-timerDelegateExpectations.count)\nactual:\(text)")
        timerDelegateExpectations.removeLast().fulfill()
    }
    
    func collectSet(duration: Int, weight: Double, reps: Int) {
        collectSetExpectation?.fulfill()
        XCTAssert(duration == 5)
        XCTAssert(weight == 10)
        XCTAssert(reps == 20)
    }
    
    func exerciseSetViewModelStartedSet(_ viewModel: ExerciseSetViewModel) {
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
