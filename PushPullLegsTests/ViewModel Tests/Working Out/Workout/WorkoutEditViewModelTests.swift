//
//  WorkoutEditViewModelTests.swift
//  PushPullLegsTests
//
//  Created by Mark Bragg on 4/18/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import XCTest
import CoreData
@testable import PushPullLegs

class WorkoutEditViewModelTests: XCTestCase {

    var sut: WorkoutEditViewModel!
    let dbHelper = DBHelper(coreDataStack: CoreDataTestStack())
    
    fileprivate func assertNoSavedWorkoutsTypeInjectedIsReturned(_ type: ExerciseTypeName) {
        sut = WorkoutEditViewModel(withType: type,  coreDataManagement: dbHelper.coreDataStack )
        XCTAssert(sut.exerciseType == type)
    }
    
    fileprivate func assertPreviousWorkouts(withTypes previousWorkoutTypes: [ExerciseTypeName], injectionType: ExerciseTypeName) {
        for type in previousWorkoutTypes {
            dbHelper.insertWorkout(name: type)
        }
        sut = WorkoutEditViewModel(withType: injectionType,  coreDataManagement: dbHelper.coreDataStack )
        XCTAssert(sut.exerciseType == injectionType)
    }
    
    fileprivate func assertPreviousWorkoutsNoInjection(_ previousWorkoutTypes: [ExerciseTypeName], expectedType: ExerciseTypeName) {
        for type in previousWorkoutTypes {
            dbHelper.insertWorkout(name: type)
        }
        sut = WorkoutEditViewModel(coreDataManagement: dbHelper.coreDataStack )
        XCTAssert(sut.exerciseType == expectedType)
    }
    
    func testGetExerciseTypeName_noPreviousWorkouts_pushTypeInjected_pushReturned() {
        assertNoSavedWorkoutsTypeInjectedIsReturned(.push)
    }
    
    func testGetExerciseTypeName_noPreviousWorkouts_pullTypeInjected_pullReturned() {
        assertNoSavedWorkoutsTypeInjectedIsReturned(.pull)
    }
    
    func testGetExerciseTypeName_noPreviousWorkouts_legsTypeInjected_legsReturned() {
        assertNoSavedWorkoutsTypeInjectedIsReturned(.legs)
    }
    
    func testGetExerciseTypeName_previousWorkoutsPush_pushTypeInjected_pushReturned() {
        assertPreviousWorkouts(withTypes: [.push], injectionType: .push)
    }
    
    func testGetExerciseTypeName_previousWorkoutsPush_pullTypeInjected_pullReturned() {
        assertPreviousWorkouts(withTypes: [.push], injectionType: .pull)
    }
    
    func testGetExerciseTypeName_previousWorkoutsPush_legsTypeInjected_legsReturned() {
        assertPreviousWorkouts(withTypes: [.push], injectionType: .legs)
    }
    
    func testGetExerciseTypeName_previousWorkoutsPushPull_legsTypeInjected_legsReturned() {
        assertPreviousWorkouts(withTypes: [.push, .pull], injectionType: .legs)
    }
    
    func testGetExerciseTypeName_previousWorkoutsPushPull_pullTypeInjected_pullReturned() {
        assertPreviousWorkouts(withTypes: [.push, .pull], injectionType: .pull)
    }
    
    func testGetExerciseTypeName_previousWorkoutsPushPull_pushTypeInjected_pushReturned() {
        assertPreviousWorkouts(withTypes: [.push, .pull], injectionType: .push)
    }
    
    func testGetExerciseTypeName_previousWorkoutsPushPullLegs_legsTypeInjected_legsReturned() {
        assertPreviousWorkouts(withTypes: [.push, .pull, .legs], injectionType: .legs)
    }
    
    func testGetExerciseTypeName_previousWorkoutsPushPullLegs_pullTypeInjected_pullReturned() {
        assertPreviousWorkouts(withTypes: [.push, .pull, .legs], injectionType: .pull)
    }
    
