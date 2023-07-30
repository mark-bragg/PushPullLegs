//
//  SuperSetExerciseSelectionViewModel.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 7/22/23.
//  Copyright © 2023 Mark Bragg. All rights reserved.
//

class SuperSetExerciseSelectionViewModel: ExerciseSelectionViewModel {
    private let exerciseNameToRemove: String
    
    init(withType type: ExerciseTypeName, templateManagement: TemplateManagement, minus exerciseName: String, dataSource: ExerciseSelectionViewModelDataSource? = nil) {
        self.exerciseNameToRemove = exerciseName
        super.init(withType: type, templateManagement: templateManagement, dataSource: dataSource)
    }
    
    override func reload() {
        exercises = templateManagement.exerciseTemplatesForWorkout(exerciseType)
        exercises.removeAll { $0.name == exerciseNameToRemove }
    }
    
    override func title() -> String? {
        "Select Second Exercise"
    }
}
