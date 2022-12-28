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
    private(set) var type: ExerciseType
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
    
    init(type: ExerciseType, dataManager: WorkoutDataManager = WorkoutDataManager()) {
        self.type = type
        super.init(dataManager: dataManager)
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
    
    func getExerciseNames() -> [String] {
        guard let temps = TemplateManagement().exerciseTemplates(withType: type) else { return [] }
        return temps.filter {
            $0.name != nil && $0.name != ""
        }.map {
            $0.name ?? ""
        }.filter {
            ExerciseDataManager().exists(name: $0)
        }
    }
}
