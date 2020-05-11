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

class DBHelper {
    
    var coreDataStack: CoreDataTestStack!
    
    init(coreDataStack: CoreDataTestStack) {
        self.coreDataStack = coreDataStack
    }
    
    // MARK: Workout
    func insertWorkout(name: ExerciseType = .push) {
        let workout = NSEntityDescription.insertNewObject(forEntityName: "Workout", into: coreDataStack.backgroundContext) as! Workout
        workout.name = name.rawValue
        workout.dateCreated = Date()
        try? coreDataStack.backgroundContext.save()
    }
    
    func fetchWorkouts() -> [Workout] {
        let request = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Workout")
        let workouts = try! self.coreDataStack.mainContext.fetch(request)
        return workouts as! [Workout]
    }
    
    func fetchWorkoutsBackground() -> [Workout] {
        let request = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Workout")
        let workouts = try! self.coreDataStack.backgroundContext.fetch(request)
        return workouts as! [Workout]
    }
    
    func createWorkout(name: ExerciseType = .push, date: Date? = nil) -> Workout {
        let workout = NSEntityDescription.insertNewObject(forEntityName: "Workout", into: coreDataStack.backgroundContext) as! Workout
        workout.name = name.rawValue
        workout.dateCreated = date
        try? coreDataStack.backgroundContext.save()
        return workout
    }
    
    // MARK: WorkoutTemplate
    func addWorkoutTemplates() {
        for type in [ExerciseType.push, ExerciseType.pull, ExerciseType.legs] {
            insertWorkoutTemplate(type: type)
        }
    }
    
    func insertWorkoutTemplate(type: ExerciseType = .push) {
        let workout = NSEntityDescription.insertNewObject(forEntityName: "WorkoutTemplate", into: coreDataStack.backgroundContext) as! WorkoutTemplate
        workout.name = type.rawValue
        try? coreDataStack.backgroundContext.save()
    }
    
    func insertWorkoutTemplateMainContext(type: ExerciseType = .push) {
        let workout = NSEntityDescription.insertNewObject(forEntityName: "WorkoutTemplate", into: coreDataStack.mainContext) as! WorkoutTemplate
        workout.name = type.rawValue
        try? coreDataStack.mainContext.save()
    }
    
    func fetchWorkoutTemplates() -> [WorkoutTemplate] {
        let request = NSFetchRequest<NSFetchRequestResult>.init(entityName: "WorkoutTemplate")
        let workouts = try! self.coreDataStack.mainContext.fetch(request)
        return workouts as! [WorkoutTemplate]
    }
    
    func addWorkoutTemplate(type: ExerciseType = .push, exerciseNames: [String] = Names) {
        let temp = NSEntityDescription.insertNewObject(forEntityName: WrkTemp, into: coreDataStack.backgroundContext) as! WorkoutTemplate
        temp.name = type.rawValue
        temp.exerciseNames = exerciseNames
        try? coreDataStack.backgroundContext.save()
        for name in exerciseNames {
            addExerciseTemplate(name: name, type: type)
        }
    }
    
    // MARK: Exercise
    func addExercise(_ name: String, to workout: Workout) {
        let exercise = NSEntityDescription.insertNewObject(forEntityName: "Exercise", into: coreDataStack.backgroundContext) as! Exercise
        exercise.name = name
        if let wkt = coreDataStack.backgroundContext.object(with: workout.objectID) as? Workout {
            wkt.addToExercises(exercise)
        }
        try? coreDataStack.backgroundContext.save()
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
    
    func createExercise(_ name: String? = nil, sets: [(d: Int, r: Int, w: Double)]? = nil) -> Exercise {
        let exercise = NSEntityDescription.insertNewObject(forEntityName: "Exercise", into: coreDataStack.backgroundContext) as! Exercise
        exercise.name = name
        if let sets = sets {
            for set in sets {
                let exerciseSet = NSEntityDescription.insertNewObject(forEntityName: "ExerciseSet", into: coreDataStack.backgroundContext) as! ExerciseSet
                exerciseSet.duration = Int16(set.d)
                exerciseSet.reps = Int16(set.r)
                exerciseSet.weight = set.w
                exercise.addToSets(exerciseSet)
            }
        }
        try? coreDataStack.backgroundContext.save()
        return exercise
    }
    
    func addSetTo(_ exercise: Exercise) {
        let set = NSEntityDescription.insertNewObject(forEntityName: "ExerciseSet", into: coreDataStack.backgroundContext) as! ExerciseSet
        if let exerciseInContext = try? coreDataStack.backgroundContext.existingObject(with: exercise.objectID) as? Exercise {
            exerciseInContext.addToSets(set)
            try? coreDataStack.backgroundContext.save()
        }
    }
    
    // MARK: ExerciseTemplate
    
    func addExerciseTemplate(_ name: String, to workout: WorkoutTemplate, addToWorkout: Bool = false) {
        let temp = NSEntityDescription.insertNewObject(forEntityName: ExTemp, into: coreDataStack.mainContext) as! ExerciseTemplate
        temp.name = name
        temp.type = workout.name
        if addToWorkout {
            let wkt = coreDataStack.mainContext.object(with: workout.objectID) as! WorkoutTemplate
            if wkt.exerciseNames == nil {
                wkt.exerciseNames = []
            }
            wkt.exerciseNames?.append(temp.name!)
        }
    try? coreDataStack.mainContext.save()
    }
    
    func addExerciseTemplate(name: String = TempName, type: ExerciseType = .push) {
        let temp = NSEntityDescription.insertNewObject(forEntityName: ExTemp, into: coreDataStack.backgroundContext) as! ExerciseTemplate
        temp.name = name
        temp.type = type.rawValue
        try? coreDataStack.backgroundContext.save()
    }
    
    func fetchExerciseTemplates() -> [ExerciseTemplate]? {
        if let temps = try? coreDataStack.mainContext.fetch(NSFetchRequest(entityName: ExTemp)) as? [ExerciseTemplate] {
            return temps
        }
        return nil
    }
    
    // MARK: ExerciseSet
    func fetchSets(_ exercise: Exercise) -> [ExerciseSet]? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ExerciseSet")
        request.predicate = NSPredicate(format: "exercise == %@", argumentArray: [exercise])
        return try? coreDataStack.mainContext.fetch(request) as? [ExerciseSet]
    }
    
    func insertSet(_ exercise: Exercise, dwr data: (d: Int?, w: Double?, r: Int?) = (nil, nil, nil)) -> ExerciseSet {
        let set = NSEntityDescription.insertNewObject(forEntityName: "ExerciseSet", into: coreDataStack.backgroundContext) as! ExerciseSet
        if let d = data.d {
            set.duration = Int16(d)
        }
        if let w = data.w {
            set.weight = w
        }
        if let r = data.r {
            set.reps = Int16(r)
        }
        exercise.addToSets(set)
        try? coreDataStack.backgroundContext.save()
        return set
    }
    
}
