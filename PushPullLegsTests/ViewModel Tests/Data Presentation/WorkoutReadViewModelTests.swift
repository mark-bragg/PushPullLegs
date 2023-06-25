//
//  WorkoutReadViewModelTests.swift
//  PushPullLegsTests
//
//  Created by Mark Bragg on 5/12/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import XCTest
@testable import PushPullLegs

class WorkoutReadViewModelTests: XCTestCase {

    var sut: WorkoutDataViewModel!
    let dbHelper = DBHelper(coreDataStack: CoreDataTestStack())
    var exerciseNames = [String]()
    var date: Date!
    
    override func setUp() {
        date = Date()
        let workout = dbHelper.createWorkout(name: .push, date: date)
        for i in 0...4 {
            exerciseNames.append("exercise \(i)")
            dbHelper.addExercise(exerciseNames.last!, to: workout)
        }
        sut = WorkoutDataViewModel(withCoreDataManagement: dbHelper.coreDataStack, workout: workout)
        XCTAssert(sut.sectionCount() == 1)
    }

    func testInit_noExercises_noRows() {
        let date = Date()
        let workout = dbHelper.createWorkout(name: .push, date: date)
        sut = WorkoutDataViewModel(withCoreDataManagement: dbHelper.coreDataStack, workout: workout)
        XCTAssert(sut.rowCount(section: 0) == 0)
    }
    
    func testRowsForSection_fiveReturned() {
        XCTAssert(sut.rowCount(section: 0) == 5)
    }
    
    func testTitleForIndexPath() {
        var i = 0
        for name in exerciseNames {
            XCTAssert(sut.title(indexPath: IndexPath(row: i, section: 0)) == name)
            i += 1
        }
    }
    
    func testDetailTextForIndexPath() {
        for exercise in dbHelper.fetchExercises() {
            dbHelper.addSetTo(exercise, data: (2, 20, 30))
        }
        let volumeText = "Volume: \((2 * 20 * 30.0.durationLog).truncateIfNecessary())"
        for i in 0..<exerciseNames.count {
            guard let detailText = sut.detailText(indexPath: IndexPath(row: i, section: 0)) else {
                XCTFail()
                return
            }
            XCTAssertEqual(detailText, volumeText)
        }
    }
    
    func testGetSelected() {
        let exercises = dbHelper.fetchExercises()
        for i in 0..<exerciseNames.count {
            sut.selectedIndex = IndexPath(row: i, section: 0)
            guard let exercise = sut.getSelected() as? Exercise else {
                XCTFail()
                return
            }
            XCTAssert(exercises.contains(where: { $0.objectID == exercise.objectID }))
        }
    }
    
    func testExerciseVolumeComparison_twoWorkoutsInHistory_noChange() {
        let oldDate = date.addingTimeInterval(-(60 * 60 * 24))
        let workout = dbHelper.createWorkout(name: .push, date: oldDate)
        for i in 0...4 {
            exerciseNames.append("exercise \(i)")
            dbHelper.addExercise(exerciseNames.last!, to: workout)
        }
        for exercise in dbHelper.fetchExercises() {
            dbHelper.addSetTo(exercise, data: (2, 20, 30))
        }
        for i in 0...4 {
            XCTAssert(sut.exerciseVolumeComparison(row: i) == .noChange)
        }
    }
    
    func testExerciseVolumeComparison_twoWorkoutsInHistory_decrease() {
        let oldDate = date.addingTimeInterval(-(60 * 60 * 24))
        let workout = dbHelper.createWorkout(name: .push, date: oldDate)
        for i in 0...4 {
            exerciseNames.append("exercise \(i)")
            dbHelper.addExercise(exerciseNames.last!, to: workout)
        }
        let oldExercises = dbHelper.fetchExercises(workout: workout)
        for exercise in dbHelper.fetchExercises() {
            if oldExercises.contains(where: { $0.objectID == exercise.objectID }) {
                dbHelper.addSetTo(exercise, data: (3, 20, 50))
            } else {
                dbHelper.addSetTo(exercise, data: (1, 20, 30))
            }
        }
        for i in 0...4 {
            XCTAssertEqual(sut.exerciseVolumeComparison(row: i), ExerciseVolumeComparison.decrease)
        }
    }
    
