//
//  ExerciseGraphModel.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/27/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

struct ExerciseGraphData: Equatable {
    static func == (lhs: ExerciseGraphData, rhs: ExerciseGraphData) -> Bool {
        var setsAreEqual = true
        for set in lhs.sets {
            if !rhs.sets.contains(where: { (setData) -> Bool in
                return setData.weight == set.weight && setData.duration == set.duration && setData.reps == set.reps
            }) { setsAreEqual = false; break }
        }
        return setsAreEqual && lhs.date == rhs.date
    }
    
    let sets: [(weight: Double, reps: Int, duration: Int)]
    let date: Date
}

class ExerciseGraphModel: NSObject {

    var exerciseDataManager: ExerciseDataManager
    var selectedExercises: [Exercise]?
    
    init(withExerciseDataManager manager: ExerciseDataManager) {
        exerciseDataManager = manager
        super.init()
    }
    
    func getExerciseNames() -> [String] {
        // func map<T>((Self.Element) -> T) -> [T]
        let names = exerciseDataManager.getAllExercises().map( { $0.name! } )
        return names
    }
    
    func select(name: String) {
        selectedExercises = exerciseDataManager.exercises(withName: name).sorted(by: { (ex1, ex2) -> Bool in
            return ex1.workout!.dateCreated!.compare(ex2.workout!.dateCreated!) == .orderedAscending
        })
    }
    
    func getSelectedExerciseDates() -> [Date]? {
        if let selectedExercises = selectedExercises {
            return selectedExercises.map({ $0.workout!.dateCreated! })
        }
        return nil
    }
    
    func getSelectedExerciseName() -> String? {
        if let selectedExercises = selectedExercises {
            return selectedExercises.first!.name!
        }
        return nil
    }
    
    func getSelectedExerciseData() -> [ExerciseGraphData]? {
        if let selectedExercises = selectedExercises {
            return selectedExercises.map { (exercise) -> ExerciseGraphData in
                var setData = [(Double, Int, Int)]()
                for set in exercise.sets!.array as! [ExerciseSet] {
                    setData.append((set.weight, Int(set.reps), Int(set.duration)))
                }
                return ExerciseGraphData(sets: setData, date: exercise.workout!.dateCreated!)
            }
        }
        return nil
    }
    
}
