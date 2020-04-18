//
//  NameSaverViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 3/21/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

class ExerciseTypeButton: UIButton {
    var exerciseType: ExerciseType! = nil
}

class ExerciseCreationViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var exerciseTypeLabel: UILabel!
    @IBOutlet weak var pushButton: ExerciseTypeButton!
    @IBOutlet weak var pullButton: ExerciseTypeButton!
    @IBOutlet weak var legsButton: ExerciseTypeButton!
    @IBOutlet weak var typeSelectionStackView: UIStackView!
    @IBOutlet weak var saveButton: UIButton!
    
    var showExerciseType: Bool = false
    var viewModel: ExerciseCreationViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = "Exercise Name"
        if showExerciseType {
            exerciseTypeLabel.text = "Exercise Type"
            setupExerciseTypeButtons()
        } else {
            hideExerciseType()
        }
        saveButton.isEnabled = false
        self.isModalInPresentation = true
    }

    @IBAction func save(_ sender: Any) {
        guard let text = textField.text else {
            return
        }
        viewModel?.saveExercise(withName: text, successCompletion: {
            dismiss(animated: true, completion: nil)
        })
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
        sender.isSelected = true
        viewModel?.selectedType(sender.exerciseType)
        updateButtonsWithSelection(sender)
    }
    
    func updateButtonsWithSelection(_ button: ExerciseTypeButton) {
        button.isSelected = true
        for btn in [pushButton, pullButton, legsButton] {
            if btn != button {
                btn?.isSelected = false
            }
        }
        enableSaveButton(textField.text)
    }
    
    func hideExerciseType() {
        exerciseTypeLabel.isHidden = true
        typeSelectionStackView.isHidden = true
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
            // enable save button
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
    
}
