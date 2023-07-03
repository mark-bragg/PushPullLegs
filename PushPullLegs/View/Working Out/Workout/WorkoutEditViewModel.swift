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

protocol WorkoutEditViewModelDelegate: NSObject {
    func workoutEditViewModelCompletedFirstExercise(_ model: WorkoutEditViewModel)
}

class WorkoutEditViewModel: WorkoutDataViewModel, ExerciseViewModelDelegate {
    
    private var exercisesToDo = [ExerciseTemplate]()
    private(set) var startingTime: Date?
    weak var delegate: WorkoutEditViewModelDelegate?
    
    init(withType type: ExerciseTypeName, coreDataManagement: CoreDataManagement = CoreDataManager.shared) {
        let startingTime = Date.now
        super.init(withCoreDataManagement: coreDataManagement)
        self.exerciseType = type
        self.startingTime = startingTime
        self.workoutManager.create(name: exerciseType?.rawValue, keyValuePairs: ["dateCreated": startingTime])
        self.workoutId = (workoutManager.creation as? Workout)?.objectID
        self.exercisesToDo = TemplateManagement(coreDataManager: coreDataManagement).exerciseTemplatesForWorkout(type).sorted(by: exerciseTemplateSorter)
        self.reload()
    }
    
    init(coreDataManagement: CoreDataManagement = CoreDataManager.shared) {
        super.init(withCoreDataManagement: coreDataManagement)
        let startingTime = Date.now
        guard let wipType = AppState.shared.workoutInProgress,
              let workout = workoutManager.previousWorkout(before: startingTime, type: wipType),
              let workoutName = workout.name
        else { return }
        exerciseType = ExerciseTypeName(rawValue: workoutName)
        workoutId = workout.objectID
        self.startingTime = workout.dateCreated
    }
    
    override func sectionCount() -> Int {
        return 2
    }
    
    override func rowCount(section: Int) -> Int {
        return section == 0 ? exercisesToDo.count : exercisesDone.count
    }
    
    override func title(indexPath: IndexPath) -> String? {
        if indexPath.section < 2 {
            if indexPath.section == 0 && indexPath.row < exercisesToDo.count, let name = exercisesToDo[indexPath.row].name {
                return name
            } else {
                return super.title(indexPath: indexPath)
            }
        }
        return "ERROR: SECTION COUNT IS LARGER THAN 2"
    }
    
    override func detailText(indexPath: IndexPath) -> String? {
        if indexPath.section == 0 { return nil }
        return super.detailText(indexPath: indexPath)
    }
    
    func timerText() -> String {
        guard let startingTime else { return "" }
        let interval = Int(startingTime.timeIntervalSinceNow * -1)
        let hours = interval / 3600
        let minutes = (interval % 3600) / 60
        let seconds = (interval % 3600) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    func finishWorkout() {
        guard
            let workoutId,
            let startingTime
        else { return }
        let workout = workoutManager.context.object(with: workoutId)
        workoutManager.update(workout, keyValuePairs: ["duration": Int(startingTime.timeIntervalSinceNow * -1)])
        AppState.shared.workoutInProgress = nil
    }
    
    func addExercise(templates: [ExerciseTemplate]) {
        guard
            templates.count > 0,
            let coreDataManager,
            let exerciseType
        else { return }
        let templateManagement = TemplateManagement(coreDataManager: coreDataManager)
        for template in templates {
            templateManagement.addToWorkout(exercise: template)
        }
        let todo = templateManagement.exerciseTemplatesForWorkout(exerciseType)
        exercisesToDo = todo.sorted(by: exerciseTemplateSorter)
        reload()
    }
    
    override func exerciseTemplatesAdded() {
        guard
            let coreDataManager,
            let exerciseType
        else { return }
        let templateManagement = TemplateManagement(coreDataManager: coreDataManager)
        let todo = templateManagement.exerciseTemplatesForWorkout(exerciseType)
        exercisesToDo = todo.sorted(by: exerciseTemplateSorter)
        super.exerciseTemplatesAdded()
    }
    
    
    override func getSelected() -> Any? {
        guard let indexPath = selectedIndex, indexPath.section == 0 && indexPath.row < exercisesToDo.count else { return super.getSelected() }
        return exercisesToDo[indexPath.row]
    }
    
    override func reload() {
        if let workoutId,
            let workout = workoutManager.context.object(with: workoutId) as? Workout,
            let done = workout.exercises,
            let doneArray = done.array as? [Exercise] {
            exercisesDone = doneArray.sorted(by: sorter)
            exercisesToDo = exercisesToDo.filter { $0.name != nil }
            if doneArray.count > 0 {
                var newTodos = [ExerciseTemplate]()
                for template in exercisesToDo {
                    if !doneArray.contains(where: { $0.name == template.name }) {
                        newTodos.append(template)
                    }
                }
                exercisesToDo = newTodos.sorted(by: exerciseTemplateSorter)
            }
        }
    }
    
    func exerciseViewModel(_ viewMode: ExerciseViewModel, started exercise: Exercise?) {
        guard
            let workoutId,
            let workout = workoutManager.context.object(with: workoutId) as? Workout
        else { return }
        if let exercise {
            workoutManager.add(exercise, to: workout)
        }
        reload()
        if exercisesDone.count == 1 {
            delegate?.workoutEditViewModelCompletedFirstExercise(self)
        }
    }
    
    private func computeExerciseType() -> ExerciseTypeName{
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

    func deleteWorkout() {
        guard
            let workoutId,
            let workout = try? coreDataManager?.mainContext.existingObject(with: workoutId) as? Workout
        else { return }
        workoutManager.delete(workout)
        AppState.shared.workoutInProgress = nil
    }
    
    func noDataText() -> String {
        "Empty Workout. Add your exercises!"
    }
}

extension Exercise: Comparable {
    public static func < (lhs: Exercise, rhs: Exercise) -> Bool {
        lhs.volume() < rhs.volume()
    }
    
    func volume() -> Double {
        guard let sets = sets?.array as? [ExerciseSet] else { return 0 }
        
        var volume = 0.0
        for set in sets {
            volume += set.volume()
        }
        return volume.truncateIfNecessary()
    }
    
}
