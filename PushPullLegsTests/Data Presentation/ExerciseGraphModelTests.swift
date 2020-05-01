//
//  ExerciseGraphModelTests.swift
//  PushPullLegsTests
//
//  Created by Mark Bragg on 4/27/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import XCTest
@testable import PushPullLegs

class ExerciseGraphModelTests: XCTestCase {

    var sut: ExerciseGraphModel!
    let dbHelper = DBHelper(coreDataStack: CoreDataTestStack())
    
    override func setUp() {
        sut = ExerciseGraphModel(withExerciseDataManager: ExerciseDataManager(backgroundContext: dbHelper.coreDataStack.backgroundContext))
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetExerciseNames() {
        var names = [String]()
        for i in 0...9 {
            names.append("exercise \(i)")
            dbHelper.addExercise(names.last!, to: nil)
        }
        let namesToTest = sut.getExerciseNames()
        XCTAssert(namesToTest.count == 10)
        for name in namesToTest {
            XCTAssert(names.contains(name))
        }
    }
    
    func testSelectExerciseWithName_getDates_oneExercise_singleCorrectDateReturned() {
        var names = [String]()
        let date = Date().addingTimeInterval(-60 * 60 * 24 * 3)
        let push = dbHelper.createWorkout(name: .push, date: date)
        for i in 0...9 {
            names.append("exercise \(i)")
            dbHelper.addExercise(names.last!, to: push)
        }
        sut.select(name: names[2])
        let dateToTest = sut.getSelectedExerciseDates()?.first!
        XCTAssert(date == dateToTest)
    }
    
    func testSelectExerciseWithName_getDates_tenExercises_correctDatesReturnedInAscendingOrder() {
        let name = "exercise"
        var dates = [Date]()
        for i in 0...9 {
            let date = Date().addingTimeInterval(TimeInterval(-60 * 60 * 24 * i))
            dates.insert(date, at: 0)
            let push = dbHelper.createWorkout(name: .push, date: date)
            dbHelper.addExercise(name, to: push)
        }
        sut.select(name: name)
        let datesToTest = sut.getSelectedExerciseDates()!
        XCTAssert(dates == datesToTest)
    }
    
    func testSelectExerciseWithName_getName_correctNameReturned() {
        var names = [String]()
        let push = dbHelper.createWorkout(name: .push)
        for i in 0...9 {
            names.append("exercise \(i)")
            dbHelper.addExercise(names.last!, to: push)
        }
        sut.select(name: names[2])
        let nameToTest = sut.getSelectedExerciseName()
        XCTAssert(nameToTest == names[2])
    }
    
    func testSelectExerciseWithName_getData_correctDataReturnedInCorrectOrder() {
        let name = "exercise"
        var exerciseData = [ExerciseGraphData]()
        for i in 0...9 {
            let date = Date().addingTimeInterval(TimeInterval(-60 * 60 * 24 * i))
            let push = dbHelper.createWorkout(name: .push, date: date)
            let setCount = Int.random(in: 1...4)
            var setData = [(Double, Int, Int)]()
            for _ in 0...setCount {
                setData.append((Double.random(in: 0...100), Int.random(in: 5...12), Int.random(in: 30...55)))
            }
            let graphData = ExerciseGraphData(sets: setData, date: date)
            exerciseData.insert(graphData, at: 0)
            dbHelper.addExercise(name, to: push, data: setData)
        }
        sut.select(name: name)
        let dataToTest = sut.getSelectedExerciseData()!
        for dataIndex in 0..<dataToTest.count {
            XCTAssert(dataToTest[dataIndex] == exerciseData[dataIndex])
        }
//        XCTAssert(dates == datesToTest)
    }


}
