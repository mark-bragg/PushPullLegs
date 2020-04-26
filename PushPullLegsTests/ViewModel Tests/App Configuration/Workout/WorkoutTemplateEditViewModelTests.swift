//
//  WorkoutTemplateEditViewModelTests.swift
//  PushPullLegsTests
//
//  Created by Mark Bragg on 4/12/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import XCTest
import CoreData

@testable import PushPullLegs

class WorkoutTemplateEditViewModelTests: XCTestCase {

    var sut: WorkoutTemplateEditViewModel!
    let coreDataStack = CoreDataTestStack()
    var count: Int = 0
    var exerciseCount: Int = 0
    var selectedCount: Int = 0
    var dbHelper: DBHelper!
    
    override func setUp() {
        dbHelper = DBHelper(coreDataStack: coreDataStack)
    }
    
    func addWorkoutTemplate(type: ExerciseType = .push) {
        let temp = NSEntityDescription.insertNewObject(forEntityName: "WorkoutTemplate", into: coreDataStack.backgroundContext) as! WorkoutTemplate
        temp.name = type.rawValue
        try? coreDataStack.backgroundContext.save()
        let temps = dbHelper.fetchWorkoutTemplates()
        count += 1
        XCTAssert(temps.count == count)
    }
    
    func addExerciseTemplate(name: String = TempName, workout: WorkoutTemplate, addToWorkout: Bool = false) {
        dbHelper.addExerciseTemplate(name, to: workout, addToWorkout: addToWorkout)
        if addToWorkout {
            selectedCount += 1
        }
        exerciseCount += 1
    }
    
    func unselectedCount() -> Int {
        return exerciseCount - selectedCount
    }
    
    func assertRowCounts() {
        XCTAssert(sut.rowCount(section: 0) == selectedCount, "\nIncorrect Selected Row Count\nexpected: \(selectedCount)\nactual: \(sut.rowCount(section: 0))")
        XCTAssert(sut.rowCount(section: 1) == unselectedCount(), "\nIncorrect Unselected Row Count\nexpected: \(unselectedCount())\nactual: \(sut.rowCount(section: 1))")
    }
    
    func select(_ indexPath: IndexPath) {
        sut.selected(indexPath: indexPath)
        selectedCount += 1
    }
    
    func unselect(_ indexPath: IndexPath) {
        sut.unselected(indexPath: indexPath)
        selectedCount -= 1
    }

    func testType_push() {
        addWorkoutTemplate()
        sut = WorkoutTemplateEditViewModel(withType: .push, templateManagement: TemplateManagement(coreDataManager: coreDataStack))
        XCTAssert(sut.type() == .push)
    }
    
    func testType_pull() {
        addWorkoutTemplate(type: .legs)
        sut = WorkoutTemplateEditViewModel(withType: .legs, templateManagement: TemplateManagement(coreDataManager: coreDataStack))
        XCTAssert(sut.type() == .legs)
    }
    
    func testType_legs() {
        addWorkoutTemplate(type: .pull)
        sut = WorkoutTemplateEditViewModel(withType: .pull, templateManagement: TemplateManagement(coreDataManager: coreDataStack))
        XCTAssert(sut.type() == .pull)
    }
    
    func testRowCount_section0() {
        addWorkoutTemplate()
        addExerciseTemplate(name: "ex\(exerciseCount)", workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: true)
        sut = WorkoutTemplateEditViewModel(withType: .push, templateManagement: TemplateManagement(coreDataManager: coreDataStack))
        XCTAssert(sut.rowCount(section: 0) == exerciseCount)
        addExerciseTemplate(name: "ex\(exerciseCount + 1)", workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: true)
        addExerciseTemplate(name: "ex\(exerciseCount + 1)", workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: true)
        sut.reload()
        XCTAssert(sut.rowCount(section: 0) == exerciseCount, "\nexpected: \(exerciseCount)\nactual: \(sut.rowCount(section: 0))")
        addExerciseTemplate(name: "ex\(exerciseCount + 1)", workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: true)
        addExerciseTemplate(name: "ex\(exerciseCount + 1)", workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: true)
        addExerciseTemplate(name: "ex\(exerciseCount + 1)", workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: true)
        addExerciseTemplate(name: "ex\(exerciseCount + 1)", workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: true)
        sut.reload()
        XCTAssert(sut.rowCount(section: 0) == exerciseCount, "\nexpected: \(exerciseCount)\nactual: \(sut.rowCount(section: 0))")
    }
    
