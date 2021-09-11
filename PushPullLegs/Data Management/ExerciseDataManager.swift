//
//  ExerciseDataManager.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 1/27/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import CoreData

class ExerciseDataManager: DataManager {
    override init(backgroundContext: NSManagedObjectContext = CoreDataManager.shared.backgroundContext) {
        super.init(backgroundContext: backgroundContext)
        entityName = .exercise
    }
    
    override func create(name: String?, keyValuePairs pairs: [String : Any] = [:]) {
        guard let name = name else {
            return
        }
        super.create(name: name, keyValuePairs: pairs)
    }
    
    func insertSet(duration: Int, weight: Double, reps: Double, exercise: Exercise, completion: ((_ exerciseSet: ExerciseSet) -> Void)? ) {
        backgroundContext.performAndWait {
            if let set = NSEntityDescription.insertNewObject(forEntityName: EntityName.exerciseSet.rawValue, into: backgroundContext) as? ExerciseSet,
                let exerciseInContext = fetch(exercise) as? Exercise {
                addSet(set, toExercise: exerciseInContext, withData: (Int16(duration), weight, reps), completion: completion)
            }
        }
    }
    
    func insertLeftSet(duration: Int, weight: Double, reps: Double, exercise: UnilateralExercise, completion: ((_ exerciseSet: ExerciseSet) -> Void)? ) {
        insertSetRightLeft(true, duration: duration, weight: weight, reps: reps, exercise: exercise, completion: completion)
    }
    
    func insertRightSet(duration: Int, weight: Double, reps: Double, exercise: UnilateralExercise, completion: ((_ exerciseSet: ExerciseSet) -> Void)? ) {
        insertSetRightLeft(false, duration: duration, weight: weight, reps: reps, exercise: exercise, completion: completion)
    }
    
    fileprivate func insertSetRightLeft(_ isLeft: Bool, duration: Int, weight: Double, reps: Double, exercise: UnilateralExercise, completion: ((_ exerciseSet: ExerciseSet) -> Void)? ) {
        backgroundContext.performAndWait {
            if let set = NSEntityDescription.insertNewObject(forEntityName: EntityName.unilateralExerciseSet.rawValue, into: backgroundContext) as? UnilateralExerciseSet,
                let exerciseInContext = fetch(exercise) as? Exercise {
                set.isLeftSide = isLeft
                addSet(set, toExercise: exerciseInContext, withData: (Int16(duration), weight, reps), completion: completion)
            }
        }
    }
    
    fileprivate func addSet(_ set: ExerciseSet, toExercise exerciseInContext: Exercise, withData data: (duration: Int16, weight: Double, reps: Double), completion: ((_ exerciseSet: ExerciseSet) -> Void)? ) {
        set.duration = data.duration
        set.weight = data.weight
        set.reps = data.reps
        exerciseInContext.addToSets(set)
        try? backgroundContext.save()
        if let completion = completion {
            completion(set)
        }
    }
    
    func set(reps: Int, forSet set: ExerciseSet) {
        self.set(value: reps, forSet: set, withKey: PPLObjectKey.reps)
    }
    
    func set(weight: Int, forSet set: ExerciseSet) {
        self.set(value: weight, forSet: set, withKey: PPLObjectKey.weight)
    }
    
    func set(duration: Int, forSet set: ExerciseSet) {
        self.set(value: duration, forSet: set, withKey: PPLObjectKey.duration)
    }
    
    func set(value: Int, forSet set: ExerciseSet, withKey key: String) {
        backgroundContext.performAndWait {
            if let set = fetch(set) as? ExerciseSet {
                set.setValue(value, forKey: key)
                try? backgroundContext.save()
            }
        }
    }
    
    func exercises(name: String) throws -> [Exercise] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName.rawValue)
        request.predicate = NSPredicate(format: "name = %@", argumentArray: [name])
        guard let exercises = try? backgroundContext.fetch(request) as? [Exercise] else { return [] }
        do {
            let sorted = try exercises.sorted { (e1, e2) -> Bool in
                if e1.workout == nil || e2.workout == nil {
                    throw NilReferenceError.nilWorkout
                }
                return e1.workout!.dateCreated! < e2.workout!.dateCreated!
            }
            return sorted
        } catch {
            throw NilReferenceError.nilWorkout
        }
    }
}

enum NilReferenceError: Error {
    case nilWorkout
}

class UnilateralExerciseDataManager: ExerciseDataManager {
    override init(backgroundContext: NSManagedObjectContext = CoreDataManager.shared.backgroundContext) {
        super.init(backgroundContext: backgroundContext)
        entityName = .unilateralExercise
    }
    
    func delete(set data: (w: Double, r: Double, d: Int, l: Bool), from exercise: UnilateralExercise) {
        guard
            let e = fetch(exercise.objectID) as? UnilateralExercise,
            var s = e.sets?.array as? [UnilateralExerciseSet],
            let i = s.firstIndex(where: { $0.weight == data.w && $0.reps == data.r && $0.duration == data.d && $0.isLeftSide == data.l })
        else { return }
        
        delete(s[i])
        s.remove(at: i)
        exercise.sets = NSOrderedSet(array: s)
        try? backgroundContext.save()
    }
}
