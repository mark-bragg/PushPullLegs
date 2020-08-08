//
//  WorkoutGraphViewModel.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 8/6/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation

class WorkoutGraphViewModel: NSObject {
    
    var yValues = [Double]()
    var xValues = [Date]()
    private var type: ExerciseType
    
    init(type: ExerciseType, dataManager: WorkoutDataManager = WorkoutDataManager()) {
        self.type = type
        super.init()
        let workouts = dataManager.workouts(ascending: true)
        for workout in workouts {
            xValues.append(workout.dateCreated!)
            yValues.append(workout.volume())
        }
    }
    
    func title() -> String {
        type.rawValue
    }
    
    func pointCount() -> Int {
        xValues.count
    }
    
    func date(_ index: Int) -> Date? {
        guard pointCount() > 0 else { return nil }
        return xValues[index]
    }
    
    func volume(_ index: Int) -> Double? {
        guard pointCount() > 0 else { return nil }
        return yValues[index]
    }
    
    
}
