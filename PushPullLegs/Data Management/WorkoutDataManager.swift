//
//  WorkoutDataManager.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 1/26/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import CoreData

class WorkoutDataManager: DataManager {
    
    override init(backgroundContext: NSManagedObjectContext = CoreDataManager.shared.backgroundContext) {
        super.init(backgroundContext: backgroundContext)
        entityName = EntityName.workout
    }
    
    func add(_ exercise: Exercise, to workout: Workout) {
        guard let exerciseInContext = fetch(exercise) as? Exercise,
            let workoutInContext = fetch(workout) as? Workout else {
                fatalError()
        }
        
        backgroundContext.performAndWait {
            workoutInContext.addToExercises(exerciseInContext)
            try? backgroundContext.save()
        }
    }
    
    func getLastWorkoutType() -> ExerciseType? {
        var type: ExerciseType = .error
        backgroundContext.performAndWait {
            type = ExerciseType(rawValue: fetchLatestWorkout()?.name ?? "") ?? .error
        }
        return type
    }
    
    private func fetchLatestWorkout() -> Workout? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityNameString())
        request.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: false)]
        request.fetchLimit = 1
        do {
            let latestWorkouts = try backgroundContext.fetch(request) as? [Workout]
            if let workout = latestWorkouts?.first {
                return workout
            }
        } catch {
            
        }
        return nil
    }
    
    func previousWorkout(before date: Date? = nil, type: ExerciseType? = nil) -> Workout? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityNameString())
        request.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: false)]
        request.fetchLimit = 2
        if let date = date {
            request.predicate =
            NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "dateCreated < %@", argumentArray: [date]),
                type != nil ? NSPredicate(format: "name = %@", argumentArray: [type!.rawValue]) : NSPredicate(value: true)
            ])
            request.fetchLimit = 1
        }
        do {
            let latestWorkouts = try backgroundContext.fetch(request) as? [Workout]
            guard let workouts = latestWorkouts, workouts.count > 0 else { return nil }
            if date == nil && workouts.count == 1 {
                return nil
            }
            return latestWorkouts?.last
        } catch {
            
        }
        return nil
    }
    
    func workouts(ascending: Bool = false, types: [ExerciseType] = [.push, .pull, .legs]) -> [Workout] {
        let req = NSFetchRequest<NSFetchRequestResult>(entityName: entityNameString())
        req.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: ascending)]
        var predicates = [NSPredicate]()
        for type in types.map({ return $0.rawValue }) {
            predicates.append(NSPredicate(format: "name = %@", argumentArray: [type]))
        }
        req.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
        if let wkts = try? backgroundContext.fetch(req) as? [Workout] {
            return wkts
        }
        return []
    }
}
