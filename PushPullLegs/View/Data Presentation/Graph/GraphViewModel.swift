//
//  GraphViewModel.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 5/27/21.
//  Copyright © 2021 Mark Bragg. All rights reserved.
//

import Foundation
import UIKit

class GraphViewModel: NSObject, ReloadProtocol {
    var yValues = [CGFloat]()
    var xValues = [String]()
    var dataManager: DataManager!
    
    init(dataManager: DataManager) {
        super.init()
        self.dataManager = dataManager
        reload()
    }
    
    func title() -> String {
        ""
    }
    
    func pointCount() -> Int {
        xValues.count
    }
    
    func dates() -> [String]? {
        guard pointCount() > 0 else { return nil }
        return xValues
    }
    
    func volumes() -> [CGFloat]? {
        guard pointCount() > 0 else { return nil }
        return yValues
    }
    
    func reload() {
        yValues.removeAll()
        xValues.removeAll()
    }
}
