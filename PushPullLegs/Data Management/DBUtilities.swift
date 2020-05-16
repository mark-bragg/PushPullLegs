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
    case exerciseSet = "ExerciseSet"
    case workoutTemplate = "WorkoutTemplate"
    case exerciseTemplate = "ExerciseTemplate"
}

enum ExerciseType: String {
    case push = "Push"
    case pull = "Pull"
    case legs = "Legs"
    case error = "EXERCISE TYPE ERROR"
}

enum TemplateError: Error {
    case duplicateWorkout
    case duplicateExercise
    case missingExercise
}
