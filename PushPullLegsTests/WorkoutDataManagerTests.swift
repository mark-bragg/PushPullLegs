//
//  WorkoutDataManager.swift
//  PushPullLegsTests
//
//  Created by Mark Bragg on 1/26/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation
import XCTest
import CoreData
@testable import PushPullLegs


class WorkoutDataManagerTests : XCTestCase {
    var sut: WorkoutDataManager!
    var coreDataStack: CoreDataTestStack!
    static let workoutTestName = "test workout name"
    static let exerciseTestName = "test exercise name"
    
    override func setUp() {
        coreDataStack = CoreDataTestStack()
        sut = WorkoutDataManager(backgroundContext: coreDataStack.backgroundContext)
    }
    
    func fetchWorkouts() -> [Workout] {
        let request = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Workout")
        let workouts = try! self.coreDataStack.backgroundContext.fetch(request)
        return workouts as! [Workout]
    }
    
    func fetchExercises(workout: Workout) -> [Exercise] {
        if let workoutInContext = try? coreDataStack.backgroundContext.existingObject(with: workout.objectID) as? Workout {
            return (workoutInContext.exercises?.array as? [Exercise])!
        }
        XCTFail("workout missing")
        return []
    }
    
    func insertWorkout(name: String = workoutTestName) -> Workout {
        let workout = NSEntityDescription.insertNewObject(forEntityName: "Workout", into: coreDataStack.backgroundContext) as! Workout
        workout.name = name
        try? coreDataStack.backgroundContext.save()
        return workout
    }
    
    func insertExercise() -> Exercise {
        let exercise = NSEntityDescription.insertNewObject(forEntityName: "Exercise", into: coreDataStack.backgroundContext) as! Exercise
        try? coreDataStack.backgroundContext.save()
        return exercise
    }
    
    func setExpectation(description: String) {
        let performAndWaitExpectation = expectation(description: description)
        coreDataStack.backgroundContext.expectation = performAndWaitExpectation
    }
    
    func add(_ exercise: Exercise, to workout: Workout) {
        workout.addToExercises(exercise)
        try? coreDataStack.backgroundContext.save()
    }
    
    func test_createWorkout_workoutCreated() {
        setExpectation(description: "background perform and wait")
        sut.create(name: WorkoutDataManagerTests.workoutTestName)
        waitForExpectations(timeout: 60) { (_) in
            let workouts = self.fetchWorkouts()
            guard let workout = workouts.first, let exercises = workout.exercises else {
                XCTFail("workout missing/exercises missing")
                return
            }
            XCTAssert(workouts.count == 1)
            XCTAssert(exercises.count == 0)
            XCTAssert(self.coreDataStack.backgroundContext.saveWasCalled)
            guard let name = workout.name else {
                XCTFail()
                return
            }
            XCTAssert(name == WorkoutDataManagerTests.workoutTestName)
        }
    }
    
    func test_deleteWorkout_workoutDeleted() {
        setExpectation(description: "background perform and wait")
        let workout1 = insertWorkout()
        let workout2 = insertWorkout()
        let workout3 = insertWorkout()
        
        sut.delete(workout2)
        
        waitForExpectations(timeout: 60) { (_) in
            let backgroundContextWorkouts = self.fetchWorkouts()
            XCTAssert(backgroundContextWorkouts.count == 2)
            XCTAssert(backgroundContextWorkouts.contains(workout1) && backgroundContextWorkouts.contains(workout3))
            XCTAssert(self.coreDataStack.backgroundContext.saveWasCalled)
        }
    }
    
    func test_deleteWorkout_switchingContexts_workoutDeleted() {
        setExpectation(description: "background perform and wait")
        let workout1 = insertWorkout()
        let workout2 = insertWorkout()
        let workout3 = insertWorkout()
        let mainContextWorkout = coreDataStack.mainContext.object(with: workout2.objectID)
        sut.delete(mainContextWorkout)
        
        waitForExpectations(timeout: 60) { (_) in
            let backgroundContextWorkouts = self.fetchWorkouts()
            XCTAssert(backgroundContextWorkouts.count == 2)
            XCTAssert(backgroundContextWorkouts.contains(workout1) && backgroundContextWorkouts.contains(workout3))
            XCTAssert(self.coreDataStack.backgroundContext.saveWasCalled)
        }
    }
    
