//
//  ExerciseTemplateListViewModel.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/15/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation
import CoreData

let sorter = { (obj1: NSManagedObject, obj2: NSManagedObject) -> Bool in
    let name1 = obj1.value(forKey: "name") as? String ?? ""
    let name2 = obj2.value(forKey: "name") as? String ?? ""
    return name1 < name2
}

let exerciseTemplateSorter = { (temp1: ExerciseTemplate, temp2: ExerciseTemplate) -> Bool in
    guard let temp1Name = temp1.name, let temp2Name = temp2.name else { return false }
    return temp1Name < temp2Name
}

protocol ExerciseTemplateListViewModelDelegate {
    func viewModelFailedToSaveExerciseWithNameAlreadyExists(_ model: ExerciseTemplateListViewModel)
}

class ExerciseTemplateListViewModel: NSObject, PPLTableViewModel, ReloadProtocol {
    
    let templateManagement: TemplateManagement
    private lazy var exercises = [ExerciseTemplate]()
    var delegate: ExerciseTemplateListViewModelDelegate?
    
    init(withTemplateManagement mgmt: TemplateManagement) {
        templateManagement = mgmt
        super.init()
        reload()
    }
    
    func rowCount(section: Int) -> Int {
        exercises.count
    }
    
    func title() -> String? {
        "Exercises"
    }
    
    func sectionCount() -> Int {
        1
    }
    
    func title(indexPath: IndexPath) -> String? {
        exercises[indexPath.row].name
    }
    
    func titleForSection(_ section: Int) -> String? {
        ExerciseTypeName.allCases[section].rawValue
    }
    
    func deleteExercise(indexPath: IndexPath) {
        guard let name = title(indexPath: indexPath) else { return }
        templateManagement.deleteExerciseTemplate(name: name)
    }
    
    func reload() {
        exercises = templateManagement.exerciseTemplates()?.sorted(by: exerciseTemplateSorter) ?? []
    }
    
    func noDataText() -> String {
        "No Exercises"
    }
    
    func templateEditViewModel(indexPath: IndexPath) -> ExerciseTemplateEditViewModel? {
        ExerciseTemplateEditViewModel(template: exercises[indexPath.row], management: templateManagement)
    }
}
