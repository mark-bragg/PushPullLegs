//
//  SegueIdentifiers.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/20/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation

enum SegueIdentifier: String {
    // MARK: Exercise
    case getExerciseType = "GetExerciseTypeSegue"
    case navigateToExerciseDetail = "NavigateToExerciseDetailSegue"
    case addExerciseOnTheFly = "AddExerciseOnTheFlySegue"
    case createTemplateExercise = "CreateTemplateExerciseSegue"

    // MARK: Workout
    case startWorkout = "StartWorkoutSegue"
    case editWorkout = "EditWorkoutSegue"
    
    // MARK: App Configuration
    case editWorkoutList = "EditWorkoutListSegue"
    case editExerciseList = "EditExerciseList"
}
