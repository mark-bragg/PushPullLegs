//
//  TemplateManagement.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 2/16/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation
import CoreData

class TemplateManagement {
    
    var workoutManager: DataManager!
    var exerciseManager: DataManager!
    
    init(backgroundContext: NSManagedObjectContext = CoreDataManager.shared.backgroundContext) {
        self.workoutManager = DataManager(backgroundContext: backgroundContext)
        self.exerciseManager = DataManager(backgroundContext: backgroundContext)
        self.workoutManager.entityName = WorkoutTemplateEntityName
        self.exerciseManager.entityName = ExerciseTemplateEntityName
    }
    
    func addExerciseTemplate(name: String, type: ExerciseType) throws {
        if exerciseManager.exists(name: name) {
            throw TemplateError.duplicateExercise
        }
        exerciseManager.create(name: name)
        if let creation = exerciseManager.creation as? ExerciseTemplate {
            creation.type = type.rawValue
            try? self.workoutManager.backgroundContext.save()
        }
    }
    
    func deleteExerciseTemplate(name: String) {
        exerciseManager.deleteTemplate(name: name)
    }
    
    func exerciseTemplate(name: String) -> ExerciseTemplate? {
        exerciseManager.getTemplate(name: name) as? ExerciseTemplate
    }
    
    // TODO: rewrite creation in DataManger extension
    func addWorkoutTemplate(name: String, type: WorkoutType, exerciseNames: [String]) throws {
        if workoutManager.exists(name: name) {
            throw TemplateError.duplicateWorkout
        }
        workoutManager.create(name: name, keyValuePairs: ["type": type.rawValue, "exerciseNames": exerciseNames])
    }
    
    func deleteWorkoutTemplate(name: String) {
        workoutManager.deleteTemplate(name: name)
    }
    
    func workoutTemplate(name: String) -> WorkoutTemplate? {
        workoutManager.getTemplate(name: name) as? WorkoutTemplate
    }
    
}

extension DataManager {
    func deleteTemplate(name: String) {
        guard let template = self.getTemplate(name: name) else {
            // TODO: handle error
            return
        }
        self.delete(template)
    }
    
    func getTemplate(name: String) -> NSManagedObject? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.predicate = NSPredicate(format: "name == %@", argumentArray: [name])
        guard let template = try? self.backgroundContext.fetch(request).first as? NSManagedObject else {
            // TODO: handle error
            return nil
        }
        return template
    }
}
