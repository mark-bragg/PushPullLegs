//
//  ExerciseCreatorViewModel.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/5/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation

class ExerciseTemplateCreationViewModel: ObservableObject {
    
    var exerciseType: ExerciseTypeName? {
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
    
    init(withType type: ExerciseTypeName? = nil, management: TemplateManagement) {
        self.exerciseType = type
        self.management = management
        self.preSetType = type != nil
    }
    
    func isTypeSelected() -> Bool {
        exerciseType != nil
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
        guard let exerciseType else { return false }
        do {
            try management.addExerciseTemplate(name: name, type: exerciseType, unilateral: isUnilateral)
        } catch {
            return false
        }
        return true
    }
    
    private func exerciseNameIsValid(_ name: String?) -> Bool {
        guard let name = name?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) else { return false }
        return name != "" && management.exerciseTemplate(name: name) == nil
    }
}
