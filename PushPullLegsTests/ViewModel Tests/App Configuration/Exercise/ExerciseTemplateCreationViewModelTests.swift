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
    var expectionReload: XCTestExpectation?
    var expectionCompletion: XCTestExpectation?
    let dbHelper = DBHelper(coreDataStack: CoreDataTestStack())

    func testSave_noTypeSelection() {
        sut = ExerciseTemplateCreationViewModel(management: TemplateManagement(coreDataManager: dbHelper.coreDataStack))
        sut.saveExercise(withName: "testing") {
            XCTFail("Success should not occur when ExerciseTemplate is saved without a type selection")
        }
    }
    
    func testSave_typeSelected_reloadDelegateCalled_exerciseSavedAnNotAddedToWorkout() {
        dbHelper.insertWorkoutTemplate(type: .push)
        sut = ExerciseTemplateCreationViewModel(management: TemplateManagement(coreDataManager: dbHelper.coreDataStack))
        expectionCompletion = XCTestExpectation(description: "save exercise template success completion")
        expectionReload = XCTestExpectation(description: "save exercise template reload delegate")
        sut.selectedType(.push)
        sut.reloader = self
        sut.saveExercise(withName: "testing") {
            expectionCompletion?.fulfill()
        }
        wait(for: [expectionCompletion!, expectionReload!], timeout: 60)
        let temps = dbHelper.fetchExerciseTemplates()!
        XCTAssert(temps.count == 1)
        XCTAssert(temps.first!.name == "testing")
        XCTAssert(temps.first!.type == ExerciseType.push.rawValue)
        guard let wktTemp = dbHelper.fetchWorkoutTemplates().first else {
            XCTFail()
            return
        }
        if let names = wktTemp.exerciseNames {
            XCTAssert(names.count == 0)
        }
    }
    
    func testSave_typeInjected_reloadDelegateCalled_exerciseSavedAndAddedToWorkout() {
        dbHelper.insertWorkoutTemplate(type: .push)
        sut = ExerciseTemplateCreationViewModel(withType: .push, management: TemplateManagement(coreDataManager: dbHelper.coreDataStack))
        expectionCompletion = XCTestExpectation(description: "save exercise template success completion")
        expectionReload = XCTestExpectation(description: "save exercise template reload delegate")
        sut.reloader = self
        sut.saveExercise(withName: "testing") {
            expectionCompletion?.fulfill()
        }
        wait(for: [expectionCompletion!, expectionReload!], timeout: 60)
        let temps = dbHelper.fetchExerciseTemplates()!
        XCTAssert(temps.count == 1)
        XCTAssert(temps.first!.name == "testing")
        XCTAssert(temps.first!.type == ExerciseType.push.rawValue)
        guard let wktTemp = dbHelper.fetchWorkoutTemplates().first else {
            XCTFail()
            return
        }
        XCTAssert(wktTemp.exerciseNames?.contains("testing") ?? false)
    }
    
    func reload() {
        expectionReload?.fulfill()
    }
    
    func testIsTypeSelected_notSelected_falseReturned() {
        dbHelper.insertWorkoutTemplate(type: .push)
        sut = ExerciseTemplateCreationViewModel(management: TemplateManagement(coreDataManager: dbHelper.coreDataStack))
        XCTAssert(sut.isTypeSelected() == false)
    }
    
    func testIsTypeSelected_selected_trueReturned() {
        dbHelper.insertWorkoutTemplate(type: .push)
        sut = ExerciseTemplateCreationViewModel(management: TemplateManagement(coreDataManager: dbHelper.coreDataStack))
        sut.selectedType(.push)
        XCTAssert(sut.isTypeSelected() == true)
    }

}
