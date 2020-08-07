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
}
