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

class WorkoutTemplateListViewModelTests: XCTestCase {

    var sut: WorkoutTemplateListViewModel!
    let types: [ExerciseType] = [.push, .pull, .legs]
    let dbHelper = DBHelper(coreDataStack: CoreDataTestStack())
    
    override func setUp() {
        dbHelper.addWorkoutTemplates()
        sut = WorkoutTemplateListViewModel(withTemplateManagement: TemplateManagement(coreDataManager: dbHelper.coreDataStack))
    }

    func testWorkoutTitleForRow_row0row1row2_pushPullLegsReturned() {
        let titles = [sut.title(indexPath: IndexPath(row: 0, section: 0)), sut.title(indexPath: IndexPath(row: 1, section: 0)), sut.title(indexPath: IndexPath(row: 2, section: 0))]
        XCTAssert(titles.contains(ExerciseType.push.rawValue))
        XCTAssert(titles.contains(ExerciseType.pull.rawValue))
        XCTAssert(titles.contains(ExerciseType.legs.rawValue))
    }
    
    func testRowCount() {
        XCTAssert(sut.rowCount(section: 0) == 3)
    }
    
    func testSelect() {
        let indexPaths = [IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0), IndexPath(row: 2, section: 0)]
        for index in indexPaths {
            sut.select(index)
            guard let selection = sut.selectedType else { return XCTFail() }
            XCTAssert(types.contains(selection))
        }
        
    }

}
