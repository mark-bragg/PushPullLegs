//
//  AddWorkoutViewModel.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/6/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation

class WorkoutTemplateListViewModel: NSObject, PPLTableViewModel {
    private let templateManagement: TemplateManagement
    private var workouts: [WorkoutTemplate]!
    private var selected: Int!
    private var exerciseType: ExerciseType!
    
    init(withTemplateManagement management: TemplateManagement) {
        templateManagement = management
        workouts = templateManagement.workoutTemplates()?.sorted(by: sorter).reversed()
    }
    
    func title(indexPath: IndexPath) -> String? {
        workouts[indexPath.row].name
    }
    
    func title() -> String? {
        "Workouts"
    }
    
    func rowCount(section: Int) -> Int {
        workouts.count
    }
    
    func select(_ indexPath: IndexPath) {
        selected = indexPath.row
        exerciseType = workouts[selected].name.map { ExerciseType(rawValue: $0)! }
    }
    
    func selectedType() -> ExerciseType {
        exerciseType
    }
}
