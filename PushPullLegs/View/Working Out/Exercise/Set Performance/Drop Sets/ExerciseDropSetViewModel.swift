//
//  ExerciseDropSetViewModel.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 7/22/23.
//  Copyright © 2023 Mark Bragg. All rights reserved.
//

class ExerciseDropSetViewModel: ExerciseSetViewModel {
    override var countdownValue: Int { 0 }
    weak var dropSetDelegate: DropSetDelegate?
    let dropSetModel: DropSetModel
    
    init(dropSetModel: DropSetModel) {
        self.dropSetModel = dropSetModel
        super.init()
        startSet()
    }
    
    override func stopTimer() {
        super.stopTimer()
        dropSetDelegate?.collectDropSet(duration: totalTime ?? 0)
    }
    
    override func finishSetWithReps(_ reps: Double) {
        super.finishSetWithReps(reps)
        dropSetDelegate?.dropSetCompleted(with: reps)
    }
}
