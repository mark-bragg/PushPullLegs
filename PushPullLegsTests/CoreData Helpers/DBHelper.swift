//
//  UtilityFunctions.swift
//  PushPullLegsTests
//
//  Created by Mark Bragg on 4/19/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation
import CoreData
@testable import PushPullLegs

let Names = ["ex1", "ex2", "ex3"]
let ExTemp = "ExerciseTemplate"
let TempName = "TestTemplateName"
let WrkTemp = "WorkoutTemplate"

class DBHelper {
    
    var coreDataStack: CoreDataTestStack!
    
    init(coreDataStack: CoreDataTestStack) {
        self.coreDataStack = coreDataStack
        addExerciseTypes()
    }
    
    // MARK: Workout
    func insertWorkout(name: ExerciseTypeName = .push) {
        let workout = NSEntityDescription.insertNewObject(forEntityName: "Workout", into: coreDataStack.mainContext) as! Workout
        workout.name = name.rawValue
        workout.dateCreated = Date()
        try? coreDataStack.mainContext.save()
    }
    
    func fetchWorkouts() -> [Workout] {
        let request = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Workout")
        let workouts = try! self.coreDataStack.mainContext.fetch(request)
        return workouts as! [Workout]
    }
    
    func fetchWorkoutsBackground() -> [Workout] {
        let request = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Workout")
        let workouts = try! self.coreDataStack.mainContext.fetch(request)
        return workouts as! [Workout]
    }
    
    func createWorkout(name: ExerciseTypeName = .push, date: Date? = nil) -> Workout {
        let workout = NSEntityDescription.insertNewObject(forEntityName: "Workout", into: coreDataStack.mainContext) as! Workout
        workout.name = name.rawValue
        workout.dateCreated = date
        try? coreDataStack.mainContext.save()
        return workout
    }
    
    // MARK: WorkoutTemplate
    func addWorkoutTemplates() {
        for type in ExerciseTypeName.allCases {
            insertWorkoutTemplateMainContext(type: type)
        }
    }
    
    func insertWorkoutTemplate(type: ExerciseTypeName = .push) {
        guard let workout = NSEntityDescription.insertNewObject(forEntityName: "WorkoutTemplate", into: coreDataStack.mainContext) as? WorkoutTemplate else {
            assert(false, "failed to add workout template")
            return
        }
        workout.name = type.rawValue
        try? coreDataStack.mainContext.save()
    }
    
    func insertWorkoutTemplateMainContext(type: ExerciseTypeName = .push) {
        let workout = NSEntityDescription.insertNewObject(forEntityName: "WorkoutTemplate", into: coreDataStack.mainContext) as! WorkoutTemplate
        workout.name = type.rawValue
        try? coreDataStack.mainContext.save()
    }
    
    func fetchWorkoutTemplates() -> [WorkoutTemplate] {
        let request = NSFetchRequest<NSFetchRequestResult>.init(entityName: "WorkoutTemplate")
        let workouts = try! self.coreDataStack.mainContext.fetch(request)
        return workouts as! [WorkoutTemplate]
    }
    
    func addWorkoutTemplate(type: ExerciseTypeName = .push, exerciseNames: [String] = Names) {
        let temp = NSEntityDescription.insertNewObject(forEntityName: WrkTemp, into: coreDataStack.mainContext) as! WorkoutTemplate
        temp.name = type.rawValue
        temp.exerciseNames = exerciseNames
        try? coreDataStack.mainContext.save()
        for name in exerciseNames {
            addExerciseTemplate(name: name, type: type)
        }
    }
    
    // MARK: Exercise
    func addExercise(_ name: String, to workout: Workout) {
        let exercise = NSEntityDescription.insertNewObject(forEntityName: "Exercise", into: coreDataStack.mainContext) as! Exercise
        exercise.name = name
        if let wkt = coreDataStack.mainContext.object(with: workout.objectID) as? Workout {
            wkt.addToExercises(exercise)
        }
        try? coreDataStack.mainContext.save()
    }
    
