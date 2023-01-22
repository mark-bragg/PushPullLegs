//
//  WorkoutGraphViewModel.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 8/6/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation
import UIKit

class WorkoutGraphViewModel: GraphViewModel {
    
    private var workoutDataManager: WorkoutDataManager? { dataManager as? WorkoutDataManager }
    override var earliestPossibleDate: Date? {
        workoutDataManager?.workouts(ascending: true, types: [type])
            .filter { $0.dateCreated != nil }
            .map { $0.dateCreated! }
            .first
    }
    override var lastPossibleDate: Date? {
        workoutDataManager?.workouts(ascending: true, types: [type])
            .filter { $0.dateCreated != nil }
            .map { $0.dateCreated! }
            .last
    }
    
    override init(dataManager: DataManager, type: ExerciseType) {
        super.init(dataManager: dataManager, type: type)
        hasEllipsis = true
    }
    
    override func reload() {
        super.reload()
        guard let workouts = workoutDataManager?.workouts(ascending: true, types: [type], initialDate: startDate, finalDate: endDate) else { return }
        for workout in workouts {
            if let date = workout.dateCreated {
                xValues.append(formatter.string(from: date))
                yValues.append(CGFloat(workout.volume()))
            }
        }
        if startDate == nil {
            startDate = earliestPossibleDate
        }
        if endDate == nil {
            endDate = lastPossibleDate
        }
    }
    
    override func title() -> String {
        type.rawValue
    }
    
    override func data() -> GraphData? {
        normalizedWorkoutData()
    }
    
    private func normalizedWorkoutData() -> GraphData? {
        guard let workouts = workoutDataManager?.workouts(ascending: true, types: [type], initialDate: startDate, finalDate: endDate)
        else { return nil }
        var data = [GraphDataPoint]()
        var highestVolume: Double = 0
        let volumes = workouts.map { $0.volume() }
        volumes.forEach { highestVolume = $0 > highestVolume ? $0 : highestVolume }
        let normalVolumes = volumes.map { $0 / highestVolume}
        var i = 0
        var name: String = ""
        for workout in workouts {
            if let date = workout.dateCreated {
                data.append(GraphDataPoint(date: date, volume: volumes[i], normalVolume: normalVolumes[i]))
                i += 1
            }
            if name.isEmpty {
                name = workout.name ?? ""
            }
        }
        return GraphData(name: name, points: data, exerciseNames: getExerciseNames())
    }
}
