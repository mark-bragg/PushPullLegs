//
//  ViewModel.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 8/6/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation

@objc protocol PPLTableViewModel: NSObjectProtocol {
    func rowCount(section: Int) -> Int
    func title(indexPath: IndexPath) -> String?
    
    @objc optional func sectionCount() -> Int
    @objc optional func titleForSection(_ section: Int) -> String?
    @objc optional func title() -> String?
    @objc optional func noDataText() -> String
}

extension PPLTableViewModel {
    func hasData() -> Bool {
        let sections = (sectionCount ?? { 1 })()
        for section in 0..<sections {
            if rowCount(section: section) > 0 {
                 return true
            }
        }
        return false
    }
}
