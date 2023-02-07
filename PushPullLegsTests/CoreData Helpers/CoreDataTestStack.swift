//
//  CoreDataTestStack.swift
//  PushPullLegsTests
//
//  Created by Mark Bragg on 1/26/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation
import CoreData
@testable import PushPullLegs


class CoreDataTestStack: CoreDataManagement {
    var persistentContainer: NSPersistentContainer
    
    var mainContext: NSManagedObjectContext
    
    init() {
        let persistentContainer = NSPersistentContainer(name: "PushPullLegs")
        let desc = persistentContainer.persistentStoreDescriptions.first
        desc?.type = NSInMemoryStoreType
        
        persistentContainer.loadPersistentStores { (desc, error) in
            guard error == nil else {
                fatalError("was unable to load store \(error!)")
            }
            persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
            persistentContainer.viewContext.mergePolicy = NSErrorMergePolicy//NSMergeByPropertyObjectTrumpMergePolicy
        }
        self.persistentContainer = persistentContainer
        
        mainContext = NSManagedObjectContextSpy(concurrencyType: .mainQueueConcurrencyType)
        mainContext.automaticallyMergesChangesFromParent = true
        mainContext.mergePolicy = NSErrorMergePolicy//NSMergeByPropertyObjectTrumpMergePolicy
        mainContext.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
    }
}
