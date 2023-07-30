//
//  ExerciseCreatorViewModel.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/5/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation

class ExerciseTemplateCreationViewModel: ObservableObject {
    
    private(set) var exerciseTypes: [ExerciseTypeName] {
        didSet {
            isSaveEnabled = exerciseNameIsValid(exerciseName)
        }
    }
    let management: TemplateManagement
    private var preSetType: Bool = false
    var reloader: ReloadProtocol?
    @Published private(set) var isSaveEnabled: Bool = false
    @Published var exerciseName: String? {
        willSet {
            guard let newValue else {
                isSaveEnabled = false
                return
            }
            isSaveEnabled = isTypeSelected() && exerciseNameIsValid(newValue) && !nameConflictExists(newValue)
        }
    }
    var lateralType: LateralType = .bilateral
    var isUnilateral: Bool { lateralType == .unilateral }
    var muscleGrouping = MuscleGrouping.compound
    var isCompound: Bool { muscleGrouping == .compound }
    var titleLabel: String { "New Exercise" }
    
    init(withType type: ExerciseTypeName? = nil, management: TemplateManagement) {
        self.exerciseTypes = type != nil ? [type!] : []
        self.management = management
        self.preSetType = type != nil
    }
    
    func isTypeSelected() -> Bool {
        !exerciseTypes.isEmpty
    }
    
    func isTypeSelected(_ type: ExerciseTypeName) -> Bool {
        exerciseTypes.contains(type)
    }
    
    func saveExercise(withName name: String, successCompletion completion: @escaping () -> Void) {
        guard saveExerciseTemplate(name) else { return }
        finishSave(name: name, completion: completion)
    }
    
    private func saveExerciseTemplate(_ name: String) -> Bool {
        guard !exerciseTypes.isEmpty else { return false }
        do {
            try management.addExerciseTemplate(name: name, types: exerciseTypes, unilateral: isUnilateral, compound: isCompound)
        } catch {
            return false
        }
        return true
    }
    
    func finishSave(name: String, completion: @escaping () -> Void) {
        if let exerciseTemplate = management.exerciseTemplate(name: name), preSetType {
            management.addToWorkout(exercise: exerciseTemplate)
        }
        completion()
        reloader?.reload()
    }
    
    private func exerciseNameIsValid(_ name: String?) -> Bool {
        guard let name = name?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        else { return false }
        return name != ""
    }
    
    func nameConflictExists(_ newName: String) -> Bool {
         management.exerciseTemplate(name: newName) != nil
    }
    
    func updateTypesWith(selection: ExerciseTypeName) {
        if let index = exerciseTypes.firstIndex(of: selection) {
            exerciseTypes.remove(at: index)
        } else {
            exerciseTypes.append(selection)
            removeConflictingTypes(selection)
        }
    }
    
    private func removeConflictingTypes(_ newType: ExerciseTypeName) {
        var typeToRemove: ExerciseTypeName
        switch newType {
        case .push:
            typeToRemove = .pull
        case .pull:
            typeToRemove = .push
        case .legs:
            typeToRemove = .arms
        case .arms:
            typeToRemove = .legs
        }
        exerciseTypes.removeAll { $0 == typeToRemove }
    }
}
