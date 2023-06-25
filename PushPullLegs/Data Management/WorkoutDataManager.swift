//
//  WorkoutDataManager.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 1/26/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import CoreData

class WorkoutDataManager: DataManager {
    
    override init(context: NSManagedObjectContext = CoreDataManager.shared.mainContext) {
        super.init(context: context)
        entityName = EntityName.workout
    }
    
    func addExercises(withNames names: [String], to workout: Workout) {
        guard names.count > 0, let workoutInContext = fetch(workout) as? Workout else {
            return
        }
        context.performAndWait {
            for name in names {
                if let exercise = NSEntityDescription.insertNewObject(forEntityName: "Exercise", into: context) as? Exercise {
                    exercise.name = name
                    workoutInContext.addToExercises(exercise)
                }
            }
            do {
                try context.save()
            } catch {
                print(error)
            }
        }
    }
    
    func add(_ exercise: Exercise, to workout: Workout) {
        guard let exerciseInContext = fetch(exercise) as? Exercise,
            let workoutInContext = fetch(workout) as? Workout else {
                fatalError()
        }
        
        context.performAndWait {
            workoutInContext.addToExercises(exerciseInContext)
            do {
                try context.save()
            } catch {
                print(error)
            }
        }
    }
    
    func getLastWorkoutType() -> ExerciseType? {
        var type: ExerciseType?
        context.performAndWait {
            type = ExerciseType(rawValue: fetchLatestWorkout()?.name ?? "")
        }
        return type
    }
    
    private func fetchLatestWorkout() -> Workout? {
        guard let entityNameString else { return nil }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityNameString)
        request.sortDescriptors = [WorkoutSortDescriptor.dateCreated]
        request.fetchLimit = 1
        do {
            let latestWorkouts = try context.fetch(request) as? [Workout]
            if let workout = latestWorkouts?.first {
                return workout
            }
        } catch {
            
        }
        return nil
    }
    
    func previousWorkout(before date: Date?, type: ExerciseType?) -> Workout? {
        guard let entityNameString, let type else { return nil }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityNameString)
        request.sortDescriptors = [WorkoutSortDescriptor.dateCreated]
        request.fetchLimit = 2
        if let date = date {
            request.predicate =
            NSCompoundPredicate(andPredicateWithSubpredicates: [
                PPLPredicate.priorToDate(date),
                PPLPredicate.nameIsEqualTo(type.rawValue)
            ])
            request.fetchLimit = 1
        }
        do {
            let latestWorkouts = try context.fetch(request) as? [Workout]
            guard let workouts = latestWorkouts, workouts.count > 0 else { return nil }
            if date == nil && workouts.count == 1 {
                return nil
            }
            return latestWorkouts?.last
        } catch {
            
        }
        return nil
    }
    
    func workouts(ascending: Bool = false, types: [ExerciseType] = ExerciseType.allCases) -> [Workout] {
        guard let entityNameString else { return [] }
        let req = NSFetchRequest<NSFetchRequestResult>(entityName: entityNameString)
        req.sortDescriptors = [WorkoutSortDescriptor.dateCreated]
        var predicates = [NSPredicate]()
        for type in types.map({ return $0.rawValue }) {
            predicates.append(PPLPredicate.nameIsEqualTo(type))
        }
        req.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
        if let wkts = try? context.fetch(req) as? [Workout] {
            if ascending {
                return wkts.reversed()
            }
            return wkts
        }
        return []
    }
    
    func workouts(ascending: Bool = false, types: [ExerciseType] = ExerciseType.allCases, initialDate: Date? = nil, finalDate: Date? = nil) -> [Workout] {
        guard let entityNameString else { return [] }
        let req = NSFetchRequest<NSFetchRequestResult>(entityName: entityNameString)
        req.sortDescriptors = [WorkoutSortDescriptor.dateCreated]
        var predicates = [NSPredicate]()
        for type in types.map({ return $0.rawValue }) {
            predicates.append(PPLPredicate.nameIsEqualTo(type))
        }
        req.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
        if let initialDate, let finalDate, let reqPred = req.predicate {
            let datePredicate = NSPredicate(format: "dateCreated >= %@ and dateCreated <= %@", argumentArray: [initialDate, finalDate])
            req.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, reqPred])
        }
        if let wkts = try? context.fetch(req) as? [Workout] {
            if ascending {
                return wkts.reversed()
            }
            return wkts
        }
        return []
    }
    
    func exercises(type: ExerciseType, name: String) -> [Exercise] {
        guard let entityNameString else { return [] }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityNameString)
        request.predicate = NSPredicate(format: "name = %@", argumentArray: [type.rawValue])
        request.sortDescriptors = [.dateCreated]
        guard let workouts = try? context.fetch(request) as? [Workout] else { return [] }
        var exercisesToReturn = [Exercise]()
        for workout in workouts {
            if let exercises = workout.exercises?.array as? [Exercise] {
                for exercise in exercises {
                    if exercise.name == name {
                        exercisesToReturn.append(exercise)
                    }
                }
            }
        }
        return exercisesToReturn.reversed()
    }
}
