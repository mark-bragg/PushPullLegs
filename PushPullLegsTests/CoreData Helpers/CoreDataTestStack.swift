//
//  CoreDataTestStack.swift
//  PushPullLegsTests
//
//  Created by Mark Bragg on 1/26/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation
import CoreData

class CoreDataTestStack {
    let persistentContainer: NSPersistentContainer
    let backgroundContext: NSManagedObjectContextSpy
    let mainContext: NSManagedObjectContextSpy
    
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
        
        backgroundContext = NSManagedObjectContextSpy(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.automaticallyMergesChangesFromParent = true
        backgroundContext.mergePolicy = NSErrorMergePolicy//NSMergeByPropertyObjectTrumpMergePolicy
        backgroundContext.parent = mainContext
    }
}
