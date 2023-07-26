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
    let isSuperSet: Bool
    let isDropSet: Bool
    
    init(withExerciseSet exerciseSet: ExerciseSet) {
        duration = Int(exerciseSet.duration)
        reps = exerciseSet.reps
        weight = exerciseSet.weight
        if PPLDefaults.instance.isKilograms() {
            weight = (weight * 0.453592).truncateIfNecessary()
        }
        volume = exerciseSet.volume()
        if let superSets = exerciseSet.exercise?.workout?.superSets?.allObjects as? [SuperSet] {
            isSuperSet = superSets.contains { Set([$0.set1, $0.set2]).contains(exerciseSet.objectID.uriRepresentation()) }
        } else {
            isSuperSet = false
        }
        isDropSet = (exerciseSet.exercise?.dropSets?.array as? [DropSet])?.contains { dropSet in
            dropSet.sets?.contains { $0 == exerciseSet.objectID.uriRepresentation() } ?? false
        } ?? false
    }
}

protocol ExerciseViewModelDelegate: NSObject {
    func exerciseViewModel(_ viewModel: ExerciseViewModel, started exercise: Exercise?)
}

class ExerciseViewModel: DatabaseViewModel, ExerciseSetCollector, SuperSetCollector {
    
    weak var reloader: ReloadProtocol?
    weak var delegate: ExerciseViewModelDelegate?
    private(set) var exerciseManager: ExerciseDataManager {
        set { dataManager = newValue }
        get { dataManager as? ExerciseDataManager ?? ExerciseDataManager() }
    }
    var exercise: Exercise?
    private var regularSetData = [FinishedSetDataModel]()
    private var dropSetData = [FinishedSetDataModel]()
    private var superSetData = [FinishedSetDataModel]()
    private var dropSetDbObjects = [DropSet]()
    private var superSetDbObjects = [SuperSet]()
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
    private var firstSuperSetSetCompleted = false
    private(set) var superSetSecondExerciseName: String?
    var isPerformingSuperSet: Bool { superSetSecondExerciseName != nil }
    var superSetFirstSet: ExerciseSet?
    
    func prepareForSuperSet(_ secondExerciseName: String) {
        superSetSecondExerciseName = secondExerciseName
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
        if let exerciseType = exerciseTemplate.types?.anyObject() as? ExerciseType, let rawValue = exerciseType.name {
            type = ExerciseTypeName(rawValue: rawValue)?.rawValue
        }
        super.init()
        exerciseManager = dataManager
    }
    
