//
//  PPLDropdownNavigationItem.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 12/28/22.
//  Copyright © 2022 Mark Bragg. All rights reserved.
//

class PPLDropdownNavigationItem: PPLDropdownItem {
    var items: [PPLDropdownItem]
    
    init(items: [PPLDropdownItem], name: String) {
        self.items = items
        super.init(target: nil, action: nil, name: name)
    }
}
