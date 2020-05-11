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
    static let workoutTestName = "test workout name"
    static let exerciseTestName = "test exercise name"
    let dbHelper = DBHelper(coreDataStack: CoreDataTestStack())
    
    override func setUp() {
        self.dbHelper.coreDataStack = CoreDataTestStack()
        sut = WorkoutDataManager(backgroundContext: self.dbHelper.coreDataStack.backgroundContext)
    }
    
    func setExpectation(description: String) {
        let performAndWaitExpectation = expectation(description: description)
        (self.dbHelper.coreDataStack.backgroundContext as! NSManagedObjectContextSpy).expectation = performAndWaitExpectation
    }
    
    func add(_ exercise: Exercise, to workout: Workout) {
        workout.addToExercises(exercise)
        try? self.dbHelper.coreDataStack.backgroundContext.save()
    }
    
    func test_createWorkout_workoutCreated() {
        setExpectation(description: "background perform and wait")
        sut.create(name: WorkoutDataManagerTests.workoutTestName)
        waitForExpectations(timeout: 60) { (_) in
            let workouts = self.dbHelper.fetchWorkouts()
            guard let workout = workouts.first, let exercises = workout.exercises else {
                XCTFail("workout missing/exercises missing")
                return
            }
            XCTAssert(workouts.count == 1)
            XCTAssert(exercises.count == 0)
            XCTAssert((self.dbHelper.coreDataStack.backgroundContext as! NSManagedObjectContextSpy).saveWasCalled)
            guard let name = workout.name else {
                XCTFail()
                return
            }
            XCTAssert(name == WorkoutDataManagerTests.workoutTestName)
        }
    }
    
    func test_deleteWorkout_workoutDeleted() {
        setExpectation(description: "background perform and wait")
        let workout1 = dbHelper.createWorkout()
        let workout2 = dbHelper.createWorkout()
        let workout3 = dbHelper.createWorkout()
        
        sut.delete(workout2)
        
        waitForExpectations(timeout: 60) { (_) in
            let backgroundContextWorkouts = self.dbHelper.fetchWorkoutsBackground()
            for wkt in backgroundContextWorkouts {
                let _ = wkt.name
            }
            XCTAssert(backgroundContextWorkouts.count == 2)
            XCTAssert(backgroundContextWorkouts.contains(workout1) && backgroundContextWorkouts.contains(workout3))
            XCTAssert((self.dbHelper.coreDataStack.backgroundContext as! NSManagedObjectContextSpy).saveWasCalled)
        }
    }
    
    func test_deleteWorkout_switchingContexts_workoutDeleted() {
        setExpectation(description: "background perform and wait")
        let workout1 = dbHelper.createWorkout()
        let workout2 = dbHelper.createWorkout()
        let workout3 = dbHelper.createWorkout()
        let mainContextWorkout = self.dbHelper.coreDataStack.mainContext.object(with: workout2.objectID)
        sut.delete(mainContextWorkout)
        
        waitForExpectations(timeout: 60) { (_) in
            let backgroundContextWorkouts = self.dbHelper.fetchWorkoutsBackground()
            XCTAssert(backgroundContextWorkouts.count == 2)
            XCTAssert(backgroundContextWorkouts.contains(workout1) && backgroundContextWorkouts.contains(workout3))
            XCTAssert((self.dbHelper.coreDataStack.backgroundContext as! NSManagedObjectContextSpy).saveWasCalled)
        }
    }
    
    func test_addExercise_exerciseAdded() {
        setExpectation(description: "background perform and wait")
        let exerciseOriginal = dbHelper.createExercise()
        sut.create(name: WorkoutDataManagerTests.workoutTestName)
        waitForExpectations(timeout: 60)
        guard let workout = sut.creation as? Workout else {
            XCTFail("nil workout assignment to property creation")
            return
        }
        setExpectation(description: "add exercise perform and wait")
        sut.add(exerciseOriginal, to: workout)
        waitForExpectations(timeout: 60) { (_) in
            guard let workout = self.dbHelper.fetchWorkouts().first else {
                XCTFail("workout not in context")
                return
            }
            XCTAssert(workout.exercises?.count == 1)
            let exerciseToTest = workout.exercises?.firstObject as! Exercise
            XCTAssert(objectsAreEqual(exerciseToTest, exerciseOriginal))
        }
    }
    
    func test_addExercise_switchingContexts_exerciseAdded() {
        setExpectation(description: "background perform and wait")
        let exerciseOriginal = dbHelper.createExercise()
        sut.create(name: WorkoutDataManagerTests.workoutTestName)
        waitForExpectations(timeout: 60)
        guard let workout = sut.creation as? Workout else {
            XCTFail("nil workout assignment to property creation")
            return
        }
        setExpectation(description: "add exercise perform and wait")
        let mainContextWorkout = self.dbHelper.coreDataStack.mainContext.object(with: workout.objectID) as! Workout
        sut.add(exerciseOriginal, to: mainContextWorkout)
        waitForExpectations(timeout: 60) { (_) in
            guard let workout = self.dbHelper.fetchWorkouts().first else {
                XCTFail("workout not in context")
                return
            }
            XCTAssert(workout.exercises?.count == 1)
            let exerciseToTest = workout.exercises?.firstObject as! Exercise
            XCTAssert(objectsAreEqual(exerciseToTest, exerciseOriginal))
        }
    }
    
    func test_deleteExercise_exerciseDeleted() {
        let exerciseOriginal = dbHelper.createExercise()
        let workoutOriginal = dbHelper.createWorkout()
        add(exerciseOriginal, to: workoutOriginal)
        setExpectation(description: "add exercise perform and wait")
        sut.delete(exerciseOriginal)
        waitForExpectations(timeout: 60) { (_) in
            guard let workout = self.dbHelper.fetchWorkouts().first else {
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
            sut.add(dbHelper.createExercise(), to: workout)
        }
        waitForExpectations(timeout: 60) { (_) in
            guard let workout = self.dbHelper.fetchWorkouts().first else {
                XCTFail("workout not in context")
                return
            }
            XCTAssert(workout.exercises?.count == 10)
        }
    }
    
    func test_deleteMultipleExercises_multipleExercisesDeleted() {
        let workout = dbHelper.createWorkout()
        for _ in 0...9 {
            add(dbHelper.createExercise(), to: workout)
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
            guard let workout = self.dbHelper.fetchWorkouts().first else {
                XCTFail("workout not in context")
                return
            }
            XCTAssert(workout.exercises?.count == 0)
        }
    }
    
    func test_deleteSpecificExercises_specificExercisesDeleted() {
        let workout = dbHelper.createWorkout()
        for _ in 0...9 {
            add(dbHelper.createExercise(), to: workout)
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
            guard let workout = self.dbHelper.fetchWorkouts().first else {
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
    
    func testGetLastWorkoutType_noWorkoutsSaved_nilReturned() {
        XCTAssert(sut.getLastWorkoutType() == .error)
    }
    
    func testGetLastWorkoutType_onePushSaved_pushReturned() {
        let workout = dbHelper.createWorkout(name: .push)
        workout.dateCreated = Date()
        try? self.dbHelper.coreDataStack.backgroundContext.save()
        XCTAssert(sut.getLastWorkoutType() == .push)
    }
    
    func testGetLastWorkoutType_onePushOnePullSaved_pullReturned() {
        for type in [ExerciseType.push, ExerciseType.pull] {
            let workout = dbHelper.createWorkout(name: type)
            workout.dateCreated = Date()
        }
        try? self.dbHelper.coreDataStack.backgroundContext.save()
        XCTAssert(sut.getLastWorkoutType() == .pull)
    }
    
    func testGetLastWorkoutType_onePushOnePullOneLegsSaved_pullReturned() {
        for type in [ExerciseType.push, ExerciseType.pull, ExerciseType.legs] {
            let workout = dbHelper.createWorkout(name: type)
            workout.dateCreated = Date()
        }
        try? self.dbHelper.coreDataStack.backgroundContext.save()
        XCTAssert(sut.getLastWorkoutType() == .legs)
    }
    
    func testGetLastWorkoutType_PushPullLegsPushSaved_pushReturned() {
        for type in [ExerciseType.push, ExerciseType.pull, ExerciseType.legs, ExerciseType.push] {
            let workout = dbHelper.createWorkout(name: type)
            workout.dateCreated = Date()
        }
        try? self.dbHelper.coreDataStack.backgroundContext.save()
        XCTAssert(sut.getLastWorkoutType() == .push)
    }
    
    func testWorkouts_zeroWorkouts() {
        XCTAssert(sut.workouts().count == 0)
    }
    
    func testWorkouts_tenWorkouts_sameName() {
        for _ in 0...9 {
            sut.add(dbHelper.createExercise(), to: dbHelper.createWorkout())
        }
        let workouts = sut.workouts()
        XCTAssert(workouts.count == 10)
    }
    
    func testGetPreviousWorkout_twoWorkouts_firstWorkoutReturned() {
        let date = Date()
        sut.add(dbHelper.createExercise("exercise"), to: dbHelper.createWorkout(name: .push, date: date))
        sut.add(dbHelper.createExercise("exercise"), to: dbHelper.createWorkout(name: .push, date: date.addingTimeInterval(60 * 60 * 24)))
        XCTAssert(sut.workouts().count == 2)
        guard let previousWorkout = sut.previousWorkout() else {
            XCTFail()
            return
        }
        let workouts = dbHelper.fetchWorkouts().sorted(by: { $0.dateCreated! > $1.dateCreated! })
        XCTAssert(previousWorkout.objectID == workouts[1].objectID)
    }
    
    func testGetPreviousWorkout_tenWorkouts_ninthWorkoutReturned() {
        var date = Date()
        for _ in 0...9 {
            sut.add(dbHelper.createExercise("exercise"), to: dbHelper.createWorkout(name: .push, date: date))
            date.addTimeInterval(60 * 60 * 24)
        }
        XCTAssert(sut.workouts().count == 10)
        guard let previousWorkout = sut.previousWorkout() else {
            XCTFail()
            return
        }
        let workouts = dbHelper.fetchWorkouts().sorted(by: { $0.dateCreated! > $1.dateCreated! })
        XCTAssert(previousWorkout.objectID == workouts[1].objectID)
    }
    
    func testGetPreviousWorkout_noWorkoutsExist_nilReturned() {
        XCTAssert(sut.previousWorkout() == nil)
    }
    
    func testGetPreviousWorkout_oneWorkoutExists_nilReturned() {
        sut.add(dbHelper.createExercise("exercise"), to: dbHelper.createWorkout(name: .push, date: Date()))
        XCTAssert(sut.previousWorkout() == nil)
    }

}
