//
//  PPLDefaults.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 6/28/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation

class PPLDefaults: NSObject {
    private let user_details_suite_name = "User Details"
    private let prompt_user_for_workout_type = "Prompt User For Workout Type"
    private let kUserDetailsKilogramsPounds = "kUserDetailsKilogramsPounds"
    private let kUserDetailsPromptForWorkoutType = "kUserDetailsPromptForWorkoutType"
    private let kWorkoutInProgress = "kWorkoutInProgress"
    private let kExerciseInProgress = "kExerciseInProgress"
    private let kIsInstalled = "kIsInstalled"
    override private init() {
        super.init()
        setupUserDetails()
    }
    static let instance = PPLDefaults()
    private var userDetails: UserDefaults!
    
    private func isInstalled() -> Bool {
        let isInstalled = userDetails.bool(forKey: kIsInstalled)
        if !isInstalled {
            userDetails.set(false, forKey: kUserDetailsKilogramsPounds)
            userDetails.set(true, forKey: kIsInstalled)
        }
        return isInstalled
    }
    
    func isKilograms() -> Bool {
        if isInstalled() {
            return userDetails.bool(forKey: kUserDetailsKilogramsPounds)
        }
        return false
    }
    
    @objc func toggleKilograms() {
        let newValue = !userDetails.bool(forKey: kUserDetailsKilogramsPounds)
        userDetails.set(newValue, forKey: kUserDetailsKilogramsPounds)
    }
    
    func isWorkoutInProgress() -> Bool {
        return userDetails.bool(forKey: kWorkoutInProgress)
    }
    
    func setWorkoutInProgress(_ value: Bool) {
        userDetails.set(value, forKey: kWorkoutInProgress)
    }
    
    func exerciseInProgress() -> String? {
        guard let name = userDetails.string(forKey: kExerciseInProgress) else {
            return nil
        }
        return name
    }
    
    func setExerciseInProgress(_ value: String?) {
        userDetails.set(value, forKey: kExerciseInProgress)
    }
    
    func workoutTypePromptSwitchValue() -> Bool {
        return userDetails.bool(forKey: kUserDetailsPromptForWorkoutType)
    }
    
    func setupUserDetails() {
        if let details = UserDefaults(suiteName: user_details_suite_name) {
            userDetails = details
        } else {
            UserDefaults.standard.addSuite(named: user_details_suite_name)
            addWorkoutTypePromptBool()
            setupUserDetails()
        }
    }
    
    func addWorkoutTypePromptBool() {
        userDetails.set(true, forKey: kUserDetailsPromptForWorkoutType)
    }
    
    @objc func toggleWorkoutTypePromptValue() {
        let newValue = !userDetails.bool(forKey: kUserDetailsPromptForWorkoutType)
        userDetails.set(newValue, forKey: kUserDetailsPromptForWorkoutType)
    }
}