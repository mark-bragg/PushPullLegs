//
//  ExerciseDataManagerTests.swift
//  PushPullLegsTests
//
//  Created by Mark Bragg on 1/27/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation
import XCTest
import CoreData
@testable import PushPullLegs

// TODO: test cascade deletion: delete workout -> exercises also deleted

func objectsAreEqual(_ obj1: NSManagedObject, _ obj2: NSManagedObject) -> Bool {
    return obj1.objectID == obj2.objectID
}

class ExerciseDataManagerTests: XCTestCase {
    
    var sut: ExerciseDataManager!
    let dbHelper = DBHelper(coreDataStack: CoreDataTestStack())
    let exerciseTestName = "exercise test name"
    
    func setExpectation(description: String) {
        let performAndWaitExpectation = expectation(description: description)
        (self.dbHelper.coreDataStack.backgroundContext as! NSManagedObjectContextSpy).expectation = performAndWaitExpectation
    }
    
    override func setUp() {
        sut = ExerciseDataManager(backgroundContext: dbHelper.coreDataStack.backgroundContext)
    }
    
    func test_createExercise_exerciseCreated() {
        setExpectation(description: "test creation exercise")
        sut.create(name: exerciseTestName)
        waitForExpectations(timeout: 60) { (_) in
            guard let exerciseOG = self.sut.creation as? Exercise, let exerciseTest = self.dbHelper.fetchExercises().first else {
                XCTFail("exercise not created")
                return
            }
            XCTAssert(objectsAreEqual(exerciseOG, exerciseTest))
            guard let name = exerciseOG.name else {
                XCTFail()
                return
            }
            XCTAssert(name == self.exerciseTestName)
        }
    }
    
    func test_deleteExercise_exerciseDeleted() {
        setExpectation(description: "test deletion exercise")
        let exercise = dbHelper.createExercise()
        sut.delete(exercise)
        waitForExpectations(timeout: 60) { (_) in
            if self.dbHelper.fetchExercises().first != nil {
                XCTFail("exercise not deleted")
            }
        }
    }
    
    func test_addSet_setAdded() {
        setExpectation(description: "add set to exercise")
        let exercise = dbHelper.createExercise()
        sut.addSet(exercise)
        waitForExpectations(timeout: 60) { (_) in
            guard let sets = self.dbHelper.fetchSets(exercise) else {
                XCTFail("set not added to exercise")
                return
            }
            XCTAssert(sets.count == 1)
        }
    }
    
    func test_deleteSet_setDeleted() {
        setExpectation(description: "delete set from exercise")
        let exercise = dbHelper.createExercise()
        let set = dbHelper.insertSet(exercise)
        sut.delete(set)
        waitForExpectations(timeout: 60) { (_) in
            guard let sets = self.dbHelper.fetchSets(exercise) else {
                XCTFail("set not added to exercise")
                return
            }
            XCTAssert(sets.count == 0)
        }
    }
    
    func test_addMultipleSets_multipleSetsAdded() {
        let exercise = dbHelper.createExercise()
        for _ in 0...9 {
            setExpectation(description: "add multiple sets to exercise")
            sut.addSet(exercise)
        }
        waitForExpectations(timeout: 60) { (_) in
            guard let sets = self.dbHelper.fetchSets(exercise) else {
                XCTFail("set not added to exercise")
                return
            }
            XCTAssert(sets.count == 10)
        }
    }
    
    func test_deleteMultipleSets_multipleSetsDeleted() {
        let exercise = dbHelper.createExercise()
        var sets = [ExerciseSet]()
        for _ in 0...9 {
            sets.append(dbHelper.insertSet(exercise))
        }
        for set in sets {
            setExpectation(description: "add multiple sets to exercise")
            sut.delete(set)
        }
        waitForExpectations(timeout: 60) { (_) in
            guard let sets = self.dbHelper.fetchSets(exercise) else {
                XCTFail("set not added to exercise")
                return
            }
            XCTAssert(sets.count == 0)
        }
    }
    
    func test_deleteSpecificSets_specificSetsDeleted() {
        let exercise = dbHelper.createExercise()
        var sets = [ExerciseSet]()
        for _ in 0...9 {
            sets.append(dbHelper.insertSet(exercise))
        }
        for i in 0...9 {
            if i % 3 == 0 {
                setExpectation(description: "add multiple sets to exercise")
                sut.delete(sets[i])
            }
        }
        waitForExpectations(timeout: 60) { (_) in
            guard let fetchedSets = self.dbHelper.fetchSets(exercise) else {
                XCTFail("set not added to exercise")
                return
            }
            XCTAssert(fetchedSets.count == 6)
            for i in 0...6 {
                XCTAssert(sets.contains(sets[i]))
            }
            
        }
    }
    
    func test_deleteSets_addMoreSets() {
        let exercise = dbHelper.createExercise()
        var sets = [ExerciseSet]()
        for _ in 0...9 {
            sets.append(dbHelper.insertSet(exercise))
        }
        for i in 0...2 {
            setExpectation(description: "delete set from exercise")
            sut.delete(sets[i])
        }
        for _ in 0...2 {
            setExpectation(description: "add to exercise")
            sut.addSet(exercise)
        }
        waitForExpectations(timeout: 60) { (_) in
            guard let fetchedSets = self.dbHelper.fetchSets(exercise) else {
                XCTFail("set not added to exercise")
                return
            }
            XCTAssert(fetchedSets.count == 10)
        }
    }
    
    func test_setReps_repsSet() {
        setExpectation(description: "set reps")
        let exercise = dbHelper.createExercise()
        let set = dbHelper.insertSet(exercise)
        sut.set(reps: 25, forSet: set)
        waitForExpectations(timeout: 60) { (_) in
            guard let set = self.dbHelper.fetchSets(exercise)?.first else {
                XCTFail("set not added to exercise")
                return
            }
            XCTAssert(set.reps == 25)
        }
    }
    
    func test_setWeight_weightSet() {
        setExpectation(description: "set weight")
        let exercise = dbHelper.createExercise()
        let set = dbHelper.insertSet(exercise)
        sut.set(weight: 25, forSet: set)
        waitForExpectations(timeout: 60) { (_) in
            guard let set = self.dbHelper.fetchSets(exercise)?.first else {
                XCTFail("set not added to exercise")
                return
            }
            XCTAssert(set.weight == 25)
        }
    }
    
    func test_setDuration_durationSet() {
        setExpectation(description: "set duration")
        let exercise = dbHelper.createExercise()
        let set = dbHelper.insertSet(exercise)
        sut.set(duration: 25, forSet: set)
        waitForExpectations(timeout: 60) { (_) in
            guard let set = self.dbHelper.fetchSets(exercise)?.first else {
                XCTFail("set not added to exercise")
                return
            }
            XCTAssert(set.duration == 25)
        }
    }
    
    func test_addCompletedSet_setAdded_durationWeightRepsSet() {
        setExpectation(description: "add completed set")
        let exercise = dbHelper.createExercise()
        sut.insertSet(duration: 25, weight: 135, reps: 12, exercise: exercise) { exerciseSet in
            
        }
        waitForExpectations(timeout: 60) { (_) in
            guard let set = self.dbHelper.fetchSets(exercise)?.first else {
                XCTFail("set not added to exercise")
                return
            }
            XCTAssert(set.duration == 25)
            XCTAssert(set.weight == 135)
            XCTAssert(set.reps == 12)
        }
    }
    
}
