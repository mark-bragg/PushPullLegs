//
//  ExerciseDataManager.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 1/27/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import CoreData

class ExerciseDataManager: DataManager {
    override init(context: NSManagedObjectContext = CoreDataManager.shared.mainContext) {
        super.init(context: context)
        entityName = .exercise
    }
    
    override func create(name: String?, keyValuePairs pairs: [String : Any] = [:]) {
        guard let name = name else {
            return
        }
        super.create(name: name, keyValuePairs: pairs)
    }
    
    func insertSet(duration: Int, weight: Double, reps: Double, exercise: Exercise?, completion: ((_ exerciseSet: ExerciseSet) -> Void)? ) {
        context.performAndWait {
            if let set = NSEntityDescription.insertNewObject(forEntityName: EntityName.exerciseSet.rawValue, into: context) as? ExerciseSet,
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
        context.performAndWait {
            if let set = NSEntityDescription.insertNewObject(forEntityName: EntityName.unilateralExerciseSet.rawValue, into: context) as? UnilateralExerciseSet,
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
        try? context.save()
        if let completion = completion {
            completion(set)
        }
    }
    
    func set(reps: Int, forSet set: ExerciseSet) {
        self.set(value: reps, forSet: set, withKey: DBAttributeKey.reps)
    }
    
    func set(weight: Int, forSet set: ExerciseSet) {
        self.set(value: weight, forSet: set, withKey: DBAttributeKey.weight)
    }
    
    func set(duration: Int, forSet set: ExerciseSet) {
        self.set(value: duration, forSet: set, withKey: DBAttributeKey.duration)
    }
    
    func set(value: Int, forSet set: ExerciseSet, withKey key: String) {
        context.performAndWait {
            if let set = fetch(set) as? ExerciseSet {
                set.setValue(value, forKey: key)
                try? context.save()
            }
        }
    }
    
    func exercises(name: String, initialDate: Date? = nil, finalDate: Date? = nil) throws -> [Exercise] {
        guard let entityNameString else { return [] }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityNameString)
        request.predicate = NSPredicate(format: "name = %@", argumentArray: [name])
        if let initialDate, let finalDate, let reqPred = request.predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [reqPred, NSPredicate(format: "workout.dateCreated >= %@ and workout.dateCreated <= %@", argumentArray: [initialDate, finalDate])])
        }
        guard let exercises = try? context.fetch(request) as? [Exercise] else { return [] }
        do {
            let sorted = try exercises.sorted { (e1, e2) -> Bool in
                guard let workoutDate1 = e1.workout?.dateCreated, let workoutDate2 = e2.workout?.dateCreated else {
                    throw NilReferenceError.nilWorkout
                }
                return workoutDate1 < workoutDate2
            }
            return sorted
        } catch {
            throw NilReferenceError.nilWorkout
        }
    }
    
    func latestPreviousExercise(name: String) -> Exercise? {
        guard let entityNameString else { return nil }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityNameString)
        request.predicate = NSPredicate(format: "name = %@", argumentArray: [name])
        request.sortDescriptors = [NSSortDescriptor.dateCreated]
        return (try? context.fetch(request) as? [Exercise])?.first
    }
    
    func change(exerciseName oldName: String, to newName: String) {
        guard let entityNameString else { return }
        let request = NSBatchUpdateRequest(entityName: entityNameString)
        request.predicate = PPLPredicate.nameIsEqualTo(oldName)
        request.propertiesToUpdate = ["name": newName]
        _ = try? context.execute(request)
    }
    
    func createSuperSet(_ workout: Workout) -> SuperSet? {
        let superSet = NSEntityDescription.insertNewObject(forEntityName: EntityName.superSet.rawValue, into: context) as? SuperSet
        superSet?.workout = workout
        return superSet
    }
    
    func insertDropSets(_ sets: [(duration: Int, weight: Double, reps: Double)], exercise: Exercise, completion: (DropSet) -> Void) {
        var exerciseSets = [NSManagedObjectID]()
        for set in sets {
            insertSet(duration: set.duration, weight: set.weight, reps: set.reps, exercise: exercise) { [weak self] exerciseSet in
                exerciseSets.append(exerciseSet.objectID)
                if exerciseSets.count == sets.count {
                    self?.addDropSet(setIds: exerciseSets, exercise: exercise, completion: completion)
                }
            }
        }
    }
    
    private func addDropSet(setIds: [NSManagedObjectID], exercise: Exercise, completion: (DropSet) -> Void) {
        context.performAndWait {
            guard let dropSet = NSEntityDescription.insertNewObject(forEntityName: EntityName.dropSet.rawValue, into: context) as? DropSet
            else { return }
            dropSet.sets = setIds.compactMap({ $0.uriRepresentation })
            dropSet.exercise = exercise
            context.save()
        }
    }
}

enum NilReferenceError: Error {
    case nilWorkout
}

class UnilateralExerciseDataManager: ExerciseDataManager {
    override init(context: NSManagedObjectContext = CoreDataManager.shared.mainContext) {
        super.init(context: context)
        entityName = .unilateralExercise
    }
    
    func delete(set data: (w: Double, r: Double, d: Int, l: Bool), from exercise: UnilateralExercise) {
        guard
            let e = fetch(exercise.objectID) as? UnilateralExercise,
            var s = e.sets?.array as? [UnilateralExerciseSet],
            let i = s.firstIndex(where: { $0.isEqualToData(data) })
        else { return }
        
        delete(s[i])
        s.remove(at: i)
        exercise.sets = NSOrderedSet(array: s)
        try? context.save()
    }
}

extension UnilateralExerciseSet {
    public func isEqualToData(_ data: (w: Double, r: Double, d: Int, l: Bool)) -> Bool {
        return self.weight == data.w && self.reps == data.r && self.duration == data.d && self.isLeftSide == data.l
    }
}

extension DropSet {
    public func exerciseSets() -> [ExerciseSet]? {
        guard let setURLs = sets as? [URL],
              let context = managedObjectContext,
              let coordinator = context.persistentStoreCoordinator
        else { return nil }
        let setIds = setURLs.compactMap { coordinator.managedObjectID(forURIRepresentation: $0) }
        let request = ExerciseSet.fetchRequest()
        request.predicate = NSPredicate(format: "self in %@", argumentArray: [setIds])
        return managedObjectContext?.fetch(request)
    }
}
