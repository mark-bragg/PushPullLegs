//
//  AppState.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 5/31/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation

/**
 
 legal states:
 workoutInProgress      currentWorkoutDate
            true                    true
            false                   false
 
 */

class AppState {
    static let shared = AppState()
    @Published var workoutInProgress: Bool {
        willSet {
            PPLDefaults.instance.setWorkoutInProgress(newValue)
        }
    }
    var exerciseInProgress: String? {
        willSet {
            PPLDefaults.instance.setExerciseInProgress(newValue)
        }
    }
    var isAdEnabled: Bool {
        get {
            PPLDefaults.instance.isAdsEnabled()
        }
    }
    private let ADVERTISE = "ADVERTISE"
    private init() {
        workoutInProgress = PPLDefaults.instance.isWorkoutInProgress()
        exerciseInProgress = PPLDefaults.instance.exerciseInProgress()
    }
    private static var isLaunching = true
    
    static func isLaunch() -> Bool {
        if (isLaunching) {
            isLaunching = false
            return true
        }
        return isLaunching
    }
}
