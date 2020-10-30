//
//  Date+Helpers.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 2/3/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation

extension Date {
    func month() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL"
        return formatter.string(from: self)
    }
    
    func dayNumber() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter.string(from: self)
    }
}
