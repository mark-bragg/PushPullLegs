//
//  ExerciseCreatorViewModel.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/5/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation

class ExerciseTemplateCreationViewModel {
    
    private var exerciseType: ExerciseType
    private var management: TemplateManagement
    private var preSetType: Bool = false
    var reloader: ReloadProtocol?
    
    init(withType type: ExerciseType = .error, management: TemplateManagement) {
        self.exerciseType = type
        self.management = management
        if type != .error {
            self.preSetType = true
        }
    }
    
    func selectedType(_ type: ExerciseType) {
        exerciseType = type
    }
    
    func isTypeSelected() -> Bool {
        return exerciseType != .error
    }
    
    func saveExercise(withName name: String, successCompletion completion: () -> Void) {
        guard exerciseType != .error else {
            return
        }
        do {
            try management.addExerciseTemplate(name: name, type: exerciseType)
        } catch {
            // TODO: present duplicate exercise error to user
            print(error)
            return
        }
        if let exerciseTemplate = management.exerciseTemplate(name: name), preSetType {
            management.addToWorkout(exercise: exerciseTemplate)
        }
        completion()
        reloader?.reload()
    }
}
