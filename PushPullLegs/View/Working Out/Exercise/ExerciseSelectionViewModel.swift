//
//  ExerciseSelectionViewModel.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/19/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation

class ExerciseSelectionViewModel: NSObject, PPLTableViewModel, ReloadProtocol {
    
    private var exercises = [ExerciseTemplate]()
    private var selectedIndices = [Int]()
    let exerciseType: ExerciseType
    private var templateManagement: TemplateManagement
    var multiSelect: Bool = true
    
    init(withType type: ExerciseType, templateManagement: TemplateManagement) {
        self.templateManagement = templateManagement
        exerciseType = type
        super.init()
        reload()
    }
    
    func rowCount(section: Int) -> Int {
        return exercises.count
    }
    
    func title(indexPath: IndexPath) -> String? {
        guard let name = exercises[indexPath.row].name else {
            return "ERROR"
        }
        return name
    }
    
    func isSelected(row: Int) -> Bool {
        return selectedIndices.contains(row)
    }
    
    func selected(row: Int) {
        selectedIndices.append(row)
    }
    
    func deselected(row: Int) {
        selectedIndices.removeAll(where: { $0 == row })
    }
    
    func commitChanges() {
        for index in selectedIndices {
            templateManagement.addToWorkout(exercise: exercises[index])
        }
        reload()
    }
    
    func selectedExercises() -> [ExerciseTemplate] {
        var selected = [ExerciseTemplate]()
        for index in selectedIndices {
            selected.append(exercises[index])
        }
        return selected
    }
    
    func reload() {
        let alreadyAddedExercises = templateManagement.exerciseTemplatesForWorkout(exerciseType)
        if let exercisesToBeAdded = templateManagement.exerciseTemplates(withType: exerciseType) {
            exercises = exercisesToBeAdded
                .filter({ !alreadyAddedExercises.contains($0) })
                .sorted(by: exerciseTemplateSorter)
        }
    }
}
