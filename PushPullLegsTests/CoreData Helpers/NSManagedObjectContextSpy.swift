//
//  NSManagedObjectContextSpy.swift
//  PushPullLegsTests
//
//  Created by Mark Bragg on 1/26/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit
import CoreData
import XCTest

class NSManagedObjectContextSpy: NSManagedObjectContext {
    var expectation: XCTestExpectation?
    
    var saveWasCalled = false
    
    override func performAndWait(_ block: () -> Void) {
        super.performAndWait(block)
        expectation?.fulfill()
    }
    
    override func save() throws {
        if self.hasChanges {
            do {
                try super.save()
            }
            catch {
                print("bake disaster type 1 \(error)")
            }
        }
        saveWasCalled = true
    }
}
