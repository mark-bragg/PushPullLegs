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
    
    init(name: String) {
        self.name = name
        super.init(dataManager: ExerciseDataManager())
    }
    
    override func reload() {
        let exercises = exerciseDataManager.exercises(name: name)
    }
}
