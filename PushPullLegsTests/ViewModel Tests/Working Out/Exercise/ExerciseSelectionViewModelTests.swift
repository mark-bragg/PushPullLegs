//
//  ExerciseSelectionViewModelTests.swift
//  PushPullLegsTests
//
//  Created by Mark Bragg on 4/19/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import XCTest
@testable import PushPullLegs

class ExerciseSelectionViewModelTests: XCTestCase {

    var sut: ExerciseSelectionViewModel!
    let dbHelper = DBHelper(coreDataStack: CoreDataTestStack())
    
    override func setUp() {
        dbHelper.addWorkoutTemplates()
    }

    func testRowCount_noExercisesToAdd_zeroReturned() {
        sut = ExerciseSelectionViewModel(withType: .push, templateManagement: TemplateManagement(coreDataManager: dbHelper.coreDataStack))
        XCTAssert(sut.rowCount() == 0)
    }
    
    func testRowCount_fiveExercisesToAdd_fiveReturned() {
        for i in 0...4 {
            dbHelper.addExerciseTemplate(name: "ex \(i)", type: .push)
        }
        sut = ExerciseSelectionViewModel(withType: .push, templateManagement: TemplateManagement(coreDataManager: dbHelper.coreDataStack))
        XCTAssert(sut.rowCount() == 5)
    }
    
    func testRowCount_fiveExercisesToAdd_fiveExercisesAdded_fiveReturned() {
        let push = dbHelper.fetchWorkoutTemplates().first(where: {$0.name == ExerciseType.push.rawValue})!
        for i in 0...4 {
            dbHelper.addExerciseTemplate(name: "ex \(i)", type: .push)
            dbHelper.addExerciseTemplate("ex \(100 + i)", to: push, addToWorkout: true)
        }
        sut = ExerciseSelectionViewModel(withType: .push, templateManagement: TemplateManagement(coreDataManager: dbHelper.coreDataStack))
        XCTAssert(sut.rowCount() == 5)
    }
    
    func testTitleForRow() {
        var names = [String]()
        for i in 0...4 {
            names.append("ex \(i)")
            dbHelper.addExerciseTemplate(name: names.last!, type: .push)
        }
        sut = ExerciseSelectionViewModel(withType: .push, templateManagement: TemplateManagement(coreDataManager: dbHelper.coreDataStack))
        for i in 0...4 {
            XCTAssert(names.contains(sut.titleForRow(i)))
        }
    }
    
    func testSelected() {
        var names = [String]()
        for i in 0...4 {
            names.append("ex \(i)")
            dbHelper.addExerciseTemplate(name: names.last!, type: .push)
        }
        sut = ExerciseSelectionViewModel(withType: .push, templateManagement: TemplateManagement(coreDataManager: dbHelper.coreDataStack))
        sut.selected(row: 1)
        sut.selected(row: 3)
        let selectedExercises = sut.selectedExercises()
        XCTAssert(selectedExercises.count == 2)
        XCTAssert(!selectedExercises.contains(where: {$0.name == names[0]}))
        XCTAssert(selectedExercises.contains(where: {$0.name == names[1]}))
        XCTAssert(!selectedExercises.contains(where: {$0.name == names[2]}))
        XCTAssert(selectedExercises.contains(where: {$0.name == names[3]}))
        XCTAssert(!selectedExercises.contains(where: {$0.name == names[4]}))
    }
    
    func testDeselected() {
        var names = [String]()
        for i in 0...4 {
            names.append("ex \(i)")
            dbHelper.addExerciseTemplate(name: names.last!, type: .push)
        }
        sut = ExerciseSelectionViewModel(withType: .push, templateManagement: TemplateManagement(coreDataManager: dbHelper.coreDataStack))
        for i in 0...4 {
            sut.selected(row: i)
        }
        sut.deselected(row: 1)
        sut.deselected(row: 2)
        sut.deselected(row: 4)
        let selectedExercises = sut.selectedExercises()
        XCTAssert(selectedExercises.count == 2)
        XCTAssert(selectedExercises.contains(where: {$0.name == names[0]}))
        XCTAssert(!selectedExercises.contains(where: {$0.name == names[1]}))
        XCTAssert(!selectedExercises.contains(where: {$0.name == names[2]}))
        XCTAssert(selectedExercises.contains(where: {$0.name == names[3]}))
        XCTAssert(!selectedExercises.contains(where: {$0.name == names[4]}))
    }
    
    func testExerciseType() {
        sut = ExerciseSelectionViewModel(withType: .push, templateManagement: TemplateManagement(coreDataManager: dbHelper.coreDataStack))
        XCTAssert(sut.exerciseType == .push)
        sut = ExerciseSelectionViewModel(withType: .pull, templateManagement: TemplateManagement(coreDataManager: dbHelper.coreDataStack))
        XCTAssert(sut.exerciseType == .pull)
        sut = ExerciseSelectionViewModel(withType: .legs, templateManagement: TemplateManagement(coreDataManager: dbHelper.coreDataStack))
        XCTAssert(sut.exerciseType == .legs)
    }
    
    func testExerciseTemplateAddedToWorkout() {
        var names = [String]()
        for i in 0...4 {
            names.append("ex \(i)")
            dbHelper.addExerciseTemplate(name: names.last!, type: .push)
        }
        sut = ExerciseSelectionViewModel(withType: .push, templateManagement: TemplateManagement(coreDataManager: dbHelper.coreDataStack))
        XCTAssert(sut.rowCount() == 5)
        dbHelper.addExerciseTemplate("to add to workout", to: dbHelper.fetchWorkoutTemplates().first(where: { $0.name == ExerciseType.push.rawValue })!, addToWorkout: true)
        sut.reload()
        XCTAssert(sut.rowCount() == 5, "\nexpected: 6\nactual: \(sut.rowCount())")
    }

    func testSelected_commitChanges_templateUpdated() {
        var names = [String]()
        for i in 0...4 {
            names.append("ex \(i)")
            dbHelper.addExerciseTemplate(name: names.last!, type: .push)
        }
        sut = ExerciseSelectionViewModel(withType: .push, templateManagement: TemplateManagement(coreDataManager: dbHelper.coreDataStack))
        sut.selected(row: 1)
        sut.selected(row: 3)
        sut.commitChanges()
        let template = dbHelper.fetchWorkoutTemplates().first(where: { $0.name! == ExerciseType.push.rawValue })
        XCTAssert((template?.exerciseNames?.contains(names[1]))!)
        XCTAssert((template?.exerciseNames?.contains(names[3]))!)
    }
    
}
