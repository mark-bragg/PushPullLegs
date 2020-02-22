//
//  ProgramManagerTests.swift
//  PushPullLegsTests
//
//  Created by Mark Bragg on 2/17/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import XCTest
import CoreData

@testable import PushPullLegs

let ProgramName = "ProgramNameTest"
let WorkoutNames = ["push", "pull", "legs"]
let Program = "Program"

class ProgramManagerTests: XCTestCase {

    var sut: ProgramManager!
    var coreDataStack: CoreDataTestStack!
    
    override func setUp() {
        coreDataStack = CoreDataTestStack()
        sut = ProgramManager(backgroundContext: coreDataStack.backgroundContext)
    }
    
    func assertProgramCreated() {
        guard let programs = try? coreDataStack.backgroundContext.fetch(NSFetchRequest(entityName: Program)) else {
            XCTFail()
            return
        }
        XCTAssert(programs.count == 1)
        guard let program = programs.first as? Program else {
            XCTFail()
            return
        }
        XCTAssert(program.name == ProgramName)
        XCTAssert(program.workoutNames == WorkoutNames)
    }

    func testCreateProgram_programCreated() {
        do {
            try sut.addProgram(name: ProgramName, workoutNames: WorkoutNames)
        } catch {
            XCTFail("create program error should not be thrown")
        }
        assertProgramCreated()
    }
    
    func testCreateTwoProgramsWithSameNames_oneProgramCreated() {
        let e = expectation(description: "create first")
        coreDataStack.backgroundContext.expectation = e
        do {
            try sut.addProgram(name: ProgramName, workoutNames: WorkoutNames)
        } catch {
            XCTFail("create program error should not be thrown")
        }
        waitForExpectations(timeout: 60) { (_) in
            
        }
        do {
            try self.sut.addProgram(name: ProgramName, workoutNames: WorkoutNames + ["extra workout"])
        } catch {
            guard let e = error as? ProgramError else {
                XCTFail()
                return
            }
            XCTAssert(e == ProgramError.duplicateProgram)
        }
        self.assertProgramCreated()
    }
    
    func testCreateTenProgramsWithSameNames_oneProgramCreated() {
        for _ in 0...9 {
            do {
                try sut.addProgram(name: ProgramName, workoutNames: WorkoutNames)
            } catch {
                guard let e = error as? ProgramError else {
                    XCTFail()
                    return
                }
                XCTAssert(e == ProgramError.duplicateProgram)
            }
        }
        assertProgramCreated()
    }
    
    func testGetProgram_programGeted() {
        guard let program = NSEntityDescription.insertNewObject(forEntityName: Program, into: coreDataStack.backgroundContext) as? Program else {
            XCTFail()
            return
        }
        program.name = ProgramName
        program.workoutNames = WorkoutNames
        try? coreDataStack.backgroundContext.save()
        let programToTest = sut.program(name: ProgramName)
        XCTAssert(program == programToTest)
    }
    
    func testUpdateProgram_programUpdated() {
        guard let program = NSEntityDescription.insertNewObject(forEntityName: Program, into: coreDataStack.backgroundContext) as? Program else {
            XCTFail()
            return
        }
        program.name = ProgramName
        program.workoutNames = WorkoutNames
        try? coreDataStack.backgroundContext.save()
        let updatedNames = ["upper", "lower"]
        sut.update(program, workoutNames: updatedNames)
        guard let programToTest = try? coreDataStack.backgroundContext.fetch(NSFetchRequest<NSFetchRequestResult>(entityName: Program)).first as? Program else {
            XCTFail()
            return
        }
        XCTAssert(programToTest.workoutNames == updatedNames)
    }

}
