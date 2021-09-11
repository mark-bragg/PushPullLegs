//
//  UnilateralExerciseViewModelTests.swift
//  PushPullLegsTests
//
//  Created by Mark Bragg on 8/23/21.
//  Copyright © 2021 Mark Bragg. All rights reserved.
//

import XCTest
@testable import PushPullLegs

class UnilateralExerciseViewModelTests: XCTestCase {
    
    var sut: UnilateralExerciseViewModel!
    let dbHelper = DBHelper(coreDataStack: CoreDataTestStack())
    let exerciseTemplateName = "exercise template"
    var exerciseCompletionExpectation: XCTestExpectation?
    var leftRowCount: Int = 0
    var rightRowCount: Int = 0
    var deletionExpectation: XCTestExpectation!

    override func setUpWithError() throws {
        dbHelper.addExerciseTemplate(name: exerciseTemplateName, type: .push)
        let template = dbHelper.fetchExerciseTemplates()!.first!
        sut = UnilateralExerciseViewModel(withDataManager: UnilateralExerciseDataManager(backgroundContext: dbHelper.coreDataStack.backgroundContext), exerciseTemplate: template)
    }
    
    func assertFinishedSet(_ d: Int, _ w: Double, _ r: Double, _ exercise: Exercise, _ rowCount: Int, _ side: HandSide) {
        let section = side == .left ? 0 : 1
        XCTAssert(sut.rowCount(section: section) == rowCount, "\nexpected: \(rowCount)\nactual:\(sut.rowCount(section: section))")
        guard dbHelper.fetchSets(exercise)!.contains(where: { (set) -> Bool in
            guard let set = set as? UnilateralExerciseSet else { return false }
            let dataIsCorrect = set.duration == d && set.weight == w.truncateDigitsAfterDecimal(afterDecimalDigits: 2) && set.reps == r
            return dataIsCorrect && (set.isLeftSide ? side == .left : side == .right)
        }) else {
            XCTFail()
            return
        }
    }

    func testFirstSet_leftHandedSet_dataIsCorrect_rowCountIsCorrect() throws {
        sut.currentSide = .left
        sut.collectSet(duration: 10, weight: 10, reps: 10)
        let exercise = dbHelper.fetchExercises().first!
        assertFinishedSet(10, 10, 10, exercise, 1, .left)
        XCTAssert(sut.rowCount() == 1)
    }
    
    func testFirstSet_leftAndRightHandedSet_dataIsCorrect_rowCountIsCorrect() throws {
        sut.currentSide = .left
        sut.collectSet(duration: 10, weight: 10, reps: 10)
        XCTAssert(sut.rowCount(section: 1) == 0)
        XCTAssert(sut.rowCount(section: 0) == 1)
        sut.currentSide = .right
        sut.collectSet(duration: 10, weight: 10, reps: 10)
        XCTAssert(sut.rowCount(section: 1) == 1)
    }
    
    func testHappyPath_tenLeftAndRightHandedSets_dataIsCorrect_rowCountIsCorrect() throws {
        var count = 0
        for i in 0..<10 {
            let side = i % 2 == 0 ? HandSide.left : .right
            count += i % 2 == 0 ? 1 : 0
            sut.currentSide = side
            sut.collectSet(duration: 10, weight: 10, reps: 10)
        }
        XCTAssert(sut.rowCount(section: 0) == 5)
        XCTAssert(sut.rowCount(section: 1) == 5)
    }
    
    func test_tenLeftHandedSets_dataIsCorrect_rowCountIsCorrect() throws {
        for i in 0..<10 {
            sut.currentSide = .left
            sut.collectSet(duration: 10, weight: 10, reps: 10)
            let exercise = dbHelper.fetchExercises().first!
            assertFinishedSet(10, 10, 10, exercise, i + 1, .left)
        }
        XCTAssert(sut.rowCount(section: 0) == 10)
        XCTAssert(sut.rowCount(section: 1) == 0)
    }
    
    func test_tenRightHandedSets_dataIsCorrect_rowCountIsCorrect() throws {
        for i in 0..<10 {
            sut.currentSide = .right
            sut.collectSet(duration: 10, weight: 10, reps: 10)
            let exercise = dbHelper.fetchExercises().first!
            assertFinishedSet(10, 10, 10, exercise, i + 1, .right)
        }
    }
    
