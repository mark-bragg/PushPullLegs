//
//  ExercisingViewModel.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/22/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation

struct FinishedSetCellData {
    var duration: Int
    var weight: Double
    var reps: Int
    var volume: Double
    
    init(withExerciseSet exerciseSet: ExerciseSet) {
        duration = Int(exerciseSet.duration)
        reps = Int(exerciseSet.reps)
        weight = exerciseSet.weight
        volume = exerciseSet.volume()
    }
}

protocol ExerciseViewModelDelegate: NSObject {
    func exerciseViewModel(_ viewMode: ExerciseViewModel, completed exercise: Exercise)
}

class ExerciseViewModel: NSObject, ExerciseSetCollector {
    
    weak var reloader: ReloadProtocol?
    weak var delegate: ExerciseViewModelDelegate?
    private let exerciseManager: ExerciseDataManager
    private var exercise: Exercise!
    private var finishedCellData = [FinishedSetCellData]()
    private var exerciseName: String!
    
    init(withDataManager dataManager: ExerciseDataManager = ExerciseDataManager(), exerciseTemplate: ExerciseTemplate) {
        exerciseManager = dataManager
        exerciseName = exerciseTemplate.name!
        super.init()
    }
    
    init(withDataManager dataManager: ExerciseDataManager = ExerciseDataManager(), exercise: Exercise) {
        exerciseManager = dataManager
        self.exercise = exercise
        super.init()
        collectFinishedCellData()
    }
    
    func rowCount() -> Int {
        return finishedCellData.count
    }
    
    func collectSet(duration: Int, weight: Double, reps: Int) {
        if finishedCellData.count == 0 {
            exerciseManager.create(name: exerciseName)
            exercise = exerciseManager.creation as? Exercise
        }
        exerciseManager.insertSet(duration: duration, weight: weight, reps: reps, exercise: exercise) { exerciseSet in
            finishedCellData.append(FinishedSetCellData(withExerciseSet: exerciseSet))
            reloader?.reload()
        }
    }
    
    func dataForRow(_ row: Int) -> FinishedSetCellData {
        return finishedCellData[row]
    }
    
    func exerciseCompleted() {
        guard let exercise = exerciseManager.fetch(exercise) as? Exercise else { return }
        delegate?.exerciseViewModel(self, completed: exercise)
    }
    
    private func collectFinishedCellData() {
        guard let exercise = exerciseManager.fetch(exercise) as? Exercise, let sets = exercise.sets?.array as? [ExerciseSet] else { return }
        for set in sets {
            finishedCellData.append(FinishedSetCellData(withExerciseSet: set))
        }
    }
    
}

extension ExerciseSet {
    func volume() -> Double {
        return ((weight * Double(reps) * Double(duration)) / 60.0).truncateDigitsAfterDecimal(afterDecimalDigits: 2)
    }
}

extension Double {
    func truncateDigitsAfterDecimal(afterDecimalDigits: Int) -> Double {
       return Double(String(format: "%.\(afterDecimalDigits)f", self))!
    }
}
