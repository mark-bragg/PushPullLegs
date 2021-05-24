//
//  AppConfigurationViewModel.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 3/21/21.
//  Copyright © 2021 Mark Bragg. All rights reserved.
//

import Foundation
import UIKit

enum AppConfigurationRowID {
    case about
    case editWorkouts
    case editExercises
    case massUnitsControl
    case countdownControl
    case timerSounds
    case disableAds
}

class AppConfigurationViewModel: NSObject, PPLTableViewModel {
    private var titles = ["About", "Edit Workout List", "Edit Exercise List", "", "Countdown for each set", "Timer Sounds"]
    private var hasDisableAdsRow: Bool
    
    override init() {
        hasDisableAdsRow = AppState.shared.isAdEnabled && StoreObserver.shared.isAuthorizedForPayments
        super.init()
        if hasDisableAdsRow {
            titles.append("Disable Ads")
        }
    }
    func rowCount(section: Int) -> Int {
        return titles.count
    }
    
    func title() -> String? {
        return "App Settings"
    }
    
    func title(indexPath: IndexPath) -> String? {
        guard indexPath.row < titles.count else {
            return "ERROR"
        }
        return titles[indexPath.row]
    }
    
    func idForRow(_ row: Int) -> AppConfigurationRowID? {
        switch row {
        case 0:
            return .about
        case 1:
            return .editWorkouts
        case 2:
            return .editExercises
        case 3:
            return .massUnitsControl
        case 4:
            return .countdownControl
        case 5:
            return .timerSounds
        default:
            return hasDisableAdsRow ? .disableAds : nil
        }
    }
    
    func disableAds() {
        
    }
}
