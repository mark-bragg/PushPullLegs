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
    var workoutInProgress: Bool {
        willSet {
            PPLDefaults.instance.setWorkoutInProgress(newValue)
        }
    }
    private init() {
        workoutInProgress = PPLDefaults.instance.isWorkoutInProgress()
    }
}