    func testExerciseVolumeComparison_twoWorkoutsInHistory_increase() {
        let oldDate = date.addingTimeInterval(-(60 * 60 * 24))
        let workout = dbHelper.createWorkout(name: .push, date: oldDate)
        for i in 0...4 {
            exerciseNames.append("exercise \(i)")
            dbHelper.addExercise(exerciseNames.last!, to: workout)
        }
        let oldExercises = dbHelper.fetchExercises(workout: workout)
        for exercise in dbHelper.fetchExercises() {
            if oldExercises.contains(where: { $0.objectID == exercise.objectID }) {
                dbHelper.addSetTo(exercise, data: (1, 20, 30))
            } else {
                dbHelper.addSetTo(exercise, data: (2, 20, 50))
            }
        }
        for i in 0...4 {
            XCTAssert(sut.exerciseVolumeComparison(row: i) == .increase)
        }
    }
    
    func testExerciseVolumeComparison_threeAscendingVolumeWorkoutsInHistory_increaseForAllThree() {
        var previousWorkouts = [Workout]()
        for i in 1...2 {
            let oldDate = date.addingTimeInterval(TimeInterval(-((60 * 60 * 24) * (2-i))))
            let workout = dbHelper.createWorkout(name: .push, date: oldDate)
            for ij in 0...4 {
                dbHelper.addExercise(exerciseNames[ij], to: workout)
            }
            previousWorkouts.append(workout)
        }
        previousWorkouts.append(dbHelper.fetchWorkouts().first(where: { $0.objectID != previousWorkouts[0].objectID && $0.objectID != previousWorkouts[1].objectID})!)
        for j in 0...2 {
            let oldExercises = dbHelper.fetchExercises(workout: previousWorkouts[j])
            var i = 1
            for exercise in dbHelper.fetchExercises() {
                if oldExercises.contains(where: { $0.objectID == exercise.objectID }) {
                    dbHelper.addSetTo(exercise, data: (Double(1*j), 20, 30))
                } else {
                    dbHelper.addSetTo(exercise, data: (10, 60, 60))
                }
                i += 1
            }
        }
        previousWorkouts.sort(by: { $0.dateCreated!.compare($1.dateCreated!) == ComparisonResult.orderedAscending })
        for i in 0..<3 {
            sut = WorkoutDataViewModel(withCoreDataManagement: dbHelper.coreDataStack, workout: previousWorkouts[i])
            for j in 0...4 {
                let comparison = sut.exerciseVolumeComparison(row: j)
                XCTAssert(comparison == .increase, "\nexpected: \(ExerciseVolumeComparison.increase)\nactual: \(comparison)")
            }
        }
    }
    
//    func testExerciseVolumeComparison_threeDescendingVolumeWorkoutsInHistory_increaseForFirst_decreaseForLastTwo() {
//        var previousWorkouts = [Workout]()
//        for i in 1...2 {
//            let oldDate = date.addingTimeInterval(TimeInterval(-((60 * 60 * 24) * (2-i))))
//            let workout = dbHelper.createWorkout(name: .push, date: oldDate)
//            for name in exerciseNames {
//                dbHelper.addExercise(name, to: workout)
//            }
//            previousWorkouts.append(workout)
//        }
//        previousWorkouts.insert(dbHelper.fetchWorkouts().first(where: { $0.objectID != previousWorkouts[0].objectID && $0.objectID != previousWorkouts[1].objectID})!, at: 0)
//        previousWorkouts.sort(by: { $0.dateCreated!.compare($1.dateCreated!) == ComparisonResult.orderedAscending })
//        var volumeConstant = 10
//        let exercises = dbHelper.fetchExercises()
//        var volumeIncrease = 0
//        for workout in previousWorkouts {
//            for exercise in exercises {
//                if let workoutExercises = workout.exercises?.array as? [Exercise], workoutExercises.contains(where: { $0.objectID == exercise.objectID }) {
//                    dbHelper.addSetTo(exercise, data: (Double(volumeConstant), 20, 30 - volumeIncrease))
//                    volumeIncrease += 20
//                }
//            }
//            volumeConstant -= 5
//        }
//        var workoutIndex = 0
//        for workout in previousWorkouts {
//            sut = WorkoutDataViewModel(withCoreDataManagement: dbHelper.coreDataStack, workout: workout)
//            for j in 0...4 {
//                let comparison = sut.exerciseVolumeComparison(row: j)
//                if workoutIndex == 0 {
//                    XCTAssert(comparison == .increase, "\nexpected: \(ExerciseVolumeComparison.increase)\nactual: \(comparison)\nexercise: \(j)")
//                } else {
//                    XCTAssert(comparison == .decrease, "\nexpected: \(ExerciseVolumeComparison.decrease)\nactual: \(comparison)\nexercise: \(j)\nworkout: \(workoutIndex)")
//                }
//            }
//            workoutIndex += 1
//        }
//    }
    
