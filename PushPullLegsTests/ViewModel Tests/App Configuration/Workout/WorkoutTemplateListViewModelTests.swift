//
//  WorkoutTemplateListViewModelTests.swift
//  PushPullLegsTests
//
//  Created by Mark Bragg on 4/11/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import XCTest
import CoreData
@testable import PushPullLegs

/*
 func workoutTitleForRow(_ row: Int) -> String
 func rowCount() -> Int
 func select(_ indexPath: IndexPath)
 func selectedWorkout() -> WorkoutTemplate
 func getExerciseType() -> ExerciseType
 */

class WorkoutTemplateListViewModelTests: XCTestCase {

    var sut: WorkoutTemplateListViewModel!
    let types: [ExerciseType] = [.push, .pull, .legs]
    let dbHelper = DBHelper(coreDataStack: CoreDataTestStack())
    
    override func setUp() {
        dbHelper.addWorkoutTemplates()
        sut = WorkoutTemplateListViewModel(withTemplateManagement: TemplateManagement(coreDataManager: dbHelper.coreDataStack))
    }

    func testWorkoutTitleForRow_row0row1row2_pushPullLegsReturned() {
        let titles = [sut.workoutTitleForRow(0), sut.workoutTitleForRow(1), sut.workoutTitleForRow(2)]
        XCTAssert(titles.contains(ExerciseType.push.rawValue))
        XCTAssert(titles.contains(ExerciseType.pull.rawValue))
        XCTAssert(titles.contains(ExerciseType.legs.rawValue))
    }
    
    func testRowCount() {
        XCTAssert(sut.rowCount() == 3)
    }
    
    func testSelect() {
        let indexPaths = [IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0), IndexPath(row: 2, section: 0)]
        for index in indexPaths {
            sut.select(index)
            XCTAssert(types.contains(sut.selectedType()))
        }
        
    }

}
