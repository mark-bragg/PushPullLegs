//
//  PPLDropdownDateItem.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 12/28/22.
//  Copyright © 2022 Mark Bragg. All rights reserved.
//

class PPLDropdownDateItem: PPLDropdownItem {
    let minDate: Date
    let maxDate: Date
    let currentDate: Date
    
    init(minDate: Date, maxDate: Date, currentDate: Date) {
        self.minDate = minDate
        self.maxDate = maxDate
        self.currentDate = currentDate
        super.init(target: nil, action: nil, name: "")
    }
}
