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
    var exerciseCount: Int = 0
    var workoutCount: Int = 0
    
    override func setUp() {
        coreDataStack = CoreDataTestStack()
        sut = TemplateManagement(backgroundContext: coreDataStack.backgroundContext)
        exerciseCount = 0
        workoutCount = 0
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
            exerciseCount += 1
            XCTAssert(temps.count == exerciseCount)
        }
    }
    
    func workoutTemplates() -> [WorkoutTemplate]? {
        if let temps = try? coreDataStack.backgroundContext.fetch(NSFetchRequest(entityName: WrkTemp)) as? [WorkoutTemplate] {
            return temps
        }
        return nil
    }
    
    func addWorkoutTemplate(type: ExerciseType = .push, exerciseNames: [String] = Names) {
        let temp = NSEntityDescription.insertNewObject(forEntityName: WrkTemp, into: coreDataStack.backgroundContext) as! WorkoutTemplate
        temp.name = type.rawValue
        temp.exerciseNames = exerciseNames
        try? coreDataStack.backgroundContext.save()
        if let temps = workoutTemplates() {
            workoutCount += 1
            XCTAssert(temps.count == workoutCount)
        }
        for name in exerciseNames {
            addExerciseTemplate(name: name, type: type)
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
    
    func testCreatePushWorkoutTemplate_templateCreated() {
        coreDataStack.backgroundContext.expectation = expectation(description: "workout template creation")
        do {
            try sut.addWorkoutTemplate(type: .push)
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
        XCTAssert(temp.name == ExerciseType.push.rawValue)
    }
    
    func testCreateLegsWorkoutTemplate_templateCreated() {
        coreDataStack.backgroundContext.expectation = expectation(description: "workout template creation")
        for name in Names {
            addExerciseTemplate(name: name, type: .legs)
        }
        do {
            try sut.addWorkoutTemplate(type: .legs)
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
        XCTAssert(temp.name == ExerciseType.legs.rawValue)
    }

    func testGetWorkoutTemplate_templateGeted() {
        addWorkoutTemplate(type: .push)
        guard let temps = workoutTemplates() else { XCTFail();return }
        XCTAssert(temps.count == 1)
        let temp = sut.workoutTemplate(type: ExerciseType.push)
        XCTAssert(temp.name == ExerciseType.push.rawValue)
    }

    func testGetSpecificWorkoutTemplate_specificTemplateGeted() {
        addWorkoutTemplate(type: .push)
        addWorkoutTemplate(type: .pull)
        addWorkoutTemplate(type: .legs)
        guard let temps = workoutTemplates() else {
            XCTFail()
            return
        }
        let tempToTest = sut.workoutTemplate(type: ExerciseType.pull)
        XCTAssert(temps.contains(tempToTest))
        XCTAssert(tempToTest.name == ExerciseType.pull.rawValue)
    }
    
    func testGetAllWorkoutTemplates_allTemplatesGeted() {
        addWorkoutTemplate(type: .push)
        addWorkoutTemplate(type: .pull)
        addWorkoutTemplate(type: .legs)
        guard let temps = workoutTemplates() else { XCTFail();return }
        XCTAssert(temps.count == 3)
        guard let tempsToTest = sut.workoutTemplates() else {
            XCTFail()
            return
        }
        XCTAssert(tempsToTest.count == 3)
        for temp in temps {
            XCTAssert(tempsToTest.contains(temp))
        }
    }
    
    func testGetAllWorkoutTemplates_noTemplatesStored_emptyArrayGeted() {
        guard let temps = workoutTemplates() else { XCTFail();return }
        XCTAssert(temps.count == 0)
        guard let tempsToTest = sut.workoutTemplates() else {
            XCTFail()
            return
        }
        XCTAssert(tempsToTest.count == 0)
    }
    
    func testGetAllExerciseTemplates_allTemplatesGeted() {
        addExerciseTemplate(name: "\(TempName)1")
        addExerciseTemplate(name: "\(TempName)2")
        addExerciseTemplate(name: "\(TempName)3")
        addExerciseTemplate(name: "\(TempName)4")
        addExerciseTemplate(name: "\(TempName)5")
        addExerciseTemplate(name: "\(TempName)6")
        guard let temps = exerciseTemplates() else { XCTFail();return }
        XCTAssert(temps.count == 6)
        guard let tempsToTest = sut.exerciseTemplates(withType: .push) else {
            XCTFail()
            return
        }
        XCTAssert(tempsToTest.count == 6)
        for temp in temps {
            XCTAssert(tempsToTest.contains(temp))
        }
    }
    
    func testGetAllExerciseTemplates_noTemplatesStored_emptyArrayGeted() {
        guard let temps = exerciseTemplates() else { XCTFail();return }
        XCTAssert(temps.count == 0)
        var tempsToTest = [ExerciseTemplate]()
        for type in [ExerciseType.push, ExerciseType.pull, ExerciseType.legs] {
            guard let tempsToAdd = sut.exerciseTemplates(withType: type) else {
                XCTFail()
                return
            }
            for temp in tempsToAdd {
                tempsToTest.append(temp)
            }
        }
        
        XCTAssert(tempsToTest.count == 0)
    }
    
    func testAddDupes_errorThrown() {
        addWorkoutTemplate(type: .legs, exerciseNames: ["A", "B", "C"])
        addExerciseTemplate(name: "A", type: .legs)
        addExerciseTemplate(name: "B", type: .legs)
        addExerciseTemplate(name: "C", type: .legs)
        do {
            try sut.addWorkoutTemplate(type: .legs)
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
    
    func testAddExerciseToWorkout() {
        addWorkoutTemplate(type: .legs, exerciseNames: ["A", "B", "C"])
        addExerciseTemplate(name: "D", type: .legs)
        sut.addToWorkout(exercise: (exerciseTemplates()?.first(where: {$0.name == "D"})!)!)
        XCTAssert(workoutTemplates()!.first!.exerciseNames!.contains("D"))
    }
    
    func testRemoveExerciseFromWorkout() {
        addWorkoutTemplate(type: .legs, exerciseNames: ["A", "B", "C", "D"])
        XCTAssert(workoutTemplates()!.first!.exerciseNames!.contains("D"))
        sut.removeFromWorkout(exercise: (exerciseTemplates()?.first(where: {$0.name == "D"})!)!)
        XCTAssert(!workoutTemplates()!.first!.exerciseNames!.contains("D"))
    }
    
    func testAddAndRemoveExerciseToFromWorkout() {
        addWorkoutTemplate(type: .legs, exerciseNames: ["A", "B", "C"])
        for i in 0...3 {
            let name = "D\(i)"
            addExerciseTemplate(name: name, type: .legs)
            sut.addToWorkout(exercise: (exerciseTemplates()?.first(where: {$0.name == name})!)!)
            XCTAssert(workoutTemplates()!.first!.exerciseNames!.contains(name))
        }
        
        for i in 0...3 {
            let name = "D\(i)"
            sut.removeFromWorkout(exercise: (exerciseTemplates()?.first(where: {$0.name == name})!)!)
            XCTAssert(!workoutTemplates()!.first!.exerciseNames!.contains(name))
        }
    }

}
