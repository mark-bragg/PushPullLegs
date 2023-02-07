//
//  CoreDataManager.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 1/25/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation
import CoreData

protocol CoreDataManagement {
    var persistentContainer: NSPersistentContainer { get }
    var mainContext: NSManagedObjectContext { get }
}

class CoreDataManager: CoreDataManagement {
    static let shared = CoreDataManager()
    private var storeType: String?
    lazy var persistentContainer: NSPersistentContainer = { [unowned self] in
        let persistentContainer = NSPersistentContainer(name: persistentContainerName)
        let description = persistentContainer.persistentStoreDescriptions.first
        description?.type = storeType ?? ""
        return persistentContainer
    }()
    lazy var mainContext: NSManagedObjectContext = { [unowned self] in
        let context = persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true
        return context
    }()
    
    func setup(storeType: String = NSSQLiteStoreType, completion: (() -> Void)?) {
        self.storeType = storeType
        loadPersistentStore { [weak self] in
            self?.addWorkouts()
            self?.cleanupUncascadedObjects()
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
    
    private func addWorkouts() {
        let mgmt = TemplateManagement(coreDataManager: self)
        guard Array.emptyOrNil(mgmt.workoutTemplates()) else {
            return
        }
        try? mgmt.addWorkoutTemplate(type: .push)
        try? mgmt.addWorkoutTemplate(type: .pull)
        try? mgmt.addWorkoutTemplate(type: .legs)
    }
    
    private func cleanupUncascadedObjects() {
        deleteExercisesWithNilWorkouts()
        deleteSetsWithNilExercises()
        save()
    }
    
    private func deleteExercisesWithNilWorkouts() {
        guard let exercises = try? mainContext.fetch(Exercise.fetchRequest()) else { return }
        for exercise in exercises {
            if exercise.workout == nil {
                mainContext.delete(exercise)
            }
        }
    }
    
    private func deleteSetsWithNilExercises() {
        guard let sets = try? mainContext.fetch(ExerciseSet.fetchRequest()) else { return }
        for set in sets {
            if set.exercise == nil {
                mainContext.delete(set)
            }
        }
    }
}

extension Array {
    static func emptyOrNil(_ arrray: Array?) -> Bool {
        arrray == nil || (arrray ?? []).count == 0
    }
}
