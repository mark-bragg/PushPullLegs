//
//  WorkoutGraphViewModelTests.swift
//  PushPullLegsTests
//
//  Created by Mark Bragg on 8/6/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import XCTest
@testable import PushPullLegs

class WorkoutGraphViewModelTests: XCTestCase {
    
    var sut: WorkoutGraphViewModel!
    let dbHelper = DBHelper(coreDataStack: CoreDataTestStack())

    func testTitle() throws {
        sut = WorkoutGraphViewModel(type: .push, dataManager: WorkoutDataManager(backgroundContext: dbHelper.coreDataStack.backgroundContext))
        XCTAssert(sut.title() == ExerciseType.push.rawValue)
        sut = WorkoutGraphViewModel(type: .pull, dataManager: WorkoutDataManager(backgroundContext: dbHelper.coreDataStack.backgroundContext))
        XCTAssert(sut.title() == ExerciseType.pull.rawValue)
        sut = WorkoutGraphViewModel(type: .legs, dataManager: WorkoutDataManager(backgroundContext: dbHelper.coreDataStack.backgroundContext))
        XCTAssert(sut.title() == ExerciseType.legs.rawValue)
    }
    
    func testPointCount_zeroWorkouts() {
        sut = WorkoutGraphViewModel(type: .push, dataManager: WorkoutDataManager(backgroundContext: dbHelper.coreDataStack.backgroundContext))
        XCTAssert(sut.pointCount() == 0)
    }
    
    func testPointCount_oneWorkout() {
        dbHelper.insertWorkout(name: .push)
        sut = WorkoutGraphViewModel(type: .push, dataManager: WorkoutDataManager(backgroundContext: dbHelper.coreDataStack.backgroundContext))
        XCTAssert(sut.pointCount() == 1)
    }
    
    func testPointCount_oneHundredWorkout() {
        let count = 100
        for _ in 0..<count {
            dbHelper.insertWorkout(name: .push)
        }
        sut = WorkoutGraphViewModel(type: .push, dataManager: WorkoutDataManager(backgroundContext: dbHelper.coreDataStack.backgroundContext))
        XCTAssert(sut.pointCount() == count)
    }
    
    func testDates_noExercises_nilReturned() {
        sut = WorkoutGraphViewModel(type: .push, dataManager: WorkoutDataManager(backgroundContext: dbHelper.coreDataStack.backgroundContext))
        XCTAssert(sut.dates() == nil)
    }
    
    func testDates() {
        let count = 100
        var dates = [String]()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/YY"
        var date = Date()
        dates.append(formatter.string(from: date))
        for _ in 0..<count {
            let _ = dbHelper.createWorkout(name: .push, date:date)
            date = date.addingTimeInterval(60 * 60 * 24)
            dates.append(formatter.string(from: date))
        }
        sut = WorkoutGraphViewModel(type: .push, dataManager: WorkoutDataManager(backgroundContext: dbHelper.coreDataStack.backgroundContext))
        let sutDates = sut.dates()!
        for i in 0..<count {
            XCTAssert(sutDates[i] == dates[i])
        }
    }
    
    func testVolumes_noWorkouts() {
        sut = WorkoutGraphViewModel(type: .push, dataManager: WorkoutDataManager(backgroundContext: dbHelper.coreDataStack.backgroundContext))
        XCTAssert(sut.volumes() == nil)
    }
    
    func testVolumes() {
        let count = 100
        var wkt: Workout?
        var volumes = [Double]()
        var dates = [Date()]
        for i in 0..<count {
            wkt = dbHelper.createWorkout(name: .push, date:dates.last!)
            let d = Int.random(in: 10...25)
            let r = Int.random(in: 10...25)
            let w = Double.random(in: 10...25)
            dates.append(wkt!.dateCreated!.addingTimeInterval(60 * 60 * 24))
            wkt?.addToExercises(dbHelper.createExercise("ex \(i)", sets: [
                (d, r, w)
            ]))
            volumes.append((Double(d * r) * w / 60).truncateDigitsAfterDecimal(afterDecimalDigits: 2))
        }
        sut = WorkoutGraphViewModel(type: .push, dataManager: WorkoutDataManager(backgroundContext: dbHelper.coreDataStack.backgroundContext))
        let sutVolumes = sut.volumes()!
        for i in 0..<count {
            XCTAssert(sutVolumes[i] == CGFloat(volumes[i]), "\nexpected: \(volumes[i])\nactual: \(sutVolumes[i])")
        }
    }

}
