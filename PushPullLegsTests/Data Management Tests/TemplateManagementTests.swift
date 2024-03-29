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

// TODO: uniqueness of names tests

class TemplateManagementTests: XCTestCase {
    
    let dbHelper = DBHelper(coreDataStack: CoreDataTestStack())
    var sut: TemplateManagement!
    var exerciseCount: Int = 0
    var workoutCount: Int = 0
    
    override func setUp() {
        sut = TemplateManagement(coreDataManager: dbHelper.coreDataStack)
        exerciseCount = 0
        workoutCount = 0
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func addExerciseTemplate(name: String = TempName, type: ExerciseType = .push) {
        dbHelper.addExerciseTemplate(name: name, type: type, addToWorkout: true)
        exerciseCount += 1
    }
    
    func addWorkoutTemplate(type: ExerciseType = .push, exerciseNames: [String] = Names) {
        dbHelper.addWorkoutTemplate(type: type, exerciseNames: exerciseNames)
        workoutCount += 1
    }
    
    // MARK: exercise

    func testCreateExerciseTemplate_templateCreated_push() {
        try? sut.addExerciseTemplate(name: TempName, type: ExerciseType.push)
        guard let temps = try? dbHelper.coreDataStack.backgroundContext.fetch(NSFetchRequest(entityName: ExTemp)) else {
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
        guard let temps = try? dbHelper.coreDataStack.backgroundContext.fetch(NSFetchRequest(entityName: ExTemp)) else {
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
        dbHelper.coreDataStack.backgroundContext.performAndWait {
            guard let temps = try? dbHelper.coreDataStack.backgroundContext.fetch(NSFetchRequest(entityName: ExTemp)) else {
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
    }
    
    func testDeleteExerciseTemplate_templateDeleted() {
        dbHelper.addWorkoutTemplate(type: .push, exerciseNames: [TempName])
        guard
            let push = dbHelper.fetchWorkoutTemplates().first(where: { $0.name == ExerciseType.push.rawValue }),
            let temps = dbHelper.fetchExerciseTemplates() else
        {
            XCTFail()
            return
        }
        XCTAssert(push.exerciseNames!.count == 1)
        XCTAssert(temps.count == 1)
        sut.deleteExerciseTemplate(name: TempName)
        guard
            let push2 = dbHelper.fetchWorkoutTemplates().first(where: { $0.name == ExerciseType.push.rawValue }),
            let temps2 = dbHelper.fetchExerciseTemplates() else
        {
            return
        }
        XCTAssert(push2.exerciseNames!.count == 0)
        XCTAssert(temps2.count == 0)
    }
    
    func testDeleteSpecificExerciseTemplate_specificTemplateDeleted() {
        print(dbHelper.fetchExerciseTemplates()!)
        addExerciseTemplate(name: "\(ExTemp)1")
        print(dbHelper.fetchExerciseTemplates()!)
        addExerciseTemplate(name: TempName)
        print(dbHelper.fetchExerciseTemplates()!)
        addExerciseTemplate(name: "\(ExTemp)3")
        print(dbHelper.fetchExerciseTemplates()!)
        guard let temps = dbHelper.fetchExerciseTemplates() else {
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
        guard let temps2 = try? dbHelper.coreDataStack.backgroundContext.fetch(NSFetchRequest(entityName: ExTemp)) as? [ExerciseTemplate] else {
            return
        }
        XCTAssert(temps2.count == 2, "\nexpected: 2\nactual: \(temps2.count)")
        XCTAssert(temps2.contains(where: { objectsAreEqual($0, toKeep[0])}) && temps2.contains(where: { objectsAreEqual($0, toKeep[1])}))
        XCTAssert(!temps2.contains(toDelete))
    }
    
    func testGetExerciseTemplate_templateGeted() {
        addExerciseTemplate()
        guard let temps = dbHelper.fetchExerciseTemplates() else { XCTFail();return }
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
        guard let temps = dbHelper.fetchExerciseTemplates() else {
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
        XCTAssert(objectsAreEqual(tempToTest, temp))
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
        (self.dbHelper.coreDataStack.backgroundContext as! NSManagedObjectContextSpy).expectation = expectation(description: "workout template creation")
        do {
            try sut.addWorkoutTemplate(type: .push)
        } catch {
            XCTFail("error shouldn't be thrown: \(error)")
        }
        wait(for: [(self.dbHelper.coreDataStack.backgroundContext as! NSManagedObjectContextSpy).expectation!], timeout: 60)
        guard let temps = try? dbHelper.coreDataStack.backgroundContext.fetch(NSFetchRequest(entityName: WrkTemp)) else {
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
        for name in Names {
            addExerciseTemplate(name: name, type: .legs)
        }
        do {
            try sut.addWorkoutTemplate(type: .legs)
        } catch {
            guard let error = error as? TemplateError else {
                XCTFail()
                return
            }
            XCTAssert(error == TemplateError.duplicateWorkout, "error should be thrown: \(error)")
        }
        guard let temps = try? dbHelper.coreDataStack.backgroundContext.fetch(NSFetchRequest(entityName: WrkTemp)) else {
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
        let temps = dbHelper.fetchWorkoutTemplates()
        XCTAssert(temps.count == 1)
        let temp = sut.workoutTemplate(type: ExerciseType.push)
        XCTAssert(temp.name == ExerciseType.push.rawValue)
    }

    func testGetSpecificWorkoutTemplate_specificTemplateGeted() {
        addWorkoutTemplate(type: .push)
        addWorkoutTemplate(type: .pull)
        addWorkoutTemplate(type: .legs)
        let temps = dbHelper.fetchWorkoutTemplates()
        let tempToTest = sut.workoutTemplate(type: ExerciseType.pull)
        XCTAssert(temps.contains(where: { objectsAreEqual($0, tempToTest) }))
        XCTAssert(tempToTest.name == ExerciseType.pull.rawValue)
    }
    
    func testGetAllWorkoutTemplates_allTemplatesGeted() {
        addWorkoutTemplate(type: .push)
        addWorkoutTemplate(type: .pull)
        addWorkoutTemplate(type: .legs)
        let temps = dbHelper.fetchWorkoutTemplates()
        XCTAssert(temps.count == 3)
        guard let tempsToTest = sut.workoutTemplates() else {
            XCTFail()
            return
        }
        XCTAssert(tempsToTest.count == 3)
        for temp in temps {
            XCTAssert(tempsToTest.contains(where: { objectsAreEqual($0, temp) }))
        }
    }
    
    func testGetAllWorkoutTemplates_noTemplatesStored_emptyArrayGeted() {
        let temps = dbHelper.fetchWorkoutTemplates()
        XCTAssert(temps.count == 0)
        guard let tempsToTest = sut.workoutTemplates() else {
            XCTFail()
            return
        }
        XCTAssert(tempsToTest.count == 0)
    }
    
    func testGetAllExerciseTemplates_allTemplatesGeted() {
        dbHelper.coreDataStack.backgroundContext.performAndWait {
            for i in 1...6 {
                addExerciseTemplate(name: "\(TempName)\(i)")
            }
        }
        guard let temps = dbHelper.fetchExerciseTemplates() else { XCTFail();return }
        XCTAssert(temps.count == 6)
        guard let tempsToTest = sut.exerciseTemplates(withType: .push) else {
            XCTFail()
            return
        }
        XCTAssert(tempsToTest.count == 6)
        for temp in temps {
            XCTAssert(tempsToTest.contains(where: { objectsAreEqual($0, temp) }))
        }
    }
    
    func testGetAllExerciseTemplates_noTemplatesStored_emptyArrayGeted() {
        guard let temps = dbHelper.fetchExerciseTemplates() else { XCTFail();return }
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
        sut.addToWorkout(exercise: (dbHelper.fetchExerciseTemplates()?.first(where: {$0.name == "D"})!)!)
        XCTAssert(dbHelper.fetchWorkoutTemplates().first!.exerciseNames!.contains("D"))
    }
    
    func testRemoveExerciseFromWorkout() {
        addWorkoutTemplate(type: .legs, exerciseNames: ["A", "B", "C", "D"])
        XCTAssert(dbHelper.fetchWorkoutTemplates().first!.exerciseNames!.contains("D"))
        sut.removeFromWorkout(exercise: (dbHelper.fetchExerciseTemplates()?.first(where: {$0.name == "D"})!)!)
        XCTAssert(!dbHelper.fetchWorkoutTemplates().first!.exerciseNames!.contains("D"))
    }
    
    func testAddAndRemoveExerciseToFromWorkout() {
        addWorkoutTemplate(type: .legs, exerciseNames: ["A", "B", "C"])
        for i in 0...3 {
            let name = "D\(i)"
            addExerciseTemplate(name: name, type: .legs)
            XCTAssert(dbHelper.fetchWorkoutTemplates().first!.exerciseNames!.contains(name))
        }
        
        for i in 0...3 {
            let name = "D\(i)"
            sut.removeFromWorkout(exercise: (dbHelper.fetchExerciseTemplates()?.first(where: {$0.name == name})!)!)
            XCTAssert(!dbHelper.fetchWorkoutTemplates().first!.exerciseNames!.contains(name))
        }
    }
    
    func testGetExercisesForWorkoutTemplate_noExercisesInWorkoutTemplate_noExerciseTemplatesReturned() {
        XCTAssert(sut.exerciseTemplatesForWorkout(.push).count == 0)
    }

}
