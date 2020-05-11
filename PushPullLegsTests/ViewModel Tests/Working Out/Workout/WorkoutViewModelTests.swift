//
//  WorkoutViewModel.swift
//  PushPullLegsTests
//
//  Created by Mark Bragg on 4/18/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import XCTest
import CoreData
@testable import PushPullLegs

class WorkoutViewModelTests: XCTestCase {

    var sut: WorkoutViewModel!
    let dbHelper = DBHelper(coreDataStack: CoreDataTestStack())
    
    fileprivate func assertNoSavedWorkoutsTypeInjectedIsReturned(_ type: ExerciseType) {
        sut = WorkoutViewModel(withType: type,  coreDataManagement: dbHelper.coreDataStack )
        XCTAssert(sut.getExerciseType() == type)
    }
    
    fileprivate func assertPreviousWorkouts(withTypes previousWorkoutTypes: [ExerciseType], injectionType: ExerciseType) {
        for type in previousWorkoutTypes {
            dbHelper.insertWorkout(name: type)
        }
        sut = WorkoutViewModel(withType: injectionType,  coreDataManagement: dbHelper.coreDataStack )
        XCTAssert(sut.getExerciseType() == injectionType)
    }
    
    fileprivate func assertPreviousWorkoutsNoInjection(_ previousWorkoutTypes: [ExerciseType], expectedType: ExerciseType) {
        for type in previousWorkoutTypes {
            dbHelper.insertWorkout(name: type)
        }
        sut = WorkoutViewModel(withType: nil,  coreDataManagement: dbHelper.coreDataStack )
        XCTAssert(sut.getExerciseType() == expectedType)
    }
    
    func testGetExerciseType_noPreviousWorkouts_noTypeInjected_pushReturned() {
        sut = WorkoutViewModel(withType: nil,  coreDataManagement: dbHelper.coreDataStack )
        XCTAssert(sut.getExerciseType() == ExerciseType.push)
    }
    
    func testGetExerciseType_noPreviousWorkouts_pushTypeInjected_pushReturned() {
        assertNoSavedWorkoutsTypeInjectedIsReturned(.push)
    }
    
    func testGetExerciseType_noPreviousWorkouts_pullTypeInjected_pullReturned() {
        assertNoSavedWorkoutsTypeInjectedIsReturned(.pull)
    }
    
    func testGetExerciseType_noPreviousWorkouts_legsTypeInjected_legsReturned() {
        assertNoSavedWorkoutsTypeInjectedIsReturned(.legs)
    }
    
    func testGetExerciseType_previousWorkoutsPush_noTypeInjected_pullReturned() {
        assertPreviousWorkoutsNoInjection([.push], expectedType: .pull)
    }
    
    func testGetExerciseType_previousWorkoutsPush_pushTypeInjected_pushReturned() {
        assertPreviousWorkouts(withTypes: [.push], injectionType: .push)
    }
    
    func testGetExerciseType_previousWorkoutsPush_pullTypeInjected_pullReturned() {
        assertPreviousWorkouts(withTypes: [.push], injectionType: .pull)
    }
    
    func testGetExerciseType_previousWorkoutsPush_legsTypeInjected_legsReturned() {
        assertPreviousWorkouts(withTypes: [.push], injectionType: .legs)
    }
    
    func testGetExerciseType_previousWorkoutsPushPull_noTypeInjected_legsReturned() {
        assertPreviousWorkoutsNoInjection([.push, .pull], expectedType: .legs)
    }
    
    func testGetExerciseType_previousWorkoutsPushPull_legsTypeInjected_legsReturned() {
        assertPreviousWorkouts(withTypes: [.push, .pull], injectionType: .legs)
    }
    
    func testGetExerciseType_previousWorkoutsPushPull_pullTypeInjected_pullReturned() {
        assertPreviousWorkouts(withTypes: [.push, .pull], injectionType: .pull)
    }
    
    func testGetExerciseType_previousWorkoutsPushPull_pushTypeInjected_pushReturned() {
        assertPreviousWorkouts(withTypes: [.push, .pull], injectionType: .push)
    }
    
