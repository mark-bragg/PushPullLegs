//
//  UnilateralIsolationExerciseViewModel.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 8/23/21.
//  Copyright © 2021 Mark Bragg. All rights reserved.
//

import Foundation
import CoreData

fileprivate class FinishedUnilateralIsolationSetDataModel: FinishedSetDataModel {
    var isLeftSide: Bool
    
    init(withExerciseSet exerciseSet: UnilateralIsolationExerciseSet) {
        isLeftSide = exerciseSet.isLeftSide
        super.init(withExerciseSet: exerciseSet)
    }
}

enum HandSide: String {
    case left = "Left"
    case right = "Right"
}

class UnilateralIsolationExerciseViewModel: ExerciseViewModel {
    var currentSide: HandSide?
    fileprivate var finishedCellDataLeft = [FinishedUnilateralIsolationSetDataModel]()
    fileprivate var finishedCellDataRight = [FinishedUnilateralIsolationSetDataModel]()
    
    override init(withDataManager dataManager: ExerciseDataManager = UnilateralIsolationExerciseDataManager(), exercise: Exercise) {
        super.init(withDataManager: dataManager, exercise: exercise)
        
    }
    
    override init(withDataManager dataManager: ExerciseDataManager = UnilateralIsolationExerciseDataManager(), exerciseTemplate: ExerciseTemplate) {
        super.init(withDataManager: dataManager, exerciseTemplate: exerciseTemplate)
    }
    
    override func collectSet(duration: Int, weight: Double, reps: Double) {
        guard let currentSide = currentSide else { return }
        if !hasData() {
            createExercise()
            exercise = exercise ?? exerciseManager.creation as? UnilateralIsolationExercise
            delegate?.exerciseViewModel(self, started: exercise)
        }
        guard let exercise = exercise as? UnilateralIsolationExercise else { return }
        if currentSide == .left {
            exerciseManager.insertLeftSet(duration: duration, weight: weight.truncateIfNecessary(), reps: reps, exercise: exercise) { [weak self] (exerciseSet) in
                guard let self = self, let name = self.title() else { return }
                self.handleFinishedSet(exerciseSet, name)
            }
        } else {
            exerciseManager.insertRightSet(duration: duration, weight: weight.truncateIfNecessary(), reps: reps, exercise: exercise) { [weak self] (exerciseSet) in
                guard let self = self, let name = self.title() else { return }
                self.handleFinishedSet(exerciseSet, name)
            }
        }
        collectRegularSetData()
    }
    
    override func handleFinishedSet(_ exerciseSet: ExerciseSet, _ name: String) {
        guard let exerciseSet = exerciseSet as? UnilateralIsolationExerciseSet else { return }
        appendFinishedSetData(FinishedUnilateralIsolationSetDataModel(withExerciseSet: exerciseSet))
        PPLDefaults.instance.setWeight(exerciseSet.weight, forExerciseWithName: name)
        self.reloader?.reload()
    }
    
    override func appendFinishedSetData(_ data: FinishedSetDataModel) {
        guard let data = data as? FinishedUnilateralIsolationSetDataModel else { return }
        addCellData(data)
    }
    
    private func addCellData(_ data: FinishedUnilateralIsolationSetDataModel) {
        if data.isLeftSide {
            finishedCellDataLeft.append(data)
        } else {
            finishedCellDataRight.append(data)
        }
    }
    
    override func collectRegularSetData() {
        guard let objectID = exercise?.objectID, let exercise = exerciseManager.fetch(objectID) as? UnilateralIsolationExercise, let sets = exercise.sets?.array as? [UnilateralIsolationExerciseSet] else { return }
        finishedCellDataLeft.removeAll()
        finishedCellDataRight.removeAll()
        for set in sets {
            addCellData(FinishedUnilateralIsolationSetDataModel(withExerciseSet: set))
        }
    }
    
    override func weightForIndexPath(_ indexPath: IndexPath) -> Double {
        dataForSection(indexPath.section)[indexPath.row].weight
    }
    
    override func repsForIndexPath(_ indexPath: IndexPath) -> Double {
        dataForSection(indexPath.section)[indexPath.row].reps
    }
    
    override func volumeForIndexPath(_ indexPath: IndexPath) -> Double {
        dataForSection(indexPath.section)[indexPath.row].volume
    }
    
    override func durationForIndexPath(_ indexPath: IndexPath) -> String {
        String.format(seconds: dataForSection(indexPath.section)[indexPath.row].duration)
    }
    
    private func dataForSection(_ section: Int) -> [FinishedUnilateralIsolationSetDataModel] {
        return section == 0 ? finishedCellDataLeft : finishedCellDataRight
    }
    
    override func rowCount(section: Int = 0) -> Int {
        section == 0 ? finishedCellDataLeft.count : finishedCellDataRight.count
    }
    
    override func sectionCount() -> Int {
        return 2
    }
    
    override func hasData() -> Bool {
        return finishedCellDataLeft.count > 0 || finishedCellDataRight.count > 0
    }
    
    override func delete(indexPath: IndexPath) {
        guard
            let man = dataManager as? UnilateralIsolationExerciseDataManager,
            let objectID = exercise?.objectID,
            let exercise = exerciseManager.fetch(objectID) as? UnilateralIsolationExercise
        else {
            return }
        man.deletionObserver = self
        man.delete(set: (
            weightForIndexPath(indexPath),
            repsForIndexPath(indexPath),
            .unstringDuration(durationForIndexPath(indexPath)),
            indexPath.section == 0
        ), from: exercise)
        refresh()
    }
    
    override func objectDeleted(_ object: NSManagedObject) {
        refresh()
    }
    
    override func refresh() {
        collectRegularSetData()
        reloader?.reload()
    }
    
    override func totalVolume() -> Double {
        var total = Double(0)
        for data in [(cell: finishedCellDataLeft, section: 0), (cell: finishedCellDataRight, section: 1)] {
            for row in 0..<data.cell.count {
                total += volumeForIndexPath(IndexPath(row: row, section: data.section))
            }
        }
        return total
    }
    
}

extension Int {
    /// expected format: "##:##"
    static func unstringDuration(_ duration: String) -> Int {
        guard let seconds = getSeconds(duration), let minutes = getMinutes(duration) else { return 0 }
        return  seconds + (minutes * 60)
    }
    
    private static func getSeconds(_ duration: String) -> Int? {
        guard let minutes = getMinutes(duration) else { return nil }
        let dropCount = minutes < 10 ? 2 : 3
        return Int(duration.dropFirst(dropCount))
    }
    
    private static func getMinutes(_ duration: String) -> Int? {
        Int(duration.dropLast(3))
    }
}
