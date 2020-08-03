//
//  NameSaverViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 3/21/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

class ExerciseTemplateCreationViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var pushButton: ExerciseTypeButton!
    @IBOutlet weak var pullButton: ExerciseTypeButton!
    @IBOutlet weak var legsButton: ExerciseTypeButton!
    @IBOutlet weak var typeSelectionStackView: UIStackView!
    @IBOutlet weak var saveButton: PPLButton!
    @IBOutlet weak var parentStackView: UIStackView!
    
    var showExerciseType: Bool = false
    var viewModel: ExerciseTemplateCreationViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = PPLColor.grey
        if showExerciseType {
            setupExerciseTypeButtons()
            saveButton.setTitle("Select Type", for: .normal)
        } else {
            hideExerciseType()
        }
        styleButtons()
    }
    
    func styleButtons() {
        for btn in [saveButton, pushButton, pullButton, legsButton] {
            btn?.style()
        }
        saveButton.disable()
    }
    
    @IBAction func touchDownSaveButton(_ sender: UIButton) {
        sender.removeShadow()
        save()
    }
    
    @IBAction func save() {
        guard let text = textField.text else {
            return
        }
        viewModel?.saveExercise(withName: text, successCompletion: { [weak self] in
            guard let self = self else { return }
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func setupExerciseTypeButtons() {
        for type in [ExerciseType.push, ExerciseType.pull, ExerciseType.legs] {
            let btn = buttonForType(type)
            btn?.setTitle(type.rawValue, for: .normal)
            btn?.exerciseType = type
        }
    }
    
    private func buttonForType(_ type: ExerciseType) -> ExerciseTypeButton? {
        switch type {
        case .push:
            return pushButton
        case .pull:
            return pullButton
        case .legs:
            return legsButton
        default:
            return nil
        }
    }
    
    @IBAction func tappedExerciseTypeButton(_ sender: ExerciseTypeButton) {
        if saveButton.title(for: .normal) != "Save" {
            saveButton.setTitle("Save", for: .normal)
        }
        viewModel?.selectedType(sender.exerciseType)
        updateButtonsWithSelection(sender)
    }
    
    func updateButtonsWithSelection(_ button: ExerciseTypeButton) {
        button.selection()
        for btn in [pushButton, pullButton, legsButton] {
            btn?.removeShadow()
            if btn != button {
                btn?.deselection()
            }
        }
        enableSaveButton(textField.text)
    }
    
    func hideExerciseType() {
        typeSelectionStackView.superview?.removeFromSuperview()
        parentStackView.removeConstraint(parentStackView.constraints.first(where: { $0.identifier == "height" })!)
        parentStackView
            .heightAnchor
            .constraint(equalToConstant: 200)
            .isActive = true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        enableSaveButton(textField.text)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        enableSaveButton(textField.text)
    }
    
    @IBAction func textFieldDidChangeEditing(_ sender: UITextField) {
        enableSaveButton(textField.text)
    }
    
    private func enableSaveButton(_ text: String?) {
        guard let vm = viewModel else {
            return
        }
        if text != nil && vm.isTypeSelected(), text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) != "" {
            saveButton.enable()
        } else {
            saveButton.disable()
        }
    }
    
}
