//
//  ExerciseListViewModel.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/15/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation
import CoreData

let sorter = { (obj1: NSManagedObject, obj2: NSManagedObject) -> Bool in
    let name1 = obj1.value(forKey: "name") as! String
    let name2 = obj2.value(forKey: "name") as! String
    return name1 < name2
}

let exerciseTemplateSorter = { (temp1: ExerciseTemplate, temp2: ExerciseTemplate) -> Bool in
    return temp1.name! < temp2.name!
}

protocol ExerciseTemplateListViewModelDelegate {
    func viewModelFailedToSaveExerciseWithNameAlreadyExists(_ model: ExerciseTemplateListViewModel)
}

class ExerciseTemplateListViewModel: NSObject, ViewModel, ReloadProtocol {
    
    let templateManagement: TemplateManagement
    private var pushExercises = [ExerciseTemplate]()
    private var pullExercises = [ExerciseTemplate]()
    private var legsExercises = [ExerciseTemplate]()
    var delegate: ExerciseTemplateListViewModelDelegate?
    
    init(withTemplateManagement mgmt: TemplateManagement) {
        templateManagement = mgmt
        super.init()
        reload()
    }
    
    func rowCount(section: Int) -> Int {
        return exercisesForSection(section).count
    }
    
    func title(indexPath: IndexPath) -> String? {
        return exercisesForSection(indexPath.section)[indexPath.row].name!
    }
    
    func titleForSection(_ section: Int) -> String? {
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
        guard let name = title(indexPath: indexPath) else { return }
        templateManagement.deleteExerciseTemplate(name: name)
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
        pushExercises = templateManagement.exerciseTemplates(withType: .push)?.sorted(by: exerciseTemplateSorter) ?? []
        pullExercises = templateManagement.exerciseTemplates(withType: .pull)?.sorted(by: exerciseTemplateSorter) ?? []
        legsExercises = templateManagement.exerciseTemplates(withType: .legs)?.sorted(by: exerciseTemplateSorter) ?? []
    }
}
