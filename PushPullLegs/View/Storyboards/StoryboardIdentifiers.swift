//
//  StoryboardIdentifiers.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 5/16/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation

class StoryboardFileName {
    static let appConfiguration = "AppConfiguration"
    static let workout = "Workout"
}

class ViewControllerIdentifier {
    static let createExerciseViewController = "CreateExerciseViewController"
}

class SegueIdentifier {
    // MARK: Exercise
    static let getExerciseType = "GetExerciseTypeSegue"
    static let navigateToExerciseDetail = "NavigateToExerciseDetailSegue"
    static let addExerciseOnTheFly = "AddExerciseOnTheFlySegue"
    static let createTemplateExercise = "CreateTemplateExerciseSegue"

    // MARK: Workout
    static let startWorkout = "StartWorkoutSegue"
    static let editWorkout = "EditWorkoutSegue"
    
    // MARK: App Configuration
    static let editWorkoutList = "EditWorkoutListSegue"
    static let editExerciseList = "EditExerciseList"
}