    func test_RLLRRLLR_fourRows() {
        sut.currentSide = .right
        sut.collectSet(duration: 10, weight: 10, reps: 10)
        sut.currentSide = .left
        sut.collectSet(duration: 10, weight: 10, reps: 10)
        sut.currentSide = .left
        sut.collectSet(duration: 10, weight: 10, reps: 10)
        sut.currentSide = .right
        sut.collectSet(duration: 10, weight: 10, reps: 10)
        sut.currentSide = .right
        sut.collectSet(duration: 10, weight: 10, reps: 10)
        sut.currentSide = .left
        sut.collectSet(duration: 10, weight: 10, reps: 10)
        sut.currentSide = .left
        sut.collectSet(duration: 10, weight: 10, reps: 10)
        sut.currentSide = .right
        sut.collectSet(duration: 10, weight: 10, reps: 10)
        
        XCTAssert(sut.rowCount(section: 0) == 4)
        XCTAssert(sut.rowCount(section: 1) == 4)
    }
    
    func testRowCount_sutInitializedAfterExerciseIsSaved_0() {
        let exercise = dbHelper.createUnilateralExercise()
        sut = UnilateralExerciseViewModel(withDataManager: UnilateralExerciseDataManager(backgroundContext: dbHelper.coreDataStack.backgroundContext), exercise: exercise)
        XCTAssert(sut.rowCount(section: 0) == 0)
        XCTAssert(sut.rowCount(section: 1) == 0)
    }
    
    func testRowCount_sutInitializedAfterExerciseIsSaved_1_0() {
        let exercise = dbHelper.createUnilateralExercise()
        dbHelper.addUnilateralExerciseSetTo(exercise, data: (r: 10, w: 10, d: 10, l: true))
        sut = UnilateralExerciseViewModel(withDataManager: UnilateralExerciseDataManager(backgroundContext: dbHelper.coreDataStack.backgroundContext), exercise: exercise)
        XCTAssert(sut.rowCount(section: 0) == 1)
        XCTAssert(sut.rowCount(section: 1) == 0)
    }
    
    func testRowCount_sutInitializedAfterExerciseIsSaved_4_3() {
        let exercise = dbHelper.createUnilateralExercise()
        for _ in 0..<4 {
            dbHelper.addUnilateralExerciseSetTo(exercise, data: (r: 10, w: 10, d: 10, l: true))
        }
        for _ in 0..<3 {
            dbHelper.addUnilateralExerciseSetTo(exercise, data: (r: 10, w: 10, d: 10, l: false))
        }
        sut = UnilateralExerciseViewModel(withDataManager: UnilateralExerciseDataManager(backgroundContext: dbHelper.coreDataStack.backgroundContext), exercise: exercise)
        XCTAssert(sut.rowCount(section: 0) == 4)
        XCTAssert(sut.rowCount(section: 1) == 3)
    }
    
    func testWeightForIndexPath_left() {
        let exercise = dbHelper.createUnilateralExercise()
        for i in 0..<4 {
            let i = Double(i)
            dbHelper.addUnilateralExerciseSetTo(exercise, data: (r: 1 * i, w: 2 * i, d: 3 * Int(i), l: true))
        }
        sut = UnilateralExerciseViewModel(withDataManager: UnilateralExerciseDataManager(backgroundContext: dbHelper.coreDataStack.backgroundContext), exercise: exercise)
        XCTAssert(sut.hasData())
        for i in 0..<4 {
            XCTAssert(sut.weightForIndexPath(IndexPath(row: i, section: 0)) == 2 * Double(i))
        }
    }
    
    func testWeightForIndexPath_right() {
        let exercise = dbHelper.createUnilateralExercise()
        for i in 0..<4 {
            let i = Double(i)
            dbHelper.addUnilateralExerciseSetTo(exercise, data: (r: 1 * i, w: 2 * i, d: 3 * Int(i), l: false))
        }
        sut = UnilateralExerciseViewModel(withDataManager: UnilateralExerciseDataManager(backgroundContext: dbHelper.coreDataStack.backgroundContext), exercise: exercise)
        XCTAssert(sut.hasData())
        for i in 0..<4 {
            XCTAssert(sut.weightForIndexPath(IndexPath(row: i, section: 1)) == 2 * Double(i))
        }
    }
    