    func testRowCount_section1() {
        addWorkoutTemplate()
        addExerciseTemplate(name: "ex\(exerciseCount)", workout:dbHelper.fetchWorkoutTemplates().first!)
        sut = WorkoutTemplateEditViewModel(withType: .push, templateManagement: TemplateManagement(coreDataManager: coreDataStack))
        XCTAssert(sut.rowCount(section: 1) == exerciseCount)
        addExerciseTemplate(name: "ex\(exerciseCount + 1)", workout:dbHelper.fetchWorkoutTemplates().first!)
        addExerciseTemplate(name: "ex\(exerciseCount + 1)", workout:dbHelper.fetchWorkoutTemplates().first!)
        sut.reload()
        XCTAssert(sut.rowCount(section: 1) == exerciseCount)
        addExerciseTemplate(name: "ex\(exerciseCount + 1)", workout:dbHelper.fetchWorkoutTemplates().first!)
        addExerciseTemplate(name: "ex\(exerciseCount + 1)", workout:dbHelper.fetchWorkoutTemplates().first!)
        addExerciseTemplate(name: "ex\(exerciseCount + 1)", workout:dbHelper.fetchWorkoutTemplates().first!)
        addExerciseTemplate(name: "ex\(exerciseCount + 1)", workout:dbHelper.fetchWorkoutTemplates().first!)
        sut.reload()
        XCTAssert(sut.rowCount(section: 1) == exerciseCount)
    }
    
    func testRowCount_section0_section1() {
        addWorkoutTemplate()
        addExerciseTemplate(name: "ex\(exerciseCount)", workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: true)
        sut = WorkoutTemplateEditViewModel(withType: .push, templateManagement: TemplateManagement(coreDataManager: coreDataStack))
        assertRowCounts()
        addExerciseTemplate(name: "ex\(exerciseCount + 1)", workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: true)
        addExerciseTemplate(name: "ex\(exerciseCount + 1)", workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: false)
        sut.reload()
        assertRowCounts()
        addExerciseTemplate(name: "ex\(exerciseCount + 1)", workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: true)
        addExerciseTemplate(name: "ex\(exerciseCount + 1)", workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: true)
        addExerciseTemplate(name: "ex\(exerciseCount + 1)", workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: true)
        addExerciseTemplate(name: "ex\(exerciseCount + 1)", workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: true)
        sut.reload()
        assertRowCounts()
    }
    
    func testTitleForRow_section0() {
        addWorkoutTemplate()
        sut = WorkoutTemplateEditViewModel(withType: .push, templateManagement: TemplateManagement(coreDataManager: coreDataStack))
        var titles = [String]()
        for i in 0...9 {
            let title = "ex\(i)"
            addExerciseTemplate(name: title, workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: true)
            sut.reload()
            titles.append(title)
            let titleToTest = sut.title(indexPath: IndexPath(row: i, section: 0))
            XCTAssert(title == titleToTest!)
        }
        for i in 0...9 {
            XCTAssert(titles.contains(sut.title(indexPath: IndexPath(row: i, section: 0))!))
        }
    }
    
    func testTitleForRow_section1() {
        addWorkoutTemplate()
        sut = WorkoutTemplateEditViewModel(withType: .push, templateManagement: TemplateManagement(coreDataManager: coreDataStack))
        var titles = [String]()
        for i in 0...9 {
            let title = "ex\(i)"
            addExerciseTemplate(name: title, workout:dbHelper.fetchWorkoutTemplates().first!)
            sut.reload()
            titles.append(title)
            let titleToTest = sut.title(indexPath: IndexPath(row: i, section: 1))
            XCTAssert(title == titleToTest!)
        }
        for i in 0...9 {
            XCTAssert(titles.contains(sut.title(indexPath: IndexPath(row: i, section: 1))!))
        }
    }
    
