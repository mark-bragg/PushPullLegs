//
//  ExerciseViewModelTests.swift
//  PushPullLegsTests
//
//  Created by Mark Bragg on 4/22/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import XCTest
@testable import PushPullLegs

class ExerciseViewModelTests: XCTestCase, ExerciseViewModelDelegate {
    
    var sut: ExerciseViewModel!
    let dbHelper = DBHelper(coreDataStack: CoreDataTestStack())
    let exerciseTemplateName = "exercise template"
    var exerciseCompletionExpectation: XCTestExpectation?
    
    override func setUp() {
        dbHelper.addExerciseTemplate(name: exerciseTemplateName, type: .push)
        let template = dbHelper.fetchExerciseTemplates()!.first!
        sut = ExerciseViewModel(withDataManager: ExerciseDataManager(backgroundContext: dbHelper.coreDataStack.backgroundContext), exerciseTemplate: template)
        assertTitle()
    }
    
    func assertTitle() {
        guard let title = sut.title() else {
            XCTFail()
            return
        }
        XCTAssert(title == exerciseTemplateName)
    }
    
    func assertFinishedSet(_ d: Int, _ w: Double, _ r: Int, _ exercise: Exercise, _ rowCount: Int) {
        sut.collectSet(duration: d, weight: w, reps: r)
        XCTAssert(sut.rowCount(section: 0) == rowCount)
        guard dbHelper.fetchSets(exercise)!.contains(where: { (set) -> Bool in
            return set.duration == d && set.weight == w.truncateDigitsAfterDecimal(afterDecimalDigits: 2) && set.reps == r
        }) else {
            XCTFail()
            return
        }
        
    }
    
    func testRowCount_oneSetCollected() {
        XCTAssert(sut.rowCount(section: 0) == 0)
        sut.collectSet(duration: 0, weight: 0, reps: 0)
        XCTAssert(sut.rowCount(section: 0) == 1, "\nexpected: 1\nactual: \(sut.rowCount(section: 0))")
    }
    
    func testRowCount_tenSetsCollected() {
        XCTAssert(sut.rowCount(section: 0) == 0)
        for _ in 0...9 {
            sut.collectSet(duration: 0, weight: 0, reps: 0)
        }
        XCTAssert(sut.rowCount(section: 0) == 10, "\nexpected: 10\nactual: \(sut.rowCount(section: 0))")
    }
    
    func testFinishedSet_setUpdated_rowCountUpdated() {
        sut.collectSet(duration: 10, weight: 10, reps: 10)
        let exercise = dbHelper.fetchExercises().first!
        assertFinishedSet(20, 150, 8, exercise, 2)
    }
    
    func testFinishedTenSets_setsUpdated_rowCountUpdated() {
        sut.collectSet(duration: 10, weight: 10, reps: 10)
        let exercise = dbHelper.fetchExercises().first!
        for i in 1..<10 {
            let (d, w, r) = (Int.random(in: 1...65), Double.random(in: 50...500), Int.random(in: 3...20))
            assertFinishedSet(d, w, r, exercise, i+1)
        }
    }
    
    func testWeightForRow_oneFinishedSet() {
        sut.collectSet(duration: 35, weight: 135, reps: 12)
        XCTAssert(sut.rowCount(section: 0) == 1)
        let weight = sut.weightForRow(0)
        XCTAssert(weight == 135)
    }
    
    func testDurationForRow_oneFinishedSet() {
        sut.collectSet(duration: 35, weight: 135, reps: 12)
        XCTAssert(sut.rowCount(section: 0) == 1)
        let duration = sut.durationForRow(0)
        XCTAssert(duration == "0:35")
    }
    
    func testRepsForRow_oneFinishedSet() {
        sut.collectSet(duration: 35, weight: 135, reps: 12)
        XCTAssert(sut.rowCount(section: 0) == 1)
        let reps = sut.repsForRow(0)
        XCTAssert(reps == 12)
    }
    
    func testVolumeForRow_oneFinishedSet() {
        sut.collectSet(duration: 35, weight: 135, reps: 12)
        XCTAssert(sut.rowCount(section: 0) == 1)
        let volume = sut.volumeForRow(0)
        XCTAssert(volume == (35 * 135 * 12) / 60)
    }
    
