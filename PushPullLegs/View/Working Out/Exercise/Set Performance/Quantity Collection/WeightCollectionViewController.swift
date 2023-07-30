//
//  WeightCollectionViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/26/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Combine
import UIKit

class WeightCollectionViewController: QuantityCollectionViewController, ExercisingViewController {

    var exerciseSetViewModel: ExerciseSetViewModel?
    weak var superSetDelegate: SuperSetDelegate?
    weak var dropSetDelegate: DropSetDelegate?
    var superSetIsReady = false {
        didSet { navigationItem.rightBarButtonItem?.isEnabled = !superSetIsReady }
    }
    var navItemTitle: String = "Weight"
    var thereAreOtherExercises = false
    
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
        guard superSetDelegate != nil
        else { return }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Super Set", style: .plain, target: self, action: #selector(addSuperSet))
    }
    
    @objc
    private func addSuperSet() {
        guard thereAreOtherExercises else {
            return presentAddAnExerciseToSuperSetAlert()
        }
        superSetDelegate?.superSetSelected()
        navigationItem.leftBarButtonItem = nil
    }
    
    private func presentAddAnExerciseToSuperSetAlert() {
        let alert = UIAlertController(title: "Add Another Exercise", message: "You need to add another exercise in order to do a super set.", preferredStyle: .alert)
        alert.addAction(.ok)
        present(alert, animated: true)
    }
    
    func addDropSetBarButtonItem() {
        guard dropSetDelegate != nil
        else { return }
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

extension UIAlertAction {
    static var ok: UIAlertAction { UIAlertAction(title: "OK", style: .default) }
}
