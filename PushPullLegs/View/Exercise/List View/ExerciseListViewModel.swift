//
//  ExerciseListViewModel.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/15/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation

let sorter = { (temp1: ExerciseTemplate, temp2: ExerciseTemplate) -> Bool in
    return temp1.name! < temp2.name!
}

protocol ExerciseListViewModelDelegate {
    func viewModelFailedToSaveExerciseWithNameAlreadyExists(_ model: ExerciseListViewModel)
}

class ExerciseListViewModel: ReloadProtocol {
    
    let templateManagement: TemplateManagement
    private var pushExercises = [ExerciseTemplate]()
    private var pullExercises = [ExerciseTemplate]()
    private var legsExercises = [ExerciseTemplate]()
    var delegate: ExerciseListViewModelDelegate?
    
    init(withTemplateManagement mgmt: TemplateManagement) {
        templateManagement = mgmt
        reload()
    }
    
    func rowCount(section: Int) -> Int {
        return exercisesForSection(section).count
    }
    
    func title(indexPath: IndexPath) -> String {
        return exercisesForSection(indexPath.section)[indexPath.row].name!
    }
    
    func titleForSection(_ section: Int) -> String {
        switch section {
        case 0:
            return ExerciseType.push.rawValue
        case 1:
            return ExerciseType.pull.rawValue
        case 2:
            return ExerciseType.legs.rawValue
        default:
            return ExerciseType.error.rawValue
        }
    }
    
    func deleteExercise(indexPath: IndexPath) {
        templateManagement.deleteExerciseTemplate(name: title(indexPath: indexPath))
    }
    
    private func exercisesForSection(_ section: Int) -> [ExerciseTemplate] {
        switch section {
        case 0:
            return pushExercises
        case 1:
            return pullExercises
        case 2:
            return legsExercises
        default:
            return []
        }
    }
    
    func reload() {
        pushExercises = templateManagement.exerciseTemplates(withType: .push)?.sorted(by: sorter) ?? []
        pullExercises = templateManagement.exerciseTemplates(withType: .pull)?.sorted(by: sorter) ?? []
        legsExercises = templateManagement.exerciseTemplates(withType: .legs)?.sorted(by: sorter) ?? []
    }
}
