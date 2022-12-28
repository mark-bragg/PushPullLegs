//
//  PPLDropdownDateNavigationItem.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 12/28/22.
//  Copyright © 2022 Mark Bragg. All rights reserved.
//

class PPLDropdownDateNavigationItem: PPLDropdownNavigationItem {
    var firstDate: Date
    var secondDate: Date
    var minDate: Date
    var maxDate: Date
    
    init(firstDate: Date, secondDate: Date, minDate: Date, maxDate: Date) {
        self.firstDate = firstDate
        self.secondDate = secondDate
        self.minDate = minDate
        self.maxDate = maxDate
        super.init(items: [PPLDropdownDateItem(minDate: minDate, maxDate: maxDate, currentDate: firstDate), PPLDropdownDateItem(minDate: minDate, maxDate: maxDate, currentDate: secondDate)], name: "Select Dates")
    }
}
