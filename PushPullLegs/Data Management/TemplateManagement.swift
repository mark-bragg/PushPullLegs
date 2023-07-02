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
    
    func addExerciseTemplate(name: String, type: ExerciseTypeName, unilateral: Bool = false) throws {
        let er = exerciseReader()
        if er.exists(name: name) {
            throw TemplateError.duplicateExercise
        }
        let ew = exerciseWriter()
        ew.create(name: name, keyValuePairs: [DBAttributeKey.type: type.rawValue, DBAttributeKey.unilateral: unilateral])
    }
    
    func deleteExerciseTemplate(name: String) {
        coreDataManager.mainContext.performAndWait {
            let req = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.exerciseTemplate.rawValue)
            req.predicate = PPLPredicate.nameIsEqualTo(name)
            if let exerciseTemplate = try? coreDataManager.mainContext.fetch(req).first as? ExerciseTemplate {
                removeFromWorkout(exercise: exerciseTemplate)
                coreDataManager.mainContext.delete(exerciseTemplate)
                try? coreDataManager.mainContext.save()
                PPLDefaults.instance.deleteDefaultWeightForExerciseWith(name: name)
            }
        }
        
    }
    
    func exerciseTemplate(name: String) -> ExerciseTemplate? {
        exerciseReader().getTemplate(name: name) as? ExerciseTemplate
    }
    
    func exerciseTemplates(withType type: ExerciseTypeName) -> [ExerciseTemplate]? {
        exerciseReader().exerciseTemplates(withType: type)
    }
    
    func addWorkoutTemplate(type: ExerciseTypeName) throws {
        if workoutReader().exists(name: type.rawValue) {
            throw TemplateError.duplicateWorkout
        }
        workoutWriter().create(name: type.rawValue, keyValuePairs: [:])
    }
    
    func saveWorkoutTemplate(exercises: [ExerciseTemplate]) throws {
        guard
            let exerciseType = exercises.first?.types?.anyObject() as? ExerciseType,
            let type = ExerciseTypeName.create(exerciseType)
        else { return }
        let names = exercises
            .filter { $0.name != nil }
            .map { $0.name! }
        if let template = workoutTemplate(type: type) {
            workoutWriter().update(template, keyValuePairs: [DBAttributeKey.exerciseNames: names])
        }
    }
    
    func workoutTemplate(type: ExerciseTypeName) -> WorkoutTemplate? {
        workoutReader().getTemplate(name: type.rawValue) as? WorkoutTemplate
    }
    
    func workoutTemplates() -> [WorkoutTemplate]? {
        return workoutReader().getAllTemplates() as? [WorkoutTemplate]
    }
    
    func addToWorkout(exercise: ExerciseTemplate) {
        guard
            let exerciseType = exercise.types?.anyObject() as? ExerciseType,
            let type = ExerciseTypeName.create(exerciseType),
            let workout = workoutTemplate(type: type),
            let exerciseName = exercise.name
        else { return }
        if workout.exerciseNames == nil {
            workout.exerciseNames = []
        }
        exercise.addToTypes(exerciseType)
        workout.exerciseNames?.append(exerciseName)
        try? coreDataManager.mainContext.save()
    }
    
    func removeFromWorkout(exercise: ExerciseTemplate) {
        guard
            let exerciseType = exercise.types?.anyObject() as? ExerciseType,
            let type = ExerciseTypeName.create(exerciseType),
            let workout = workoutTemplate(type: type),
            var exerciseNames = workout.exerciseNames
        else {
            // TODO: ERROR empty exerciseNames should not be empty
            return
        }
        exerciseNames.removeAll(where: {$0 == exercise.name})
        workout.exerciseNames = exerciseNames
        try? self.coreDataManager.mainContext.save()
    }
    
    func exerciseTemplatesForWorkout(_ type: ExerciseTypeName) -> [ExerciseTemplate] {
        let req = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.workoutTemplate.rawValue)
        req.fetchLimit = 1
        req.predicate = PPLPredicate.nameIsEqualTo(type.rawValue)
        if let workoutTemplate = try? coreDataManager.mainContext.fetch(req).first as? WorkoutTemplate {
            if let names = workoutTemplate.exerciseNames {
                let req = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.exerciseTemplate.rawValue)
                req.predicate = PPLPredicate.typeIsEqualTo(type)
                if let exerciseTemplates = try? coreDataManager.mainContext.fetch(req) as? [ExerciseTemplate] {
                    return exerciseTemplates.filter { (temp) -> Bool in
                        names.contains {
                            guard let name = temp.name else { return false }
                            return name == $0
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
        let edm = ExerciseDataManager(context: coreDataManager.mainContext)
        edm.entityName = .exerciseTemplate
        return edm
    }
    
    private func exerciseReader() -> ExerciseDataManager {
        let edm = ExerciseDataManager(context: coreDataManager.mainContext)
        edm.entityName = .exerciseTemplate
        return edm
    }
    
    private func workoutWriter() -> WorkoutDataManager {
        let wdm = WorkoutDataManager(context: coreDataManager.mainContext)
        wdm.entityName = .workoutTemplate
        return wdm
    }
    
    private func workoutReader() -> WorkoutDataManager {
        let wdm = WorkoutDataManager(context: coreDataManager.mainContext)
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
        guard let entityNameString else { return nil }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityNameString)
        request.predicate = PPLPredicate.nameIsEqualTo(name)
        guard let template = try? self.context.fetch(request).first as? NSManagedObject else {
            // TODO: handle error
            return nil
        }
        return template
    }
    
    func getTemplates(names: [String]) -> [ExerciseTemplate]? {
        guard let entityNameString else { return nil }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityNameString)
        var predicates = [NSPredicate]()
        for name in names {
            predicates.append(PPLPredicate.nameIsEqualTo(name))
        }
        request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
        guard let template = try? self.context.fetch(request) as? [ExerciseTemplate] else {
            // TODO: handle error
            return nil
        }
        return template
    }
    
    func exerciseTemplates(withType type: ExerciseTypeName) -> [ExerciseTemplate]? {
        guard let entityNameString else { return nil }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityNameString)
        request.predicate = PPLPredicate.typeIsEqualTo(type)
        guard let templates = try? self.context.fetch(request) as? [ExerciseTemplate] else {
            // TODO: handle error
            return nil
        }
        return templates
    }
    
    func getAllTemplates() -> [NSManagedObject]? {
        guard let entityNameString else { return nil }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityNameString)
        guard let templates = try? self.context.fetch(request) as? [NSManagedObject] else {
            // TODO: handle error
            return nil
        }
        return templates
    }
    
}
