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

    func testType_push() {
        addWorkoutTemplate()
        sut = WorkoutTemplateEditViewModel(withType: .push, templateManagement: TemplateManagement(coreDataManager: coreDataStack))
        XCTAssert(sut.exerciseType == .push)
    }
    
    func testType_pull() {
        addWorkoutTemplate(type: .legs)
        sut = WorkoutTemplateEditViewModel(withType: .legs, templateManagement: TemplateManagement(coreDataManager: coreDataStack))
        XCTAssert(sut.exerciseType == .legs)
    }
    
    func testType_legs() {
        addWorkoutTemplate(type: .pull)
        sut = WorkoutTemplateEditViewModel(withType: .pull, templateManagement: TemplateManagement(coreDataManager: coreDataStack))
        XCTAssert(sut.exerciseType == .pull)
    }
    
    func testRowCount_exercisesAddedAndNotAdded_section0() {
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
    
    func testRowCount_exercisesAddedAndNotAdded_section1() {
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
    
    func testRowCount_exercisesAddedAndNotAdded_section0_section1() {
        addWorkoutTemplate()
        addExerciseTemplate(name: "ex\(exerciseCount)", workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: true)
        addExerciseTemplate(name: "ex\(exerciseCount + 1)", workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: true)
        addExerciseTemplate(name: "ex\(exerciseCount + 1)", workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: false)
        sut = WorkoutTemplateEditViewModel(withType: .push, templateManagement: TemplateManagement(coreDataManager: coreDataStack))
        assertRowCounts()
        addExerciseTemplate(name: "ex\(exerciseCount + 1)", workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: true)
        addExerciseTemplate(name: "ex\(exerciseCount + 1)", workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: true)
        addExerciseTemplate(name: "ex\(exerciseCount + 1)", workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: true)
        addExerciseTemplate(name: "ex\(exerciseCount + 1)", workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: true)
        sut.reload()
        assertRowCounts()
    }
    
    func testRowCount_exercisesAddedOnly_section0() {
        addWorkoutTemplate()
        addExerciseTemplate(name: "ex\(exerciseCount)", workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: true)
        sut = WorkoutTemplateEditViewModel(withType: .push, templateManagement: TemplateManagement(coreDataManager: coreDataStack))
        XCTAssert(sut.rowCount(section: 0) == 1)
    }
    
    func testRowCount_exercisesNotAddedOnly_section0() {
        addWorkoutTemplate()
        addExerciseTemplate(name: "ex\(exerciseCount)", workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: false)
        sut = WorkoutTemplateEditViewModel(withType: .push, templateManagement: TemplateManagement(coreDataManager: coreDataStack))
        XCTAssert(sut.rowCount(section: 0) == 1)
    }
    
    func testTitleForRow_onlyExercisesAdded_section0() {
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
    
    func testTitleForRow_onlyExercisesNotAdded_section0() {
        addWorkoutTemplate()
        sut = WorkoutTemplateEditViewModel(withType: .push, templateManagement: TemplateManagement(coreDataManager: coreDataStack))
        var titles = [String]()
        for i in 0...9 {
            let title = "ex\(i)"
            addExerciseTemplate(name: title, workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: false)
            sut.reload()
            titles.append(title)
            let titleToTest = sut.title(indexPath: IndexPath(row: i, section: 0))
            XCTAssert(title == titleToTest!)
        }
        for i in 0...9 {
            XCTAssert(titles.contains(sut.title(indexPath: IndexPath(row: i, section: 0))!))
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
    
    func testSectionCount_noExercises_sectionCountIsZero() {
        addWorkoutTemplate(type: .push)
        sut = WorkoutTemplateEditViewModel(withType: .push, templateManagement: TemplateManagement(coreDataManager: coreDataStack))
        XCTAssert(sut.sectionCount() == 0)
    }
    
    func testSectionCount_oneExerciseNotAdded_sectionCountIsOne() {
        addWorkoutTemplate(type: .push)
        addExerciseTemplate(name: "ex", workout: dbHelper.fetchWorkoutTemplates().first!, addToWorkout: false)
        sut = WorkoutTemplateEditViewModel(withType: .push, templateManagement: TemplateManagement(coreDataManager: coreDataStack))
        XCTAssert(sut.sectionCount() == 1)
    }
    
    func testSectionCount_oneExerciseAdded_sectionCountIsOne() {
        addWorkoutTemplate(type: .push)
        addExerciseTemplate(name: "ex", workout: dbHelper.fetchWorkoutTemplates().first!, addToWorkout: true)
        sut = WorkoutTemplateEditViewModel(withType: .push, templateManagement: TemplateManagement(coreDataManager: coreDataStack))
        XCTAssert(sut.sectionCount() == 1)
    }
    
    func testSectionCount_oneExerciseAdded_oneExerciseNotAdded_sectionCountIsOne() {
        addWorkoutTemplate(type: .push)
        addExerciseTemplate(name: "ex", workout: dbHelper.fetchWorkoutTemplates().first!, addToWorkout: true)
        addExerciseTemplate(name: "ex1", workout: dbHelper.fetchWorkoutTemplates().first!, addToWorkout: false)
        sut = WorkoutTemplateEditViewModel(withType: .push, templateManagement: TemplateManagement(coreDataManager: coreDataStack))
        XCTAssert(sut.sectionCount() == 2)
    }
    
    func testSelected() {
        addWorkoutTemplate()
        sut = WorkoutTemplateEditViewModel(withType: .push, templateManagement: TemplateManagement(coreDataManager: coreDataStack))
        addExerciseTemplate(name: "ex1", workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: false)
        sut.reload()
        XCTAssert(sut.rowCount(section: 0) == 1)
        select(IndexPath(row: 0, section: 0))
        XCTAssert(sut.rowCount(section: 0) == 1)
    }
    
    func testUnselected() {
        addWorkoutTemplate()
        sut = WorkoutTemplateEditViewModel(withType: .push, templateManagement: TemplateManagement(coreDataManager: coreDataStack))
        addExerciseTemplate(name: "ex1", workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: true)
        sut.reload()
        XCTAssert(sut.rowCount(section: 0) == 1)
        select(IndexPath(row: 0, section: 0))
        XCTAssert(sut.rowCount(section: 0) == 1)
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
        select(IndexPath(row: 0, section: 0))
        XCTAssert(sut.rowCount(section: 0) == 3)
        XCTAssert(sut.rowCount(section: 1) == 5)
        select(IndexPath(row: 0, section: 0))
        XCTAssert(sut.rowCount(section: 0) == 2)
        XCTAssert(sut.rowCount(section: 1) == 6)
        select(IndexPath(row: 0, section: 0))
        XCTAssert(sut.rowCount(section: 0) == 1)
        XCTAssert(sut.rowCount(section: 1) == 7)
        for i in 0...3 {
            addExerciseTemplate(name: "ex\(i+200)", workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: false)
        }
        sut.reload()
        XCTAssert(sut.rowCount(section: 0) == 1)
        XCTAssert(sut.rowCount(section: 1) == 11)
        select(IndexPath(row: 3, section: 1))
        select(IndexPath(row: 2, section: 1))
        select(IndexPath(row: 1, section: 1))
        XCTAssert(sut.rowCount(section: 0) == 4)
        XCTAssert(sut.rowCount(section: 1) == 8)
    }
    
    func testTitleForSection_noWorkoutsAdded_NotAddedToWorkoutReturnedForSection0() {
        addWorkoutTemplate()
        for i in 0...3 {
            addExerciseTemplate(name: "ex\(i+100)", workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: false)
        }
        sut = WorkoutTemplateEditViewModel(withType: .push, templateManagement: TemplateManagement(coreDataManager: coreDataStack))
        XCTAssert(WorkoutTemplateEditViewModel.removed == sut.titleForSection(0))
    }
    
    func testTitleForSection_onlyWorkoutsAdded_addedToWorkoutReturnedForSection0() {
        addWorkoutTemplate()
        for i in 0...3 {
            addExerciseTemplate(name: "ex\(i+100)", workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: true)
        }
        sut = WorkoutTemplateEditViewModel(withType: .push, templateManagement: TemplateManagement(coreDataManager: coreDataStack))
        XCTAssert(WorkoutTemplateEditViewModel.added == sut.titleForSection(0))
    }
    
    func testTitleForSection_workoutsAddedAndNotAddedt_addedToWorkoutReturnedForSection0_notAddedToWorkoutReturnedForSection1() {
        addWorkoutTemplate()
        for i in 0...3 {
            addExerciseTemplate(name: "ex\(i+100)", workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: true)
        }
        sut = WorkoutTemplateEditViewModel(withType: .push, templateManagement: TemplateManagement(coreDataManager: coreDataStack))
        XCTAssert(WorkoutTemplateEditViewModel.added == sut.titleForSection(0))
    }
    
    func testTitleForSection_allWorkoutsAdded_nilTitleReturnedForSection1() {
        addWorkoutTemplate()
        for i in 0...3 {
            addExerciseTemplate(name: "ex\(i+100)", workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: true)
            addExerciseTemplate(name: "ex\(i+1000)", workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: false)
        }
        sut = WorkoutTemplateEditViewModel(withType: .push, templateManagement: TemplateManagement(coreDataManager: coreDataStack))
        XCTAssert(WorkoutTemplateEditViewModel.added == sut.titleForSection(0))
        XCTAssert(WorkoutTemplateEditViewModel.removed == sut.titleForSection(1))
    }
    
    func testTitleForSection() {
        addWorkoutTemplate()
        for i in 0...3 {
            addExerciseTemplate(name: "ex\(i)", workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: true)
            addExerciseTemplate(name: "ex\(i+100)", workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: false)
        }
        sut = WorkoutTemplateEditViewModel(withType: .push, templateManagement: TemplateManagement(coreDataManager: coreDataStack))
        XCTAssert(WorkoutTemplateEditViewModel.added == sut.titleForSection(0))
        XCTAssert(WorkoutTemplateEditViewModel.removed == sut.titleForSection(1))
    }
    
    func testTitleForSection_noExercisesInDB_noExercisesReturned() {
        addWorkoutTemplate()
        sut = WorkoutTemplateEditViewModel(withType: .push, templateManagement: TemplateManagement(coreDataManager: coreDataStack))
        XCTAssert(WorkoutTemplateEditViewModel.noExercises == sut.titleForSection(0))
    }
    
    func testIsSelected() {
        addWorkoutTemplate()
        sut = WorkoutTemplateEditViewModel(withType: .push, templateManagement: TemplateManagement(coreDataManager: coreDataStack))
        for i in 0...3 {
            addExerciseTemplate(name: "ex\(i)", workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: true)
            addExerciseTemplate(name: "ex\(i+100)", workout:dbHelper.fetchWorkoutTemplates().first!, addToWorkout: false)
        }
        sut.reload()
        assertRowCounts()
        for i in 0...3 {
            XCTAssert(sut.isSelected(IndexPath(row: i, section: 0)))
            XCTAssert(!sut.isSelected(IndexPath(row: i, section: 1)))
        }
    }

}
