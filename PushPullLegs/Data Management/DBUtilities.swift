//
//  DBUtilities.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 2/21/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation

enum EntityName: String {
    case workout = "Workout"
    case exercise = "Exercise"
    case unilateralExercise = "UnilateralExercise"
    case exerciseSet = "ExerciseSet"
    case unilateralExerciseSet = "UnilateralExerciseSet"
    case workoutTemplate = "WorkoutTemplate"
    case exerciseTemplate = "ExerciseTemplate"
    case exerciseType = "ExerciseType"
    case superSet = "SuperSet"
}

enum ExerciseTypeName: String, CaseIterable {
    case push = "Push"
    case pull = "Pull"
    case legs = "Legs"
    case arms = "Arms"
    
    static func create(_ type: ExerciseType) -> ExerciseTypeName? {
        guard let name = type.name else { return nil }
        return ExerciseTypeName(rawValue: name)
    }
}

enum TemplateError: Error {
    case duplicateWorkout
    case duplicateExercise
    case missingExercise
    case failedToCreateExercise
}

extension Exercise {
    var isUnilateral: Bool {
        return TemplateManagement.init().exerciseTemplate(name: name ?? "")?.unilateral ?? false
    }
}

enum LateralType {
    case bilateral
    case unilateral
}
