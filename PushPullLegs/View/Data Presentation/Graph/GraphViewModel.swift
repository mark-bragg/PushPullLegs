//
//  GraphViewModel.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 5/27/21.
//  Copyright © 2021 Mark Bragg. All rights reserved.
//

import Foundation
import UIKit
import Combine

class GraphViewModel: NSObject, ObservableObject {
    private(set) var type: ExerciseType
    private var workoutDataManager: WorkoutDataManager
    private var exerciseDataManager: ExerciseDataManager
    @Published var data: GraphData = GraphData(name: "", points: [], exerciseNames: [])
    var hasData: Bool {
        !data.points.isEmpty
    }
    
    init(type: ExerciseType, workoutDataManager: WorkoutDataManager = WorkoutDataManager(), exerciseDataManager: ExerciseDataManager = ExerciseDataManager()) {
        self.type = type
        self.workoutDataManager = workoutDataManager
        self.exerciseDataManager = exerciseDataManager
        super.init()
        setToWorkoutData()
    }
    
    func setToWorkoutData() {
        data = GraphDataManager.calculateWorkoutData(type: type)
    }
    
    func updateToExerciseData(_ name: String) {
        guard let exerciseData = GraphDataManager.exercisesData(name: name) else { return }
        exerciseData.startDate = data.startDate
        exerciseData.endDate = data.endDate
        data = exerciseData
    }
}

class GraphDataManager {
    static func calculateWorkoutData(_ dm: WorkoutDataManager = WorkoutDataManager(), type: ExerciseType) -> GraphData {
        let workouts = dm.workouts(ascending: true, types: [type])
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
        return GraphData(name: name, points: data, exerciseNames: getExerciseNames(type: type))
    }
    
    static func getExerciseNames(_ edm: ExerciseDataManager = ExerciseDataManager(), type: ExerciseType, excluding name: String? = nil) -> [String] {
        guard let temps = TemplateManagement().exerciseTemplates(withType: type) else { return [] }
        return temps.filter {
            $0.name != nil && $0.name != ""
        }.map {
            $0.name ?? ""
        }.filter {
            edm.exists(name: $0) && $0 != name
        }
    }
    
    static func exercisesData(_ edm: ExerciseDataManager = ExerciseDataManager(), name: String) -> GraphData? {
        guard
            let exercises = try? edm.exercises(name: name),
            let workoutName = exercises.first?.workout?.name,
            let type = ExerciseType(rawValue: workoutName)
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
        return GraphData(name: name, points: data, exerciseNames: GraphDataManager.getExerciseNames(type: type, excluding: name))
    }
}
