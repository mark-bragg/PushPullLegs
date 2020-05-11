//
//  WorkoutViewModel.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/18/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation
import CoreData

enum ExerciseVolumeComparison {
    case increase
    case decrease
    case noChange
}

class WorkoutViewModel: NSObject, ReloadProtocol, ExerciseTemplateSelectionDelegate, ExerciseViewModelDelegate {
    
    private var exerciseType: ExerciseType!
    private var workoutManager: WorkoutDataManager
    private var exercisesToDo = [ExerciseTemplate]()
    private var exercisesDone = [Exercise]()
    private var workoutId: NSManagedObjectID!
    private var startingTime: Date!
    private var coreDataManager: CoreDataManagement!
    private var selectedIndex: IndexPath?
    
    init(withType type: ExerciseType? = nil, coreDataManagement: CoreDataManagement = CoreDataManager.shared) {
        coreDataManager = coreDataManagement
        workoutManager = WorkoutDataManager(backgroundContext: coreDataManagement.mainContext)
        super.init()
        exerciseType = type == nil ? computeExerciseType() : type
        exercisesToDo = TemplateManagement(coreDataManager: coreDataManagement).exerciseTemplatesForWorkout(exerciseType).sorted(by: exerciseTemplateSorter)
        startingTime = Date()
        workoutManager.create(name: exerciseType.rawValue, keyValuePairs: ["dateCreated": startingTime!])
        workoutId = (workoutManager.creation as? Workout)?.objectID
    }
    
    private func computeExerciseType() -> ExerciseType {
        switch workoutManager.getLastWorkoutType() {
        case .push:
            return .pull
        case .pull:
            return .legs
        case .legs:
            fallthrough
        default:
            return .push
        }
    }
    
    func getExerciseType() -> ExerciseType {
        return exerciseType
    }
    
    func sectionCount() -> Int {
        return 2
    }
    
    func rowsForSection(_ section: Int) -> Int {
        return section == 0 ? exercisesToDo.count : exercisesDone.count
    }
    
    func titleForIndexPath(_ indexPath: IndexPath) -> String {
        if indexPath.section < 2 {
            if indexPath.section == 0 && indexPath.row < exercisesToDo.count, let name = exercisesToDo[indexPath.row].name {
                return name
            } else if indexPath.row < exercisesDone.count, let name = exercisesDone[indexPath.row].name {
                return name
            }
            return "ERROR: CAN'T GET NAME FOR INDEX PATH: \(indexPath)"
        }
        return "ERROR: SECTION COUNT IS LARGER THAN 2"
    }
    
    func timerText() -> String {
        let interval = Int(startingTime.timeIntervalSinceNow * -1)
        let hours = interval / 3600
        let minutes = (interval % 3600) / 60
        let seconds = (interval % 3600) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    func finishWorkout() {
        let workout = workoutManager.backgroundContext.object(with: workoutId)
        workoutManager.update(workout, keyValuePairs: ["duration": Int(startingTime.timeIntervalSinceNow * -1)])
    }
    
    func addExercise(templates: [ExerciseTemplate]) {
        guard templates.count > 0 else {
            return
        }
        let templateManagement = TemplateManagement(coreDataManager: coreDataManager)
        for template in templates {
            templateManagement.addToWorkout(exercise: template)
        }
        let todo = templateManagement.exerciseTemplatesForWorkout(exerciseType)
        exercisesToDo = todo.sorted(by: exerciseTemplateSorter)
        reload()
    }
    
    func exerciseTemplatesAdded() {
        let templateManagement = TemplateManagement(coreDataManager: coreDataManager)
        let todo = templateManagement.exerciseTemplatesForWorkout(exerciseType)
        exercisesToDo = todo.sorted(by: exerciseTemplateSorter)
        reload()
    }
    
    func selected(indexPath: IndexPath) {
        selectedIndex = indexPath
    }
    
    func getSelectedExerciseTemplate() -> ExerciseTemplate? {
        guard let indexPath = selectedIndex, indexPath.section == 0 else { return nil }
        return exercisesToDo[indexPath.row]
    }
    
    func getSelectedExercise() -> Exercise? {
        guard let indexPath = selectedIndex, indexPath.section == 1 else { return nil }
        return exercisesDone[indexPath.row]
    }
    
    func reload() {
        if let workout = workoutManager.backgroundContext.object(with: workoutId) as? Workout,
            let done = workout.exercises,
            let doneArray = done.array as? [Exercise] {
            exercisesDone = doneArray.sorted(by: sorter)
            if doneArray.count > 0 {
                var newTodos = [ExerciseTemplate]()
                for template in exercisesToDo {
                    if !doneArray.contains(where: { $0.name! == template.name! }) {
                        newTodos.append(template)
                    }
                }
                exercisesToDo = newTodos.sorted(by: exerciseTemplateSorter)
            }
        }
    }
    
    func exerciseViewModel(_ viewMode: ExerciseViewModel, completed exercise: Exercise) {
        guard let workout = workoutManager.backgroundContext.object(with: workoutId) as? Workout else { return }
        workoutManager.add(exercise, to: workout)
        reload()
    }
    
    func detailText(indexPath: IndexPath) -> String? {
        guard indexPath.section == 1 else { return nil }
        
        return "\(volumeFor(exercise: exercisesDone[indexPath.row]))"
    }
    
    private func volumeFor(exercise: Exercise) -> Int {
        guard let sets = exercise.sets?.array as? [ExerciseSet] else { return 0 }
        
        var volume = 0
        for set in sets {
            volume += (set.duration.intValue() * Int(set.weight) * set.reps.intValue()) / 60
        }
        return volume
    }
    
    func exerciseVolumeComparison(row: Int) -> ExerciseVolumeComparison {
        guard let previousWorkout = workoutManager.previousWorkout(),
            let exerciseToCompare = previousWorkout.exercises?.first(where: { ($0 as! Exercise).name == exercisesDone[row].name}) as? Exercise
            else { return .increase }
        if exerciseToCompare.volume() == exercisesDone[row].volume() {
            return .noChange
        }
        return exerciseToCompare < exercisesDone[row] ? .increase : .decrease
    }
}

extension FixedWidthInteger {
    func intValue() -> Int {
        return Int(self)
    }
}

extension Exercise: Comparable {
    public static func < (lhs: Exercise, rhs: Exercise) -> Bool {
        return lhs.volume() < rhs.volume()
    }
    
    func volume() -> Int {
        guard let sets = sets?.array as? [ExerciseSet] else { return 0 }
        
        var volume = 0
        for set in sets {
            volume += set.volume()
        }
        return volume
    }
    
}