    func testGetExerciseType_previousWorkoutsPushPullLegs_noTypeInjected_pushReturned() {
        assertPreviousWorkoutsNoInjection([.push, .pull, .legs], expectedType: .push)
    }
    
    func testGetExerciseType_previousWorkoutsPushPullLegs_legsTypeInjected_legsReturned() {
        assertPreviousWorkouts(withTypes: [.push, .pull, .legs], injectionType: .legs)
    }
    
    func testGetExerciseType_previousWorkoutsPushPullLegs_pullTypeInjected_pullReturned() {
        assertPreviousWorkouts(withTypes: [.push, .pull, .legs], injectionType: .pull)
    }
    
    func testGetExerciseType_previousWorkoutsPushPullLegs_pushTypeInjected_pushReturned() {
        assertPreviousWorkouts(withTypes: [.push, .pull, .legs], injectionType: .push)
    }
    
    func testSectionCount() {
        sut = WorkoutViewModel(withType: nil, coreDataManagement: dbHelper.coreDataStack )
        XCTAssert(sut.sectionCount() == 2)
    }
    
    func testRowsForSection_zeroExercises_zeroRowsForBothSections() {
        sut = WorkoutViewModel(withType: nil, coreDataManagement: dbHelper.coreDataStack )
        XCTAssert(sut.rowsForSection(0) == 0, "\nexpected: 0\nactual: \(sut.rowsForSection(0))")
        XCTAssert(sut.rowsForSection(1) == 0)
    }
    
    func testRowsForSection_zeroExercisesDone_oneExerciseToDo_oneRowForSectionZero_zeroRowsForSectionOne() {
        dbHelper.insertWorkoutTemplateMainContext()
        let workoutTemplate = dbHelper.fetchWorkoutTemplates().first!
        dbHelper.addExerciseTemplate("exercise to do", to: workoutTemplate, addToWorkout: true)
        sut = WorkoutViewModel(withType: nil,coreDataManagement: dbHelper.coreDataStack)
        assertEqual(sut.rowsForSection(0), 1)
        XCTAssert(sut.rowsForSection(1) == 0)
    }
    
    func testRowsForSection_zeroExercisesDone_tenExercisesToDo_tenRowsForSectionZero_zeroRowsForSectionOne() {
        dbHelper.insertWorkoutTemplate()
        for i in 0...9 {
            dbHelper.addExerciseTemplate("exercise to do #\(i)", to: dbHelper.fetchWorkoutTemplates().first!, addToWorkout: true)
        }
        sut = WorkoutViewModel(withType: nil,coreDataManagement: dbHelper.coreDataStack)
        assertEqual(sut.rowsForSection(0), 10)
        XCTAssert(sut.rowsForSection(1) == 0)
    }
    
    func testRowsForSection_oneExerciseDone_zeroExercisesToDo_zeroRowsForSectionZero_oneRowForSectionOne() {
        sut = WorkoutViewModel(withType: nil, coreDataManagement: dbHelper.coreDataStack)
        dbHelper.addExercise("exercise done", to: dbHelper.fetchWorkouts().first!)
        sut.exerciseTemplatesAdded()
        XCTAssert(sut.rowsForSection(0) == 0)
        XCTAssert(sut.rowsForSection(1) == 1)
    }
    
