//
//  ExerciseGraphViewModel.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 5/27/21.
//  Copyright © 2021 Mark Bragg. All rights reserved.
//

import Foundation
import UIKit

class ExerciseGraphViewModel: GraphViewModel {
    
    private var name: String
    private var exerciseDataManager: ExerciseDataManager { dataManager as! ExerciseDataManager }
    private var type: ExerciseType
    
    init(name: String, type: ExerciseType) {
        self.name = name
        self.type = type
        super.init(dataManager: ExerciseDataManager())
    }
    
    override func reload() {
        super.reload()
        var exercises: [Exercise]
        do {
            exercises = try exerciseDataManager.exercises(name: name)
        } catch NilReferenceError.nilWorkout {
            exercises = WorkoutDataManager().exercises(type: type, name: name)
        } catch {
            exercises = []
        }
        let format = formatter()
        for exercise in exercises {
            xValues.append(format.string(from: exercise.workout!.dateCreated!))
            yValues.append(CGFloat(exercise.volume()))
        }
    }
    
    override func title() -> String {
        name
    }
}
