//
//  WorkoutReadViewModel.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 5/12/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation

class WorkoutReadViewModel: NSObject {
    
    var exerciseType: ExerciseType!
    var workoutManager: WorkoutDataManager
    var coreDataManager: CoreDataManagement!
    var exercisesDone = [Exercise]()
    var selectedIndex: IndexPath?
    
    init(withType type: ExerciseType? = nil, coreDataManagement: CoreDataManagement = CoreDataManager.shared) {
        coreDataManager = coreDataManagement
        workoutManager = WorkoutDataManager(backgroundContext: coreDataManagement.mainContext)
        exerciseType = type
        super.init()
    }
    
    func sectionCount() -> Int {
        return 1
    }

    func rowsForSection(_ section: Int) -> Int {
        return exercisesDone.count
    }
    
    func titleForIndexPath(_ indexPath: IndexPath) -> String {
        if indexPath.row < exercisesDone.count, let name = exercisesDone[indexPath.row].name {
            return name
        }
        return "ERROR: CAN'T GET NAME FOR INDEX PATH: \(indexPath)"
    }
    
    func detailText(indexPath: IndexPath) -> String? {
        return "\(volumeFor(exercise: exercisesDone[indexPath.row]))"
    }
    
    func getSelected() -> Any? {
        guard let indexPath = selectedIndex, indexPath.row < exercisesDone.count else { return nil }
        return exercisesDone[indexPath.row]
    }
    
    func exerciseVolumeComparison(row: Int) -> ExerciseVolumeComparison {
        guard let previousWorkout = workoutManager.previousWorkout(),
            let exerciseToCompare = previousWorkout.exercises?.first(where: { ($0 as! Exercise).name == exercisesDone[row].name}) as? Exercise
            else { return .increase }
        if exerciseToCompare.volume() == exercisesDone[row].volume() {
            return .noChange
        }
        return exerciseToCompare < exercisesDone[row] ? .increase : .decrease
    }
    
    private func volumeFor(exercise: Exercise) -> Double {
        guard let sets = exercise.sets?.array as? [ExerciseSet] else { return 0 }
        
        var volume = 0.0
        for set in sets {
            volume += (Double(set.duration) * set.weight * Double(set.reps)) / 60.0
        }
        return volume
    }
}
