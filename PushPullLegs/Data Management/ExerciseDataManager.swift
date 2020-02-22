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
        entityName = ExerciseEntityName
    }
    
    func addSet(_ exercise: Exercise) {
        backgroundContext.performAndWait {
            if let set = NSEntityDescription.insertNewObject(forEntityName: ExerciseSetEntityName, into: backgroundContext) as? ExerciseSet,
                let exerciseInContext = fetch(exercise) as? Exercise {
                exerciseInContext.addToSets(set)
                try? backgroundContext.save()
            }
        }
    }
    
    func set(reps: Int, forSet set: ExerciseSet) {
        self.set(value: reps, forSet: set, withKey: "reps")
    }
    
    func set(weight: Int, forSet set: ExerciseSet) {
        self.set(value: weight, forSet: set, withKey: "weight")
    }
    
    func set(duration: Int, forSet set: ExerciseSet) {
        self.set(value: duration, forSet: set, withKey: "duration")
    }
    
    func set(value: Int, forSet set: ExerciseSet, withKey key: String) {
        backgroundContext.performAndWait {
            if let set = fetch(set) as? ExerciseSet {
                set.setValue(value, forKey: key)
                try? backgroundContext.save()
            }
        }
    }
}