    func testWeightForRow_tenFinishedSets() {
        for i in 0...9 {
            let w = Double.random(in: 20...500).truncateDigitsAfterDecimal(afterDecimalDigits: 2)
            sut.collectSet(duration: 0, weight: w, reps: 0)
            XCTAssert(sut.rowCount(section: 0) == i + 1)
            XCTAssert(sut.weightForRow(i) == w)
        }
    }
    
    func testDurationForRow_tenFinishedSets() {
        for i in 0...9 {
            let d = Int.random(in: 10...100)
            sut.collectSet(duration: d, weight: 0, reps: 0)
            XCTAssert(sut.rowCount(section: 0) == i + 1)
            XCTAssert(sut.durationForRow(i) == String.format(seconds: d))
        }
    }
    
    func testRepsForRow_tenFinishedSets() {
        for i in 0...9 {
            let r = Int.random(in: 12...20)
            sut.collectSet(duration: 0, weight: 0, reps: r)
            XCTAssert(sut.rowCount(section: 0) == i + 1)
            XCTAssert(sut.repsForRow(i) == r)
        }
    }

    func testTitleForRow_tenFinishedSets() {
        for i in 0...9 {
            let d = Int.random(in: 10...100)
            let w = Double.random(in: 20...500).truncateDigitsAfterDecimal(afterDecimalDigits: 2)
            let r = Int.random(in: 12...20)
            sut.collectSet(duration: d, weight: w, reps: r)
            XCTAssert(sut.rowCount(section: 0) == i + 1)
            XCTAssert(sut.durationForRow(i) == String.format(seconds: d))
            XCTAssert(sut.weightForRow(i) == w)
            XCTAssert(sut.repsForRow(i) == r)
            let volume = ((Double(d) * w * Double(r)) / 60.0).truncateDigitsAfterDecimal(afterDecimalDigits: 2)
            XCTAssert(sut.volumeForRow(i).distance(to: volume) <= 0.02, "\nexpected: \(volume)\nactual: \(sut.volumeForRow(i))")
        }
    }
    
    func testCollectSet_deinit_reinitWithSet_onlyOneExerciseInDB_onlyOneSetPerTheExercise() {
        XCTAssert(sut.rowCount(section: 0) == 0)
        sut.collectSet(duration: 0, weight: 0, reps: 0)
        XCTAssert(sut.rowCount(section: 0) == 1, "\nexpected: 1\nactual: \(sut.rowCount(section: 0))")
        sut = ExerciseViewModel(withDataManager: ExerciseDataManager(backgroundContext: dbHelper.coreDataStack.backgroundContext), exercise: dbHelper.fetchExercises().first!)
        XCTAssert(dbHelper.fetchExercises().count == 1)
        XCTAssert(sut.rowCount(section: 0) == 1, "\nexpected: 1\nactual: \(sut.rowCount(section: 0))")
    }
    
    func testExerciseComplete_exerciseCompletionDelegateCalled() {
        exerciseCompletionExpectation = XCTestExpectation(description: "ExerciseViewModelDelegate func exerciseCompleted(_ exercise: Exercise)")
        sut.delegate = self
        sut.collectSet(duration: 10, weight: 10, reps: 10)
        wait(for: [exerciseCompletionExpectation!], timeout: 1)
    }
    
    func testInitWithExercise_titleIsCorrect() {
        let name = "testing testing 1 2"
        let exercise = dbHelper.createExercise(name, sets: nil)
        sut = ExerciseViewModel(withDataManager: MockExerciseDataManager(backgroundContext: dbHelper.coreDataStack.backgroundContext), exercise: exercise)
        XCTAssert(sut.title() == name)
    }
    
//    func testHeaderLabelText() {
//        if !PPLDefaults.instance.isKilograms() {
//            PPLDefaults.instance.toggleKilograms()
//        }
//        XCTAssert(sut.headerLabelText(0) == "Kg")
//        PPLDefaults.instance.toggleKilograms()
//        XCTAssert(sut.headerLabelText(0) == "lbs")
//        XCTAssert(sut.headerLabelText(1) == "Reps")
//        XCTAssert(sut.headerLabelText(2) == "Time")
//    }
    
    func exerciseViewModel(_ viewMode: ExerciseViewModel, started exercise: Exercise) {
        exerciseCompletionExpectation?.fulfill()
    }

}

class MockExerciseDataManager: ExerciseDataManager {
    
}
