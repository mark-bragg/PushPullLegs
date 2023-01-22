//
//  ExerciseGraphViewModel.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 5/27/21.
//  Copyright © 2021 Mark Bragg. All rights reserved.
//

import Foundation
import UIKit

class ExerciseGraphViewModel: GraphViewModel {
    
    private var name: String
    private(set) var otherNames: [String]
    private var exerciseDataManager: ExerciseDataManager { dataManager as? ExerciseDataManager ?? ExerciseDataManager() }
    override var earliestPossibleDate: Date? {
        WorkoutDataManager().workouts(ascending: true, types: [type])
            .filter { $0.dateCreated != nil }
            .map { $0.dateCreated! }
            .first
    }
    override var lastPossibleDate: Date? {
        WorkoutDataManager().workouts(ascending: true, types: [type])
            .filter { $0.dateCreated != nil }
            .map { $0.dateCreated! }
            .last
    }
    
    init(name: String, otherNames: [String], type: ExerciseType) {
        self.name = name
        self.otherNames = otherNames
        super.init(dataManager: ExerciseDataManager(), type: type)
        hasEllipsis = otherNames.count > 0
    }
    
    override func reload() {
        super.reload()
        // TODO: turn this into performReload() to avoid the super call and extract the start/end date setter
        var exercises: [Exercise]
        do {
            exercises = try exerciseDataManager.exercises(name: name, initialDate: startDate, finalDate: endDate)
        } catch NilReferenceError.nilWorkout {
            exercises = WorkoutDataManager().exercises(type: type, name: name)
        } catch {
            exercises = []
        }
        for exercise in exercises {
            if let date = exercise.workout?.dateCreated {
                xValues.append(formatter.string(from: date))
                yValues.append(CGFloat(exercise.volume()))
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
        name
    }
    
    override func data() -> GraphData? {
        guard let exercises = try? exerciseDataManager.exercises(name: name, initialDate: startDate, finalDate: endDate)
        else { return nil }
        var data = [GraphDataPoint]()
        var highestVolume: Double = 0
        let volumes = exercises.map { $0.volume() }
        volumes.forEach { highestVolume = $0 > highestVolume ? $0 : highestVolume }
        let normalVolumes = volumes.map { $0 / highestVolume}
        var i = 0
        for exercise in exercises {
            if let date = exercise.workout?.dateCreated {
                data.append(GraphDataPoint(date: date, volume: volumes[i], normalVolume: normalVolumes[i]))
                i += 1
            }
        }
        return GraphData(name: name, points: data, exerciseNames: getExerciseNames())
    }
}
