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
    var creationView: ExerciseTemplateCreationView {
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
        if !showExerciseType {
            hideExerciseType()
        }
        creationView.textField.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        bind()
        setupLateralTypeSegmentedControl()
    }
    
    fileprivate func bind() {
        bindButtons()
        bindViewModel()
    }
    
    fileprivate func bindButtons() {
        for btn in [creationView.pushButton, creationView.pullButton, creationView.legsButton] {
            btn?.addTarget(self, action: #selector(typeSelected(_:)), for: .touchUpInside)
        }
        creationView.saveButton.addTarget(self, action: #selector(save), for: .touchUpInside)
    }
    
    fileprivate func bindViewModel() {
        guard let viewModel = viewModel else { return }
        bindSaveButtonToViewModel(viewModel)
        bindSanitizerToTextField(viewModel)
//        bindTypeButtonDeselectionToViewModel(viewModel)
        bindExerciseNameToTextField(viewModel)
    }
    
    fileprivate func bindSaveButtonToViewModel(_ viewModel: ExerciseTemplateCreationViewModel) {
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
    
    fileprivate func bindSanitizerToTextField(_ viewModel: ExerciseTemplateCreationViewModel) {
        viewModel.$exerciseName.sink { [weak self] name in
            guard let textField = self?.creationView.textField, let name = name else { return }
            textField.text = ExerciseNameSanitizer().sanitize(name)
        }
        .store(in: &cancellables)
    }
    
//    fileprivate func bindTypeButtonDeselectionToViewModel(_ viewModel: ExerciseTemplateCreationViewModel) {
//        viewModel.$exerciseType.sink { [weak self] type in
//            guard let btn = self?.creationView.saveButton else { return }
//            if btn.title(for: .normal) != "Save" {
//                btn.setTitle("Save", for: .normal)
//            }
////            self?.highlightType(type)
//        }
//        .store(in: &cancellables)
//    }
    
    fileprivate func bindExerciseNameToTextField(_ viewModel: ExerciseTemplateCreationViewModel) {
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
        viewModel?.selectedType(type)
        DispatchQueue.main.async {
            self.highlightType(type)
        }
    }
    
    fileprivate func highlightType(_ buttonType: ExerciseType) {
        print("\(buttonType)")
        for type in [ExerciseType.push, .pull, .legs] {
            let button = buttonForType(type)
            button?.isHighlighted = button?.exerciseType == buttonType
        }
    }
    
    @objc func save() {
        guard let text = creationView.textField.text else {
            return
        }
        let alert = UIAlertController(title: "Add to Workout?", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] (action) in
            guard let self = self else { return }
            self.viewModel?.saveExercise(withName: text, successCompletion: {
                self.dismiss(animated: true, completion: nil)
            })
        }))
        alert.addAction(UIAlertAction(title: "No", style: .destructive, handler: { [weak self] (action) in
            self?.creationView.saveButton.isEnabled = false
        }))
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func buttonForType(_ type: ExerciseType) -> ExerciseTypeButton? {
        switch type {
        case .push:
            return creationView.pushButton
        case .pull:
            return creationView.pullButton
        case .legs:
            return creationView.legsButton
        default:
            return nil
        }
    }
    
    fileprivate func setupLateralTypeSegmentedControl() {
        creationView.lateralTypeSegmentedControl?.addTarget(self, action: #selector(lateralTypeChanged(_:)), for: .valueChanged)
        creationView.lateralTypeSegmentedControl?.selectedSegmentIndex = 0
        viewModel?.lateralType = .bilateral
    }
    
    @objc fileprivate func lateralTypeChanged(_ control: UISegmentedControl) {
        viewModel?.lateralType = control.selectedSegmentIndex == 0 ? LateralType.bilateral : .unilateral
    }
    
    fileprivate func hideExerciseType() {
        guard let constraint = creationView.parentStackView.constraints.first(where: { $0.identifier == "height" }) else { return }
        creationView.typeSelectionStackView?.superview?.removeFromSuperview()
        creationView.parentStackView.removeConstraint(constraint)
        creationView.parentStackView
            .heightAnchor
            .constraint(equalToConstant: 200)
            .isActive = true
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

