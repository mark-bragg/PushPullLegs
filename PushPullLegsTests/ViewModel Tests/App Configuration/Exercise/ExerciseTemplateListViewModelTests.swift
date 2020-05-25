//
//  ExerciseTemplateListViewModelTests.swift
//  PushPullLegsTests
//
//  Created by Mark Bragg on 4/15/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import XCTest
import CoreData

@testable import PushPullLegs

class ExerciseTemplateListViewModelTests: XCTestCase, ExerciseTemplateListViewModelDelegate {

    var sut: ExerciseTemplateListViewModel!
    let dbHelper = DBHelper(coreDataStack: CoreDataTestStack())
    let types: [ExerciseType] = [.push, .pull, .legs]
    var exerciseCount: Int = 0
    var expectation: XCTestExpectation!
    
    override func setUp() {
        dbHelper.addWorkoutTemplates()
    }
    
    func addExerciseTemplate(name: String = TempName, workout: WorkoutTemplate, addToWorkout: Bool = false) {
        dbHelper.addExerciseTemplate(name, to: workout, addToWorkout: addToWorkout)
        exerciseCount += 1
        if let temps = dbHelper.fetchExerciseTemplates() {
            XCTAssert(temps.count == exerciseCount)
        }
    }
    
    func viewModelFailedToSaveExerciseWithNameAlreadyExists(_ model: ExerciseTemplateListViewModel) {
        expectation.fulfill()
    }

    func testRowCount_zeroExercises_zeroRows() {
        sut = ExerciseTemplateListViewModel(withTemplateManagement: TemplateManagement(coreDataManager: dbHelper.coreDataStack))
        XCTAssert(sut.rowCount(section: 0) == 0)
        XCTAssert(sut.rowCount(section: 1) == 0)
        XCTAssert(sut.rowCount(section: 2) == 0)
    }
    
    func testRowCount_oneExercisePerType_oneRowPersection() {
        var i = 0
        for wkt in dbHelper.fetchWorkoutTemplates() {
            addExerciseTemplate(name:"ex\(i)", workout: wkt)
            i+=1
        }
        sut = ExerciseTemplateListViewModel(withTemplateManagement: TemplateManagement(coreDataManager: dbHelper.coreDataStack))
        XCTAssert(sut.rowCount(section: 0) == 1)
        XCTAssert(sut.rowCount(section: 1) == 1)
        XCTAssert(sut.rowCount(section: 2) == 1)
    }
    
    func testRowCount_randomExerciseCountPerType_correctRowsPersection() {
        var i = 0
        var rowCounts = [ExerciseType: Int]()
        for wkt in dbHelper.fetchWorkoutTemplates() {
            let count = Int.random(in: 5...15)
            rowCounts[ExerciseType(rawValue: wkt.name!)!] = count
            for j in 0..<count {
                addExerciseTemplate(name:"ex\(i + j)", workout: wkt)
            }
            i+=100
        }
        sut = ExerciseTemplateListViewModel(withTemplateManagement: TemplateManagement(coreDataManager: dbHelper.coreDataStack))
        XCTAssert(sut.rowCount(section: 0) == rowCounts[.push], "\nexpected: \(rowCounts[.push]!)\nactual: \(sut.rowCount(section: 0))")
        XCTAssert(sut.rowCount(section: 1) == rowCounts[.pull], "\nexpected: \(rowCounts[.pull]!)\nactual: \(sut.rowCount(section: 1))")
        XCTAssert(sut.rowCount(section: 2) == rowCounts[.legs], "\nexpected: \(rowCounts[.legs]!)\nactual: \(sut.rowCount(section: 2))")
    }
    
    func testTitle() {
        var i = 0
        var rowCounts = [ExerciseType: Int]()
        for wkt in dbHelper.fetchWorkoutTemplates() {
            let count = Int.random(in: 5...15)
            rowCounts[ExerciseType(rawValue: wkt.name!)!] = count
            for j in 0..<count {
                addExerciseTemplate(name:"ex\(i + j)", workout: wkt)
            }
            i+=100
        }
        sut = ExerciseTemplateListViewModel(withTemplateManagement: TemplateManagement(coreDataManager: dbHelper.coreDataStack))
        let pushExercises = dbHelper.fetchExerciseTemplates()?.filter({  $0.type! == ExerciseType.push.rawValue }).map({ $0.name! })
        let pullExercises = dbHelper.fetchExerciseTemplates()?.filter({  $0.type! == ExerciseType.pull.rawValue }).map({ $0.name! })
        let legsExercises = dbHelper.fetchExerciseTemplates()?.filter({  $0.type! == ExerciseType.legs.rawValue }).map({ $0.name! })
        for j in 0..<rowCounts[.push]! {
            guard let title = sut.title(indexPath: IndexPath(row: j, section: 0)) else {
                XCTFail()
                return
            }
            XCTAssert((pushExercises?.contains(title))!)
        }
        for j in 0..<rowCounts[.pull]! {
            guard let title = sut.title(indexPath: IndexPath(row: j, section: 1)) else {
                XCTFail()
                return
            }
            XCTAssert((pullExercises?.contains(title))!)
        }
        for j in 0..<rowCounts[.legs]! {
            guard let title = sut.title(indexPath: IndexPath(row: j, section: 2)) else {
                XCTFail()
                return
            }
            XCTAssert((legsExercises?.contains(title))!)
        }
    }
    
    func testTitleForSection() {
        sut = ExerciseTemplateListViewModel(withTemplateManagement: TemplateManagement(coreDataManager: dbHelper.coreDataStack))
        var i = 0
        for type in types {
            XCTAssert(type.rawValue == sut.titleForSection(i))
            i+=1
        }
    }
    
    func testDeleteExerciseTemplate_templateDeleted() {
        var exerciseCount = 0
        var section = 0
        var names = [String]()
        for wkt in dbHelper.fetchWorkoutTemplates().sorted(by: { $0.name! > $1.name! }) {
            names.append("section: \(section) row: 0")
            addExerciseTemplate(name:names[exerciseCount], workout: wkt)
            section += 1
            exerciseCount+=1
        }
        section -= 1
        sut = ExerciseTemplateListViewModel(withTemplateManagement: TemplateManagement(coreDataManager: dbHelper.coreDataStack))
        var temps = dbHelper.fetchExerciseTemplates()!
        XCTAssert(temps.count == exerciseCount, "\nexpected: \(exerciseCount)\nactual:\(temps.count)")
        sut.deleteExercise(indexPath: IndexPath(row: 0, section: section))
        exerciseCount-=1
        temps = dbHelper.fetchExerciseTemplates()!
        XCTAssert(temps.count == exerciseCount, "\nexpected: \(exerciseCount)\nactual:\(temps.count)")
        let missingName = names.remove(at: section)
        XCTAssert(!temps.contains(where: { $0.name! == missingName }))
        for name in names {
            XCTAssert(temps.contains(where: { $0.name! == name }))
        }
    }

}
