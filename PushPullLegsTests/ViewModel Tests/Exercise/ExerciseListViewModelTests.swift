//
//  ExerciseListViewModelTests.swift
//  PushPullLegsTests
//
//  Created by Mark Bragg on 4/15/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import XCTest
import CoreData

@testable import PushPullLegs

class ExerciseListViewModelTests: XCTestCase, ExerciseListViewModelDelegate {

    var sut: ExerciseListViewModel!
    let coreDataStack = CoreDataTestStack()
    let types: [ExerciseType] = [.push, .pull, .legs]
    var exerciseCount: Int = 0
    var expectation: XCTestExpectation!
    
    override func setUp() {
        addWorkouts()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func fetchWorkouts() -> [WorkoutTemplate] {
        let request = NSFetchRequest<NSFetchRequestResult>.init(entityName: "WorkoutTemplate")
        let workouts = try! self.coreDataStack.backgroundContext.fetch(request)
        return workouts as! [WorkoutTemplate]
    }
    
    func insertWorkout(name: String) {
        let workout = NSEntityDescription.insertNewObject(forEntityName: "WorkoutTemplate", into: coreDataStack.backgroundContext) as! WorkoutTemplate
        workout.name = name
        try? coreDataStack.backgroundContext.save()
    }
    
    func exerciseTemplates() -> [ExerciseTemplate]? {
        if let temps = try? coreDataStack.backgroundContext.fetch(NSFetchRequest(entityName: ExTemp)) as? [ExerciseTemplate] {
            return temps
        }
        return nil
    }
    
    func addExerciseTemplate(name: String = TempName, workout: WorkoutTemplate, addToWorkout: Bool = false) {
        let temp = NSEntityDescription.insertNewObject(forEntityName: ExTemp, into: coreDataStack.backgroundContext) as! ExerciseTemplate
        temp.name = name
        temp.type = workout.name
        try? coreDataStack.backgroundContext.save()
        if addToWorkout {
            if workout.exerciseNames == nil {
                workout.exerciseNames = []
            }
            workout.exerciseNames?.append(temp.name!)
            try? coreDataStack.backgroundContext.save()
        }
        exerciseCount += 1
        if let temps = exerciseTemplates() {
            XCTAssert(temps.count == exerciseCount)
        }
    }
    
    func addWorkouts() {
        insertWorkout(name: ExerciseType.push.rawValue)
        insertWorkout(name: ExerciseType.pull.rawValue)
        insertWorkout(name: ExerciseType.legs.rawValue)
    }
    
    func viewModelFailedToSaveExerciseWithNameAlreadyExists(_ model: ExerciseListViewModel) {
        expectation.fulfill()
    }

    func testRowCount_zeroExercises_zeroRows() {
        sut = ExerciseListViewModel(withTemplateManagement: TemplateManagement(backgroundContext: coreDataStack.backgroundContext))
        XCTAssert(sut.rowCount(section: 0) == 0)
        XCTAssert(sut.rowCount(section: 1) == 0)
        XCTAssert(sut.rowCount(section: 2) == 0)
    }
    
    func testRowCount_oneExercisePerType_oneRowPersection() {
        var i = 0
        for wkt in fetchWorkouts() {
            addExerciseTemplate(name:"ex\(i)", workout: wkt)
            i+=1
        }
        sut = ExerciseListViewModel(withTemplateManagement: TemplateManagement(backgroundContext: coreDataStack.backgroundContext))
        XCTAssert(sut.rowCount(section: 0) == 1)
        XCTAssert(sut.rowCount(section: 1) == 1)
        XCTAssert(sut.rowCount(section: 2) == 1)
    }
    
    func testRowCount_randomExerciseCountPerType_correctRowsPersection() {
        var i = 0
        var rowCounts = [ExerciseType: Int]()
        for wkt in fetchWorkouts() {
            let count = Int.random(in: 5...15)
            rowCounts[ExerciseType(rawValue: wkt.name!)!] = count
            for j in 0..<count {
                addExerciseTemplate(name:"ex\(i + j)", workout: wkt)
            }
            i+=100
        }
        sut = ExerciseListViewModel(withTemplateManagement: TemplateManagement(backgroundContext: coreDataStack.backgroundContext))
        XCTAssert(sut.rowCount(section: 0) == rowCounts[.push], "\nexpected: \(rowCounts[.push]!)\nactual: \(sut.rowCount(section: 0))")
        XCTAssert(sut.rowCount(section: 1) == rowCounts[.pull], "\nexpected: \(rowCounts[.pull]!)\nactual: \(sut.rowCount(section: 1))")
        XCTAssert(sut.rowCount(section: 2) == rowCounts[.legs], "\nexpected: \(rowCounts[.legs]!)\nactual: \(sut.rowCount(section: 2))")
    }
    
    func testTitle() {
        var i = 0
        var rowCounts = [ExerciseType: Int]()
        for wkt in fetchWorkouts() {
            let count = Int.random(in: 5...15)
            rowCounts[ExerciseType(rawValue: wkt.name!)!] = count
            for j in 0..<count {
                addExerciseTemplate(name:"ex\(i + j)", workout: wkt)
            }
            i+=100
        }
        sut = ExerciseListViewModel(withTemplateManagement: TemplateManagement(backgroundContext: coreDataStack.backgroundContext))
        let pushExercises = exerciseTemplates()?.filter({  $0.type! == ExerciseType.push.rawValue }).map({ $0.name! })
        let pullExercises = exerciseTemplates()?.filter({  $0.type! == ExerciseType.pull.rawValue }).map({ $0.name! })
        let legsExercises = exerciseTemplates()?.filter({  $0.type! == ExerciseType.legs.rawValue }).map({ $0.name! })
        for j in 0..<rowCounts[.push]! {
            XCTAssert((pushExercises?.contains(sut.title(indexPath: IndexPath(row: j, section: 0))))!)
        }
        for j in 0..<rowCounts[.pull]! {
            XCTAssert((pullExercises?.contains(sut.title(indexPath: IndexPath(row: j, section: 1))))!)
        }
        for j in 0..<rowCounts[.legs]! {
            XCTAssert((legsExercises?.contains(sut.title(indexPath: IndexPath(row: j, section: 2))))!)
        }
    }
    
    func testTitleForSection() {
        sut = ExerciseListViewModel(withTemplateManagement: TemplateManagement(backgroundContext: coreDataStack.backgroundContext))
        var i = 0
        for type in types {
            XCTAssert(type.rawValue == sut.titleForSection(i))
            i+=1
        }
    }
    
    func testDeleteExerciseTemplate_templateDeleted() {
        var exerciseCount = 0
        var indexPath = IndexPath(row: 0, section: 0)
        var names = [String]()
        for wkt in fetchWorkouts() {
            names.append("section: \(indexPath.section) row: \(indexPath.row)")
            addExerciseTemplate(name:names[exerciseCount], workout: wkt)
            indexPath.section += 1
            exerciseCount+=1
        }
        indexPath.section -= 1
        sut = ExerciseListViewModel(withTemplateManagement: TemplateManagement(backgroundContext: coreDataStack.backgroundContext))
        var temps = exerciseTemplates()!
        XCTAssert(temps.count == exerciseCount, "\nexpected: \(exerciseCount)\nactual:\(temps.count)")
        sut.deleteExercise(indexPath: indexPath)
        exerciseCount-=1
        temps = exerciseTemplates()!
        XCTAssert(temps.count == exerciseCount, "\nexpected: \(exerciseCount)\nactual:\(temps.count)")
        XCTAssert(!temps.contains(where: { $0.name! == names.remove(at: indexPath.row) }))
        for name in names {
            XCTAssert(temps.contains(where: { $0.name! == name }))
        }
    }

}
