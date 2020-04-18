//
//  AppStates.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 2/22/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation
/*
- no programs/workouts/exercises
    - initial launch state
- between workouts
- workout in progress
    - between exercises (resting state)
    - exercise in progress (exercising state)
- creating program
    - can only be performed between workouts
- creating workout
    - can only be performed between workouts
- creating exercise
    - can be performed at any time except for during exercising state
*/

/*
-
*/

protocol LegalStates {
    func legalStates() -> [[LegalStates]]
}

enum LaunchState: LegalStates {
    case initialLaunch
    case standardLaunch
    func legalStates() -> [[LegalStates]] {
        return [[LaunchState.initialLaunch], [LaunchState.standardLaunch]]
    }
}

enum Creating: LegalStates {
    case program
    case workout
    case exercise
    func legalStates() -> [[LegalStates]] {
        return [
            [Creating.program, Creating.workout, Creating.exercise],
            [Creating.program, Creating.workout],
            [Creating.program],
            [Creating.exercise],
            [Creating.workout, Creating.exercise],
            [Creating.workout]
        ]
    }
}

enum WorkoutState: LegalStates {
    case initial
    case inProgress
    case betweenExercises
    case betweenSets
    case performingSet
    case resting
    func legalStates() -> [[LegalStates]] {
        return [
            [WorkoutState.inProgress, WorkoutState.initial],
            [WorkoutState.inProgress, WorkoutState.betweenExercises],
            [WorkoutState.inProgress, WorkoutState.betweenSets],
            [WorkoutState.inProgress, WorkoutState.performingSet],
            [WorkoutState.inProgress, WorkoutState.resting]
        ]
    }
}