    func testRowsForSection_tenExercisesDone_fiveExercisesToDo_fiveRowsForSectionZero_tenRowsForSectionOne() {
        dbHelper.insertWorkoutTemplate(type: .push)
        let workoutTemplate = dbHelper.fetchWorkoutTemplates().first!
        for i in 0...4 {
            dbHelper.addExerciseTemplate("to do \(i)", to: workoutTemplate, addToWorkout: true)
        }
        sut = WorkoutViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack )
        for i in 0...9 {
            dbHelper.addExercise("done \(i)", to: dbHelper.fetchWorkouts().first!)
        }
        sut.reload()
        let done = sut.rowsForSection(1)
        let todo = sut.rowsForSection(0)
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
        sut = WorkoutViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack )
        var doneNames = [String]()
        for i in 0...9 {
            doneNames.append("done \(i)")
            dbHelper.addExercise(doneNames.last!, to: dbHelper.fetchWorkouts().first!)
        }
        sut.reload()
        var row = 0
        for name in todoNames.sorted(by: { $0 < $1 }) {
            XCTAssert(sut.titleForIndexPath(IndexPath(row: row, section: 0)) == name, "\nexpected: \(name)\nactual: \(sut.titleForIndexPath(IndexPath(row: row, section: 0)))")
            row += 1
        }
        row = 0
        for name in doneNames.sorted(by: { $0 < $1 }) {
            XCTAssert(sut.titleForIndexPath(IndexPath(row: row, section: 1)) == name)
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
        sut = WorkoutViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack )
        sleep(15)
        sut.finishWorkout()
        guard let workout = dbHelper.fetchWorkouts().first else {
            XCTFail()
            return
        }
        XCTAssert(Int(workout.dateCreated!.timeIntervalSinceNow) < 5)
        XCTAssert(workout.duration == 15)
        XCTAssert(workout.name == ExerciseType.push.rawValue)
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
        sut = WorkoutViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack )
        assertEqual(sut.rowsForSection(0), 5)
        XCTAssert(sut.rowsForSection(1) == 0)
        guard let exerciseToBeAdded = dbHelper.fetchExerciseTemplates()?.first(where: { $0.name! == name })! else {
            XCTFail()
            return
        }
        sut.addExercise(templates: [exerciseToBeAdded])
        assertEqual(sut.rowsForSection(0), 6)
        XCTAssert(sut.rowsForSection(1) == 0)
    }
    
    func testAddExercises_exerciseTemplatesAdded() {
        dbHelper.insertWorkoutTemplate(type: .push)
        let workoutTemplate = dbHelper.fetchWorkoutTemplates().first!
        var todoNames = [String]()
        for i in 0...4 {
            todoNames.append("to do \(i)")
            dbHelper.addExerciseTemplate(todoNames.last!, to: workoutTemplate, addToWorkout: true)
        }
        
        sut = WorkoutViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack )
        assertEqual(sut.rowsForSection(0), 5)
        XCTAssert(sut.rowsForSection(1) == 0)
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
        assertEqual(sut.rowsForSection(0), 10)
        XCTAssert(sut.rowsForSection(1) == 0)
    }
    
    func testAddZeroExercises_zeroExerciseTemplatesAdded() {
        dbHelper.insertWorkoutTemplate(type: .push)
        let workoutTemplate = dbHelper.fetchWorkoutTemplates().first!
        var todoNames = [String]()
        for i in 0...4 {
            todoNames.append("to do \(i)")
            dbHelper.addExerciseTemplate(todoNames.last!, to: workoutTemplate, addToWorkout: true)
        }
        
        sut = WorkoutViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack )
        assertEqual(sut.rowsForSection(0), 5)
        XCTAssert(sut.rowsForSection(1) == 0)
        sut.addExercise(templates: [])
        assertEqual(sut.rowsForSection(0), 5)
        XCTAssert(sut.rowsForSection(1) == 0)
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
        sut = WorkoutViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack )
        XCTAssert(sut.rowsForSection(0) == 5)
        XCTAssert(sut.rowsForSection(1) == 0)
        dbHelper.addExerciseTemplate(name, to: workoutTemplate, addToWorkout: true)
        guard let _ = dbHelper.fetchExerciseTemplates()?.first(where: { $0.name! == name })! else {
            XCTFail()
            return
        }
        sut.exerciseTemplatesAdded()
        assertEqual(sut.rowsForSection(0), 6)
        XCTAssert(sut.rowsForSection(1) == 0)
    }
    
    func testExercisesAdded_5Exercises_changesRecognized() {
        dbHelper.insertWorkoutTemplate(type: .push)
        let workoutTemplate = dbHelper.fetchWorkoutTemplates().first!
        var todoNames = [String]()
        for i in 0...4 {
            todoNames.append("to do \(i)")
            dbHelper.addExerciseTemplate(todoNames.last!, to: workoutTemplate, addToWorkout: true)
        }
        
        sut = WorkoutViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack )
        assertEqual(sut.rowsForSection(0), 5)
        XCTAssert(sut.rowsForSection(1) == 0)
        var toAddNames = [String]()
        for i in 0...4 {
            toAddNames.append("to be added \(i)")
            dbHelper.addExerciseTemplate(toAddNames.last!, to: workoutTemplate, addToWorkout: true)
        }
        sut.exerciseTemplatesAdded()
        assertEqual(sut.rowsForSection(0), 10)
        XCTAssert(sut.rowsForSection(1) == 0)
    }
    
    func testSelectedIndexPath_sectionZero_getExerciseTemplate_templateReturned_getExercise_nilReturned() {
        dbHelper.insertWorkoutTemplate(type: .push)
        let workoutTemplate = dbHelper.fetchWorkoutTemplates().first!
        var todoNames = [String]()
        for i in 0...4 {
            todoNames.append("to do \(i)")
            dbHelper.addExerciseTemplate(todoNames.last!, to: workoutTemplate, addToWorkout: true)
        }
        sut = WorkoutViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack )
        XCTAssert(sut.getSelectedExerciseTemplate() == nil)
        sut.selected(indexPath: IndexPath(row: 0, section: 0))
        var tempToTest = sut.getSelectedExerciseTemplate()
        var tempTester = dbHelper.fetchExerciseTemplates()?.first(where: { $0.name! == todoNames[0] })
        XCTAssert(tempToTest == tempTester)
        sut.selected(indexPath: IndexPath(row: 2, section: 0))
        XCTAssert(sut.getSelectedExercise() == nil)
        tempToTest = sut.getSelectedExerciseTemplate()
        tempTester = dbHelper.fetchExerciseTemplates()?.first(where: { $0.name! == todoNames[2] })
        XCTAssert(tempToTest == tempTester)
    }
    
    func testSelectedIndexPath_sectionOne_getExercise_exerciseReturned_getExerciseTemplate_nilReturned() {
        dbHelper.insertWorkoutTemplate(type: .push)
        let workoutTemplate = dbHelper.fetchWorkoutTemplates().first!
        var todoNames = [String]()
        for i in 0...4 {
            todoNames.append("to do \(i)")
            dbHelper.addExerciseTemplate(todoNames.last!, to: workoutTemplate, addToWorkout: true)
        }
        sut = WorkoutViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack )
        dbHelper.addExercise(todoNames[0], to: dbHelper.fetchWorkouts().first!)
        sut.reload()
        sut.selected(indexPath: IndexPath(row: 0, section: 1))
        let exerciseToTest = sut.getSelectedExercise()
        let exerciseTester = dbHelper.fetchExercises().first(where: { $0.name! == todoNames[0] })
        XCTAssert(exerciseToTest == exerciseTester)
        XCTAssert(sut.getSelectedExerciseTemplate() == nil)
        XCTAssert(sut.rowsForSection(0) == 4)
        XCTAssert(sut.rowsForSection(1) == 1)
    }
    
    func testExerciseViewModelCompletedExercise_dataUpdated() {
        dbHelper.insertWorkoutTemplate(type: .push)
        let workoutTemplate = dbHelper.fetchWorkoutTemplates().first!
        var todoNames = [String]()
        for i in 0...4 {
            todoNames.append("to do \(i)")
            dbHelper.addExerciseTemplate(todoNames.last!, to: workoutTemplate, addToWorkout: true)
        }
        sut = WorkoutViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack )
        let name = todoNames.remove(at: 2)
        let exercise = dbHelper.createExercise(name)
        sut.exerciseViewModel(ExerciseViewModelMock(withExercise: exercise), completed: exercise)
        XCTAssert(sut.rowsForSection(0) == 4, "\nexpected: 4\nactual: \(sut.rowsForSection(0))")
        XCTAssert(sut.rowsForSection(1) == 1, "\nexpected: 1\nactual: \(sut.rowsForSection(1))")
        for i in 0...3 {
            XCTAssert(sut.titleForIndexPath(IndexPath(row: i, section: 0)) == todoNames[i])
        }
        XCTAssert(sut.titleForIndexPath(IndexPath(row: 0, section: 1)) == name)
    }
    
    func testExerciseViewModelCompletedExercises_dataUpdated() {
        dbHelper.insertWorkoutTemplate(type: .push)
        let workoutTemplate = dbHelper.fetchWorkoutTemplates().first!
        var todoNames = [String]()
        for i in 0...4 {
            todoNames.append("to do \(i)")
            dbHelper.addExerciseTemplate(todoNames.last!, to: workoutTemplate, addToWorkout: true)
        }
        sut = WorkoutViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack )
        let name1 = todoNames.remove(at: 2)
        var exercise = dbHelper.createExercise(name1)
        sut.exerciseViewModel(ExerciseViewModelMock(withExercise: exercise), completed: exercise)
        XCTAssert(sut.rowsForSection(0) == 4, "\nexpected: 4\nactual: \(sut.rowsForSection(0))")
        XCTAssert(sut.rowsForSection(1) == 1, "\nexpected: 1\nactual: \(sut.rowsForSection(1))")
        for i in 0...3 {
            XCTAssert(sut.titleForIndexPath(IndexPath(row: i, section: 0)) == todoNames[i])
        }
        XCTAssert(sut.titleForIndexPath(IndexPath(row: 0, section: 1)) == name1)
        
        let name2 = todoNames.remove(at: 2)
        exercise = dbHelper.createExercise(name2)
        sut.exerciseViewModel(ExerciseViewModelMock(withExercise: exercise), completed: exercise)
        XCTAssert(sut.rowsForSection(0) == 3, "\nexpected: 3\nactual: \(sut.rowsForSection(0))")
        XCTAssert(sut.rowsForSection(1) == 2, "\nexpected: 2\nactual: \(sut.rowsForSection(1))")
        for i in 0...2 {
            XCTAssert(sut.titleForIndexPath(IndexPath(row: i, section: 0)) == todoNames[i])
        }
        XCTAssert(sut.titleForIndexPath(IndexPath(row: 0, section: 1)) == name1, "\nexpected: \(name1)\nactual: \(sut.titleForIndexPath(IndexPath(row: 0, section: 0)))")
        XCTAssert(sut.titleForIndexPath(IndexPath(row: 1, section: 1)) == name2, "\nexpected: \(name2)\nactual: \(sut.titleForIndexPath(IndexPath(row: 0, section: 1)))")
    }
    
    func testDetailTextForIndexPath_correctVolumeReturnedForCompletedExercise() {
        dbHelper.insertWorkoutTemplate(type: .push)
        let workoutTemplate = dbHelper.fetchWorkoutTemplates().first!
        let name = "exercise"
        dbHelper.addExerciseTemplate(name, to: workoutTemplate, addToWorkout: true)
        sut = WorkoutViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack )
        let set = (10, 1, 60.0)
        let exercise = dbHelper.createExercise(name, sets: [set, set, set])
        sut.exerciseViewModel(ExerciseViewModelMock(withExercise: exercise), completed: exercise)
        guard let volume = sut.detailText(indexPath: IndexPath(row: 0, section: 1)) else {
            XCTFail()
            return
        }
        XCTAssert(volume == "\(10.0*60.0*3.0/60.0)")
    }
    
    func testDetailTextForIndexPath_incorrectSection_nilReturned() {
        dbHelper.insertWorkoutTemplate(type: .push)
        let workoutTemplate = dbHelper.fetchWorkoutTemplates().first!
        let name = "exercise"
        dbHelper.addExerciseTemplate(name, to: workoutTemplate, addToWorkout: true)
        sut = WorkoutViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack )
        let set = (10, 1, 60.0)
        let exercise = dbHelper.createExercise(name, sets: [set, set, set])
        sut.exerciseViewModel(ExerciseViewModelMock(withExercise: exercise), completed: exercise)
        XCTAssert(sut.detailText(indexPath: IndexPath(row: 0, section: 0)) == nil)
    }
    
    func testExerciseVolumeComparison_equalVolumes_noChangeReturned() {
        dbHelper.insertWorkoutTemplate(type: .push)
        let workoutTemplate = dbHelper.fetchWorkoutTemplates().first!
        let name = "exercise"
        dbHelper.addExerciseTemplate(name, to: workoutTemplate, addToWorkout: true)
        sut = WorkoutViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack )
        let set1 = (10, 1, 60.0)
        let exercise1 = dbHelper.createExercise(name, sets: [set1])
        sut.exerciseViewModel(ExerciseViewModelMock(withExercise: exercise1), completed: exercise1)
        sut = WorkoutViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack )
        let set2 = (10, 1, 60.0)
        let exercise2 = dbHelper.createExercise(name, sets: [set2])
        sut.exerciseViewModel(ExerciseViewModelMock(withExercise: exercise2), completed: exercise2)
        let progression = sut.exerciseVolumeComparison(row: 0)
        XCTAssert(progression == .noChange)
    }
    
    func testExerciseVolumeComparison_increaseInVolume_positiveReturned() {
        dbHelper.insertWorkoutTemplate(type: .push)
        let workoutTemplate = dbHelper.fetchWorkoutTemplates().first!
        let name = "exercise"
        dbHelper.addExerciseTemplate(name, to: workoutTemplate, addToWorkout: true)
        sut = WorkoutViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack )
        let set1 = (10, 1, 60.0)
        let exercise1 = dbHelper.createExercise(name, sets: [set1])
        sut.exerciseViewModel(ExerciseViewModelMock(withExercise: exercise1), completed: exercise1)
        sut = WorkoutViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack )
        let set2 = (10, 2, 60.0)
        let exercise2 = dbHelper.createExercise(name, sets: [set2])
        sut.exerciseViewModel(ExerciseViewModelMock(withExercise: exercise2), completed: exercise2)
        let progression = sut.exerciseVolumeComparison(row: 0)
        XCTAssert(progression == .increase)
    }
    
    func testExerciseVolumeComparison_decreaseInVolume_negativeReturned() {
        dbHelper.insertWorkoutTemplate(type: .push)
        let workoutTemplate = dbHelper.fetchWorkoutTemplates().first!
        let name = "exercise"
        dbHelper.addExerciseTemplate(name, to: workoutTemplate, addToWorkout: true)
        sut = WorkoutViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack )
        let set1 = (10, 2, 60.0)
        let exercise1 = dbHelper.createExercise(name, sets: [set1])
        sut.exerciseViewModel(ExerciseViewModelMock(withExercise: exercise1), completed: exercise1)
        sut = WorkoutViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack )
        let set2 = (10, 1, 60.0)
        let exercise2 = dbHelper.createExercise(name, sets: [set2])
        sut.exerciseViewModel(ExerciseViewModelMock(withExercise: exercise2), completed: exercise2)
        let progression = sut.exerciseVolumeComparison(row: 0)
        XCTAssert(progression == .decrease)
    }
    
    func testExerciseVolumeComparison_noPreviousWorkouts_positiveReturned() {
        dbHelper.insertWorkoutTemplate(type: .push)
        let workoutTemplate = dbHelper.fetchWorkoutTemplates().first!
        let name = "exercise"
        dbHelper.addExerciseTemplate(name, to: workoutTemplate, addToWorkout: true)
        sut = WorkoutViewModel(withType: .push, coreDataManagement: dbHelper.coreDataStack )
        let set1 = (10, 2, 60.0)
        let exercise1 = dbHelper.createExercise(name, sets: [set1])
        sut.exerciseViewModel(ExerciseViewModelMock(withExercise: exercise1), completed: exercise1)
        let progression = sut.exerciseVolumeComparison(row: 0)
        XCTAssert(progression == .increase)
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
