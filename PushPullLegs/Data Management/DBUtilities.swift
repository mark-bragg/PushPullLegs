//
//  DBUtilities.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 2/21/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation

let WorkoutEntityName = "Workout"
let ExerciseEntityName = "Exercise"
let ExerciseSetEntityName = "ExerciseSet"

let ProgramEntityName = "Program"
let WorkoutTemplateEntityName = "WorkoutTemplate"
let ExerciseTemplateEntityName = "ExerciseTemplate"

enum ExerciseType: String {
    case push = "Push"
    case pull = "Pull"
    case legs = "Legs"
    case error = "EXERCISE TYPE ERROR"
}

enum ProgramError: Error {
    case duplicateProgram
}

enum TemplateError: Error {
    case duplicateWorkout
    case duplicateExercise
    case missingExercise
}
