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
    
    func exerciseTemplates(withType type: ExerciseType) -> [ExerciseTemplate]? {
        exerciseManager.exerciseTemplates(withType: type)
    }
    
    func addWorkoutTemplate(type: ExerciseType) throws {
        if workoutManager.exists(name: type.rawValue) {
            throw TemplateError.duplicateWorkout
        }
        workoutManager.create(name: type.rawValue, keyValuePairs: [:])
    }
    
    func saveWorkoutTemplate(exercises: [ExerciseTemplate]) throws {
        let type = ExerciseType(rawValue: exercises[0].type!)!
    let names =  exercises.map({ (temp) -> String in
            return temp.name!
        })
        workoutManager.update(workoutTemplate(type: type), keyValuePairs: ["exerciseNames": names])
    }
    
    func workoutTemplate(type: ExerciseType) -> WorkoutTemplate {
        workoutManager.getTemplate(name: type.rawValue) as! WorkoutTemplate
    }
    
    func workoutTemplates() -> [WorkoutTemplate]? {
        return workoutManager.getAllTemplates() as? [WorkoutTemplate]
    }
    
    func addToWorkout(exercise: ExerciseTemplate) {
        let workout = workoutTemplate(type: ExerciseType(rawValue: exercise.type!) ?? .error)
        if workout.exerciseNames == nil {
            workout.exerciseNames = []
        }
        workout.exerciseNames?.append(exercise.name!)
        try? self.workoutManager.backgroundContext.save()
    }
    
    func removeFromWorkout(exercise: ExerciseTemplate) {
        let workout = workoutTemplate(type: ExerciseType(rawValue: exercise.type!) ?? .error)
        guard
            var exerciseNames = workout.exerciseNames
        else {
            // TODO: ERROR empty exerciseNames should not be empty
            return
        }
        
        exerciseNames.removeAll(where: {$0 == exercise.name})
        workout.exerciseNames = exerciseNames
        try? self.workoutManager.backgroundContext.save()
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
    
    func exerciseTemplates(withType type: ExerciseType) -> [ExerciseTemplate]? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.predicate = NSPredicate(format: "type == %@", argumentArray: [type.rawValue])
        guard let templates = try? self.backgroundContext.fetch(request) as? [ExerciseTemplate] else {
            // TODO: handle error
            return nil
        }
        return templates
    }
    
    func getAllTemplates() -> [NSManagedObject]? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        guard let templates = try? self.backgroundContext.fetch(request) as? [NSManagedObject] else {
            // TODO: handle error
            return nil
        }
        return templates
    }
    
}
