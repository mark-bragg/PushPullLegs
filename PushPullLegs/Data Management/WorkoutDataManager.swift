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
        entityName = "Workout"
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
    
    func fetchLatestWorkout() -> Workout? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
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
    
    func workouts() -> [Workout] {
        let req = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        if let wkts = try? backgroundContext.fetch(req) as? [Workout] {
            return wkts
        }
        return []
    }
}
