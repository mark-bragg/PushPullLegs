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
}
