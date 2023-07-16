//
//  ExerciseSelectionViewModel.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/19/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation

@objc protocol ExerciseSelectionViewModelDataSource {
    func completedExercises() -> [String]
}

class ExerciseSelectionViewModel: NSObject, PPLTableViewModel, ReloadProtocol {
    
    var exercises = [ExerciseTemplate]()
    private var selectedIndices = [Int]()
    let exerciseType: ExerciseTypeName
    private(set) var templateManagement: TemplateManagement
    var multiSelect: Bool = true
    weak var dataSource: ExerciseSelectionViewModelDataSource?
    
    init(withType type: ExerciseTypeName, templateManagement: TemplateManagement, dataSource: ExerciseSelectionViewModelDataSource? = nil) {
        self.templateManagement = templateManagement
        exerciseType = type
        super.init()
        self.dataSource = dataSource
        reload()
    }
    
    func rowCount(section: Int) -> Int {
        exercises.count
    }
    
    func title(indexPath: IndexPath) -> String? {
        guard let name = exercises[indexPath.row].name else {
            // TODO: LOG NO TITLE ERROR
            return ""
        }
        return name
    }
    
    func isSelected(row: Int) -> Bool {
        selectedIndices.contains(row)
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
        if let completedExercises = dataSource?.completedExercises(), let alreadyAddedExercises = templateManagement.exerciseTemplates(withType: exerciseType) {
            exercises = alreadyAddedExercises
                .filter { $0.name != nil }
                .filter { !completedExercises.contains($0.name!) }
                .sorted(by: exerciseTemplateSorter)
        } else {
            let alreadyAddedExercises = templateManagement.exerciseTemplatesForWorkout(exerciseType)
            if let exercisesToBeAdded = templateManagement.exerciseTemplates(withType: exerciseType) {
                exercises = exercisesToBeAdded
                    .filter { !alreadyAddedExercises.contains($0) }
                    .sorted(by: exerciseTemplateSorter)
            }
        }
    }
    
    func title() -> String? {
        "Select Exercises"
    }
}
