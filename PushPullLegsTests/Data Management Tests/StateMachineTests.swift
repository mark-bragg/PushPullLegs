//
//  StateMachineTests.swift
//  PushPullLegsTests
//
//  Created by Mark Bragg on 2/22/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import XCTest

@testable import PushPullLegs

class StateMachineTests: XCTestCase {

    var sut: StateMachine!
    
    override func setUp() {
        sut = StateMachine.shared
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_correctState_standardLaunch() {
        XCTAssert(sut.appIsInValidState())
    }
    
    func test_correctState_creatingProgramWorkoutExercise() {
        
    }

}
