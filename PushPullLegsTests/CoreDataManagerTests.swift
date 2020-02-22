//
//  PushPullLegsTests.swift
//  PushPullLegsTests
//
//  Created by Mark Bragg on 1/25/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import XCTest
import CoreData
@testable import PushPullLegs

class CoreDataManagerTests: XCTestCase {

    var sut: CoreDataManager!
    var completion: (() -> Void)?
    var type = NSInMemoryStoreType
    
    override func setUp() {
        self.sut = CoreDataManager()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func handleSetupCompletion() {
        let setupExpecation = expectation(description: "test setup completion")
        sut.setup(storeType: type) {
            setupExpecation.fulfill()
            self.completion?()
        }
        wait(for: [setupExpecation], timeout: 60)
    }
    
    func testSetupPersistentStoreCreated() {
        handleSetupCompletion()
        XCTAssert(sut.persistentContainer.persistentStoreCoordinator.persistentStores.count > 0)
    }
    
    func testSetupPersistentContainerLoadedOnDisk() {
        type = NSSQLiteStoreType
        let destroyExpectation = expectation(description: "finished loading on disk")
        completion = {
            XCTAssertEqual(self.sut.persistentContainer.persistentStoreDescriptions.first?.type, NSSQLiteStoreType)
            destroyExpectation.fulfill()
        }
        handleSetupCompletion()
        wait(for: [destroyExpectation], timeout: 60)
        try! self.sut.persistentContainer.persistentStoreCoordinator.remove(self.sut.persistentContainer.persistentStoreCoordinator.persistentStores.first!)
    }
    
    func testSetupPersistentContainerLoadedInMemory() {
        completion = {
            XCTAssertEqual(self.sut.persistentContainer.persistentStoreDescriptions.first?.type, self.type)
        }
        handleSetupCompletion()
    }
    
    func test_backgroundContext_concurrencyType() {
        completion = {
            XCTAssertEqual(self.sut.backgroundContext.concurrencyType, .privateQueueConcurrencyType)
        }
        handleSetupCompletion()
    }
    
    func test_mainContext_concurrencyType() {
        completion = {
            XCTAssertEqual(self.sut.mainContext.concurrencyType, .mainQueueConcurrencyType)
        }
        handleSetupCompletion()
    }

}
