//
//  WorkoutReadViewModel.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 5/12/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation
import CoreData

class WorkoutDataViewModel: DatabaseViewModel, ReloadProtocol, ExerciseTemplateSelectionDelegate {
    
    var exerciseType: ExerciseType!
    var coreDataManager: CoreDataManagement!
    var selectedIndex: IndexPath?
    var workoutId: NSManagedObjectID!
    var workoutManager: WorkoutDataManager {
        get {
            dataManager as! WorkoutDataManager
        }
    }
    var exercisesDone: [Exercise] {
        set {
            dbObjects = newValue
        }
        get {
            dbObjects as! [Exercise]
        }
    }
    
    init(withCoreDataManagement coreDataManagement: CoreDataManagement = CoreDataManager.shared, workout: Workout? = nil) {
        coreDataManager = coreDataManagement
        super.init()
        if let wkt = workout, let name = wkt.name {
            workoutId = wkt.objectID
            exerciseType = ExerciseType(rawValue: name)
            if let exercises = wkt.exercises?.array as? [Exercise] {
                exercisesDone = exercises
            }
        }
        dataManager = WorkoutDataManager(backgroundContext: coreDataManagement.mainContext)
    }
    
    override func rowCount(section: Int) -> Int { return exercisesDone.count }
    
    func title() -> String? { exerciseType.rawValue }
    
    func sectionCount() -> Int { 1 }
    
    
    override func title(indexPath: IndexPath) -> String? {
        if indexPath.row < exercisesDone.count, let name = exercisesDone[indexPath.row].name {
            return name
        }
        // TODO: LOG ERROR: CAN'T GET NAME FOR INDEX PATH: \(indexPath)
        return ""
    }
    
    func detailText(indexPath: IndexPath) -> String? { "Volume: \(exercisesDone[indexPath.row].volume())" }
    
    func getSelected() -> Any? {
        guard let indexPath = selectedIndex, indexPath.row < exercisesDone.count else { return nil }
        return exercisesDone[indexPath.row]
    }
    
    func exerciseVolumeComparison(row: Int) -> ExerciseVolumeComparison {
        guard
            let workout = workoutManager.backgroundContext.object(with: workoutId) as? Workout,
            let date = workout.dateCreated,
            let previousWorkout = workoutManager.previousWorkout(before: date, type: exerciseType),
            let previousExercise = previousWorkout.exercises?.first(where: { ($0 as! Exercise).name == exercisesDone[row].name}) as? Exercise
        else {
            return .increase
        }
        
        if previousExercise.volume() == exercisesDone[row].volume() {
            return .noChange
        }
        return previousExercise < exercisesDone[row] ? .increase : .decrease
    }
    
    override func deletionAlertMessage() -> String? {
        "Delete exercise?"
    }
    
    override func deleteDatabaseObject() {
        super.deleteDatabaseObject()
        guard let wkt = dataManager.fetch(workoutId) as? Workout,
              let exercises = wkt.exercises?.array as? [Exercise] else { return }
        exercisesDone = exercises
    }
    
    override func refresh() {
        guard let wkt = dataManager.fetch(workoutId) as? Workout,
              let exercises = wkt.exercises?.array as? [Exercise] else { return }
        exercisesDone = exercises
    }
    
    override func objectDeleted(_ object: NSManagedObject) {
        guard let exercise = object as? Exercise else { return }
        exercisesDone = exercisesDone.filter({ $0 != exercise })
    }
    
    func exerciseTemplatesAdded() {
        reload()
    }
    
    func reload() {
        if let workout = workoutManager.backgroundContext.object(with: workoutId) as? Workout,
            let done = workout.exercises,
            let doneArray = done.array as? [Exercise] {
            exercisesDone = doneArray.sorted(by: sorter)
        }
    }
    
    override func addObjectsWithNames(_ names: [String]) {
        guard let wkt = dataManager.fetch(workoutId) as? Workout else { return }
        workoutManager.addExercises(withNames: names, to: wkt)
        reload()
    }
    
    func updateNote(_ text: String) {
        guard let wkt = dataManager.fetch(workoutId) as? Workout else { return }
        wkt.note = text
        try? dataManager.backgroundContext.save()
    }
    
    func noteText() -> String {
        guard let wkt = dataManager.fetch(workoutId) as? Workout else { return "" }
        return wkt.note ?? ""
    }
}

extension Workout {
    func volume() -> Double {
        var volume = 0.0
        let exercises = self.exercises!.array as! [Exercise]
        for exercise in exercises {
            volume += exercise.volume()
        }
        return volume
    }
}

extension WorkoutDataViewModel: ExerciseSelectionViewModelDataSource {
    func completedExercises() -> [String] {
        exercisesDone.compactMap({ $0.name! })
    }
}
