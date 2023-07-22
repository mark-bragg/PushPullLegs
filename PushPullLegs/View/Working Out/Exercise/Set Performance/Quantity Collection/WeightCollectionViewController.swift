//
//  WeightCollectionViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/26/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Combine
import UIKit

protocol SuperSetDelegate: NSObjectProtocol {
    func superSetSelected()
    func secondExerciseSelected(_ name: String)
}

class SuperSetWeightCollectionViewController: WeightCollectionViewController {
    override func addSuperSetBarButtonItem() {
        // no op
    }
    
    override func addDropSetBarButtonItem() {
        // no op
    }
}

class WeightCollectionViewController: QuantityCollectionViewController, ExercisingViewController {

    var exerciseSetViewModel: ExerciseSetViewModel?
    weak var superSetDelegate: SuperSetDelegate?
    weak var dropSetDelegate: DropSetDelegate?
    var superSetIsReady = false {
        didSet { navigationItem.rightBarButtonItem?.isEnabled = !superSetIsReady }
    }
    var navItemTitle: String = "Weight"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = navItemTitle
        label?.text = PPLDefaults.instance.isKilograms() ? "Kilograms" : "Pounds"
        button?.setTitle(exerciseSetViewModel?.weightCollectionButtonText(), for: .normal)
        textField?.keyboardType = .decimalPad
        characterLimit = 7
        addSuperSetBarButtonItem()
        addDropSetBarButtonItem()
    }
    
    func addSuperSetBarButtonItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Super Set", style: .plain, target: self, action: #selector(addSuperSet))
    }
    
    @objc
    private func addSuperSet() {
        superSetDelegate?.superSetSelected()
        navigationItem.leftBarButtonItem = nil
    }
    
    func addDropSetBarButtonItem() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Drop Sets", style: .plain, target: self, action: #selector(addDropSets))
    }
    
    @objc
    private func addDropSets() {
        dropSetDelegate?.dropSetSelected()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let text = textField?.text, text != ""  {
            button?.isEnabled = true
        } else if let defaultWeight = exerciseSetViewModel?.defaultWeight {
            textField?.text = "\(defaultWeight)".trimTrailingZeroes()
            button?.isEnabled = true
        } else {
            button?.isEnabled = false
        }
    }
    
    override func buttonReleased(_ sender: Any) {
        if let t = textField?.text, let weight = Double(t) {
            super.buttonReleased(sender)
            let converter = PPLDefaults.instance.isKilograms() ? 2.20462 : 1.0
            exerciseSetViewModel?.willStartSetWithWeight(weight * converter)
        }
    }
    
}

class SuperSetViewController: ExerciseTemplateSelectionViewController {
    weak var superSetDelegate: SuperSetDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView?.allowsMultipleSelection = false
    }
    
    override func setupBarButtonItems() {
        // no op
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let name = exerciseSelectionViewModel?.title(indexPath: indexPath)
        else { return }
        superSetDelegate?.secondExerciseSelected(name)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        super.tableHeaderViewContainer(titles: ["Select Exercise For Second Set"])
    }
}

class SuperSetExerciseSelectionViewModel: ExerciseSelectionViewModel {
    private let exerciseNameToRemove: String
    
    init(withType type: ExerciseTypeName, templateManagement: TemplateManagement, minus exerciseName: String, dataSource: ExerciseSelectionViewModelDataSource? = nil) {
        self.exerciseNameToRemove = exerciseName
        super.init(withType: type, templateManagement: templateManagement, dataSource: dataSource)
    }
    
    override func reload() {
        exercises = templateManagement.exerciseTemplatesForWorkout(exerciseType)
        exercises.removeAll { $0.name == exerciseNameToRemove }
    }
    
    override func title() -> String? {
        "Select Second Exercise"
    }
}
