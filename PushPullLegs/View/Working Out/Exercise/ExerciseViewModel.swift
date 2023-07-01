//
//  ExercisingViewModel.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/22/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation
import Combine

class FinishedSetDataModel {
    var duration: Int
    var weight: Double
    var reps: Double
    var volume: Double
    
    init(withExerciseSet exerciseSet: ExerciseSet) {
        duration = Int(exerciseSet.duration)
        reps = exerciseSet.reps
        weight = exerciseSet.weight
        if PPLDefaults.instance.isKilograms() {
            weight = (weight * 0.453592).truncateIfNecessary()
        }
        volume = exerciseSet.volume()
    }
}

protocol ExerciseViewModelDelegate: NSObject {
    func exerciseViewModel(_ viewModel: ExerciseViewModel, started exercise: Exercise?)
}

class ExerciseViewModel: DatabaseViewModel, ExerciseSetCollector {
    
    weak var reloader: ReloadProtocol?
    weak var delegate: ExerciseViewModelDelegate?
    private(set) var exerciseManager: ExerciseDataManager {
        set { dataManager = newValue }
        get { dataManager as? ExerciseDataManager ?? ExerciseDataManager() }
    }
    var exercise: Exercise?
    private var finishedCellData = [FinishedSetDataModel]()
    private(set) var exerciseName: String?
    var defaultWeight: Double? {
        guard let name = title()
        else { return nil }
        return PPLDefaults.instance.weightForExerciseWith(name: name)
    }
    private(set) var isFirstSet = true
    private(set) var type: String?
    var previousExercise: Exercise? {
        guard
            let exerciseName,
            let type = ExerciseTypeName(rawValue: type ?? "")
        else { return nil }
        let workouts = WorkoutDataManager().workouts(ascending: false, types: [type])
        for workout in workouts {
            if let previous = previousExerciseWith(name: exerciseName, workout: workout) {
                return previous
            }
        }
        return nil
    }
    
    private func previousExerciseWith(name: String, workout: Workout) -> Exercise? {
        if let prevExercise = ((workout.exercises?.array as? [Exercise])?.first { $0.name == exerciseName }) {
            if let exercise {
                if exercise.objectID != prevExercise.objectID {
                    return prevExercise
                }
            } else {
                return prevExercise
            }
        }
        return nil
    }
    
    init(withDataManager dataManager: ExerciseDataManager = ExerciseDataManager(), exerciseTemplate: ExerciseTemplate) {
        exerciseName = exerciseTemplate.name
        type = exerciseTemplate.type
        super.init()
        exerciseManager = dataManager
    }
    
    init(withDataManager dataManager: ExerciseDataManager = ExerciseDataManager(), exercise: Exercise) {
        self.exercise = exercise
        exerciseName = exercise.name
        type = exercise.workout?.name
        super.init()
        exerciseManager = dataManager
        collectFinishedCellData()
    }
    
    func isFirstTimePerformingExercise() -> Bool {
        guard
            let type = ExerciseTypeName(rawValue: exercise?.workout?.name ?? ""),
            let currentWorkout = exercise?.workout,
            let previousWorkout = WorkoutDataManager().previousWorkout(before: currentWorkout.dateCreated, type: type),
            let exercises = previousWorkout.exercises?.array as? [Exercise]
        else { return false }
        return exercises.contains(where: { $0.name == exercise?.name && $0.sets != nil && $0.sets!.count > 0 })
    }
    
    func progressTitle() -> String {
        if let prefix = exercise?.name {
            return "\(prefix) Progress"
        }
        return "Exercise Progress"
    }
    
    func progressMessage() -> String {
        let currentVolume = totalVolume()
        let preVolume = previousVolume()
        let percent = Int(((currentVolume / preVolume) - 1) * 100)
        var percentMessage = "\(percent)%"
        if percent == 0 {
            // no change
            percentMessage.append(" difference")
        } else if percent < 0 {
            // decrease in volume
            percentMessage.append(" decrease")
        } else {
            // increase in volume
            percentMessage.append(" increase")
        }
        percentMessage.append(" in volume from last workout.")
        return "\(percentMessage)"
    }
    
    func previousVolume() -> Double {
        guard
            let type = ExerciseTypeName(rawValue: exercise?.workout?.name ?? ""),
            let currentWorkout = exercise?.workout,
            let previousWorkout = WorkoutDataManager().previousWorkout(before: currentWorkout.dateCreated, type: type),
            let previousExercises = previousWorkout.exercises?.array as? [Exercise],
            let previousExercise = previousExercises.first(where: { $0.name == exercise?.name })
        else { return 0 }
        return previousExercise.volume()
    }
    
