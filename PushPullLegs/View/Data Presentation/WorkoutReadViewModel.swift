//
//  WorkoutReadViewModel.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 5/12/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation
import CoreData

class WorkoutReadViewModel: NSObject, ViewModel {
    
    var exerciseType: ExerciseType!
    var workoutManager: WorkoutDataManager
    var coreDataManager: CoreDataManagement!
    var exercisesDone = [Exercise]()
    var selectedIndex: IndexPath?
    var workoutId: NSManagedObjectID!
    
    init(withCoreDataManagement coreDataManagement: CoreDataManagement = CoreDataManager.shared, workout: Workout? = nil) {
        coreDataManager = coreDataManagement
        workoutManager = WorkoutDataManager(backgroundContext: coreDataManagement.mainContext)
        workoutId = workout?.objectID
        if let exercises = workout?.exercises?.array as? [Exercise] {
            exercisesDone = exercises
        }
        super.init()
    }
    
    func rowCount(section: Int) -> Int {
        return exercisesDone.count
    }
    
    func sectionCount() -> Int {
        return 1
    }
    
    
    func title(indexPath: IndexPath) -> String? {
        if indexPath.row < exercisesDone.count, let name = exercisesDone[indexPath.row].name {
            return name
        }
        return "ERROR: CAN'T GET NAME FOR INDEX PATH: \(indexPath)"
    }
    
    func detailText(indexPath: IndexPath) -> String? {
        return "\(exercisesDone[indexPath.row].volume())"
    }
    
    func getSelected() -> Any? {
        guard let indexPath = selectedIndex, indexPath.row < exercisesDone.count else { return nil }
        return exercisesDone[indexPath.row]
    }
    
    func exerciseVolumeComparison(row: Int) -> ExerciseVolumeComparison {
        guard
            let workout = workoutManager.backgroundContext.object(with: workoutId) as? Workout,
            let date = workout.dateCreated,
            let previousWorkout = workoutManager.previousWorkout(before: date),
            let previousExercise = previousWorkout.exercises?.first(where: { ($0 as! Exercise).name == exercisesDone[row].name}) as? Exercise
            else {
                return .increase }
        
        if previousExercise.volume() == exercisesDone[row].volume() {
            return .noChange
        }
        return previousExercise < exercisesDone[row] ? .increase : .decrease
    }
}

extension Workout {
    func volume() -> Double {
        var volume = 0.0
        let exercises = self.exercises!.array as! [Exercise]
        for exercise in exercises {
            volume += exercise.volume()
        }
        return volume
    }
}
