//
//  ExerciseViewControllerFactory.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 9/10/21.
//  Copyright © 2021 Mark Bragg. All rights reserved.
//

import Foundation
import UIKit

class ExerciseViewControllerFactory {
    
    static func getExerciseViewController(_ object: Any?, isDB: Bool = false) -> ExerciseViewController? {
        guard let vm = getViewModelForExerciseVC(object, isDB) else { return nil }
        var vc: ExerciseViewController
        if isDB {
            vc = self.isUnilateralIsolation(vm) ? DBUnilateralIsolationExerciseViewController() : DBExerciseViewController()
            vc.viewModel = vm
            
        } else {
            vc = self.isUnilateralIsolation(vm) ? UnilateralIsolationExerciseViewController() : ExerciseViewController()
            vm.reloader = vc
            vc.viewModel = vm
        }
        return vc
    }
    
    private static func getViewModelForExerciseVC(_ object: Any?, _ isDB: Bool) -> ExerciseViewModel? {
        isDB ? getDBVM(object) : getVM(object)
    }
    
    private static func getDBVM(_ object: Any?) -> ExerciseViewModel? {
        guard let exercise = object as? Exercise else { return nil }
        return getExerciseViewModel(exercise, exercise.isKind(of: UnilateralIsolationExercise.self))
    }
    
    private static func getVM(_ object: Any?) -> ExerciseViewModel? {
        if let exerciseTemplate = object as? ExerciseTemplate {
            return getTemplateViewModel(exerciseTemplate, exerciseTemplate.unilateral && exerciseTemplate.isolation)
        } else if let exercise = object as? Exercise {
            return getExerciseViewModel(exercise, exercise.isUnilateral && exercise.isIsolation)
        }
        return nil
    }
    
    private static func getTemplateViewModel(_ exerciseTemplate: ExerciseTemplate, _ unilateralIsolation: Bool) -> ExerciseViewModel? {
        unilateralIsolation ? UnilateralIsolationExerciseViewModel(exerciseTemplate: exerciseTemplate) : ExerciseViewModel(exerciseTemplate: exerciseTemplate)
    }
    
    private static func getExerciseViewModel(_ exercise: Exercise, _ unilateralIsolation: Bool) -> ExerciseViewModel? {
        unilateralIsolation ? UnilateralIsolationExerciseViewModel(exercise: exercise) : ExerciseViewModel(exercise: exercise)
    }
    
    private static func isUnilateralIsolation(_ vm: ExerciseViewModel) -> Bool {
        vm.isKind(of: UnilateralIsolationExerciseViewModel.self)
    }

}