    func testGetExerciseTypeName_previousWorkoutsPushPullLegs_pushTypeInjected_pushReturned() {
        assertPreviousWorkouts(withTypes: [.push, .pull, .legs], injectionType: .push)
    }
    
    func testSectionCount() {
        sut = WorkoutEditViewModel(coreDataManagement: dbHelper.coreDataStack )
        XCTAssert(sut.sectionCount() == 2)
    }
    
    func testRowsForSection_zeroExercises_zeroRowsForBothSections() {
        sut = WorkoutEditViewModel(coreDataManagement: dbHelper.coreDataStack )
        XCTAssert(sut.rowCount(section: 0) == 0, "\nexpected: 0\nactual: \(sut.rowCount(section: 0))")
        XCTAssert(sut.rowCount(section: 1) == 0)
    }
    
    func testRowsForSection_zeroExercisesDone_oneExerciseToDo_oneRowForSectionZero_zeroRowsForSectionOne() {
        AppState.shared.workoutInProgress = nil
        dbHelper.insertWorkoutTemplateMainContext()
        let workoutTemplate = dbHelper.fetchWorkoutTemplates().first!
        dbHelper.addExerciseTemplate("exercise to do", to: workoutTemplate, addToWorkout: true)
        sut = WorkoutEditViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack)
        assertEqual(sut.rowCount(section: 0), 1)
        XCTAssert(sut.rowCount(section: 1) == 0)
    }
    
    func testRowsForSection_zeroExercisesDone_tenExercisesToDo_tenRowsForSectionZero_zeroRowsForSectionOne() {
        dbHelper.insertWorkoutTemplate()
        for i in 0...9 {
            dbHelper.addExerciseTemplate("exercise to do #\(i)", to: dbHelper.fetchWorkoutTemplates().first!, addToWorkout: true)
        }
        sut = WorkoutEditViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack)
        XCTAssertEqual(sut.rowCount(section: 0), 10)
        XCTAssertEqual(sut.rowCount(section: 1), 0)
    }
    
    func testRowsForSection_oneExerciseDone_zeroExercisesToDo_zeroRowsForSectionZero_oneRowForSectionOne() {
        sut = WorkoutEditViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack)
        dbHelper.addExercise("exercise done", to: dbHelper.fetchWorkouts().first!)
        sut.exerciseTemplatesAdded()
        XCTAssert(sut.rowCount(section: 0) == 0)
        XCTAssert(sut.rowCount(section: 1) == 1)
    }
    
    func testRowsForSection_tenExercisesDone_fiveExercisesToDo_fiveRowsForSectionZero_tenRowsForSectionOne() {
        dbHelper.insertWorkoutTemplate(type: .push)
        let workoutTemplate = dbHelper.fetchWorkoutTemplates().first!
        for i in 0...4 {
            dbHelper.addExerciseTemplate("to do \(i)", to: workoutTemplate, addToWorkout: true)
        }
        sut = WorkoutEditViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack )
        for i in 0...9 {
            dbHelper.addExercise("done \(i)", to: dbHelper.fetchWorkouts().first!)
        }
        sut.reload()
        let done = sut.rowCount(section: 1)
        let todo = sut.rowCount(section: 0)
        XCTAssert(todo == 5, "\nexpected: 5\nactual: \(todo)")
        XCTAssert(done == 10, "\nexpected: 10\nactual: \(done)")
    }
    
    func testTitleForIndexPath() {
        dbHelper.insertWorkoutTemplate(type: .push)
        let workoutTemplate = dbHelper.fetchWorkoutTemplates().first!
        var todoNames = [String]()
        for i in 0...4 {
            todoNames.append("to do \(i)")
            dbHelper.addExerciseTemplate(todoNames.last!, to: workoutTemplate, addToWorkout: true)
        }
        sut = WorkoutEditViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack )
        var doneNames = [String]()
        for i in 0...9 {
            doneNames.append("done \(i)")
            dbHelper.addExercise(doneNames.last!, to: dbHelper.fetchWorkouts().first!)
        }
        sut.reload()
        var row = 0
        for name in todoNames.sorted(by: { $0 < $1 }) {
            XCTAssert(sut.title(indexPath: IndexPath(row: row, section: 0)) == name, "\nexpected: \(name)\nactual: \(sut.title(indexPath: IndexPath(row: row, section: 0))!)")
            row += 1
        }
        row = 0
        for name in doneNames.sorted(by: { $0 < $1 }) {
            XCTAssert(sut.title(indexPath: IndexPath(row: row, section: 1)) == name)
            row += 1
        }
    }
    
