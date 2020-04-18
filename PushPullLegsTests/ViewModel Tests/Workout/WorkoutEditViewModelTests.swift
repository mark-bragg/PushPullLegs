//
//  WorkoutEditViewModelTests.swift
//  PushPullLegsTests
//
//  Created by Mark Bragg on 4/12/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import XCTest
import CoreData

@testable import PushPullLegs

class WorkoutEditViewModelTests: XCTestCase {

    var sut: WorkoutEditViewModel!
    let coreDataStack = CoreDataTestStack()
    var count: Int = 0
    var exerciseCount: Int = 0
    var selectedCount: Int = 0
    
    override func setUp() {
        
    }
    
    func workoutTemplates() -> [WorkoutTemplate]? {
        if let temps = try? coreDataStack.backgroundContext.fetch(NSFetchRequest(entityName: "WorkoutTemplate")) as? [WorkoutTemplate] {
            return temps
        }
        return nil
    }
    
    func addWorkoutTemplate(type: ExerciseType = .push) {
        let temp = NSEntityDescription.insertNewObject(forEntityName: "WorkoutTemplate", into: coreDataStack.backgroundContext) as! WorkoutTemplate
        temp.name = type.rawValue
        try? coreDataStack.backgroundContext.save()
        if let temps = workoutTemplates() {
            count += 1
            XCTAssert(temps.count == count)
        }
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
            selectedCount += 1
        }
        exerciseCount += 1
        if let temps = exerciseTemplates() {
            XCTAssert(temps.count == exerciseCount)
        }
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
        sut = WorkoutEditViewModel(withType: .push, templateManagement: TemplateManagement(backgroundContext: coreDataStack.backgroundContext))
        XCTAssert(sut.type() == .push)
    }
    
    func testType_pull() {
        addWorkoutTemplate(type: .legs)
        sut = WorkoutEditViewModel(withType: .legs, templateManagement: TemplateManagement(backgroundContext: coreDataStack.backgroundContext))
        XCTAssert(sut.type() == .legs)
    }
    
    func testType_legs() {
        addWorkoutTemplate(type: .pull)
        sut = WorkoutEditViewModel(withType: .pull, templateManagement: TemplateManagement(backgroundContext: coreDataStack.backgroundContext))
        XCTAssert(sut.type() == .pull)
    }
    
    func testRowCount_section0() {
        addWorkoutTemplate()
        addExerciseTemplate(name: "ex\(exerciseCount)", workout: workoutTemplates()!.first!, addToWorkout: true)
        sut = WorkoutEditViewModel(withType: .push, templateManagement: TemplateManagement(backgroundContext: coreDataStack.backgroundContext))
        XCTAssert(sut.rowCount(section: 0) == exerciseCount)
        addExerciseTemplate(name: "ex\(exerciseCount + 1)", workout: workoutTemplates()!.first!, addToWorkout: true)
        addExerciseTemplate(name: "ex\(exerciseCount + 1)", workout: workoutTemplates()!.first!, addToWorkout: true)
        sut.reload()
        XCTAssert(sut.rowCount(section: 0) == exerciseCount)
        addExerciseTemplate(name: "ex\(exerciseCount + 1)", workout: workoutTemplates()!.first!, addToWorkout: true)
        addExerciseTemplate(name: "ex\(exerciseCount + 1)", workout: workoutTemplates()!.first!, addToWorkout: true)
        addExerciseTemplate(name: "ex\(exerciseCount + 1)", workout: workoutTemplates()!.first!, addToWorkout: true)
        addExerciseTemplate(name: "ex\(exerciseCount + 1)", workout: workoutTemplates()!.first!, addToWorkout: true)
        sut.reload()
        XCTAssert(sut.rowCount(section: 0) == exerciseCount)
    }
    
    func testRowCount_section1() {
        addWorkoutTemplate()
        addExerciseTemplate(name: "ex\(exerciseCount)", workout: workoutTemplates()!.first!)
        sut = WorkoutEditViewModel(withType: .push, templateManagement: TemplateManagement(backgroundContext: coreDataStack.backgroundContext))
        XCTAssert(sut.rowCount(section: 1) == exerciseCount)
        addExerciseTemplate(name: "ex\(exerciseCount + 1)", workout: workoutTemplates()!.first!)
        addExerciseTemplate(name: "ex\(exerciseCount + 1)", workout: workoutTemplates()!.first!)
        sut.reload()
        XCTAssert(sut.rowCount(section: 1) == exerciseCount)
        addExerciseTemplate(name: "ex\(exerciseCount + 1)", workout: workoutTemplates()!.first!)
        addExerciseTemplate(name: "ex\(exerciseCount + 1)", workout: workoutTemplates()!.first!)
        addExerciseTemplate(name: "ex\(exerciseCount + 1)", workout: workoutTemplates()!.first!)
        addExerciseTemplate(name: "ex\(exerciseCount + 1)", workout: workoutTemplates()!.first!)
        sut.reload()
        XCTAssert(sut.rowCount(section: 1) == exerciseCount)
    }
    
    func testRowCount_section0_section1() {
        addWorkoutTemplate()
        addExerciseTemplate(name: "ex\(exerciseCount)", workout: workoutTemplates()!.first!, addToWorkout: true)
        sut = WorkoutEditViewModel(withType: .push, templateManagement: TemplateManagement(backgroundContext: coreDataStack.backgroundContext))
        assertRowCounts()
        addExerciseTemplate(name: "ex\(exerciseCount + 1)", workout: workoutTemplates()!.first!, addToWorkout: true)
        addExerciseTemplate(name: "ex\(exerciseCount + 1)", workout: workoutTemplates()!.first!, addToWorkout: false)
        sut.reload()
        assertRowCounts()
        addExerciseTemplate(name: "ex\(exerciseCount + 1)", workout: workoutTemplates()!.first!, addToWorkout: true)
        addExerciseTemplate(name: "ex\(exerciseCount + 1)", workout: workoutTemplates()!.first!, addToWorkout: true)
        addExerciseTemplate(name: "ex\(exerciseCount + 1)", workout: workoutTemplates()!.first!, addToWorkout: true)
        addExerciseTemplate(name: "ex\(exerciseCount + 1)", workout: workoutTemplates()!.first!, addToWorkout: true)
        sut.reload()
        assertRowCounts()
    }
    
    func testTitleForRow_section0() {
        addWorkoutTemplate()
        sut = WorkoutEditViewModel(withType: .push, templateManagement: TemplateManagement(backgroundContext: coreDataStack.backgroundContext))
        var titles = [String]()
        for i in 0...9 {
            let title = "ex\(i)"
            addExerciseTemplate(name: title, workout: workoutTemplates()!.first!, addToWorkout: true)
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
        sut = WorkoutEditViewModel(withType: .push, templateManagement: TemplateManagement(backgroundContext: coreDataStack.backgroundContext))
        var titles = [String]()
        for i in 0...9 {
            let title = "ex\(i)"
            addExerciseTemplate(name: title, workout: workoutTemplates()!.first!)
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
        sut = WorkoutEditViewModel(withType: .push, templateManagement: TemplateManagement(backgroundContext: coreDataStack.backgroundContext))
        var selectedTitles = [String]()
        var unselectedTitles = [String]()
        for i in 0...9 {
            let title1 = "ex\(i)"
            let title2 = "\(title1)\(i)"
            addExerciseTemplate(name: title1, workout: workoutTemplates()!.first!, addToWorkout: true)
            addExerciseTemplate(name: title2, workout: workoutTemplates()!.first!, addToWorkout: false)
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
        sut = WorkoutEditViewModel(withType: .push, templateManagement: TemplateManagement(backgroundContext: coreDataStack.backgroundContext))
        XCTAssert(sut.sectionCount() == 2)
    }
    
    func testSelected() {
        addWorkoutTemplate()
        sut = WorkoutEditViewModel(withType: .push, templateManagement: TemplateManagement(backgroundContext: coreDataStack.backgroundContext))
        addExerciseTemplate(name: "ex1", workout: workoutTemplates()!.first!, addToWorkout: false)
        sut.reload()
        assertRowCounts()
        select(IndexPath(row: 0, section: 1))
        assertRowCounts()
    }
    
    func testUnselected() {
        addWorkoutTemplate()
        sut = WorkoutEditViewModel(withType: .push, templateManagement: TemplateManagement(backgroundContext: coreDataStack.backgroundContext))
        addExerciseTemplate(name: "ex1", workout: workoutTemplates()!.first!, addToWorkout: true)
        sut.reload()
        assertRowCounts()
        unselect(IndexPath(row: 0, section: 0))
        assertRowCounts()
    }
    
    func testSelectedUnselected() {
        addWorkoutTemplate()
        sut = WorkoutEditViewModel(withType: .push, templateManagement: TemplateManagement(backgroundContext: coreDataStack.backgroundContext))
        for i in 0...3 {
            addExerciseTemplate(name: "ex\(i)", workout: workoutTemplates()!.first!, addToWorkout: true)
            addExerciseTemplate(name: "ex\(i+100)", workout: workoutTemplates()!.first!, addToWorkout: false)
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
            addExerciseTemplate(name: "ex\(i+200)", workout: workoutTemplates()!.first!, addToWorkout: false)
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
            addExerciseTemplate(name: "ex\(i+100)", workout: workoutTemplates()!.first!, addToWorkout: false)
        }
        sut = WorkoutEditViewModel(withType: .push, templateManagement: TemplateManagement(backgroundContext: coreDataStack.backgroundContext))
        XCTAssert(nil == sut.titleForSection(0))
        XCTAssert("Not Added to Workout" == sut.titleForSection(1))
    }
    
    func testTitleForSection_allWorkoutsAdded_nilTitleReturnedForSection1() {
        addWorkoutTemplate()
        for i in 0...3 {
            addExerciseTemplate(name: "ex\(i+100)", workout: workoutTemplates()!.first!, addToWorkout: true)
        }
        sut = WorkoutEditViewModel(withType: .push, templateManagement: TemplateManagement(backgroundContext: coreDataStack.backgroundContext))
        XCTAssert("Added to Workout" == sut.titleForSection(0))
        XCTAssert(nil == sut.titleForSection(1))
    }
    
    func testTitleForSection() {
        addWorkoutTemplate()
        for i in 0...3 {
            addExerciseTemplate(name: "ex\(i)", workout: workoutTemplates()!.first!, addToWorkout: true)
            addExerciseTemplate(name: "ex\(i+100)", workout: workoutTemplates()!.first!, addToWorkout: false)
        }
        sut = WorkoutEditViewModel(withType: .push, templateManagement: TemplateManagement(backgroundContext: coreDataStack.backgroundContext))
        XCTAssert("Added to Workout" == sut.titleForSection(0))
        XCTAssert("Not Added to Workout" == sut.titleForSection(1))
    }

}
