//
//  PPLDefaults.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 6/28/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation
import Combine

@objc enum MeasurementType: Int {
    case imperial
    case metric
}

class PPLDefaults: NSObject {
    private let user_details_suite_name = "User Details"
    private let kUserDetailsKilogramsPounds = "kUserDetailsKilogramsPounds"
    private let kWorkoutInProgress = "kWorkoutInProgress"
    private let kExerciseInProgress = "kExerciseInProgress"
    private let kIsInstalled = "kIsInstalled"
    private let kCountdownInt = "kCountdownInt"
    private let kIsAdsEnabled = "kIsAdsEnabled"
    private let kGraphInterstitalDate = "kGraphInterstitialDate"
    private let kTimerSoundsEnabled = "kTimerSoundsEnabled"
    private let kDefaultColor = "kDefaultColor"
    override private init() {
        super.init()
        setupUserDetails()
        if !isInstalled() {
            userDetails.set(true, forKey: self.kIsAdsEnabled)
        }
    }
    static let instance = PPLDefaults()
    private var userDetails: UserDefaults!
    private var cancellables = [AnyCancellable]()
    
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
    
    @objc func setImperialMetric(_ type: MeasurementType) {
        let oldValue = userDetails.bool(forKey: kUserDetailsKilogramsPounds)
        if oldValue && type == .imperial {
            userDetails.set(false, forKey: kUserDetailsKilogramsPounds)
        } else  if !oldValue && type == .metric {
            userDetails.set(true, forKey: kUserDetailsKilogramsPounds)
        }
    }
    
    func countdown() -> Int {
        return userDetails.integer(forKey: kCountdownInt)
    }
    
    func setCountdown(_ value: Int) {
        userDetails.set(value, forKey: kCountdownInt)
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
    
    func setupUserDetails() {
        if let details = UserDefaults(suiteName: user_details_suite_name) {
            userDetails = details
        } else {
            UserDefaults.standard.addSuite(named: user_details_suite_name)
            userDetails.set(5, forKey: kCountdownInt)
            setupUserDetails()
        }
    }
    
    func isAdvertisingEnabled() -> Bool {
        userDetails.bool(forKey: kIsAdsEnabled)
    }
    
    func disableAds() {
        userDetails.setValue(false, forKey: kIsAdsEnabled)
        SceneDelegate.shared.adsRemoved()
    }
    
    func wasGraphInterstitialShownToday() -> Bool {
        guard let date = userDetails.dictionary(forKey: kGraphInterstitalDate)?["date"] as? Date else { return false }
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        let dateString = formatter.string(from: date)
        let todayDateString = formatter.string(from: Date())
        return dateString == todayDateString
    }
    
    func graphInterstitialWasJustShown() {
        var dict = [String: Date]()
        dict["date"] = Date()
        userDetails.setValue(dict, forKey: kGraphInterstitalDate)
    }
    
    func setTimerSoundsEnabled(_ enabled: Bool) {
        userDetails.setValue(enabled, forKey: kTimerSoundsEnabled)
    }
    
    func areTimerSoundsEnabled() -> Bool {
        userDetails.bool(forKey: kTimerSoundsEnabled)
    }
}

protocol WeightDefaults {
    func weightForExerciseWith(name: String) -> Double?
    func setWeight(_ weight: Double, forExerciseWithName name: String)
    func deleteDefaultWeightForExerciseWith(name: String?)
}

extension PPLDefaults: WeightDefaults {
    func weightForExerciseWith(name: String) -> Double? {
        userDetails.value(forKey: name) as? Double
    }
    
    func setWeight(_ weight: Double, forExerciseWithName name: String) {
        userDetails.set(weight, forKey: name)
    }
    
    func deleteDefaultWeightForExerciseWith(name: String?) {
        guard let name = name else { return }
        userDetails.removeObject(forKey: name)
    }
}

protocol ColorDefaults {
    func setDefaultColor(_ colorName: String)
    func getDefaultColor() -> String
}

extension PPLDefaults: ColorDefaults {
    func setDefaultColor(_ colorName: String) {
        userDetails.set(colorName, forKey: kDefaultColor)
        DefaultColorUpdate.notifyObservers()
    }
    
    func getDefaultColor() -> String {
        (userDetails.value(forKey: kDefaultColor) as? String) ?? "black"
    }
}
