//
//  ExercisingViewModel.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/22/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation
import Combine

struct FinishedSetDataModel {
    var duration: Int
    var weight: Double
    var reps: Int
    var volume: Double
    
    init(withExerciseSet exerciseSet: ExerciseSet) {
        duration = Int(exerciseSet.duration)
        reps = Int(exerciseSet.reps)
        weight = exerciseSet.weight
        if PPLDefaults.instance.isKilograms() {
            weight = (weight * 0.453592).truncateDigitsAfterDecimal(afterDecimalDigits: 2)
        }
        volume = exerciseSet.volume()
    }
}

protocol ExerciseViewModelDelegate: NSObject {
    func exerciseViewModel(_ viewModel: ExerciseViewModel, started exercise: Exercise)
}

class ExerciseViewModel: NSObject, ViewModel, ExerciseSetCollector {
    
    weak var reloader: ReloadProtocol?
    weak var delegate: ExerciseViewModelDelegate?
    private let exerciseManager: ExerciseDataManager
    private var exercise: Exercise!
    private var finishedCellData = [FinishedSetDataModel]()
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
    
    func collectSet(duration: Int, weight: Double, reps: Int) {
        if finishedCellData.count == 0 {
            exerciseManager.create(name: exerciseName)
            exercise = exerciseManager.creation as? Exercise
            delegate?.exerciseViewModel(self, started: exercise)
        }
        exerciseManager.insertSet(duration: duration, weight: weight.truncateDigitsAfterDecimal(afterDecimalDigits: 2), reps: reps, exercise: exercise) { [weak self] (exerciseSet) in
            guard let self = self else { return }
            self.finishedCellData.append(FinishedSetDataModel(withExerciseSet: exerciseSet))
            self.reloader?.reload()
        }
    }
    
    func rowCount(section: Int = 0) -> Int {
        return finishedCellData.count
    }
    
    func title(indexPath: IndexPath) -> String? {
        return nil
    }
    
    func dataForRow(_ row: Int) -> FinishedSetDataModel {
        return finishedCellData[row]
    }
    
    func title() -> String? {
        guard let name = exerciseName else {
            return exercise.name
        }
        return name
    }
    
    func headerLabelText(_ index: Int) -> String {
        if index == 0 {
            return PPLDefaults.instance.isKilograms() ? "Kilograms" : "Pounds"
        } else if index == 1 {
            return "Reps"
        }
        return "Time"
    }
    
    private func collectFinishedCellData() {
        guard let exercise = exerciseManager.fetch(exercise) as? Exercise, let sets = exercise.sets?.array as? [ExerciseSet] else { return }
        for set in sets {
            finishedCellData.append(FinishedSetDataModel(withExerciseSet: set))
        }
    }
    
}

extension ExerciseSet {
    func volume() -> Double {
        if PPLDefaults.instance.isKilograms() {
            let convertedWeight = weight * 2.20462
            return ((convertedWeight * Double(reps) * Double(duration)) / 60.0).truncateDigitsAfterDecimal(afterDecimalDigits: 2)
        }
        return ((weight * Double(reps) * Double(duration)) / 60.0).truncateDigitsAfterDecimal(afterDecimalDigits: 2)
    }
}

extension Double {
    func truncateDigitsAfterDecimal(afterDecimalDigits: Int) -> Double {
       return Double(String(format: "%.\(afterDecimalDigits)f", self))!
    }
}