    func test_addExercise_exerciseAdded() {
        setExpectation(description: "background perform and wait")
        let exerciseOriginal = insertExercise()
        sut.create(name: WorkoutDataManagerTests.workoutTestName)
        waitForExpectations(timeout: 60)
        guard let workout = sut.creation as? Workout else {
            XCTFail("nil workout assignment to property creation")
            return
        }
        setExpectation(description: "add exercise perform and wait")
        sut.add(exerciseOriginal, to: workout)
        waitForExpectations(timeout: 60) { (_) in
            guard let workout = self.fetchWorkouts().first else {
                XCTFail("workout not in context")
                return
            }
            XCTAssert(workout.exercises?.count == 1)
            let exerciseToTest = workout.exercises?.firstObject as! Exercise
            XCTAssert(exerciseToTest == exerciseOriginal)
        }
    }
    
    func test_addExercise_switchingContexts_exerciseAdded() {
        setExpectation(description: "background perform and wait")
        let exerciseOriginal = insertExercise()
        sut.create(name: WorkoutDataManagerTests.workoutTestName)
        waitForExpectations(timeout: 60)
        guard let workout = sut.creation as? Workout else {
            XCTFail("nil workout assignment to property creation")
            return
        }
        setExpectation(description: "add exercise perform and wait")
        let mainContextWorkout = coreDataStack.mainContext.object(with: workout.objectID) as! Workout
        sut.add(exerciseOriginal, to: mainContextWorkout)
        waitForExpectations(timeout: 60) { (_) in
            guard let workout = self.fetchWorkouts().first else {
                XCTFail("workout not in context")
                return
            }
            XCTAssert(workout.exercises?.count == 1)
            let exerciseToTest = workout.exercises?.firstObject as! Exercise
            XCTAssert(exerciseToTest == exerciseOriginal)
        }
    }
    
    func test_deleteExercise_exerciseDeleted() {
        let exerciseOriginal = insertExercise()
        let workoutOriginal = insertWorkout()
        add(exerciseOriginal, to: workoutOriginal)
        setExpectation(description: "add exercise perform and wait")
        sut.delete(exerciseOriginal)
        waitForExpectations(timeout: 60) { (_) in
            guard let workout = self.fetchWorkouts().first else {
                XCTFail("workout not in context")
                return
            }
            XCTAssert(workout.exercises?.count == 0)
        }
    }
    
    func test_addMultipleExercises_multipleExercisesAdded() {
        setExpectation(description: "background perform and wait")
        sut.create(name: WorkoutDataManagerTests.workoutTestName)
        waitForExpectations(timeout: 60)
        guard let workout = sut.creation as? Workout else {
            XCTFail("nil workout assignment to property creation")
            return
        }
        for _ in 0...9 {
            setExpectation(description: "add exercise perform and wait")
            sut.add(insertExercise(), to: workout)
        }
        waitForExpectations(timeout: 60) { (_) in
            guard let workout = self.fetchWorkouts().first else {
                XCTFail("workout not in context")
                return
            }
            XCTAssert(workout.exercises?.count == 10)
        }
    }
    
    func test_deleteMultipleExercises_multipleExercisesDeleted() {
        let workout = insertWorkout()
        for _ in 0...9 {
            add(insertExercise(), to: workout)
        }
        guard let exercises = workout.exercises?.array as? [Exercise] else {
            XCTFail()
            return
        }
        XCTAssert(workout.exercises?.count == 10)
        for exercise in exercises {
            setExpectation(description: "delete exercise")
            sut.delete(exercise)
        }
        
        waitForExpectations(timeout: 60) { (_) in
            guard let workout = self.fetchWorkouts().first else {
                XCTFail("workout not in context")
                return
            }
            XCTAssert(workout.exercises?.count == 0)
        }
    }
    
    func test_deleteSpecificExercises_specificExercisesDeleted() {
        let workout = insertWorkout()
        for _ in 0...9 {
            add(insertExercise(), to: workout)
        }
        guard let exercises = workout.exercises?.array as? [Exercise] else {
            XCTFail()
            return
        }
        XCTAssert(workout.exercises?.count == 10)
        let exercisesDeleted = exercises[0...2]
        for i in 0...2 {
            setExpectation(description: "delete exercise")
            sut.delete(exercises[i])
        }
        
        waitForExpectations(timeout: 60) { (_) in
            guard let workout = self.fetchWorkouts().first else {
                XCTFail("workout not in context")
                return
            }
            XCTAssert(workout.exercises?.count == 7)
            guard let exercises = workout.exercises?.array as? [Exercise] else {
                XCTFail()
                return
            }
            for deletedExercise in exercisesDeleted {
                XCTAssert(!exercises.contains(deletedExercise))
            }
        }
    }

}
