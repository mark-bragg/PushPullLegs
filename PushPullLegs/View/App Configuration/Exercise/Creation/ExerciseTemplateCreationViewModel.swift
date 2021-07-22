//
//  ExerciseCreatorViewModel.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/5/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation

class ExerciseTemplateCreationViewModel: ObservableObject {
    
    @Published private(set) var exerciseType: ExerciseType
    private var management: TemplateManagement
    private var preSetType: Bool = false
    var reloader: ReloadProtocol?
    @Published private(set) var isSaveEnabled: Bool = false
    @Published var exerciseName: String? {
        willSet {
            isSaveEnabled = isTypeSelected() && exerciseNameIsValid(newValue)
        }
    }
    
    init(withType type: ExerciseType = .error, management: TemplateManagement) {
        self.exerciseType = type
        self.management = management
        if type != .error {
            self.preSetType = true
        }
    }
    
    func selectedType(_ type: ExerciseType) {
        exerciseType = type
        isSaveEnabled = exerciseNameIsValid(exerciseName)
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
        guard exerciseType != .error else { return false }
        do {
            try management.addExerciseTemplate(name: name, type: exerciseType)
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
