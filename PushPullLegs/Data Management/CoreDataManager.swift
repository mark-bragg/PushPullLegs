//
//  CoreDataManager.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 1/25/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    private var storeType: String!
    lazy var persistentContainer: NSPersistentContainer! = {
        let persistentContainer = NSPersistentContainer(name: "PushPullLegs")
        let description = persistentContainer.persistentStoreDescriptions.first
        description?.type = storeType
        return persistentContainer
    }()
    lazy var backgroundContext: NSManagedObjectContext! = {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()
    lazy var mainContext: NSManagedObjectContext! = {
        let context = persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true
        return context
    }()
    
    func setup(storeType: String = NSSQLiteStoreType, completion: (() -> Void)?) {
        self.storeType = storeType
        loadPersistentStore {
            completion?()
        }
    }
    
     func save() {
           let context = persistentContainer.viewContext
           if context.hasChanges {
               do {
                   try context.save()
               } catch {
                   // Replace this implementation with code to handle the error appropriately.
                   // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                   let nserror = error as NSError
                   fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
               }
           }
       }
    
    private func loadPersistentStore(completion: @escaping () -> Void) {
        persistentContainer.loadPersistentStores { (desc, error) in
            guard error == nil else {
                fatalError("unable to load persistent stores - \(String(describing: error))")
            }
            completion()
        }
    }
}
