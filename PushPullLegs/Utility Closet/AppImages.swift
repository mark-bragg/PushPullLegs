//
//  AppImages.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 10/31/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation
import UIKit

typealias TabBarImage = UIImage
extension TabBarImage {
    static func forWorkoutTab() -> UIImage? {
        UIImage(named: "curlbar")
    }
    
    static func forDatabaseTab() -> UIImage? {
        UIImage(named: "database")
    }
    
    static func forTrendsTab() -> UIImage? {
        UIImage(named: "line_graph")
    }
    
    static func forSettingsTab() -> UIImage? {
        UIImage(named: "gear")
    }
}
