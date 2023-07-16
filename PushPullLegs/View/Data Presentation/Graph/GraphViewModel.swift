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
    private(set) var type: ExerciseTypeName
    private var workoutDataManager: WorkoutDataManager
    private var exerciseDataManager: ExerciseDataManager
    @Published var data: GraphData = GraphData(name: "", points: [], exerciseNames: [])
    var hasData: Bool {
        !data.points.isEmpty
    }
    
    init(type: ExerciseTypeName, workoutDataManager: WorkoutDataManager = WorkoutDataManager(), exerciseDataManager: ExerciseDataManager = ExerciseDataManager()) {
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

struct GraphPointDTO {
    let volume: Double
    let dateCreated: Date?
}

class GraphDataManager {
    static func calculateWorkoutData(_ dm: WorkoutDataManager = WorkoutDataManager(), type: ExerciseTypeName) -> GraphData {
        let workouts = dm.workouts(ascending: true, types: [type])
            .map { GraphPointDTO(volume: $0.volume(), dateCreated: $0.dateCreated) }
        return graphData(workouts, type: type, name: type.rawValue)
    }
    
    static func exercisesData(_ edm: ExerciseDataManager = ExerciseDataManager(), name: String) -> GraphData? {
        guard
            let exercises = try? edm.exercises(name: name),
            let workoutName = exercises.first?.workout?.name,
            let type = ExerciseTypeName(rawValue: workoutName)
        else { return nil }
        return graphData(exercises.map({ GraphPointDTO(volume: $0.volume(), dateCreated: $0.workout?.dateCreated) }), type: type, name: name, excludedName: name)
    }
    
    private static func graphData(_ dto: [GraphPointDTO], type: ExerciseTypeName, name: String, excludedName: String? = nil) -> GraphData {
        var data = [GraphDataPoint]()
        for datum in dto {
            if let date = datum.dateCreated {
                data.append(GraphDataPoint(date: date, volume: datum.volume))
            }
        }
        return GraphData(name: name, points: data, exerciseNames: GraphDataManager.getExerciseNames(type: type, excluding: excludedName))
    }
    
    private static func getExerciseNames(_ edm: ExerciseDataManager = ExerciseDataManager(), type: ExerciseTypeName, excluding name: String? = nil) -> [String] {
        guard let temps = TemplateManagement().exerciseTemplates(withType: type) else { return [] }
        return temps.filter {
            $0.name != nil && $0.name != ""
        }.map {
            $0.name ?? ""
        }.filter {
            edm.exists(name: $0) && $0 != name
        }
    }
}