    func testRepsForIndexPath_left() {
        let exercise = dbHelper.createUnilateralExercise()
        for i in 0..<4 {
            let i = Double(i)
            dbHelper.addUnilateralExerciseSetTo(exercise, data: (r: 11 * i, w: 0, d: 0, l: true))
        }
        sut = UnilateralExerciseViewModel(withDataManager: UnilateralExerciseDataManager(backgroundContext: dbHelper.coreDataStack.backgroundContext), exercise: exercise)
        XCTAssert(sut.hasData())
        for i in 0..<4 {
            XCTAssert(sut.repsForIndexPath(IndexPath(row: i, section: 0)) == 11 * Double(i))
        }
    }
    
    func testRepsForIndexPath_right() {
        let exercise = dbHelper.createUnilateralExercise()
        for i in 0..<4 {
            let i = Double(i)
            dbHelper.addUnilateralExerciseSetTo(exercise, data: (r: 11 * i, w: 0, d: 0, l: false))
        }
        sut = UnilateralExerciseViewModel(withDataManager: UnilateralExerciseDataManager(backgroundContext: dbHelper.coreDataStack.backgroundContext), exercise: exercise)
        XCTAssert(sut.hasData())
        for i in 0..<4 {
            XCTAssert(sut.repsForIndexPath(IndexPath(row: i, section: 1)) == 11 * Double(i))
        }
    }
    
    func testDurationForIndexPath_left() {
        let exercise = dbHelper.createUnilateralExercise()
        for i in 0..<4 {
            dbHelper.addUnilateralExerciseSetTo(exercise, data: (r: 0, w: 0, d: 7 * i, l: true))
        }
        sut = UnilateralExerciseViewModel(withDataManager: UnilateralExerciseDataManager(backgroundContext: dbHelper.coreDataStack.backgroundContext), exercise: exercise)
        XCTAssert(sut.hasData())
        for i in 0..<4 {
            XCTAssert(sut.durationForIndexPath(IndexPath(row: i, section: 0)) == String.format(seconds: 7 * i))
        }
    }
    
    func testDurationForIndexPath_right() {
        let exercise = dbHelper.createUnilateralExercise()
        for i in 0..<4 {
            dbHelper.addUnilateralExerciseSetTo(exercise, data: (r: 0, w: 0, d: 7 * i, l: false))
        }
        sut = UnilateralExerciseViewModel(withDataManager: UnilateralExerciseDataManager(backgroundContext: dbHelper.coreDataStack.backgroundContext), exercise: exercise)
        XCTAssert(sut.hasData())
        for i in 0..<4 {
            XCTAssert(sut.durationForIndexPath(IndexPath(row: i, section: 1)) == String.format(seconds: 7 * i))
        }
    }
    
    func testVolumeForIndexPath_left() {
        let exercise = dbHelper.createUnilateralExercise()
        for i in 0..<4 {
            let i = Double(i)
            dbHelper.addUnilateralExerciseSetTo(exercise, data: (r: 90 + i, w: 25 + i, d: 7 + Int(i), l: true))
        }
        sut = UnilateralExerciseViewModel(withDataManager: UnilateralExerciseDataManager(backgroundContext: dbHelper.coreDataStack.backgroundContext), exercise: exercise)
        XCTAssert(sut.hasData())
        for i in 0..<4 {
            let i = Double(i)
            let w = 90 + i
            let r = 25 + i
            let t = 7 + i
            let volumeActual = sut.volumeForIndexPath(IndexPath(row: Int(i), section: 0))
            let volumeExpected = ((w * r * t) / 60).truncateDigitsAfterDecimal(afterDecimalDigits: 2)
            XCTAssert(volumeExpected == volumeActual, "\nexpected: \(volumeExpected)\nactual: \(volumeActual)")
        }
    }
    
    func testVolumeForIndexPath_right() {
        let exercise = dbHelper.createUnilateralExercise()
        for i in 0..<4 {
            let i = Double(i)
            dbHelper.addUnilateralExerciseSetTo(exercise, data: (r: 90 + i, w: 25 + i, d: 7 + Int(i), l: false))
        }
        sut = UnilateralExerciseViewModel(withDataManager: UnilateralExerciseDataManager(backgroundContext: dbHelper.coreDataStack.backgroundContext), exercise: exercise)
        XCTAssert(sut.hasData())
        for i in 0..<4 {
            let i = Double(i)
            let w = 90 + i
            let r = 25 + i
            let t = 7 + i
            let volumeActual = sut.volumeForIndexPath(IndexPath(row: Int(i), section: 1))
            let volumeExpected = ((w * r * t) / 60).truncateDigitsAfterDecimal(afterDecimalDigits: 2)
            XCTAssert(volumeExpected == volumeActual, "\nexpected: \(volumeExpected)\nactual: \(volumeActual)")
        }
    }
    