    func testTitleForRow_section0_section1() {
        addWorkoutTemplate()
        sut = WorkoutTemplateEditViewModel(withType: .push, templateManagement: TemplateManagement(coreDataManager: coreDataStack))
        var selectedTitles = [String]()
        var unselectedTitles = [String]()
        for i in 0...9 {
            let title1 = "ex\(i)"
            let title2 = "\(title1)\(i)"
            addExerciseTemplate(name: title1, workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: true)
            addExerciseTemplate(name: title2, workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: false)
            sut.reload()
            selectedTitles.append(title1)
            unselectedTitles.append(title2)
            let title1ToTest = sut.title(indexPath: IndexPath(row: i, section: 0))
            XCTAssert(title1 == title1ToTest!)
            let title2ToTest = sut.title(indexPath: IndexPath(row: i, section: 1))
            XCTAssert(title2 == title2ToTest!)
        }
        for i in 0...9 {
            XCTAssert(selectedTitles.contains(sut.title(indexPath: IndexPath(row: i, section: 0))!))
            XCTAssert(unselectedTitles.contains(sut.title(indexPath: IndexPath(row: i, section: 1))!))
        }
    }
    
    func testSectionCount() {
        addWorkoutTemplate(type: .push)
        sut = WorkoutTemplateEditViewModel(withType: .push, templateManagement: TemplateManagement(coreDataManager: coreDataStack))
        XCTAssert(sut.sectionCount() == 2)
    }
    
    func testSelected() {
        addWorkoutTemplate()
        sut = WorkoutTemplateEditViewModel(withType: .push, templateManagement: TemplateManagement(coreDataManager: coreDataStack))
        addExerciseTemplate(name: "ex1", workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: false)
        sut.reload()
        assertRowCounts()
        select(IndexPath(row: 0, section: 1))
        assertRowCounts()
    }
    
    func testUnselected() {
        addWorkoutTemplate()
        sut = WorkoutTemplateEditViewModel(withType: .push, templateManagement: TemplateManagement(coreDataManager: coreDataStack))
        addExerciseTemplate(name: "ex1", workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: true)
        sut.reload()
        assertRowCounts()
        unselect(IndexPath(row: 0, section: 0))
        assertRowCounts()
    }
    
    func testSelectedUnselected() {
        addWorkoutTemplate()
        sut = WorkoutTemplateEditViewModel(withType: .push, templateManagement: TemplateManagement(coreDataManager: coreDataStack))
        for i in 0...3 {
            addExerciseTemplate(name: "ex\(i)", workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: true)
            addExerciseTemplate(name: "ex\(i+100)", workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: false)
        }
        sut.reload()
        assertRowCounts()
        unselect(IndexPath(row: 0, section: 0))
        assertRowCounts()
        unselect(IndexPath(row: 0, section: 0))
        assertRowCounts()
        unselect(IndexPath(row: 0, section: 0))
        assertRowCounts()
        for i in 0...3 {
            addExerciseTemplate(name: "ex\(i+200)", workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: false)
        }
        sut.reload()
        assertRowCounts()
        select(IndexPath(row: 3, section: 1))
        select(IndexPath(row: 2, section: 1))
        select(IndexPath(row: 1, section: 1))
        assertRowCounts()
    }
    
    func testTitleForSection_noWorkoutsAdded_nilTitleReturnedForSection0() {
        addWorkoutTemplate()
        for i in 0...3 {
            addExerciseTemplate(name: "ex\(i+100)", workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: false)
        }
        sut = WorkoutTemplateEditViewModel(withType: .push, templateManagement: TemplateManagement(coreDataManager: coreDataStack))
        XCTAssert(nil == sut.titleForSection(0))
        XCTAssert("Not Added to Workout" == sut.titleForSection(1))
    }
    
    func testTitleForSection_allWorkoutsAdded_nilTitleReturnedForSection1() {
        addWorkoutTemplate()
        for i in 0...3 {
            addExerciseTemplate(name: "ex\(i+100)", workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: true)
        }
        sut = WorkoutTemplateEditViewModel(withType: .push, templateManagement: TemplateManagement(coreDataManager: coreDataStack))
        XCTAssert("Added to Workout" == sut.titleForSection(0))
        XCTAssert(nil == sut.titleForSection(1))
    }
    
    func testTitleForSection() {
        addWorkoutTemplate()
        for i in 0...3 {
            addExerciseTemplate(name: "ex\(i)", workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: true)
            addExerciseTemplate(name: "ex\(i+100)", workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: false)
        }
        sut = WorkoutTemplateEditViewModel(withType: .push, templateManagement: TemplateManagement(coreDataManager: coreDataStack))
        XCTAssert("Added to Workout" == sut.titleForSection(0))
        XCTAssert("Not Added to Workout" == sut.titleForSection(1))
    }

}
