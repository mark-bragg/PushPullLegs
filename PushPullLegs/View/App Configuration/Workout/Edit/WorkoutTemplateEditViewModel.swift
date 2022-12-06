//
//  WorkoutEditViewModel.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/7/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation
import CoreData

protocol WorkoutCreationDelegate {
    func workout(name: String)
}

class WorkoutTemplateEditViewModel: NSObject, PPLTableViewModel, ReloadProtocol {
    
    static let added = "Added to Workout"
    static let removed = "Removed from Workout"
    static let noExercises = "No Exercises"
    
    private var selectedExercises = [ExerciseTemplate]()
    private var unselectedExercises = [ExerciseTemplate]()
    private var selectedIndices = [Int]()
    let templateManagement: TemplateManagement
    let exerciseType: ExerciseType?
    var multiSelect: Bool = true
    
    init(withType type: ExerciseType, templateManagement mgmt: TemplateManagement) {
        self.templateManagement = mgmt
        self.exerciseType = type
        super.init()
        reload()
    }
    
    func rowCount(section: Int) -> Int {
        if sectionCount() == 1 {
            return selectedExercises.count > 0 ? selectedExercises.count : unselectedExercises.count
        }
        return section == 0 ? selectedExercises.count : unselectedExercises.count
    }
    
    func title() -> String? {
        guard let exerciseType else { return nil }
        return "\(exerciseType.rawValue) Exercises"
    }
    
    func sectionCount() -> Int {
        var sectionCount = 0
        if selectedExercises.count > 0 { sectionCount += 1 }
        if unselectedExercises.count > 0 { sectionCount += 1 }
        return sectionCount
    }
    
    func title(indexPath: IndexPath) -> String? {
        if indexPath.section == 0 {
            return selectedExercises.count > 0 ? selectedExercises[indexPath.row].name : unselectedExercises[indexPath.row].name
        }
        return unselectedExercises[indexPath.row].name
    }
    
    func titleForSection(_ section: Int) -> String? {
        if section == 0 {
            if selectedExercises.count == 0 {
                return unselectedExercises.count > 0 ? WorkoutTemplateEditViewModel.removed : WorkoutTemplateEditViewModel.noExercises
            } else {
                return WorkoutTemplateEditViewModel.added
            }
        }
        return WorkoutTemplateEditViewModel.removed
    }
    
    func noDataText() -> String {
        "Empty Workout"
    }
    
    func selected(indexPath: IndexPath) {
        if indexPath.section == 0 {
            if selectedExercises.count > 0 {
                unselect(indexPath.row)
            } else {
                select(indexPath.row)
            }
        } else {
            select(indexPath.row)
        }
    }
    
    private func select(_ index: Int) {
        let exercise = unselectedExercises.remove(at: index)
        selectedExercises.append(exercise)
        templateManagement.addToWorkout(exercise: exercise)
        refresh()
    }
    
    private func unselect(_ index: Int) {
        let exercise = selectedExercises.remove(at: index)
        unselectedExercises.append(exercise)
        templateManagement.removeFromWorkout(exercise: exercise)
        refresh()
    }
    
    func reload() {
        if let exerciseType, let templates = templateManagement.exerciseTemplates(withType: exerciseType) {
            unselectedExercises = templates.sorted(by: sorter)
            selectedExercises = []
            selectExercises()
            refresh()
        }
    }
    
    private func selectExercises() {
        guard
            let exerciseType,
            let workoutTemplate = templateManagement.workoutTemplate(type: exerciseType),
            let names = workoutTemplate.exerciseNames
        else { return }
        for name in names {
            if let temp = templateManagement.exerciseTemplate(name: name), !selectedExercises.contains(temp) {
                selectedExercises.append(temp)
                unselectedExercises.removeAll { $0.name == name }
            }
        }
        
    }
    
    private func refresh() {
        selectedExercises.sort(by: sorter)
        unselectedExercises.sort(by: sorter)
    }
    
    func isSelected(_ indexPath: IndexPath) -> Bool {
        indexPath.section == 0 && selectedExercises.count > 0
    }
}
