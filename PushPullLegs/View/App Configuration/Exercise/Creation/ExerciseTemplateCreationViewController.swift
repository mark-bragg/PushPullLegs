//
//  NameSaverViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 3/21/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit
import Combine

class ExerciseTemplateCreationViewController: UIViewController, UITextFieldDelegate {
    private var creationView: ExerciseTemplateCreationView {
        (view as? ExerciseTemplateCreationView) ?? ExerciseTemplateCreationView()
    }
    private var cancellables: Set<AnyCancellable> = []
    var showExerciseType: Bool = false
    var viewModel: ExerciseTemplateCreationViewModel?
    
    override func loadView() {
        view = ExerciseTemplateCreationView(showExerciseType: showExerciseType)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        creationView.textField.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        bind()
        if let segCon = creationView.lateralTypeSegmentedControl, segCon.allTargets.isEmpty {
            segCon.addTarget(self, action: #selector(lateralTypeChanged(_:)), for: .valueChanged)
        }
    }
    
    private func bind() {
        bindButtons()
        bindViewModel()
    }
    
    private func bindButtons() {
        creationView.typeButtons.forEach {
            $0?.addTarget(self, action: #selector(typeSelected(_:)), for: .touchUpInside)
        }
        creationView.saveButton.addTarget(self, action: #selector(save), for: .touchUpInside)
    }
    
    private func bindViewModel() {
        guard let viewModel = viewModel else { return }
        bindSaveButtonToViewModel(viewModel)
        bindSanitizerToTextField(viewModel)
        bindExerciseNameToTextField(viewModel)
    }
    
    private func bindSaveButtonToViewModel(_ viewModel: ExerciseTemplateCreationViewModel) {
        viewModel.$isSaveEnabled.sink { [weak self] enabled in
            guard let btn = self?.creationView.saveButton else { return }
            if enabled && !btn.isEnabled {
                btn.isEnabled = true
            } else if !enabled && btn.isEnabled {
                btn.isEnabled = false
            }
        }
        .store(in: &cancellables)
    }
    
    private func bindSanitizerToTextField(_ viewModel: ExerciseTemplateCreationViewModel) {
        viewModel.$exerciseName.sink { [weak self] name in
            guard let textField = self?.creationView.textField, let name = name else { return }
            textField.text = ExerciseNameSanitizer().sanitize(name)
        }
        .store(in: &cancellables)
    }
    
    private func bindExerciseNameToTextField(_ viewModel: ExerciseTemplateCreationViewModel) {
        [UITextField.textDidChangeNotification,
         UITextField.textDidBeginEditingNotification,
         UITextField.textDidEndEditingNotification
        ].forEach({ notif in
            NotificationCenter.default.publisher(for: notif, object: creationView.textField)
            .map( { (($0.object as? UITextField)?.text ?? "") } )
            .map({ (text) -> String in
                return ExerciseNameSanitizer().sanitize(text)
            })
            .assign(to: \ExerciseTemplateCreationViewModel.exerciseName, on: viewModel)
            .store(in: &cancellables)
        })
    }
    
    @objc private func typeSelected(_ button: ExerciseTypeButton) {
        guard let type = button.exerciseType else { return }
        viewModel?.exerciseType = type
        DispatchQueue.main.async {
            self.highlightType(type)
        }
    }
    
    private func highlightType(_ buttonType: ExerciseTypeName) {
        for type in ExerciseTypeName.allCases {
            let button = creationView.button(for: type)
            button?.isHighlighted = button?.exerciseType == buttonType
        }
    }
    
    @objc func save() {
        guard let text = creationView.textField.text, let alert = saveAlert(text) else {
            return
        }
        present(alert, animated: true, completion: nil)
    }
    
    private func saveAlert(_ exerciseName: String) -> UIAlertController? {
        guard let type = viewModel?.exerciseType else { return nil }
        let alert = UIAlertController(title: "Add \(exerciseName) to your \(type.rawValue) Workout?", message: nil, preferredStyle: .actionSheet)
        alert.addAction(saveAction(exerciseName))
        alert.addAction(cancelAction())
        return alert
    }
    
    private func saveAction(_ exerciseName: String) -> UIAlertAction {
        UIAlertAction(title: "Yes", style: .default) { [weak self] (action) in
            self?.viewModel?.saveExercise(withName: exerciseName, successCompletion: {
                self?.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    private func cancelAction() -> UIAlertAction {
        UIAlertAction(title: "No", style: .destructive)
    }
    
    @objc private func lateralTypeChanged(_ control: UISegmentedControl) {
        viewModel?.lateralType = control.selectedSegmentIndex == 0 ? LateralType.bilateral : .unilateral
    }
    
}

class ExerciseNameSanitizer: NSObject, StringSanitizer {
    var characters: [String] = [" "]
    
    func sanitize(_ string: String) -> String {
        var sanitized = string
        while sanitized.first == " " {
            sanitized.removeFirst()
        }
        sanitized.removeAll(where: { !($0.isLetter || $0.isWhitespace) })
        while sanitized.suffix(2) == "  " {
            sanitized.removeLast()
        }
        return sanitized
    }
}

protocol StringSanitizer: NSObject {
    var characters: [String] { get set }
    func sanitize(_ string: String) -> String
}