//    func testTimer() {
//        var seconds: UInt32 = 5
//        sut = WorkoutViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack )
//        sleep(seconds)
//        XCTAssert(sut.timerText() == "00:00:05")
//        seconds += 5
//        sleep(seconds)
//        XCTAssert(sut.timerText() == "00:00:15")
//        seconds += 35
//        sleep(seconds)
//        XCTAssert(sut.timerText() == "00:01:00")
//        seconds = 63
//        sleep(seconds)
//        XCTAssert(sut.timerText() == "00:02:03")
//    }
    
    func testFinishWorkout() {
        sut = WorkoutEditViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack )
        sleep(15)
        sut.finishWorkout()
        guard let workout = dbHelper.fetchWorkouts().first else {
            XCTFail()
            return
        }
        XCTAssert(Int(workout.dateCreated!.timeIntervalSinceNow) < 5)
        XCTAssert(workout.duration == 15)
        XCTAssert(workout.name == ExerciseTypeName.push.rawValue)
    }
    
    func testAddExercise_exerciseTemplateAdded() {
        dbHelper.insertWorkoutTemplate(type: .push)
        let workoutTemplate = dbHelper.fetchWorkoutTemplates().first!
        var todoNames = [String]()
        for i in 0...4 {
            todoNames.append("to do \(i)")
            dbHelper.addExerciseTemplate(todoNames.last!, to: workoutTemplate, addToWorkout: true)
        }
        let name = "to be added"
        dbHelper.addExerciseTemplate(name, to: workoutTemplate, addToWorkout: false)
        sut = WorkoutEditViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack )
        assertEqual(sut.rowCount(section: 0), 5)
        XCTAssert(sut.rowCount(section: 1) == 0)
        guard let exerciseToBeAdded = dbHelper.fetchExerciseTemplates()?.first(where: { $0.name! == name })! else {
            XCTFail()
            return
        }
        sut.addExercise(templates: [exerciseToBeAdded])
        assertEqual(sut.rowCount(section: 0), 6)
        XCTAssert(sut.rowCount(section: 1) == 0)
    }
    
    func testAddExercises_exerciseTemplatesAdded() {
        dbHelper.insertWorkoutTemplate(type: .push)
        let workoutTemplate = dbHelper.fetchWorkoutTemplates().first!
        var todoNames = [String]()
        for i in 0...4 {
            todoNames.append("to do \(i)")
            dbHelper.addExerciseTemplate(todoNames.last!, to: workoutTemplate, addToWorkout: true)
        }
        
        sut = WorkoutEditViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack )
        assertEqual(sut.rowCount(section: 0), 5)
        XCTAssert(sut.rowCount(section: 1) == 0)
        var toAddNames = [String]()
        for i in 0...4 {
            toAddNames.append("to be added \(i)")
            dbHelper.addExerciseTemplate(toAddNames.last!, to: workoutTemplate, addToWorkout: false)
        }
        guard let exercisesToBeAdded = dbHelper.fetchExerciseTemplates()?.filter({ temp in toAddNames.contains { $0 == temp.name! } }) else {
            XCTFail()
            return
        }
        sut.addExercise(templates: exercisesToBeAdded)
        assertEqual(sut.rowCount(section: 0), 10)
        XCTAssert(sut.rowCount(section: 1) == 0)
    }
    
    func testAddZeroExercises_zeroExerciseTemplatesAdded() {
        dbHelper.insertWorkoutTemplate(type: .push)
        let workoutTemplate = dbHelper.fetchWorkoutTemplates().first!
        var todoNames = [String]()
        for i in 0...4 {
            todoNames.append("to do \(i)")
            dbHelper.addExerciseTemplate(todoNames.last!, to: workoutTemplate, addToWorkout: true)
        }
        
        sut = WorkoutEditViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack )
        assertEqual(sut.rowCount(section: 0), 5)
        XCTAssert(sut.rowCount(section: 1) == 0)
        sut.addExercise(templates: [])
        assertEqual(sut.rowCount(section: 0), 5)
        XCTAssert(sut.rowCount(section: 1) == 0)
    }
    
    func testExercisesAdded_oneExercise_changesRecognized() {
        dbHelper.insertWorkoutTemplate(type: .push)
        let workoutTemplate = dbHelper.fetchWorkoutTemplates().first!
        var todoNames = [String]()
        for i in 0...4 {
            todoNames.append("to do \(i)")
            dbHelper.addExerciseTemplate(todoNames.last!, to: workoutTemplate, addToWorkout: true)
        }
        let name = "to be added"
        sut = WorkoutEditViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack )
        XCTAssert(sut.rowCount(section: 0) == 5)
        XCTAssert(sut.rowCount(section: 1) == 0)
        dbHelper.addExerciseTemplate(name, to: workoutTemplate, addToWorkout: true)
        guard let _ = dbHelper.fetchExerciseTemplates()?.first(where: { $0.name! == name })! else {
            XCTFail()
            return
        }
        sut.exerciseTemplatesAdded()
        assertEqual(sut.rowCount(section: 0), 6)
        XCTAssert(sut.rowCount(section: 1) == 0)
    }
    
    func testExercisesAdded_5Exercises_changesRecognized() {
        dbHelper.insertWorkoutTemplate(type: .push)
        let workoutTemplate = dbHelper.fetchWorkoutTemplates().first!
        var todoNames = [String]()
        for i in 0...4 {
            todoNames.append("to do \(i)")
            dbHelper.addExerciseTemplate(todoNames.last!, to: workoutTemplate, addToWorkout: true)
        }
        
        sut = WorkoutEditViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack )
        assertEqual(sut.rowCount(section: 0), 5)
        XCTAssert(sut.rowCount(section: 1) == 0)
        var toAddNames = [String]()
        for i in 0...4 {
            toAddNames.append("to be added \(i)")
            dbHelper.addExerciseTemplate(toAddNames.last!, to: workoutTemplate, addToWorkout: true)
        }
        sut.exerciseTemplatesAdded()
        assertEqual(sut.rowCount(section: 0), 10)
        XCTAssert(sut.rowCount(section: 1) == 0)
    }
    
    func testSelectedIndexPath_sectionZero_getSelected_templateReturned() {
        dbHelper.insertWorkoutTemplate(type: .push)
        let workoutTemplate = dbHelper.fetchWorkoutTemplates().first!
        var todoNames = [String]()
        for i in 0...4 {
            todoNames.append("to do \(i)")
            dbHelper.addExerciseTemplate(todoNames.last!, to: workoutTemplate, addToWorkout: true)
        }
        sut = WorkoutEditViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack )
        XCTAssert(sut.getSelected() == nil)
        sut.selectedIndex = IndexPath(row: 0, section: 0)
        var tempToTest = sut.getSelected() as! ExerciseTemplate
        var tempTester = dbHelper.fetchExerciseTemplates()?.first(where: { $0.name! == todoNames[0] })
        XCTAssert(tempToTest == tempTester)
        sut.selectedIndex = IndexPath(row: 2, section: 0)
        tempToTest = sut.getSelected() as! ExerciseTemplate
        tempTester = dbHelper.fetchExerciseTemplates()?.first(where: { $0.name! == todoNames[2] })
        XCTAssert(tempToTest == tempTester)
    }
    
    func testSelectedIndexPath_sectionOne_getSelected_exerciseReturned() {
        dbHelper.insertWorkoutTemplate(type: .push)
        let workoutTemplate = dbHelper.fetchWorkoutTemplates().first!
        var todoNames = [String]()
        for i in 0...4 {
            todoNames.append("to do \(i)")
            dbHelper.addExerciseTemplate(todoNames.last!, to: workoutTemplate, addToWorkout: true)
        }
        sut = WorkoutEditViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack )
        dbHelper.addExercise(todoNames[0], to: dbHelper.fetchWorkouts().first!)
        sut.reload()
        sut.selectedIndex = IndexPath(row: 0, section: 1)
        let exerciseToTest = sut.getSelected() as! Exercise
        let exerciseTester = dbHelper.fetchExercises().first(where: { $0.name! == todoNames[0] })
        XCTAssert(exerciseToTest == exerciseTester)
        XCTAssert(sut.rowCount(section: 0) == 4)
        XCTAssert(sut.rowCount(section: 1) == 1)
    }
    
    func testSelectedIndexPath_sectionZero_workoutHasExerciseAndTemplate_getSelected_exerciseReturned() {
        dbHelper.insertWorkoutTemplate(type: .push)
        let workoutTemplate = dbHelper.fetchWorkoutTemplates().first!
        var todoNames = [String]()
        for i in 0...4 {
            todoNames.append("to do \(i)")
            dbHelper.addExerciseTemplate(todoNames.last!, to: workoutTemplate, addToWorkout: true)
        }
        sut = WorkoutEditViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack )
        dbHelper.addExercise(todoNames[0], to: dbHelper.fetchWorkouts().first!)
        sut.reload()
        sut.selectedIndex = IndexPath(row: 0, section: 1)
        let exerciseToTest = sut.getSelected() as! Exercise
        let exerciseTester = dbHelper.fetchExercises().first(where: { $0.name! == todoNames[0] })
        XCTAssert(exerciseToTest == exerciseTester)
        sut.selectedIndex = IndexPath(row: 0, section: 0)
        let tempToTest = sut.getSelected() as! ExerciseTemplate
        let tempTester = dbHelper.fetchExerciseTemplates()?.first(where: { $0.name! == todoNames[1] })
        XCTAssert(tempToTest == tempTester)
        XCTAssert(sut.rowCount(section: 0) == 4)
        XCTAssert(sut.rowCount(section: 1) == 1)
    }
    
    func testExerciseViewModelCompletedExercise_dataUpdated() {
        dbHelper.insertWorkoutTemplate(type: .push)
        let workoutTemplate = dbHelper.fetchWorkoutTemplates().first!
        var todoNames = [String]()
        for i in 0...4 {
            todoNames.append("to do \(i)")
            dbHelper.addExerciseTemplate(todoNames.last!, to: workoutTemplate, addToWorkout: true)
        }
        sut = WorkoutEditViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack )
        let name = todoNames.remove(at: 2)
        let exercise = dbHelper.createExercise(name)
        sut.exerciseViewModel(ExerciseViewModelMock(withExercise: exercise), started: exercise)
        XCTAssert(sut.rowCount(section: 0) == 4, "\nexpected: 4\nactual: \(sut.rowCount(section: 0))")
        XCTAssert(sut.rowCount(section: 1) == 1, "\nexpected: 1\nactual: \(sut.rowCount(section: 1))")
        for i in 0...3 {
            XCTAssert(sut.title(indexPath: IndexPath(row: i, section: 0)) == todoNames[i])
        }
        XCTAssert(sut.title(indexPath: IndexPath(row: 0, section: 1)) == name)
    }
    
    func testExerciseViewModelCompletedExercises_dataUpdated() {
        dbHelper.insertWorkoutTemplate(type: .push)
        let workoutTemplate = dbHelper.fetchWorkoutTemplates().first!
        var todoNames = [String]()
        for i in 0...4 {
            todoNames.append("to do \(i)")
            dbHelper.addExerciseTemplate(todoNames.last!, to: workoutTemplate, addToWorkout: true)
        }
        sut = WorkoutEditViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack )
        let name1 = todoNames.remove(at: 2)
        var exercise = dbHelper.createExercise(name1)
        sut.exerciseViewModel(ExerciseViewModelMock(withExercise: exercise), started: exercise)
        XCTAssert(sut.rowCount(section: 0) == 4, "\nexpected: 4\nactual: \(sut.rowCount(section: 0))")
        XCTAssert(sut.rowCount(section: 1) == 1, "\nexpected: 1\nactual: \(sut.rowCount(section: 1))")
        for i in 0...3 {
            XCTAssert(sut.title(indexPath: IndexPath(row: i, section: 0)) == todoNames[i])
        }
        XCTAssert(sut.title(indexPath: IndexPath(row: 0, section: 1)) == name1)
        
        let name2 = todoNames.remove(at: 2)
        exercise = dbHelper.createExercise(name2)
        sut.exerciseViewModel(ExerciseViewModelMock(withExercise: exercise), started: exercise)
        XCTAssert(sut.rowCount(section: 0) == 3, "\nexpected: 3\nactual: \(sut.rowCount(section: 0))")
        XCTAssert(sut.rowCount(section: 1) == 2, "\nexpected: 2\nactual: \(sut.rowCount(section: 1))")
        for i in 0...2 {
            XCTAssert(sut.title(indexPath: IndexPath(row: i, section: 0)) == todoNames[i])
        }
        XCTAssert(sut.title(indexPath: IndexPath(row: 0, section: 1)) == name1, "\nexpected: \(name1)\nactual: \(sut.title(indexPath: IndexPath(row: 0, section: 0))!)")
        XCTAssert(sut.title(indexPath: IndexPath(row: 1, section: 1)) == name2, "\nexpected: \(name2)\nactual: \(sut.title(indexPath: IndexPath(row: 0, section: 1))!)")
    }
    
    func testDetailTextForIndexPath_correctVolumeReturnedForCompletedExercise() {
        dbHelper.insertWorkoutTemplate(type: .push)
        let workoutTemplate = dbHelper.fetchWorkoutTemplates().first!
        let name = "exercise"
        dbHelper.addExerciseTemplate(name, to: workoutTemplate, addToWorkout: true)
        sut = WorkoutEditViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack )
        let set = (10, 1.0, 60.0)
        let exercise = dbHelper.createExercise(name, sets: [set, set, set])
        sut.exerciseViewModel(ExerciseViewModelMock(withExercise: exercise), started: exercise)
        guard let volume = sut.detailText(indexPath: IndexPath(row: 0, section: 1)) else {
            XCTFail()
            return
        }
        XCTAssertEqual(volume, "Volume: \((60 * 10.0.durationLog) * 3)")
    }
    
    func testDetailTextForIndexPath_incorrectSection_nilReturned() {
        dbHelper.insertWorkoutTemplate(type: .push)
        let workoutTemplate = dbHelper.fetchWorkoutTemplates().first!
        let name = "exercise"
        dbHelper.addExerciseTemplate(name, to: workoutTemplate, addToWorkout: true)
        sut = WorkoutEditViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack )
        let set = (10, 1.0, 60.0)
        let exercise = dbHelper.createExercise(name, sets: [set, set, set])
        sut.exerciseViewModel(ExerciseViewModelMock(withExercise: exercise), started: exercise)
        XCTAssert(sut.detailText(indexPath: IndexPath(row: 0, section: 0)) == nil)
    }
    
    func testExerciseVolumeComparison_equalVolumes_noChangeReturned() {
        dbHelper.insertWorkoutTemplate(type: .push)
        let workoutTemplate = dbHelper.fetchWorkoutTemplates().first!
        let name = "exercise"
        dbHelper.addExerciseTemplate(name, to: workoutTemplate, addToWorkout: true)
        sut = WorkoutEditViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack )
        let set1 = (10, 1.0, 60.0)
        let exercise1 = dbHelper.createExercise(name, sets: [set1])
        sut.exerciseViewModel(ExerciseViewModelMock(withExercise: exercise1), started: exercise1)
        sut = WorkoutEditViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack )
        let set2 = (10, 1.0, 60.0)
        let exercise2 = dbHelper.createExercise(name, sets: [set2])
        sut.exerciseViewModel(ExerciseViewModelMock(withExercise: exercise2), started: exercise2)
        let progression = sut.exerciseVolumeComparison(row: 0)
        XCTAssert(progression == .noChange)
    }
    
    func testExerciseVolumeComparison_increaseInVolume_positiveReturned() {
        dbHelper.insertWorkoutTemplate(type: .push)
        let workoutTemplate = dbHelper.fetchWorkoutTemplates().first!
        let name = "exercise"
        dbHelper.addExerciseTemplate(name, to: workoutTemplate, addToWorkout: true)
        sut = WorkoutEditViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack )
        let set1 = (10, 1.0, 60.0)
        let exercise1 = dbHelper.createExercise(name, sets: [set1])
        sut.exerciseViewModel(ExerciseViewModelMock(withExercise: exercise1), started: exercise1)
        sut = WorkoutEditViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack )
        let set2 = (10, 2.0, 61.0)
        let exercise2 = dbHelper.createExercise(name, sets: [set2])
        sut.exerciseViewModel(ExerciseViewModelMock(withExercise: exercise2), started: exercise2)
        let progression = sut.exerciseVolumeComparison(row: 0)
        XCTAssert(progression == .increase)
    }
    
    func testExerciseVolumeComparison_decreaseInVolume_negativeReturned() {
        dbHelper.insertWorkoutTemplate(type: .push)
        let workoutTemplate = dbHelper.fetchWorkoutTemplates().first!
        let name = "exercise"
        dbHelper.addExerciseTemplate(name, to: workoutTemplate, addToWorkout: true)
        sut = WorkoutEditViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack )
        let set1 = (30, 2.0, 60.0)
        let exercise1 = dbHelper.createExercise(name, sets: [set1])
        sut.exerciseViewModel(ExerciseViewModelMock(withExercise: exercise1), started: exercise1)
        sut.finishWorkout()
        sut = WorkoutEditViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack )
        let set2 = (10, 1.0, 60.0)
        let exercise2 = dbHelper.createExercise(name, sets: [set2])
        sut.exerciseViewModel(ExerciseViewModelMock(withExercise: exercise2), started: exercise2)
        let progression = sut.exerciseVolumeComparison(row: 0)
        XCTAssert(progression == .decrease)
    }
    
    func testExerciseVolumeComparison_noPreviousWorkouts_positiveReturned() {
        dbHelper.insertWorkoutTemplate(type: .push)
        let workoutTemplate = dbHelper.fetchWorkoutTemplates().first!
        let name = "exercise"
        dbHelper.addExerciseTemplate(name, to: workoutTemplate, addToWorkout: true)
        sut = WorkoutEditViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack )
        let set1 = (10, 2.0, 60.0)
        let exercise1 = dbHelper.createExercise(name, sets: [set1])
        sut.exerciseViewModel(ExerciseViewModelMock(withExercise: exercise1), started: exercise1)
        let progression = sut.exerciseVolumeComparison(row: 0)
        XCTAssert(progression == .increase)
    }
    
    func testDeleteWorkout() {
        dbHelper.insertWorkoutTemplate(type: .push)
        let workoutTemplate = dbHelper.fetchWorkoutTemplates().first!
        let name = "exercise"
        dbHelper.addExerciseTemplate(name, to: workoutTemplate, addToWorkout: true)
        sut = WorkoutEditViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack )
        let set1 = (10, 2.0, 60.0)
        let exercise1 = dbHelper.createExercise(name, sets: [set1])
        sut.exerciseViewModel(ExerciseViewModelMock(withExercise: exercise1), started: exercise1)
        sut.deleteWorkout()
        let workouts = dbHelper.fetchWorkouts()
        XCTAssert(workouts.count == 0)
    }
    
    func testDeleteWorkout_twoWorkoutsPreviouslySaved_bothWorkoutsStillExist() {
        dbHelper.insertWorkoutTemplate(type: .push)
        let workoutTemplate = dbHelper.fetchWorkoutTemplates().first!
        let name = "exercise"
        dbHelper.addExerciseTemplate(name, to: workoutTemplate, addToWorkout: true)
        let _ = dbHelper.createWorkout(name: .push, date: Date().addingTimeInterval(-(60 * 60 * 24)))
        let _ = dbHelper.createWorkout(name: .push, date: Date().addingTimeInterval(-(60 * 60 * 24 * 2)))
        sut = WorkoutEditViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack )
        let workoutDeletedId = sut.workoutId
        let workoutsBeforeDeletion = dbHelper.fetchWorkouts()
        XCTAssert(workoutsBeforeDeletion.count == 3)
        XCTAssert(workoutsBeforeDeletion.contains(where: { $0.objectID == workoutDeletedId }))
        sut.deleteWorkout()
        let workoutsAfterDeletion = dbHelper.fetchWorkouts()
        XCTAssert(workoutsAfterDeletion.count == 2)
        XCTAssert(!workoutsAfterDeletion.contains(where: { $0.objectID == workoutDeletedId }))
    }
    
    func testInit_WIP_viewModelIsInitializedWithWIP() {
        let workout = dbHelper.createWorkout(name: .push, date: Date())
        for i in 0...4 {
            dbHelper.addExercise("ex\(i)", to: workout)
        }
        AppState.shared.workoutInProgress = .push
        sut = WorkoutEditViewModel(coreDataManagement: dbHelper.coreDataStack)
        XCTAssertEqual(dbHelper.fetchWorkouts().count, 1)
        XCTAssertEqual(dbHelper.fetchWorkouts().first!.objectID, workout.objectID)
    }
    
    func testInit_WIP_deleteWorkout_workoutDeleted_appStateWIPisFalse() {
        let workout = dbHelper.createWorkout(name: .push, date: Date())
        for i in 0...4 {
            dbHelper.addExercise("ex\(i)", to: workout)
        }
        AppState.shared.workoutInProgress = .push
        sut = WorkoutEditViewModel(coreDataManagement: dbHelper.coreDataStack)
        sut.deleteWorkout()
        XCTAssertEqual(dbHelper.fetchWorkouts().count, 0)
        XCTAssertNil(AppState.shared.workoutInProgress)
    }
    
    func testInit_WIP_deleteWorkout_workoutFinished_appStateWIPisFalse() {
        let workout = dbHelper.createWorkout(name: .push, date: Date())
        for i in 0...4 {
            dbHelper.addExercise("ex\(i)", to: workout)
        }
        AppState.shared.workoutInProgress = .push
        sut = WorkoutEditViewModel(coreDataManagement: dbHelper.coreDataStack)
        sut.finishWorkout()
        XCTAssertEqual(dbHelper.fetchWorkouts().count, 1)
        XCTAssertNil(AppState.shared.workoutInProgress)
    }
}

func assertEqual(_ v1: Int, _ v2: Int) {
    XCTAssert(v1 == v2, "\nexpected: \(v2)\nactual: \(v1)")
}

class ExerciseViewModelMock: ExerciseViewModel {
    init(withExercise exercise: Exercise) {
        super.init(exercise: exercise)
    }
}