    func collectSet(duration: Int, weight: Double, reps: Double) {
        if finishedCellData.count == 0 {
            createExercise()
            exercise = exercise ?? exerciseManager.creation as? Exercise
            delegate?.exerciseViewModel(self, started: exercise)
        }
        exerciseManager.insertSet(duration: duration, weight: weight.truncateIfNecessary(), reps: reps, exercise: exercise) { [weak self] (exerciseSet) in
            guard let self = self, let name = self.title() else { return }
            self.handleFinishedSet(exerciseSet, name)
        }
        collectFinishedCellData()
    }
    
    func handleFinishedSet(_ exerciseSet: ExerciseSet, _ name: String) {
        isFirstSet = false
        appendFinishedSetData(FinishedSetDataModel(withExerciseSet: exerciseSet))
        reloader?.reload()
        let row = rowCount() - 1
        PPLDefaults.instance.setWeight(weightForIndexPath(IndexPath(row: row, section: 0)), forExerciseWithName: name)
    }
    
    func appendFinishedSetData(_ data: FinishedSetDataModel) {
        finishedCellData.append(data)
    }
    
    override func rowCount(section: Int = 0) -> Int {
        return finishedCellData.count
    }
    
    override func title(indexPath: IndexPath) -> String? {
        return nil
    }
    
    func weightForIndexPath(_ indexPath: IndexPath) -> Double {
        return finishedCellData[indexPath.row].weight
    }
    
    func durationForIndexPath(_ indexPath: IndexPath) -> String {
        return String.format(seconds: finishedCellData[indexPath.row].duration)
    }
    
    func repsForIndexPath(_ indexPath: IndexPath) -> Double {
        return finishedCellData[indexPath.row].reps
    }
    
    func totalVolume() -> Double {
        var total = Double(0)
        for row in 0..<finishedCellData.count {
            total += volumeForIndexPath(IndexPath(row: row, section: 0))
        }
        return total
    }
    
    func volumeForIndexPath(_ indexPath: IndexPath) -> Double {
        return finishedCellData[indexPath.row].volume
    }
    
    func title() -> String? {
        guard let name = exerciseName else {
            return exercise?.name ?? ""
        }
        return name
    }
    
    func headerLabelText(_ index: Int) -> String {
        if index == 0 {
            return PPLDefaults.instance.isKilograms() ? "Kg" : "lbs"
        } else if index == 1 {
            return "Reps"
        }
        return "Time"
    }
    
    func collectFinishedCellData() {
        guard let exercise = exerciseManager.fetch(exercise) as? Exercise, let sets = exercise.sets?.array as? [ExerciseSet] else { return }
        finishedCellData.removeAll()
        for set in sets {
            finishedCellData.append(FinishedSetDataModel(withExerciseSet: set))
        }
        dbObjects = sets
    }
    
    override func deleteDatabaseObject() {
        super.deleteDatabaseObject()
        refresh()
    }
    
    override func refresh() {
        finishedCellData = [FinishedSetDataModel]()
        collectFinishedCellData()
        if finishedCellData.count == 0 {
            reloader?.reload()
        }
    }
    
    func hasData() -> Bool {
        finishedCellData.count > 0
    }
    
    func createExercise() {
        exerciseManager.create(name: exerciseName)
    }
    
    func noDataText() -> String {
        "Start your next set!"
    }
    
}

extension ExerciseSet {
    func volume() -> Double {
        let weight = weight * (PPLDefaults.instance.isKilograms() ? 2.20462 : 1)
        return weight * reps * log(base: 4, value: Double(duration))
    }
    
    func averageRepDuration() -> Double {
        guard reps > 0 else { return 0 }
        return Double(duration) / reps
    }
}

extension Double {
    var durationLog: Double {
        log(base: 4, value: self)
    }
}

func log(base: Double, value: Double) -> Double {
    guard base > 0 && value > 0 else { return 0 }
    return log(value) / log(base)
}

extension Double {
    func truncateIfNecessary() -> Double {
        let digitCount = "\(Int(self))".count
        guard digitCount < 3
        else { return self }
        let decimalCount = digitCount < 3 ? 2 : 1
        return Double(String(format: "%.\(decimalCount)f", self)) ?? 0
    }
}