    func testExerciseVolumeComparison_threeEqualVolumeWorkoutsInHistory_increaseForFirst_noChangeForLastTwo() {
        var previousWorkouts = [Workout]()
        for i in 1...2 {
            let oldDate = date.addingTimeInterval(TimeInterval(-((60 * 60 * 24) * (2-i))))
            let workout = dbHelper.createWorkout(name: .push, date: oldDate)
            for name in exerciseNames {
                dbHelper.addExercise(name, to: workout)
            }
            previousWorkouts.append(workout)
        }
        previousWorkouts.insert(dbHelper.fetchWorkouts().first(where: { $0.objectID != previousWorkouts[0].objectID && $0.objectID != previousWorkouts[1].objectID})!, at: 0)
        previousWorkouts.sort(by: { $0.dateCreated!.compare($1.dateCreated!) == ComparisonResult.orderedAscending })
        let volumeConstant = 10
        let exercises = dbHelper.fetchExercises()
        
        for workout in previousWorkouts {
            for exercise in exercises {
                if let workoutExercises = workout.exercises?.array as? [Exercise], workoutExercises.contains(where: { $0.objectID == exercise.objectID }) {
                    dbHelper.addSetTo(exercise, data: (Double(volumeConstant), Double(volumeConstant), volumeConstant))
                }
            }
        }
        var workoutIndex = 0
        for workout in previousWorkouts {
            sut = WorkoutDataViewModel(withCoreDataManagement: dbHelper.coreDataStack, workout: workout)
            for j in 0...4 {
                let comparison = sut.exerciseVolumeComparison(row: j)
                if workoutIndex == 0 {
                    XCTAssert(comparison == .increase, "\nexpected: \(ExerciseVolumeComparison.increase)\nactual: \(comparison)\nexercise: \(j)")
                } else {
                    XCTAssert(comparison == .noChange, "\nexpected: \(ExerciseVolumeComparison.noChange)\nactual: \(comparison)\nexercise: \(j)\nworkout: \(workoutIndex)")
                }
            }
            workoutIndex += 1
        }
    }
    
    func testExerciseVolumeComparison_tenWorkoutsInHistory_alternatingIncreaseAndDecrease() {
        var previousWorkouts = [Workout]()
        var oldDate = date!
        for i in 1...9 {
            oldDate = oldDate.addingTimeInterval(TimeInterval((60 * 60 * 24) * i))
            let workout = dbHelper.createWorkout(name: .push, date: oldDate)
            for name in exerciseNames {
                dbHelper.addExercise(name, to: workout)
            }
            previousWorkouts.append(workout)
        }
        previousWorkouts.insert(dbHelper.fetchWorkouts().first(where: { (wktToAdd) -> Bool in
            for previousWorkout in previousWorkouts {
                if wktToAdd.objectID == previousWorkout.objectID { return false }
            }
            return true
        })!, at: 0)
        previousWorkouts.sort(by: { $0.dateCreated!.compare($1.dateCreated!) == ComparisonResult.orderedAscending })
        let volumeConstant = 10
        let exercises = dbHelper.fetchExercises()
        var workoutIndex = 0
        for workout in previousWorkouts {
            for exercise in exercises {
                if let workoutExercises = workout.exercises?.array as? [Exercise], workoutExercises.contains(where: { $0.objectID == exercise.objectID }) {
                    let volume = workoutIndex % 2 == 0 ? 0 : volumeConstant
                    dbHelper.addSetTo(exercise, data: (Double(volume), Double(volume), volume))
                }
            }
            workoutIndex += 1
        }
        workoutIndex = 0
        for workout in previousWorkouts {
            sut = WorkoutDataViewModel(withCoreDataManagement: dbHelper.coreDataStack, workout: workout)
            for j in 0...4 {
                let comparison = sut.exerciseVolumeComparison(row: j)
                if workoutIndex == 0 {
                    XCTAssert(comparison == .increase, "\nexpected: \(ExerciseVolumeComparison.decrease)\nactual: \(comparison)\nexercise: \(j)\nworkout: \(workoutIndex)")
                } else if workoutIndex % 2 == 0 {
                    XCTAssert(comparison == .decrease, "\nexpected: \(ExerciseVolumeComparison.increase)\nactual: \(comparison)\nexercise: \(j)\nworkout: \(workoutIndex)")
                } else {
                    XCTAssert(comparison == .increase, "\nexpected: \(ExerciseVolumeComparison.decrease)\nactual: \(comparison)\nexercise: \(j)\nworkout: \(workoutIndex)")
                }
            }
            workoutIndex += 1
        }
    }

}
