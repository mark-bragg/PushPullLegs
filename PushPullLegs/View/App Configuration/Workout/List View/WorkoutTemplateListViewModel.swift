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
    private var workouts: [WorkoutTemplate]?
    private(set) var selectedType: ExerciseTypeName?
    
    init(withTemplateManagement management: TemplateManagement) {
        templateManagement = management
        workouts = templateManagement.workoutTemplates()?.sorted(by: sorter).reversed()
    }
    
    func title(indexPath: IndexPath) -> String? {
        workouts?[indexPath.row].name
    }
    
    func title() -> String? {
        "Workouts"
    }
    
    func rowCount(section: Int) -> Int {
        (workouts ?? []).count
    }
    
    func select(_ indexPath: IndexPath) {
        guard let workouts, indexPath.row < workouts.count else { return }
        selectedType = workouts[indexPath.row].name.map { ExerciseTypeName(rawValue: $0)! }
    }
}
