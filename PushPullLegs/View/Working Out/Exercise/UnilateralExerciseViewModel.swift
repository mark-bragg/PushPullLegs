//
//  UnilateralExerciseViewModel.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 8/23/21.
//  Copyright © 2021 Mark Bragg. All rights reserved.
//

import Foundation
import CoreData

fileprivate class FinishedUnilateralSetDataModel: FinishedSetDataModel {
    var isLeftSide: Bool
    
    init(withExerciseSet exerciseSet: UnilateralExerciseSet) {
        isLeftSide = exerciseSet.isLeftSide
        super.init(withExerciseSet: exerciseSet)
    }
}

enum HandSide: String {
    case left = "Left"
    case right = "Right"
}

class UnilateralExerciseViewModel: ExerciseViewModel {
    var currentSide: HandSide?
    fileprivate var finishedCellDataLeft = [FinishedUnilateralSetDataModel]()
    fileprivate var finishedCellDataRight = [FinishedUnilateralSetDataModel]()
    
    override init(withDataManager dataManager: ExerciseDataManager = UnilateralExerciseDataManager(), exercise: Exercise) {
        super.init(withDataManager: dataManager, exercise: exercise)
        
    }
    
    override init(withDataManager dataManager: ExerciseDataManager = UnilateralExerciseDataManager(), exerciseTemplate: ExerciseTemplate) {
        super.init(withDataManager: dataManager, exerciseTemplate: exerciseTemplate)
    }
    
    override func collectSet(duration: Int, weight: Double, reps: Double) {
        guard let currentSide = currentSide else { return }
        if !hasData() {
            createExercise()
            exercise = exercise ?? exerciseManager.creation as? UnilateralExercise
            delegate?.exerciseViewModel(self, started: exercise)
        }
        if currentSide == .left {
            exerciseManager.insertLeftSet(duration: duration, weight: weight.truncateDigitsAfterDecimal(afterDecimalDigits: 2), reps: reps, exercise: exercise as! UnilateralExercise) { [weak self] (exerciseSet) in
                guard let self = self, let name = self.title() else { return }
                self.handleFinishedSet(exerciseSet, name)
            }
        } else {
            exerciseManager.insertRightSet(duration: duration, weight: weight.truncateDigitsAfterDecimal(afterDecimalDigits: 2), reps: reps, exercise: exercise as! UnilateralExercise) { [weak self] (exerciseSet) in
                guard let self = self, let name = self.title() else { return }
                self.handleFinishedSet(exerciseSet, name)
            }
        }
        collectFinishedCellData()
    }
    
    override func handleFinishedSet(_ exerciseSet: ExerciseSet, _ name: String) {
        guard let exerciseSet = exerciseSet as? UnilateralExerciseSet else { return }
        appendFinishedSetData(FinishedUnilateralSetDataModel(withExerciseSet: exerciseSet))
        self.reloader?.reload()
    }
    
    override func appendFinishedSetData(_ data: FinishedSetDataModel) {
        guard let data = data as? FinishedUnilateralSetDataModel else { return }
        addCellData(data)
    }
    
    private func addCellData(_ data: FinishedUnilateralSetDataModel) {
        if data.isLeftSide {
            finishedCellDataLeft.append(data)
        } else {
            finishedCellDataRight.append(data)
        }
    }
    
    override func collectFinishedCellData() {
        guard let exercise = exerciseManager.fetch(exercise.objectID) as? UnilateralExercise, let sets = exercise.sets?.array as? [UnilateralExerciseSet] else { return }
        finishedCellDataLeft.removeAll()
        finishedCellDataRight.removeAll()
        for set in sets {
            addCellData(FinishedUnilateralSetDataModel(withExerciseSet: set))
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
    
    private func dataForSection(_ section: Int) -> [FinishedUnilateralSetDataModel] {
        return section == 0 ? finishedCellDataLeft : finishedCellDataRight
    }
    
    override func rowCount(section: Int = 0) -> Int {
        section == 0 ? finishedCellDataLeft.count : finishedCellDataRight.count
    }
    
    func sectionCount() -> Int {
        return 2
    }
    
    override func hasData() -> Bool {
        return finishedCellDataLeft.count > 0 || finishedCellDataRight.count > 0
    }
    
    override func delete(indexPath: IndexPath) {
        guard
            let man = dataManager as? UnilateralExerciseDataManager,
            let exercise = exerciseManager.fetch(exercise.objectID) as? UnilateralExercise
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
    
    override func refresh() {
        collectFinishedCellData()
        reloader?.reload()
    }
    
    override func objectDeleted(_ object: NSManagedObject) {
        refresh()
    }
    
}

extension Int {
    /// expected format: "##:##"
    static func unstringDuration(_ duration: String) -> Int {
        guard let seconds = getSeconds(duration), let minutes = getMinutes(duration) else { return 0 }
        return  seconds + (minutes * 60)
    }
    
    private static func getMinutes(_ duration: String) -> Int? {
        Int(duration.dropLast(3))
    }
    
    private static func getSeconds(_ duration: String) -> Int? {
        guard let minutes = getMinutes(duration) else { return nil }
        let dropCount = minutes < 10 ? 2 : 3
        return Int(duration.dropFirst(dropCount))
    }
}
