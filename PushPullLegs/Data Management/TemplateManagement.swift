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
    
    func addExerciseTemplate(name: String, types: [ExerciseTypeName], unilateral: Bool = false) throws {
        let er = exerciseReader()
        if er.exists(name: name) {
            throw TemplateError.duplicateExercise
        }
        let ew = exerciseWriter()
        ew.create(name: name, keyValuePairs: [DBAttributeKey.unilateral: unilateral])
        guard let et = ew.creation as? ExerciseTemplate else {
            throw TemplateError.failedToCreateExercise
        }
        for type in getExerciseTypes(types) {
            et.addToTypes(type)
        }
        try? coreDataManager.mainContext.save()
    }
    
    func getExerciseTypes(_ typeNames: [ExerciseTypeName] = ExerciseTypeName.allCases) -> [ExerciseType] {
        let typeNameStrings = typeNames.map { $0.rawValue }
        let req = ExerciseType.fetchRequest()
        req.predicate = NSPredicate(format: "name IN %@", argumentArray: [typeNameStrings])
        return (try? coreDataManager.mainContext.fetch(req)) ?? []
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
    
    func exerciseTemplates() -> [ExerciseTemplate]? {
        exerciseReader().exerciseTemplates()
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
        guard let exerciseTypes = exercise.types?.allObjects as? [ExerciseType] else { return }
        for exerciseType in exerciseTypes {
            guard
                let type = ExerciseTypeName.create(exerciseType),
                let workout = workoutTemplate(type: type),
                let exerciseName = exercise.name
            else { return }
            if workout.exerciseNames == nil {
                workout.exerciseNames = []
            }
            workout.exerciseNames?.append(exerciseName)
            try? coreDataManager.mainContext.save()
        }
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
        guard let workoutTemp = workoutTemplate(type: type),
              let exerciseNames = workoutTemp.exerciseNames
        else { return [] }
        let req = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.exerciseTemplate.rawValue)
        let typeIsInPred = PPLPredicate.typeIsEqualTo(type)
        let nameIsInPred = PPLPredicate.nameIsIn(exerciseNames)
        req.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [typeIsInPred, nameIsInPred])
        return (try? coreDataManager.mainContext.fetch(req) as? [ExerciseTemplate]) ?? []
    }
    
    func update(exerciseTemplate: ExerciseTemplate, with name: String, and types: [ExerciseTypeName]) {
        exerciseTemplate.name = name
        for type in getExerciseTypes(ExerciseTypeName.allCases) {
            exerciseTemplate.removeFromTypes(type)
        }
        for type in getExerciseTypes(types) {
            exerciseTemplate.addToTypes(type)
        }
        try? coreDataManager.mainContext.save()
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
    
    func exerciseTemplates(withType type: ExerciseTypeName? = nil) -> [ExerciseTemplate]? {
        guard let entityNameString else { return nil }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityNameString)
        if let type {
            request.predicate = PPLPredicate.typeIsEqualTo(type)
        }
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
