//
//  WorkoutEditViewModel.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/18/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation

enum ExerciseVolumeComparison {
    case increase
    case decrease
    case noChange
}

class WorkoutEditViewModel: WorkoutReadViewModel, ReloadProtocol, ExerciseTemplateSelectionDelegate, ExerciseViewModelDelegate {
    
    private var exercisesToDo = [ExerciseTemplate]()
    private var startingTime: Date!
    
    init(withType type: ExerciseType? = nil, coreDataManagement: CoreDataManagement = CoreDataManager.shared) {
        super.init(withCoreDataManagement: coreDataManagement)
        exerciseType = type != nil ? type : computeExerciseType() 
        exercisesToDo = TemplateManagement(coreDataManager: coreDataManagement).exerciseTemplatesForWorkout(exerciseType).sorted(by: exerciseTemplateSorter)
        startingTime = Date()
        workoutManager.create(name: exerciseType.rawValue, keyValuePairs: ["dateCreated": startingTime!])
        workoutId = (workoutManager.creation as? Workout)?.objectID
    }
    
    override func sectionCount() -> Int {
        return 2
    }
    
    override func rowsForSection(_ section: Int) -> Int {
        return section == 0 ? exercisesToDo.count : exercisesDone.count
    }
    
    override func titleForIndexPath(_ indexPath: IndexPath) -> String {
        if indexPath.section < 2 {
            if indexPath.section == 0 && indexPath.row < exercisesToDo.count, let name = exercisesToDo[indexPath.row].name {
                return name
            } else {
                return super.titleForIndexPath(indexPath)
            }
        }
        return "ERROR: SECTION COUNT IS LARGER THAN 2"
    }
    
    override func detailText(indexPath: IndexPath) -> String? {
        if indexPath.section == 0 { return nil }
        return super.detailText(indexPath: indexPath)
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
    
    
    override func getSelected() -> Any? {
        guard let indexPath = selectedIndex, indexPath.section == 0 && indexPath.row < exercisesToDo.count else { return super.getSelected() }
        return exercisesToDo[indexPath.row]
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
}

extension Exercise: Comparable {
    public static func < (lhs: Exercise, rhs: Exercise) -> Bool {
        return lhs.volume() < rhs.volume()
    }
    
    func volume() -> Double {
        guard let sets = sets?.array as? [ExerciseSet] else { return 0 }
        
        var volume = 0.0
        for set in sets {
            volume += set.volume()
        }
        return volume
    }
    
}