    func testSectionCount() {
        XCTAssert(sut.sectionCount() == 2)
    }
    
    func testDeleteLeftSet() {
        let exercise = dbHelper.createUnilateralExercise()
        leftRowCount = 3
        rightRowCount = 2
        for i in 0..<5 {
            let ii = Double(i)
            dbHelper.addUnilateralExerciseSetTo(exercise, data: (r: 90 + ii, w: 25 + ii, d: 7 + i, l: i % 2 == 0))
        }
        sut = UnilateralExerciseViewModel(withDataManager: UnilateralExerciseDataManager(backgroundContext: dbHelper.coreDataStack.backgroundContext), exercise: exercise)
        sut.reloader = self
        XCTAssert(sut.rowCount(section: 0) == leftRowCount)
        XCTAssert(sut.rowCount(section: 1) == rightRowCount)
        
        // delete
        leftRowCount -= 1
        deletionExpectation = XCTestExpectation(description: "deletion expectation")
        sut.delete(indexPath: IndexPath(row: 0, section: 0))
        wait(for: [deletionExpectation], timeout: 1.0)
    }
    
    func testDeleteRightSet() {
        let exercise = dbHelper.createUnilateralExercise()
        leftRowCount = 3
        rightRowCount = 2
        for i in 0..<5 {
            let ii = Double(i)
            dbHelper.addUnilateralExerciseSetTo(exercise, data: (r: 90 + ii, w: 25 + ii, d: 7 + i, l: i % 2 == 0))
        }
        sut = UnilateralExerciseViewModel(withDataManager: UnilateralExerciseDataManager(backgroundContext: dbHelper.coreDataStack.backgroundContext), exercise: exercise)
        sut.reloader = self
        XCTAssert(sut.rowCount(section: 0) == leftRowCount)
        XCTAssert(sut.rowCount(section: 1) == rightRowCount)
        
        // delete
        rightRowCount -= 1
        deletionExpectation = XCTestExpectation(description: "deletion expectation")
        sut.delete(indexPath: IndexPath(row: 0, section: 1))
        wait(for: [deletionExpectation], timeout: 1.0)
    }
    
    func testDeleteAllSets() {
        let exercise = dbHelper.createUnilateralExercise()
        leftRowCount = 3
        rightRowCount = 2
        for i in 0..<5 {
            let ii = Double(i)
            dbHelper.addUnilateralExerciseSetTo(exercise, data: (r: 90 + ii, w: 25 + ii, d: 7 + i, l: i % 2 == 0))
        }
        sut = UnilateralExerciseViewModel(withDataManager: UnilateralExerciseDataManager(backgroundContext: dbHelper.coreDataStack.backgroundContext), exercise: exercise)
        XCTAssert(sut.rowCount(section: 0) == leftRowCount)
        XCTAssert(sut.rowCount(section: 1) == rightRowCount)
        
        sut.reloader = self
        
        // delete
        leftRowCount -= 1
        deletionExpectation = XCTestExpectation(description: "deletion expectation")
        sut.delete(indexPath: IndexPath(row: 0, section: 0))
        wait(for: [deletionExpectation], timeout: 1.0)
        leftRowCount -= 1
        deletionExpectation = XCTestExpectation(description: "deletion expectation")
        sut.delete(indexPath: IndexPath(row: 0, section: 0))
        wait(for: [deletionExpectation], timeout: 1.0)
        leftRowCount -= 1
        deletionExpectation = XCTestExpectation(description: "deletion expectation")
        sut.delete(indexPath: IndexPath(row: 0, section: 0))
        wait(for: [deletionExpectation], timeout: 1.0)
        rightRowCount -= 1
        deletionExpectation = XCTestExpectation(description: "deletion expectation")
        sut.delete(indexPath: IndexPath(row: 0, section: 1))
        wait(for: [deletionExpectation], timeout: 1.0)
        rightRowCount -= 1
        deletionExpectation = XCTestExpectation(description: "deletion expectation")
        sut.delete(indexPath: IndexPath(row: 0, section: 1))
        wait(for: [deletionExpectation], timeout: 1.0)
    }
    