    func fetchExercises(workout: Workout) -> [Exercise] {
        if let workoutInContext = try? coreDataStack.mainContext.existingObject(with: workout.objectID) as? Workout {
            return (workoutInContext.exercises?.array as? [Exercise])!
        }
        return []
    }
    
    func fetchExercises() -> [Exercise] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Exercise")
        if let exercises = try? coreDataStack.mainContext.fetch(request) as? [Exercise] {
            return exercises
        }
        return []
    }
    
    func createExercise(_ name: String? = nil, sets: [(d: Int, r: Double, w: Double)]? = nil) -> Exercise {
        let exercise = NSEntityDescription.insertNewObject(forEntityName: "Exercise", into: coreDataStack.mainContext) as! Exercise
        exercise.name = name
        if let sets = sets {
            for set in sets {
                let exerciseSet = NSEntityDescription.insertNewObject(forEntityName: "ExerciseSet", into: coreDataStack.mainContext) as! ExerciseSet
                exerciseSet.duration = Int16(set.d)
                exerciseSet.reps = set.r
                exerciseSet.weight = set.w
                exercise.addToSets(exerciseSet)
            }
        }
        try? coreDataStack.mainContext.save()
        return exercise
    }
    
    func createUnilateralExercise(_ name: String? = nil, sets: [(d: Int, r: Double, w: Double, l: Bool)]? = nil) -> UnilateralExercise {
        let exercise = NSEntityDescription.insertNewObject(forEntityName: "UnilateralExercise", into: coreDataStack.mainContext) as! UnilateralExercise
        exercise.name = name
        if let sets = sets {
            for set in sets {
                let exerciseSet = NSEntityDescription.insertNewObject(forEntityName: "UnilateralExerciseSet", into: coreDataStack.mainContext) as! UnilateralExerciseSet
                exerciseSet.duration = Int16(set.d)
                exerciseSet.reps = set.r
                exerciseSet.weight = set.w
                exerciseSet.isLeftSide = set.l
                exercise.addToSets(exerciseSet)
            }
        }
        try? coreDataStack.mainContext.save()
        return exercise
    }
    
    func addSetTo(_ exercise: Exercise, data: (r: Double, w: Double, d: Int)? = nil) {
        let set = NSEntityDescription.insertNewObject(forEntityName: "ExerciseSet", into: coreDataStack.mainContext) as! ExerciseSet
        if let exerciseInContext = try? coreDataStack.mainContext.existingObject(with: exercise.objectID) as? Exercise {
            exerciseInContext.addToSets(set)
            if let data = data {
                set.duration = Int16(data.d)
                set.reps = data.r
                set.weight = data.w
            }
            try? coreDataStack.mainContext.save()
        }
    }
    
    func addUnilateralExerciseSetTo(_ exercise: UnilateralExercise, data: (r: Double, w: Double, d: Int, l: Bool)? = nil) {
        let set = NSEntityDescription.insertNewObject(forEntityName: "UnilateralExerciseSet", into: coreDataStack.mainContext) as! UnilateralExerciseSet
        if let exerciseInContext = try? coreDataStack.mainContext.existingObject(with: exercise.objectID) as? UnilateralExercise {
            exerciseInContext.addToSets(set)
            if let data = data {
                set.duration = Int16(data.d)
                set.reps = data.r
                set.weight = data.w
                set.isLeftSide = data.l
            }
            try? coreDataStack.mainContext.save()
        }
    }
    
    // MARK: ExerciseTemplate
    
    func addExerciseTemplate(_ name: String, to workout: WorkoutTemplate, addToWorkout: Bool = false) {
        guard let temp = NSEntityDescription.insertNewObject(forEntityName: EntityName.exerciseTemplate.rawValue, into: coreDataStack.mainContext) as? ExerciseTemplate,
              let typeName = ExerciseTypeName(rawValue: workout.name ?? ""),
              let type = getOrAddExerciseType(typeName)
        else { return }
        temp.name = name
        temp.addToTypes(type)
        if addToWorkout {
            let wkt = coreDataStack.mainContext.object(with: workout.objectID) as! WorkoutTemplate
            if wkt.exerciseNames == nil {
                wkt.exerciseNames = []
            }
            wkt.exerciseNames?.append(temp.name!)
        }
        try? coreDataStack.mainContext.save()
    }
    
    func addExerciseTemplate(name: String = TempName, type: ExerciseTypeName = .push, addToWorkout: Bool = false) {
        guard let dbType = getOrAddExerciseType(type) else { return }
        if addToWorkout {
            if let wkt = fetchWorkoutTemplates().first(where: { $0.name == type.rawValue }) {
                var names = wkt.exerciseNames
                if names != nil {
                    names!.append(name)
                } else {
                    names = [name]
                }
                wkt.exerciseNames = names
                let temp = NSEntityDescription.insertNewObject(forEntityName: ExTemp, into: coreDataStack.mainContext) as! ExerciseTemplate
                temp.name = name
                temp.addToTypes(dbType)
            } else {
                addWorkoutTemplate(type: type, exerciseNames: [name])
            }
        } else {
            let temp = NSEntityDescription.insertNewObject(forEntityName: ExTemp, into: coreDataStack.mainContext) as! ExerciseTemplate
            temp.name = name
            temp.addToTypes(dbType)
        }
        try? coreDataStack.mainContext.save()
    }
    
    func addExerciseTypes() {
        if let typeObjects = try? coreDataStack.mainContext.fetch(ExerciseType.fetchRequest()) {
            ExerciseTypeName.allCases.forEach { type in
                guard !typeObjects.contains(where: { $0.name == type.rawValue }) else { return }
                getOrAddExerciseType(type)
            }
        } else {
            ExerciseTypeName.allCases.forEach { type in
                getOrAddExerciseType(type)
            }
        }
    }
    
    @discardableResult
    func getOrAddExerciseType(_ typeName: ExerciseTypeName) -> ExerciseType? {
        let req = ExerciseType.fetchRequest()
        req.predicate = NSPredicate.nameIsEqualTo(typeName.rawValue)
        if let alreadyExistingType = try? coreDataStack.mainContext.fetch(req).first {
            return alreadyExistingType
        }
        guard let type = NSEntityDescription.insertNewObject(forEntityName: EntityName.exerciseType.rawValue, into: coreDataStack.mainContext) as? ExerciseType
        else { return nil }
        type.name = typeName.rawValue
        try? coreDataStack.mainContext.save()
        return type
    }
    
    func fetchExerciseTemplates() -> [ExerciseTemplate]? {
        if let temps = try? coreDataStack.mainContext.fetch(NSFetchRequest(entityName: ExTemp)) as? [ExerciseTemplate] {
            return temps
        }
        return nil
    }
    
    func removeExerciseTemplate(type: ExerciseType, name: String) {
        guard let exTemp = fetchExerciseTemplates()?.first(where: { (temp) -> Bool in
            temp.name == name
        }) else {
            return
        }
        coreDataStack.mainContext.delete(exTemp)
        try? coreDataStack.mainContext.save()
    }
    
    // MARK: ExerciseSet
    func fetchSets(_ exercise: Exercise? = nil) -> [ExerciseSet]? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ExerciseSet")
        if let exercise = exercise {
            request.predicate = NSPredicate(format: "exercise == %@", argumentArray: [exercise])
        }
        return try? coreDataStack.mainContext.fetch(request) as? [ExerciseSet]
    }
    
    func insertSet(_ exercise: Exercise, dwr data: (d: Int?, w: Double?, r: Double?) = (nil, nil, nil)) -> ExerciseSet {
        let set = NSEntityDescription.insertNewObject(forEntityName: "ExerciseSet", into: coreDataStack.mainContext) as! ExerciseSet
        if let d = data.d {
            set.duration = Int16(d)
        }
        if let w = data.w {
            set.weight = w
        }
        if let r = data.r {
            set.reps = r
        }
        exercise.addToSets(set)
        try? coreDataStack.mainContext.save()
        return set
    }
    
}
