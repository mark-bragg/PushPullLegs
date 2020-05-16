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
    
    private let coreDataManager: CoreDataManagement
    
    init(coreDataManager: CoreDataManagement = CoreDataManager.shared) {
        self.coreDataManager = coreDataManager
    }
    
    func addExerciseTemplate(name: String, type: ExerciseType) throws {
        let er = exerciseReader()
        if er.exists(name: name) {
            throw TemplateError.duplicateExercise
        }
        let ew = exerciseWriter()
        ew.create(name: name, keyValuePairs: ["type": type.rawValue])
    }
    
    func deleteExerciseTemplate(name: String) {
        coreDataManager.mainContext.performAndWait {
            let req = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.exerciseTemplate.rawValue)
            req.predicate = NSPredicate(format: "name == %@", argumentArray: [name])
            if let template = try? coreDataManager.backgroundContext.fetch(req).first as? ExerciseTemplate {
                coreDataManager.backgroundContext.delete(template)
                try? coreDataManager.backgroundContext.save()
            }
        }
        
    }
    
    func exerciseTemplate(name: String) -> ExerciseTemplate? {
        exerciseReader().getTemplate(name: name) as? ExerciseTemplate
    }
    
    func exerciseTemplates(withType type: ExerciseType) -> [ExerciseTemplate]? {
        exerciseReader().exerciseTemplates(withType: type)
    }
    
    func addWorkoutTemplate(type: ExerciseType) throws {
        if workoutReader().exists(name: type.rawValue) {
            throw TemplateError.duplicateWorkout
        }
        workoutWriter().create(name: type.rawValue, keyValuePairs: [:])
    }
    
    func saveWorkoutTemplate(exercises: [ExerciseTemplate]) throws {
        let type = ExerciseType(rawValue: exercises[0].type!)!
        let names =  exercises.map({ (temp) -> String in
            return temp.name!
        })
        workoutWriter().update(workoutTemplate(type: type), keyValuePairs: ["exerciseNames": names])
    }
    
    func workoutTemplate(type: ExerciseType) -> WorkoutTemplate {
        workoutReader().getTemplate(name: type.rawValue) as! WorkoutTemplate
    }
    
    func workoutTemplates() -> [WorkoutTemplate]? {
        return workoutReader().getAllTemplates() as? [WorkoutTemplate]
    }
    
    func addToWorkout(exercise: ExerciseTemplate) {
        let workout = workoutTemplate(type: ExerciseType(rawValue: exercise.type!) ?? .error)
        if workout.exerciseNames == nil {
            workout.exerciseNames = []
        }
        workout.exerciseNames?.append(exercise.name!)
        try? coreDataManager.mainContext.save()
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
        try? self.coreDataManager.mainContext.save()
    }
    
    func exerciseTemplatesForWorkout(_ type: ExerciseType) -> [ExerciseTemplate] {
        let req = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.workoutTemplate.rawValue)
        req.fetchLimit = 1
        req.predicate = NSPredicate(format: "name == %@", argumentArray: [type.rawValue])
        if let workoutTemplate = try? coreDataManager.mainContext.fetch(req).first as? WorkoutTemplate {
            if let names = workoutTemplate.exerciseNames {
                let req = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.exerciseTemplate.rawValue)
                req.predicate = NSPredicate(format: "type == %@", argumentArray: [type.rawValue])
                if let exerciseTemplates = try? coreDataManager.mainContext.fetch(req) as? [ExerciseTemplate] {
                    return exerciseTemplates.filter { (temp) -> Bool in
                        return names.contains { (name) -> Bool in
                            return temp.name! == name
                        }
                    }
                }
            }
        }
        guard
            let workoutTemplate = workoutReader().getTemplate(name: type.rawValue) as? WorkoutTemplate,
            let names = workoutTemplate.exerciseNames,
            let exerciseTemplates = exerciseReader().getTemplates(names: names)
        else
        {
            return []
        }
        return exerciseTemplates
    }
    
    private func exerciseWriter() -> ExerciseDataManager {
        let edm = ExerciseDataManager(backgroundContext: coreDataManager.backgroundContext)
        edm.entityName = .exerciseTemplate
        return edm
    }
    
    private func exerciseReader() -> ExerciseDataManager {
        let edm = ExerciseDataManager(backgroundContext: coreDataManager.mainContext)
        edm.entityName = .exerciseTemplate
        return edm
    }
    
    private func workoutWriter() -> WorkoutDataManager {
        let wdm = WorkoutDataManager(backgroundContext: coreDataManager.backgroundContext)
        wdm.entityName = .workoutTemplate
        return wdm
    }
    
    private func workoutReader() -> WorkoutDataManager {
        let wdm = WorkoutDataManager(backgroundContext: coreDataManager.mainContext)
        wdm.entityName = .workoutTemplate
        return wdm
    }
    
}

fileprivate extension DataManager {
    func deleteTemplate(name: String) {
        guard let template = self.getTemplate(name: name) else {
            // TODO: handle error
            return
        }
        self.delete(template)
    }
    
    func getTemplate(name: String) -> NSManagedObject? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityNameString())
        request.predicate = NSPredicate(format: "name == %@", argumentArray: [name])
        guard let template = try? self.backgroundContext.fetch(request).first as? NSManagedObject else {
            // TODO: handle error
            return nil
        }
        return template
    }
    
    func getTemplates(names: [String]) -> [ExerciseTemplate]? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityNameString())
        var predicates = [NSPredicate]()
        for name in names {
            predicates.append(NSPredicate(format: "name == %@", argumentArray: [name]))
        }
        request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
        guard let template = try? self.backgroundContext.fetch(request) as? [ExerciseTemplate] else {
            // TODO: handle error
            return nil
        }
        return template
    }
    
    func exerciseTemplates(withType type: ExerciseType) -> [ExerciseTemplate]? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityNameString())
        request.predicate = NSPredicate(format: "type == %@", argumentArray: [type.rawValue])
        guard let templates = try? self.backgroundContext.fetch(request) as? [ExerciseTemplate] else {
            // TODO: handle error
            return nil
        }
        return templates
    }
    
    func getAllTemplates() -> [NSManagedObject]? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityNameString())
        guard let templates = try? self.backgroundContext.fetch(request) as? [NSManagedObject] else {
            // TODO: handle error
            return nil
        }
        return templates
    }
    
}
