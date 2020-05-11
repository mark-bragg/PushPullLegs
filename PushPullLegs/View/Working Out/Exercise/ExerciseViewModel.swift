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
    var volume: Int
    
    init(withExerciseSet exerciseSet: ExerciseSet) {
        duration = exerciseSet.duration.intValue()
        reps = exerciseSet.reps.intValue()
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
    private let exercise: Exercise
    private var finishedCellData = [FinishedSetCellData]()
    
    init(withDataManager dataManager: ExerciseDataManager = ExerciseDataManager(), exerciseTemplate: ExerciseTemplate) {
        exerciseManager = dataManager
        exerciseManager.create(name: exerciseTemplate.name!)
        exercise = exerciseManager.creation as! Exercise
        super.init()
        collectFinishedCellData()
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
    func volume() -> Int {
        return (Int(weight) * reps.intValue() * duration.intValue()) / 60
    }
}