    init(withDataManager dataManager: ExerciseDataManager = ExerciseDataManager(), exercise: Exercise) {
        self.exercise = exercise
        exerciseName = exercise.name
        type = exercise.workout?.name
        super.init()
        exerciseManager = dataManager
        collectSetData()
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
        let percent = preVolume >= 1 ? Int(((currentVolume / preVolume) - 1) * 100) : 0
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
    
    func collectSetData() {
        collectDropSetData()
        collectSuperSetData()
        collectRegularSetData()
    }
    
    func collectDropSets(_ sets: [(duration: Int, weight: Double, reps: Double)]) {
        handleFirstSetCompletion()
        guard let exercise else { return }
        exerciseManager.insertDropSets(sets, exercise: exercise) { [weak self] (dropSet) in
            guard let self = self, let name = self.title(), let sets = dropSet.exerciseSets() else { return }
            self.handleFinishedDropSets(sets, name)
        }
        collectSetData()
    }
    
    private func collectDropSetData() {
        guard let exercise = exerciseManager.fetch(exercise) as? Exercise,
              let dropSets = exercise.dropSets?.array as? [DropSet]
        else { return }
        dropSetData.removeAll()
        var dropSetsToSave = [DropSet]()
        for dropSet in dropSets {
            guard let dropSetSets = dropSet.exerciseSets()
            else { continue }
            dropSetData.append(contentsOf: dropSetSets.compactMap { FinishedSetDataModel(withExerciseSet: $0) })
            dropSetsToSave.append(dropSet)
        }
        dropSetDbObjects = dropSetsToSave
    }
    
    func handleFinishedDropSets(_ exerciseSets: [ExerciseSet], _ name: String) {
        isFirstSet = false
        for exerciseSet in exerciseSets {
            dropSetData.append(FinishedSetDataModel(withExerciseSet: exerciseSet))
        }
        reloader?.reload()
    }
    
    func collectSet(duration: Int, weight: Double, reps: Double) {
        handleFirstSetCompletion()
        exerciseManager.insertSet(duration: duration, weight: weight.truncateIfNecessary(), reps: reps, exercise: exercise) { [weak self] (exerciseSet) in
            guard let self = self, let name = self.title() else { return }
            self.handleFinishedSet(exerciseSet, name)
        }
        collectSetData()
    }
    
    func handleFinishedSet(_ exerciseSet: ExerciseSet, _ name: String) {
        isFirstSet = false
        appendFinishedSetData(FinishedSetDataModel(withExerciseSet: exerciseSet))
        reloader?.reload()
        let row = rowCount() - 1
        PPLDefaults.instance.setWeight(weightForIndexPath(IndexPath(row: row, section: 0)), forExerciseWithName: name)
    }
    
    func appendFinishedSetData(_ data: FinishedSetDataModel) {
        regularSetData.append(data)
    }
    
    override func rowCount(section: Int = 0) -> Int {
        if section == 0 {
            return regularSetData.count
        } else if section == 1 {
            return dropSetData.count
        }
        return superSetData.count
    }
    
    func sectionCount() -> Int {
        3
    }
    
    override func title(indexPath: IndexPath) -> String? {
        nil
    }
    
    func dataFor(section: Int) -> [FinishedSetDataModel] {
        if section == 0 {
            return regularSetData
        } else if section == 1 {
            return dropSetData
        }
        return superSetData
    }
    
    func dataForIndexPath(_ indexPath: IndexPath) -> FinishedSetDataModel {
        dataFor(section: indexPath.section)[indexPath.row]
    }
    
    func weightForIndexPath(_ indexPath: IndexPath) -> Double {
        dataForIndexPath(indexPath).weight
    }
    
    func durationForIndexPath(_ indexPath: IndexPath) -> String {
        String.format(seconds: dataForIndexPath(indexPath).duration)
    }
    
    func repsForIndexPath(_ indexPath: IndexPath) -> Double {
        dataForIndexPath(indexPath).reps
    }
    
    func totalVolume() -> Double {
        var total = Double(0)
        for row in 0..<regularSetData.count {
            total += volumeForIndexPath(IndexPath(row: row, section: 0))
        }
        return total
    }
    
    func volumeForIndexPath(_ indexPath: IndexPath) -> Double {
        regularSetData[indexPath.row].volume
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
    
    func collectSuperSetSet(duration: Int, weight: Double, reps: Double, _ delegate: ExerciseSetViewModelDelegate?) {
        if firstSuperSetSetCompleted, let superSetSecondExerciseName, let workout = exercise?.workout, let exercises = workout.exercises?.array as? [Exercise] {
            var secondExercise = exercises.first { $0.name == superSetSecondExerciseName }
            if secondExercise == nil {
                let tempMan = ExerciseDataManager()
                tempMan.create(name: superSetSecondExerciseName)
                guard let secondExerciseCreation = tempMan.creation as? Exercise else { return }
                WorkoutDataManager().add(secondExerciseCreation, to: workout)
                secondExercise = secondExerciseCreation
            }
            exerciseManager.insertSet(duration: duration, weight: weight, reps: reps, exercise: secondExercise) { [weak self] secondSet in
                guard let self, let workout = self.exercise?.workout, let firstSet = self.superSetFirstSet else { return }
                let currentSuperSet = self.exerciseManager.createSuperSet(with: workout, set1: firstSet, set2: secondSet)
                self.collectSetData()
                self.clearSuperSetState()
                self.reloader?.reload()
                delegate?.exerciseSetViewModelFinishedSet(nil)
            }
        } else {
            firstSuperSetSetCompleted = true
            handleFirstSetCompletion()
            exerciseManager.insertSet(duration: duration, weight: weight.truncateIfNecessary(), reps: reps, exercise: exercise) { [weak self] (exerciseSet) in
                guard let self, let name = self.title() else { return }
                self.handleFinishedSuperSet(exerciseSet, name)
                self.superSetFirstSet = exerciseSet
                delegate?.exerciseSetViewModelFinishedSet(nil)
            }
        }
    }
    
    func handleFinishedSuperSet(_ exerciseSet: ExerciseSet, _ name: String) {
        isFirstSet = false
        superSetData.append(FinishedSetDataModel(withExerciseSet: exerciseSet))
        reloader?.reload()
        let row = rowCount() - 1
    }
    
    private func clearSuperSetState() {
        firstSuperSetSetCompleted = false
        superSetSecondExerciseName = nil
        superSetFirstSet = nil
    }
    
    private func handleFirstSetCompletion() {
        guard regularSetData.count == 0 else { return }
        createExercise()
        exercise = exercise ?? exerciseManager.creation as? Exercise
        delegate?.exerciseViewModel(self, started: exercise)
    }
    
    func collectSuperSetData() {
        guard let exercise = exerciseManager.fetch(exercise) as? Exercise,
              let workout = exercise.workout,
              let superSets = workout.superSets?.allObjects as? [SuperSet],
              !superSets.isEmpty
        else { return }
        superSetData.removeAll()
        var superSetsToSave = [SuperSet]()
        for superSet in superSets {
            guard let superSetSets = superSet.exerciseSets(),
                  let exerciseSets = exercise.sets?.array as? [ExerciseSet]
            else { continue }
            if exerciseSets.contains(where: { $0 == superSetSets.set1 }) {
                superSetData.append(FinishedSetDataModel(withExerciseSet: superSetSets.set1))
                superSetsToSave.append(superSet)
            } else if exerciseSets.contains(where: { $0 == superSetSets.set2 }) {
                superSetData.append(FinishedSetDataModel(withExerciseSet: superSetSets.set2))
                superSetsToSave.append(superSet)
            }
        }
        superSetDbObjects = superSetsToSave
    }
    
    func collectRegularSetData() {
        guard let exercise = exerciseManager.fetch(exercise) as? Exercise, var sets = exercise.sets?.array as? [ExerciseSet] else { return }
        sets = sets.filter { regularSet in
            for dropSetDbObject in dropSetDbObjects {
                if let dropSetSets = dropSetDbObject.exerciseSets(), dropSetSets.contains(where: { $0 == regularSet }) {
                    return false
                }
            }
            for superSetDbObject in superSetDbObjects {
                if let superSetSets = superSetDbObject.exerciseSets(), superSetSets.set1  == regularSet || superSetSets.set2 == regularSet {
                    return false
                }
            }
            return true
        }
        regularSetData.removeAll()
        for set in sets {
            regularSetData.append(FinishedSetDataModel(withExerciseSet: set))
        }
        dbObjects = sets
    }
    
    func titleForSection(_ section: Int) -> String? {
        if section == 0 {
            if regularSetData.isEmpty {
                return !dropSetData.isEmpty ? "Drop Sets" : "Super Sets"
            }
        } else if section == 1 {
            return !dropSetData.isEmpty ? "Drop Sets" : "Super Sets"
        } else if section == 2 {
            return "Super Sets"
        }
        return nil
    }
    
    override func deleteDatabaseObject() {
        super.deleteDatabaseObject()
        refresh()
    }
    
    override func refresh() {
        regularSetData = [FinishedSetDataModel]()
        collectSetData()
        if regularSetData.count == 0 || dropSetData.count == 0  || superSetData.count == 0  {
            reloader?.reload()
        }
    }
    
    func hasData() -> Bool {
        !(regularSetData.isEmpty && dropSetData.isEmpty && superSetData.isEmpty)
    }
    
    func createExercise() {
        exerciseManager.create(name: exerciseName)
    }
    
    func noDataText() -> String {
        "Start your next set!"
    }
    
    func superSet(at index: Int) -> SuperSet? {
        guard superSetDbObjects.count > index else { return nil }
        return superSetDbObjects[index]
    }
    
    override func delete(indexPath: IndexPath) {
        if indexPath.section == 0 {
            dataManager?.delete(dbObjects[indexPath.row])
        } else if indexPath.section == 1 {
            dataManager?.delete(dropSetDbObjects[indexPath.row])
        } else {
            delete(superSet: superSetDbObjects[indexPath.row])
        }
        CoreDataManager.shared.save()
    }
    
    private func delete(superSet: SuperSet) {
        guard let sets = superSet.exerciseSets()
        else { return }
        dataManager?.delete(sets.set1)
        dataManager?.delete(sets.set2)
        dataManager?.delete(superSet)
    }
    
    override func deletionAlertMessage(_ indexPath: IndexPath) -> String? {
        if indexPath.section == 2 {
            return "This will delete the other set as well"
        }
        return nil
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
