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
    var types: [ExerciseTypeName] { ExerciseTypeName.allCases }
    var exerciseCount: Int = 0
    var expectation: XCTestExpectation!
    
    override func setUp() {
        dbHelper.addWorkoutTemplates()
    }
    
    func addExerciseTemplate(name: String = TempName, workout: WorkoutTemplate, addToWorkout: Bool = false) {
        dbHelper.addExerciseTemplate(name, to: workout, addToWorkout: addToWorkout)
        exerciseCount += 1
        if let temps = dbHelper.fetchExerciseTemplates() {
            XCTAssertEqual(temps.count, exerciseCount)
        }
    }
    
    func viewModelFailedToSaveExerciseWithNameAlreadyExists(_ model: ExerciseTemplateListViewModel) {
        expectation.fulfill()
    }

    func testRowCount_zeroExercises_zeroRows() {
        sut = ExerciseTemplateListViewModel(withTemplateManagement: TemplateManagement(coreDataManager: dbHelper.coreDataStack))
        XCTAssertEqual(sut.rowCount(section: 0), 0)
        XCTAssertEqual(sut.rowCount(section: 1), 0)
        XCTAssertEqual(sut.rowCount(section: 2), 0)
    }
    
    func testRowCount_oneExercisePerType_oneRowPersection() {
        var i = 0
        for wkt in dbHelper.fetchWorkoutTemplates() {
            addExerciseTemplate(name: "ex\(i)", workout: wkt)
            i+=1
        }
        sut = ExerciseTemplateListViewModel(withTemplateManagement: TemplateManagement(coreDataManager: dbHelper.coreDataStack))
        XCTAssertEqual(sut.rowCount(section: 0), ExerciseTypeName.allCases.count)
    }
    
//    func testTitle() {
//
//    }
    
    func testTitleForSection() {
        sut = ExerciseTemplateListViewModel(withTemplateManagement: TemplateManagement(coreDataManager: dbHelper.coreDataStack))
        var i = 0
        for type in types {
            XCTAssertEqual(type.rawValue, sut.titleForSection(i))
            i+=1
        }
    }
    
    func testDeleteExerciseTemplate_templateDeleted() {
        var exerciseCount = 0
        var names = [String]()
        for wkt in dbHelper.fetchWorkoutTemplates().sorted(by: { $0.name! > $1.name! }) {
            names.append("row: \(exerciseCount)")
            addExerciseTemplate(name:names[exerciseCount], workout: wkt)
            exerciseCount+=1
        }
        sut = ExerciseTemplateListViewModel(withTemplateManagement: TemplateManagement(coreDataManager: dbHelper.coreDataStack))
        let firstName = sut.title(indexPath: IndexPath(row: 0, section: 0))
        var temps = dbHelper.fetchExerciseTemplates()!
        XCTAssertEqual(temps.count, exerciseCount)
        sut.deleteExercise(indexPath: IndexPath(row: 0, section: 0))
        names.remove(at: 0)
        exerciseCount-=1
        temps = dbHelper.fetchExerciseTemplates()!
        XCTAssertEqual(temps.count, exerciseCount)
//        let missingName = names.removeAll { $0 == firstName }
        XCTAssert(!temps.contains(where: { $0.name! == firstName }))
        for name in names {
            XCTAssert(temps.contains(where: { $0.name! == name }))
        }
    }

}
