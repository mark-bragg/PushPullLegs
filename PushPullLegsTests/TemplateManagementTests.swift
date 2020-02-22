//
//  TemplateManagementTests.swift
//  PushPullLegsTests
//
//  Created by Mark Bragg on 2/16/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import XCTest
import CoreData

@testable import PushPullLegs

let ExTemp = "ExerciseTemplate"
let TempName = "TestTemplateName"
let WrkTemp = "WorkoutTemplate"
let Names = ["ex1", "ex2", "ex3"]

// TODO: uniqueness of names tests

class TemplateManagementTests: XCTestCase {
    
    var coreDataStack: CoreDataTestStack!
    var sut: TemplateManagement!
    var count: Int = 0
    
    override func setUp() {
        coreDataStack = CoreDataTestStack()
        sut = TemplateManagement(backgroundContext: coreDataStack.backgroundContext)
        count = 0
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func exerciseTemplates() -> [ExerciseTemplate]? {
        if let temps = try? coreDataStack.backgroundContext.fetch(NSFetchRequest(entityName: ExTemp)) as? [ExerciseTemplate] {
            return temps
        }
        return nil
    }
    
    func addExerciseTemplate(name: String = TempName, type: ExerciseType = .push) {
        let temp = NSEntityDescription.insertNewObject(forEntityName: ExTemp, into: coreDataStack.backgroundContext) as! ExerciseTemplate
        temp.name = name
        temp.type = type.rawValue
        try? coreDataStack.backgroundContext.save()
        if let temps = exerciseTemplates() {
            count += 1
            XCTAssert(temps.count == count)
        }
    }
    
    func workoutTemplates() -> [WorkoutTemplate]? {
        if let temps = try? coreDataStack.backgroundContext.fetch(NSFetchRequest(entityName: WrkTemp)) as? [WorkoutTemplate] {
            return temps
        }
        return nil
    }
    
    func addWorkoutTemplate(name: String = TempName, type: WorkoutType = .upper, exerciseNames: [String] = Names) {
        let temp = NSEntityDescription.insertNewObject(forEntityName: WrkTemp, into: coreDataStack.backgroundContext) as! WorkoutTemplate
        temp.name = name
        temp.type = type.rawValue
        temp.exerciseNames = exerciseNames
        try? coreDataStack.backgroundContext.save()
        if let temps = workoutTemplates() {
            count += 1
            XCTAssert(temps.count == count)
        }
    }
    
    // MARK: exercise

    func testCreateExerciseTemplate_templateCreated_push() {
        try? sut.addExerciseTemplate(name: TempName, type: ExerciseType.push)
        guard let temps = try? coreDataStack.backgroundContext.fetch(NSFetchRequest(entityName: ExTemp)) else {
            XCTFail()
            return
        }
        XCTAssert(temps.count == 1)
        guard let temp = temps.first as? ExerciseTemplate else {
            XCTFail()
            return
        }
        XCTAssert(temp.name == TempName)
        XCTAssert(temp.type == ExerciseType.push.rawValue)
    }
    
    func testCreateExerciseTemplate_templateCreated_pull() {
        try? sut.addExerciseTemplate(name: TempName, type: ExerciseType.pull)
        guard let temps = try? coreDataStack.backgroundContext.fetch(NSFetchRequest(entityName: ExTemp)) else {
            XCTFail()
            return
        }
        XCTAssert(temps.count == 1)
        guard let temp = temps.first as? ExerciseTemplate else {
            XCTFail()
            return
        }
        XCTAssert(temp.name == TempName)
        XCTAssert(temp.type == ExerciseType.pull.rawValue)
    }
    
    func testCreateExerciseTemplate_templateCreated_legs() {
        try? sut.addExerciseTemplate(name: TempName, type: ExerciseType.legs)
        guard let temps = try? coreDataStack.backgroundContext.fetch(NSFetchRequest(entityName: ExTemp)) else {
            XCTFail()
            return
        }
        XCTAssert(temps.count == 1)
        guard let temp = temps.first as? ExerciseTemplate else {
            XCTFail()
            return
        }
        XCTAssert(temp.name == TempName)
        XCTAssert(temp.type == ExerciseType.legs.rawValue)
    }
    
    func testDeleteExerciseTemplate_templateDeleted() {
        addExerciseTemplate()
        guard let temps = exerciseTemplates() else {
            XCTFail()
            return
        }
        XCTAssert(temps.count == 1)
        sut.deleteExerciseTemplate(name: TempName)
        guard let temps2 = exerciseTemplates() else {
            return
        }
        XCTAssert(temps2.count == 0)
    }
    
    func testDeleteSpecificExerciseTemplate_specificTemplateDeleted() {
        addExerciseTemplate(name: "\(ExTemp)1")
        addExerciseTemplate(name: TempName)
        addExerciseTemplate(name: "\(ExTemp)3")
        guard let temps = exerciseTemplates() else {
            XCTFail()
            return
        }
        let toDelete = temps.filter { (temp) -> Bool in
            temp.name == TempName
        }.first!
        let toKeep = temps.filter { (temp) -> Bool in
            temp.name != TempName
        }
        sut.deleteExerciseTemplate(name: TempName)
        guard let temps2 = try? coreDataStack.backgroundContext.fetch(NSFetchRequest(entityName: ExTemp)) as? [ExerciseTemplate] else {
            return
        }
        XCTAssert(temps2.count == 2)
        XCTAssert(temps2.contains(toKeep[0]) && temps2.contains(toKeep[1]))
        XCTAssert(!temps2.contains(toDelete))
    }
    
    func testGetExerciseTemplate_templateGeted() {
        addExerciseTemplate()
        guard let temps = exerciseTemplates() else { XCTFail();return }
        XCTAssert(temps.count == 1)
        guard let temp = sut.exerciseTemplate(name: TempName) else {
            XCTFail()
            return
        }
        XCTAssert(temp.name == TempName)
    }
    
    func testGetSpecificExerciseTemplate_specificTemplateGeted() {
        addExerciseTemplate(name: "\(ExTemp)1")
        addExerciseTemplate(name: TempName)
        addExerciseTemplate(name: "\(ExTemp)2")
        guard let temps = exerciseTemplates() else {
            XCTFail()
            return
        }
        let temp = temps.filter { (temp) -> Bool in
            temp.name == TempName
        }.first!
        guard let tempToTest = sut.exerciseTemplate(name: TempName) else {
            XCTFail()
            return
        }
        XCTAssert(tempToTest == temp)
    }
    
    func testCreateDuplicateExerciseTemplates_errorThrown() {
        addExerciseTemplate(name: TempName, type: ExerciseType.legs)
        do {
            try sut.addExerciseTemplate(name: TempName, type: ExerciseType.legs)
        } catch {
            guard let e = error as? TemplateError else {
                XCTFail("incorrect error thrown with duplicate exercise templates")
                return
            }
            XCTAssert(e == .duplicateExercise)
            return
        }
        XCTFail("didn't throw error duplicate exercise")
    }

    // MARK: workout
    
    func testCreateWorkoutTemplate_templateCreated_typeUpper() {
        coreDataStack.backgroundContext.expectation = expectation(description: "workout template creation")
        do {
            try sut.addWorkoutTemplate(name:TempName, type: WorkoutType.upper, exerciseNames: Names)
        } catch {
            XCTFail("error shouldn't be thrown: \(error)")
        }
        wait(for: [coreDataStack.backgroundContext.expectation!], timeout: 60)
        guard let temps = try? coreDataStack.backgroundContext.fetch(NSFetchRequest(entityName: WrkTemp)) else {
            XCTFail()
            return
        }
        XCTAssert(temps.count == 1)
        guard let temp = temps.first as? WorkoutTemplate else {
            XCTFail()
            return
        }
        XCTAssert(temp.name == TempName)
        XCTAssert(temp.type == WorkoutType.upper.rawValue)
        for name in Names {
            XCTAssert((temp.exerciseNames?.contains(name))!)
        }
    }
    
    func testCreateWorkoutTemplate_templateCreated_typeLower() {
        coreDataStack.backgroundContext.expectation = expectation(description: "workout template creation")
        do {
            try sut.addWorkoutTemplate(name:TempName, type: WorkoutType.lower, exerciseNames: Names)
        } catch {
            XCTFail("error shouldn't be thrown: \(error)")
        }
        wait(for: [coreDataStack.backgroundContext.expectation!], timeout: 60)
        guard let temps = try? coreDataStack.backgroundContext.fetch(NSFetchRequest(entityName: WrkTemp)) else {
            XCTFail()
            return
        }
        XCTAssert(temps.count == 1)
        guard let temp = temps.first as? WorkoutTemplate else {
            XCTFail()
            return
        }
        XCTAssert(temp.name == TempName)
        XCTAssert(temp.type == WorkoutType.lower.rawValue)
        for name in Names {
            XCTAssert((temp.exerciseNames?.contains(name))!)
        }
    }

    func testDeleteWorkoutTemplate_templateDeleted() {
        addWorkoutTemplate()
        guard let temps = workoutTemplates() else {
            XCTFail()
            return
        }
        XCTAssert(temps.count == 1)
        sut.deleteWorkoutTemplate(name: TempName)
        guard let temps2 = workoutTemplates() else {
            return
        }
        XCTAssert(temps2.count == 0)
    }

    func testDeleteSpecificWorkoutTemplate_specificTemplateDeleted() {
        addWorkoutTemplate(name: "\(TempName)1")
        addWorkoutTemplate(name: TempName)
        addWorkoutTemplate(name: "\(TempName)3")
        guard let temps = workoutTemplates() else {
            XCTFail()
            return
        }
        let toDelete = temps.filter { (temp) -> Bool in
            temp.name == TempName
        }.first!
        let toKeep = temps.filter { (temp) -> Bool in
            temp.name != TempName
        }
        sut.deleteWorkoutTemplate(name: TempName)
        guard let temps2 = try? coreDataStack.backgroundContext.fetch(NSFetchRequest(entityName: WrkTemp)) as? [WorkoutTemplate] else {
            return
        }
        XCTAssert(temps2.count == 2)
        XCTAssert(temps2.contains(toKeep[0]) && temps2.contains(toKeep[1]))
        XCTAssert(!temps2.contains(toDelete))
    }

    func testGetWorkoutTemplate_templateGeted() {
        addWorkoutTemplate()
        guard let temps = workoutTemplates() else { XCTFail();return }
        XCTAssert(temps.count == 1)
        guard let temp = sut.workoutTemplate(name: TempName) else {
            XCTFail()
            return
        }
        XCTAssert(temp.name == TempName)
    }

    func testGetSpecificWorkoutTemplate_specificTemplateGeted() {
        addWorkoutTemplate(name: "\(TempName)1")
        addWorkoutTemplate(name: TempName)
        addWorkoutTemplate(name: "\(TempName)3")
        guard let temps = workoutTemplates() else {
            XCTFail()
            return
        }
        let toGet = temps.filter { (temp) -> Bool in
            temp.name == TempName
        }.first!
        guard let tempToTest = sut.workoutTemplate(name: TempName) else {
            XCTFail()
            return
        }
        XCTAssert(tempToTest == toGet)
    }
    
    func testAddDupes_errorThrown() {
        addWorkoutTemplate(name: TempName, type: .lower, exerciseNames: ["A", "B", "C"])
        do {
            try sut.addWorkoutTemplate(name: TempName, type: .lower, exerciseNames: ["A", "B", "C"])
        } catch {
            guard let e = error as? TemplateError else {
                XCTFail("incorrect error thrown: \(error)")
                return
            }
            XCTAssert(e == .duplicateWorkout)
            return
        }
        XCTFail("didn't throw error duplicate workout")
    }

}