    func testDeleteDatabaseObject() {
        let exercise = dbHelper.createUnilateralExercise()
        leftRowCount = 3
        rightRowCount = 2
        for i in 0..<5 {
            let ii = Double(i)
            dbHelper.addUnilateralExerciseSetTo(exercise, data: (r: 90 + ii, w: 25 + ii, d: 7 + i, l: i % 2 == 0))
        }
        sut = UnilateralExerciseViewModel(withDataManager: UnilateralExerciseDataManager(backgroundContext: dbHelper.coreDataStack.backgroundContext), exercise: exercise)
        sut.reloader = self
        XCTAssert(sut.rowCount(section: 0) == leftRowCount)
        XCTAssert(sut.rowCount(section: 1) == rightRowCount)
        
        // delete
        rightRowCount -= 1
        sut.objectToDelete = IndexPath(row: 0, section: 1)
        deletionExpectation = XCTestExpectation(description: "deletion expectation")
        sut.deleteDatabaseObject()
        wait(for: [deletionExpectation], timeout: 1.0)
    }
    
    // MARK: String Extension Tests
    func testUnstringDuration_zero() {
        assertUnstringed(Int.unstringDuration("0:00"), 0)
    }
    
    func testUnstringDuration_lessThanTenSeconds() {
        for i in 1..<10 {
            assertUnstringed(Int.unstringDuration("0:0\(i)"), i)
        }
    }
    
    func testUnstringDuration_tenToFiftyNineSeconds() {
        for i in 10..<60 {
            assertUnstringed(Int.unstringDuration("0:\(i)"), i)
        }
    }
    
    func testUnstringDuration_lessThanTenMinutes() {
        for i in 1..<10 {
            assertUnstringed(Int.unstringDuration("\(i):00"), 60 * i)
        }
    }
    
    func testUnstringDuration_tenToFiftyNineMinutes() {
        for i in 10..<59 {
            assertUnstringed(Int.unstringDuration("\(i):00"), 60 * i)
        }
    }
    
    func testMinutesAndNumbers_lessThanTenSeconds_lessThanTenMinutes() {
        for _ in 0..<10 {
            let minutes = Int.random(in: 0..<10)
            let seconds = Int.random(in: 0..<10)
            assertUnstringed(Int.unstringDuration("\(minutes):0\(seconds)"), (60 * minutes) + seconds)
        }
    }
    
    func testMinutesAndNumbers_tenToFiftyNineSeconds_tenToFiftyNineMinutes() {
        for _ in 10..<60 {
            let minutes = Int.random(in: 10..<60)
            let seconds = Int.random(in: 10..<60)
            assertUnstringed(Int.unstringDuration("\(minutes):\(seconds)"), (60 * minutes) + seconds)
        }
    }
    
    func testMinutesAndNumbers_tenToFiftyNineSeconds_lessThanTenMinutes() {
        for _ in 10..<60 {
            let minutes = Int.random(in: 0..<10)
            let seconds = Int.random(in: 10..<60)
            assertUnstringed(Int.unstringDuration("\(minutes):\(seconds)"), (60 * minutes) + seconds)
        }
    }
    
    func testMinutesAndNumbers_lessThanTenSeconds_tenToFiftyNineMinutes() {
        for _ in 10..<60 {
            let minutes = Int.random(in: 10..<60)
            let seconds = Int.random(in: 0..<10)
            assertUnstringed(Int.unstringDuration("\(minutes):0\(seconds)"), (60 * minutes) + seconds)
        }
    }

    private func assertUnstringed(_ expected: Int, _ actual: Int) {
        XCTAssert(actual == expected)
    }
    
}

extension UnilateralExerciseViewModelTests: ReloadProtocol {
    func reload() {
        deletionExpectation.fulfill()
        XCTAssert(sut.rowCount(section: 0) == leftRowCount, "\nexpected: \(leftRowCount)\nactual: \(sut.rowCount(section: 0))")
        XCTAssert(sut.rowCount(section: 1) == rightRowCount, "\nexpected: \(rightRowCount)\nactual: \(sut.rowCount(section: 1))")
    }
}
