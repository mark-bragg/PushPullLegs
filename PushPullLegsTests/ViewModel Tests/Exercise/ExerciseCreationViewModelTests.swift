//
//  ExerciseCreationViewModelTests.swift
//  PushPullLegsTests
//
//  Created by Mark Bragg on 4/15/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import XCTest
import CoreData

@testable import PushPullLegs

/*
 var reloader: ReloadProtocol?
 func selectedType(_ type: ExerciseType)
 func saveExercise(withName name: String, successCompletion completion: () -> Void)
 */

class ExerciseCreationViewModelTests: XCTestCase, ReloadProtocol {

    var sut: ExerciseCreationViewModel!
    var expectionReload: XCTestExpectation?
    var expectionCompletion: XCTestExpectation?
    let coreDataStack = CoreDataTestStack()
    
    func exerciseTemplates() -> [ExerciseTemplate]? {
        if let temps = try? coreDataStack.backgroundContext.fetch(NSFetchRequest(entityName: ExTemp)) as? [ExerciseTemplate] {
            return temps
        }
        return nil
    }
    
    func fetchWorkouts() -> [WorkoutTemplate] {
        let request = NSFetchRequest<NSFetchRequestResult>.init(entityName: "WorkoutTemplate")
        let workouts = try! self.coreDataStack.backgroundContext.fetch(request)
        return workouts as! [WorkoutTemplate]
    }
    
    func insertWorkout(name: String) {
        let workout = NSEntityDescription.insertNewObject(forEntityName: "WorkoutTemplate", into: coreDataStack.backgroundContext) as! WorkoutTemplate
        workout.name = name
        try? coreDataStack.backgroundContext.save()
    }

    func testSave_noTypeSelection() {
        sut = ExerciseCreationViewModel(management: TemplateManagement(backgroundContext: coreDataStack.backgroundContext))
        sut.saveExercise(withName: "testing") {
            XCTFail("Success should not occur when ExerciseTemplate is saved without a type selection")
        }
    }
    
    func testSave_typeSelected_reloadDelegateCalled_exerciseSavedAnNotAddedToWorkout() {
        insertWorkout(name: ExerciseType.push.rawValue)
        sut = ExerciseCreationViewModel(management: TemplateManagement(backgroundContext: coreDataStack.backgroundContext))
        expectionCompletion = XCTestExpectation(description: "save exercise template success completion")
        expectionReload = XCTestExpectation(description: "save exercise template reload delegate")
        sut.selectedType(.push)
        sut.reloader = self
        sut.saveExercise(withName: "testing") {
            expectionCompletion?.fulfill()
        }
        wait(for: [expectionCompletion!, expectionReload!], timeout: 60)
        let temps = exerciseTemplates()!
        XCTAssert(temps.count == 1)
        XCTAssert(temps.first!.name == "testing")
        XCTAssert(temps.first!.type == ExerciseType.push.rawValue)
        guard let wktTemp = fetchWorkouts().first else {
            XCTFail()
            return
        }
        if let names = wktTemp.exerciseNames {
            XCTAssert(names.count == 0)
        }
    }
    
    func testSave_typeInjected_reloadDelegateCalled_exerciseSavedAndAddedToWorkout() {
        insertWorkout(name: ExerciseType.push.rawValue)
        sut = ExerciseCreationViewModel(withType: .push, management: TemplateManagement(backgroundContext: coreDataStack.backgroundContext))
        expectionCompletion = XCTestExpectation(description: "save exercise template success completion")
        expectionReload = XCTestExpectation(description: "save exercise template reload delegate")
        sut.reloader = self
        sut.saveExercise(withName: "testing") {
            expectionCompletion?.fulfill()
        }
        wait(for: [expectionCompletion!, expectionReload!], timeout: 60)
        let temps = exerciseTemplates()!
        XCTAssert(temps.count == 1)
        XCTAssert(temps.first!.name == "testing")
        XCTAssert(temps.first!.type == ExerciseType.push.rawValue)
        guard let wktTemp = fetchWorkouts().first else {
            XCTFail()
            return
        }
        XCTAssert(wktTemp.exerciseNames?.contains("testing") ?? false)
    }
    
    func reload() {
        expectionReload?.fulfill()
    }
    
    func testIsTypeSelected_notSelected_falseReturned() {
        insertWorkout(name: ExerciseType.push.rawValue)
        sut = ExerciseCreationViewModel(management: TemplateManagement(backgroundContext: coreDataStack.backgroundContext))
        XCTAssert(sut.isTypeSelected() == false)
    }
    
    func testIsTypeSelected_selected_trueReturned() {
        insertWorkout(name: ExerciseType.push.rawValue)
        sut = ExerciseCreationViewModel(management: TemplateManagement(backgroundContext: coreDataStack.backgroundContext))
        sut.selectedType(.push)
        XCTAssert(sut.isTypeSelected() == true)
    }

}
