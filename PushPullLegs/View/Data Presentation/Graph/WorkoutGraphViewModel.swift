//
//  WorkoutGraphViewModel.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 8/6/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation
import UIKit

class WorkoutGraphViewModel: NSObject, ReloadProtocol {
    
    private var yValues = [CGFloat]()
    private var xValues = [String]()
    private var type: ExerciseType
    private var dataManager: WorkoutDataManager!
    
    init(type: ExerciseType, dataManager: WorkoutDataManager = WorkoutDataManager()) {
        self.type = type
        super.init()
        self.dataManager = dataManager
        reload()
    }
    
    func title() -> String {
        type.rawValue
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
        let workouts = dataManager.workouts(ascending: true, types: [type])
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/YY"
        for workout in workouts {
            xValues.append(formatter.string(from: workout.dateCreated!))
            yValues.append(CGFloat(workout.volume()))
        }
    }
    
}
