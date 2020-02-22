//
//  ProgramMakerTests.swift
//  PushPullLegsTests
//
//  Created by Mark Bragg on 2/17/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import XCTest
import CoreData

@testable import PushPullLegs

// TODO: UI - in between sets, have a modal/popover showing the counter with a button (text: "start next set") to dismiss (saving time between sets) and begin next set
// TODO: Testing - create program with already stored workouts
/*
 store workouts, create program with workouts, no exercises
 can't create program without workouts
 
 */

class ProgramMakerTests: XCTestCase {

    var sut: ProgramMaker!
    var coreDataStack: CoreDataTestStack!
    
    override func setUp() {
        self.coreDataStack = CoreDataTestStack()
        sut = ProgramMaker(withManager: ProgramManager(backgroundContext: self.coreDataStack.backgroundContext),
                           support: TemplateManagement(backgroundContext: self.coreDataStack.backgroundContext))
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func getPrograms() -> [Program]? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: ProgramEntityName)
        return try? coreDataStack.backgroundContext.fetch(request) as? [Program]
    }
    
    func getWorkoutTemplates() -> [WorkoutTemplate]? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "WorkoutTemplate")
        return try? coreDataStack.backgroundContext.fetch(request) as? [WorkoutTemplate]
    }
    
    func getExerciseTemplates() -> [ExerciseTemplate]? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ExerciseTemplate")
        return try? coreDataStack.backgroundContext.fetch(request) as? [ExerciseTemplate]
    }

    func testMakeProgram_programMaked() {
        let name = "ABC"
        let workoutNames = ["A", "B", "C"]
        let workoutTypes = [WorkoutType.upper, WorkoutType.lower, WorkoutType.upper]
        let exerciseNames = [["a", "b", "c"],["d", "e", "f"],["g", "h", "i"]]
        let exerciseTypes = [ExerciseType.push, ExerciseType.legs, ExerciseType.pull]
        do {
            try sut.makeProgram(program: ProgramStruct(name: name, workoutNames: workoutNames, workoutTypes: workoutTypes, exerciseNames: exerciseNames, exerciseTypes: [exerciseTypes, exerciseTypes, exerciseTypes]))
        } catch {
            XCTFail("error shouldn't be thrown: \(error)")
        }
        guard let program = getPrograms()?.first else {
            XCTFail()
            return
        }
        XCTAssert(program.name == name)
        XCTAssert(program.workoutNames == workoutNames)
        guard let workouts = getWorkoutTemplates() else {
            XCTFail()
            return
        }
        XCTAssert(workouts.count == workoutNames.count)
        for i in 0..<workouts.count {
            guard let exerciseNamesToTest = workouts[i].exerciseNames else {
                XCTFail()
                return
            }
            guard let index = workoutNames.firstIndex(of: workouts[i].name!) else {
                XCTFail()
                return
            }
            XCTAssert(exerciseNamesToTest.count == exerciseNames.count)
            for j in 0..<exerciseNamesToTest.count {
                XCTAssert(exerciseNamesToTest[j] == exerciseNames[index][j])
            }
        }
    }
    
    func testMake2ProgramsWithSameName_oneProgramMaked() {
        let name = "ABC"
        let workoutNames = ["A", "B", "C"]
        let workoutTypes = [WorkoutType.upper, WorkoutType.lower, WorkoutType.upper]
        let exerciseNames = [["a", "b", "c"],["d", "e", "f"],["g", "h", "i"]]
        let exerciseTypes = [ExerciseType.push, ExerciseType.legs, ExerciseType.pull]
        do {
            try sut.makeProgram(program: ProgramStruct(name: name, workoutNames: workoutNames, workoutTypes: workoutTypes, exerciseNames: exerciseNames, exerciseTypes: [exerciseTypes, exerciseTypes, exerciseTypes]))
        } catch {
            XCTFail("error shouldn't be thrown: \(error)")
        }
        do {
            try sut.makeProgram(program: ProgramStruct(name: name, workoutNames: workoutNames, workoutTypes: workoutTypes, exerciseNames: exerciseNames, exerciseTypes: [exerciseTypes, exerciseTypes, exerciseTypes]))
        } catch {
            guard let e = error as? ProgramError else {
                XCTFail("incorrect error thrown: \(error)")
                return
            }
            XCTAssert(e == ProgramError.duplicateProgram)
        }
        guard let programs = getPrograms() else {
            XCTFail()
            return
        }
        XCTAssert(programs.count == 1)
        guard let workouts = getWorkoutTemplates() else {
            XCTFail()
            return
        }
        var workoutCount = 0
        for _ in workoutNames {
            workoutCount += 1
        }
        XCTAssert(workouts.count == workoutCount)
        guard let exercises = getExerciseTemplates() else {
            XCTFail()
            return
        }
        var exerciseCount = 0
        for names in exerciseNames {
            for _ in names {
                exerciseCount += 1
            }
        }
        XCTAssert(exercises.count == exerciseCount)
    }
    
    func testMake2ProgramsWithSameNameDifferentWorkoutNames_onlyOriginalProgramDetailsCreated() {
        let name = "ABC"
        let workoutNames1 = ["A", "B", "C"]
        let workoutNames2 = ["D", "E", "F"]
        let workoutTypes = [WorkoutType.upper, WorkoutType.lower, WorkoutType.upper]
        let exerciseNames = [["a", "b", "c"],["d", "e", "f"],["g", "h", "i"]]
        let exerciseTypes = [ExerciseType.push, ExerciseType.legs, ExerciseType.pull]
        do {
            try sut.makeProgram(program: ProgramStruct(name: name, workoutNames: workoutNames1, workoutTypes: workoutTypes, exerciseNames: exerciseNames, exerciseTypes: [exerciseTypes, exerciseTypes, exerciseTypes]))
        } catch {
            XCTFail("error shouldn't be thrown: \(error)")
        }
        do {
            try sut.makeProgram(program: ProgramStruct(name: name, workoutNames: workoutNames2, workoutTypes: workoutTypes, exerciseNames: exerciseNames, exerciseTypes: [exerciseTypes, exerciseTypes, exerciseTypes]))
        } catch {
            guard let e = error as? ProgramError else {
                XCTFail("incorrect error thrown: \(error)")
                return
            }
            XCTAssert(e == .duplicateProgram)
        }
        guard let programs = getPrograms() else {
            XCTFail()
            return
        }
        XCTAssert(programs.count == 1)
        guard let workouts = getWorkoutTemplates() else {
            XCTFail()
            return
        }
        XCTAssert(workouts.count == workoutNames1.count)
        guard let exercises = getExerciseTemplates() else {
            XCTFail()
            return
        }
        var exerciseCount = 0
        for names in exerciseNames {
            for _ in names {
                exerciseCount += 1
            }
        }
        XCTAssert(exercises.count == exerciseCount)
    }

}
