//
//  ExerciseTemplateCreationViewModelTests.swift
//  PushPullLegsTests
//
//  Created by Mark Bragg on 4/15/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import XCTest
import CoreData
@testable import PushPullLegs

class ExerciseTemplateCreationViewModelTests: XCTestCase, ReloadProtocol {

    var sut: ExerciseTemplateCreationViewModel!
    var expectationReload: XCTestExpectation?
    var expectationCompletion: XCTestExpectation?
    let dbHelper = DBHelper(coreDataStack: CoreDataTestStack())

    func testSave_noTypeSelection() {
        sut = ExerciseTemplateCreationViewModel(management: TemplateManagement(coreDataManager: dbHelper.coreDataStack))
        sut.saveExercise(withName: "testing") {
            XCTFail("Success should not occur when ExerciseTemplate is saved without a type selection")
        }
    }
    
    func testSave_typeSelected_reloadDelegateCalled_exerciseSavedAndNotAddedToWorkout_isNotUnilateral() {
        assertNewExerciseTemplateWithTypeSelected(unilateral: false)
    }
    
    func testSave_typeSelected_reloadDelegateCalled_exerciseSavedAndNotAddedToWorkout_isUnilateral() {
        assertNewExerciseTemplateWithTypeSelected(unilateral: true)
    }
    
    func assertNewExerciseTemplateWithTypeSelected(unilateral: Bool) {
        dbHelper.addExerciseTypes()
        dbHelper.insertWorkoutTemplate(type: .push)
        sut = ExerciseTemplateCreationViewModel(management: TemplateManagement(coreDataManager: dbHelper.coreDataStack))
        expectationCompletion = XCTestExpectation(description: "save exercise template success completion")
        expectationReload = XCTestExpectation(description: "save exercise template reload delegate")
        sut.updateTypesWith(selection: .push)
        sut.reloader = self
        sut.lateralType = unilateral ? .unilateral : .bilateral
        sut.saveExercise(withName: "testing") {
            self.expectationCompletion?.fulfill()
        }
        wait(for: [expectationCompletion!, expectationReload!], timeout: 60)
        guard let temps = dbHelper.fetchExerciseTemplates(),
              let first = temps.first,
              let types = first.types?.allObjects as? [ExerciseType]
        else { return XCTFail() }
        XCTAssertEqual(temps.count, 1)
        XCTAssertEqual(first.name, "testing")
        XCTAssert(types.contains(where: { $0.name == ExerciseTypeName.push.rawValue }))
        XCTAssertEqual(first.unilateral, unilateral)
        guard let wktTemp = dbHelper.fetchWorkoutTemplates().first else {
            XCTFail()
            return
        }
        if let names = wktTemp.exerciseNames {
            XCTAssert(names.count == 0)
        }
    }
    
    func testSave_typeInjected_reloadDelegateCalled_exerciseSavedAndAddedToWorkout() {
        dbHelper.addExerciseTypes()
        dbHelper.insertWorkoutTemplate(type: .push)
        sut = ExerciseTemplateCreationViewModel(withType: .push, management: TemplateManagement(coreDataManager: dbHelper.coreDataStack))
        expectationCompletion = XCTestExpectation(description: "save exercise template success completion")
        expectationReload = XCTestExpectation(description: "save exercise template reload delegate")
        sut.reloader = self
        sut.saveExercise(withName: "testing") {
            self.expectationCompletion?.fulfill()
        }
        wait(for: [expectationCompletion!, expectationReload!], timeout: 60)
        guard let temps = dbHelper.fetchExerciseTemplates(),
              let first = temps.first,
              let types = first.types
        else { return XCTFail() }
        XCTAssert(temps.count == 1)
        XCTAssert(first.name == "testing")
        XCTAssert(types.contains(where: { type in
            guard let type = type as? ExerciseType else { return false }
            return type.name == ExerciseTypeName.push.rawValue
        }))
        guard let wktTemp = dbHelper.fetchWorkoutTemplates().first else {
            XCTFail()
            return
        }
        XCTAssert(wktTemp.exerciseNames?.contains("testing") ?? false)
    }
    
    func reload() {
        expectationReload?.fulfill()
    }
    
    func testIsTypeSelected_notSelected_falseReturned() {
        dbHelper.insertWorkoutTemplate(type: .push)
        sut = ExerciseTemplateCreationViewModel(management: TemplateManagement(coreDataManager: dbHelper.coreDataStack))
        XCTAssert(sut.isTypeSelected() == false)
    }
    
    func testIsTypeSelected_selected_trueReturned() {
        dbHelper.insertWorkoutTemplate(type: .push)
        sut = ExerciseTemplateCreationViewModel(management: TemplateManagement(coreDataManager: dbHelper.coreDataStack))
        sut.updateTypesWith(selection: .push)
        XCTAssert(sut.isTypeSelected() == true)
    }
    
    

}
