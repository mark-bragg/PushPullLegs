//
//  ExerciseCreatorViewModel.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/5/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation

class ExerciseTemplateCreationViewModel: ObservableObject {
    
    var exerciseType: ExerciseType? {
        didSet {
            isSaveEnabled = exerciseNameIsValid(exerciseName)
        }
    }
    private var management: TemplateManagement
    private var preSetType: Bool = false
    var reloader: ReloadProtocol?
    @Published private(set) var isSaveEnabled: Bool = false
    @Published var exerciseName: String? {
        willSet {
            isSaveEnabled = isTypeSelected() && exerciseNameIsValid(newValue)
        }
    }
    var lateralType: LateralType = .bilateral
    private var isUnilateral: Bool {
        lateralType == .unilateral
    }
    
    init(withType type: ExerciseType = .error, management: TemplateManagement) {
        self.exerciseType = type
        self.management = management
        if type != .error {
            self.preSetType = true
        }
    }
    
    func isTypeSelected() -> Bool {
        return exerciseType != .error
    }
    
    func saveExercise(withName name: String, successCompletion completion: () -> Void) {
        guard saveExerciseTemplate(name) else { return }
        if let exerciseTemplate = management.exerciseTemplate(name: name), preSetType {
            management.addToWorkout(exercise: exerciseTemplate)
        }
        completion()
        reloader?.reload()
    }
    
    private func saveExerciseTemplate(_ name: String) -> Bool {
        guard let exerciseType, exerciseType != .error else { return false }
        do {
            try management.addExerciseTemplate(name: name, type: exerciseType, unilateral: isUnilateral)
        } catch {
            return false
        }
        return true
    }
    
    private func exerciseNameIsValid(_ name: String?) -> Bool {
        guard let name = name?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) else { return false}
        return name != "" && management.exerciseTemplate(name: name) == nil
    }
}
