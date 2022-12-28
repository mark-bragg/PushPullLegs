//
//  PPLDropdownItem.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 12/28/22.
//  Copyright © 2022 Mark Bragg. All rights reserved.
//

class PPLDropdownItem: NSObject {
    let target: AnyObject?
    let action: Selector?
    let name: String
    
    init(target: AnyObject?, action: Selector?, name: String) {
        self.target = target
        self.action = action
        self.name = name
    }
}
