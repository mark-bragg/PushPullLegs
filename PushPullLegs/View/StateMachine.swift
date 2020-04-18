//
//  StateMachine.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 2/22/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation
import UIKit

class StateMachine {
    private var creating = false
    private var workingOut = false
    private var states: [LegalStates]
    private let firstLaunch: Bool = UserDefaults.standard.bool(forKey: "firstAppLaunch")
    static var shared: StateMachine! {
        let machine = StateMachine()
        if let del = UIApplication.shared.delegate {
            print(del)
        }
        return machine
    }
    
    private init() {
        self.states = self.firstLaunch ? [LaunchState.initialLaunch] : [LaunchState.standardLaunch]
    }
    
    func appIsInValidState() -> Bool {
        guard let firstState = self.states.first else {
            print("neutral state")
            return true
        }
        if creating, let ls = firstState.legalStates() as? [[Creating]] {
            return ls.contains(states as! [Creating])
        } else if workingOut, let ls = firstState.legalStates() as? [[WorkoutState]] {
            return ls.contains(states as! [WorkoutState])
        } else if let ls = firstState.legalStates() as? [[LaunchState]] {
            return ls.contains(states as! [LaunchState])
        }
        // error, shouldn't get here
        return false
    }
}
