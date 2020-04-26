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

class WorkoutTemplateEditViewModel: NSObject, ReloadProtocol {
    private var selectedExercises = [ExerciseTemplate]()
    private var unselectedExercises = [ExerciseTemplate]()
    private var selectedIndices = [Int]()
    let templateManagement: TemplateManagement
    private let exerciseType: ExerciseType!
    
    init(withType type: ExerciseType, templateManagement mgmt: TemplateManagement) {
        self.templateManagement = mgmt
        self.exerciseType = type
        super.init()
        reload()
    }
    
    func rowCount(section: Int) -> Int {
        return section == 0 ? selectedExercises.count : unselectedExercises.count
    }
    
    func sectionCount() -> Int {
        return 2
    }
    
    func title(indexPath: IndexPath) -> String? {
        if indexPath.section == 0 {
            return selectedExercises[indexPath.row].name
        }
        return unselectedExercises[indexPath.row].name
    }
    
    func titleForSection(_ section: Int) -> String? {
        if section == 0 {
            return selectedExercises.count == 0 ? nil : "Added to Workout"
        }
        return unselectedExercises.count == 0 ? nil : "Not Added to Workout"
    }
    
    func selected(indexPath: IndexPath) {
        let exercise = unselectedExercises.remove(at: indexPath.row)
        selectedExercises.append(exercise)
        templateManagement.addToWorkout(exercise: exercise)
        refresh()
    }
    
    func unselected(indexPath: IndexPath) {
        let exercise = selectedExercises.remove(at: indexPath.row)
        unselectedExercises.append(exercise)
        templateManagement.removeFromWorkout(exercise: exercise)
        refresh()
    }
    
    func type() -> ExerciseType {
        return exerciseType
    }
    
    func reload() {
        if let templates = templateManagement.exerciseTemplates(withType: exerciseType) {
            unselectedExercises = templates.sorted(by: sorter)
            selectedExercises = []
            selectExercises()
            refresh()
        }
    }
    
    private func selectExercises() {
        guard let names = templateManagement.workoutTemplate(type: exerciseType).exerciseNames else { return }
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
}
