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
        context.retainsRegisteredObjects = true
        return context
    }()
    
    func setup(storeType: String = NSSQLiteStoreType, completion: (() -> Void)?) {
        self.storeType = storeType
        loadPersistentStore { [weak self] in
            self?.addWorkouts()
            self?.addExerciseTypes()
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
        let templates = mgmt.workoutTemplates() ?? []
        ExerciseTypeName.allCases.forEach { type in
            guard !templates.contains(where: { $0.name == type.rawValue }) else { return }
            try? mgmt.addWorkoutTemplate(type: type)
        }
    }
    
    private func addExerciseTypes() {
        guard let typeObjects = try? mainContext.fetch(ExerciseType.fetchRequest()) else { return }
        let etm = exerciseTypeManager()
        ExerciseTypeName.allCases.forEach { type in
            guard !typeObjects.contains(where: { $0.name == type.rawValue }) else { return }
            etm.create(name: type.rawValue)
        }
    }
    
    private func exerciseTypeManager() -> DataManager {
        let dm = DataManager()
        dm.entityName = EntityName.exerciseType
        return dm
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
