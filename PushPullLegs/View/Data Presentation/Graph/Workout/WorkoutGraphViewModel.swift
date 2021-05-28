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
    
    private var workoutDataManager: WorkoutDataManager { dataManager as! WorkoutDataManager }
    private var type: ExerciseType
    
    init(type: ExerciseType) {
        self.type = type
        super.init(dataManager: WorkoutDataManager())
    }
    
    override func reload() {
        super.reload()
        let workouts = workoutDataManager.workouts(ascending: true, types: [type])
        let formatter = formatter()
        for workout in workouts {
            xValues.append(formatter.string(from: workout.dateCreated!))
            yValues.append(CGFloat(workout.volume()))
        }
    }
    
    override func title() -> String {
        type.rawValue
    }
    
    func getExerciseNames() -> [String] {
        guard let temps = TemplateManagement().exerciseTemplates(withType: type) else { return [] }
        return temps.map {
            $0.name!
        }.filter {
            ExerciseDataManager().exists(name: $0)
        }
    }
}
