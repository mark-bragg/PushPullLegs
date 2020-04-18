//
//  AddWorkoutViewModel.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/6/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation

class WorkoutListViewModel {
    
    private let templateManagement: TemplateManagement
    private var workouts: [WorkoutTemplate]!
    private var selected: Int!
    private var exerciseType: ExerciseType!
    
    init(withTemplateManagement management: TemplateManagement) {
        templateManagement = management
        workouts = templateManagement.workoutTemplates()
    }
    
    func workoutTitleForRow(_ row: Int) -> String {
        guard let title = workouts[row].name else {
            // TODO: handle unnamed workout error
            return "ERROR!"
        }
        return title
    }
    
    func rowCount() -> Int {
        return workouts.count
    }
    
    func select(_ indexPath: IndexPath) {
        selected = indexPath.row
        exerciseType = workouts[selected].name.map { ExerciseType(rawValue: $0)! }
    }
    
    func selectedType() -> ExerciseType {
        return exerciseType
    }
}
