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
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var pushButton: ExerciseTypeButton!
    @IBOutlet weak var pullButton: ExerciseTypeButton!
    @IBOutlet weak var legsButton: ExerciseTypeButton!
    @IBOutlet weak var typeSelectionStackView: UIStackView!
    @IBOutlet weak var saveButton: PPLButton!
    @IBOutlet weak var parentStackView: UIStackView!
    private var cancellables: Set<AnyCancellable> = []
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
        bind()
    }
    
    fileprivate func bind() {
        bindButtons()
        bindViewModel()
    }
    
    fileprivate func bindButtons() {
        NotificationCenter.default.addObserver(self, selector: #selector(pushButtonSelected(_:)), name: PPLButton.touchDownNotificationName(), object: pushButton)
        NotificationCenter.default.addObserver(self, selector: #selector(pullButtonSelected(_:)), name: PPLButton.touchDownNotificationName(), object: pullButton)
        NotificationCenter.default.addObserver(self, selector: #selector(legsButtonSelected(_:)), name: PPLButton.touchDownNotificationName(), object: legsButton)
        NotificationCenter.default.addObserver(self, selector: #selector(touchDownSaveButton(_:)), name: PPLButton.touchDownNotificationName(), object: saveButton)
    }
    
    fileprivate func bindViewModel() {
        guard let viewModel = viewModel else { return }
        bindSaveButtonToViewModel(viewModel)
        bindSanitizerToTextField(viewModel)
        bindTypButtonDeselectionToViewModel(viewModel)
        bindExerciseNameToTextField(viewModel)
    }
    
    fileprivate func bindSaveButtonToViewModel(_ viewModel: ExerciseTemplateCreationViewModel) {
        viewModel.$isSaveEnabled.sink { [weak self] enabled in
            guard let self = self else { return }
            if enabled && !self.saveButton.isEnabled {
                self.saveButton.enable()
            } else if !enabled && self.saveButton.isEnabled {
                self.saveButton.disable()
            }
        }
        .store(in: &cancellables)
    }
    
    fileprivate func bindSanitizerToTextField(_ viewModel: ExerciseTemplateCreationViewModel) {
        viewModel.$exerciseName.sink { [weak self] name in
            guard let self = self, let name = name else { return }
            self.textField.text = ExerciseNameSanitizer().sanitize(name)
        }
        .store(in: &cancellables)
    }
    
    fileprivate func bindTypButtonDeselectionToViewModel(_ viewModel: ExerciseTemplateCreationViewModel) {
        viewModel.$exerciseType.sink { [weak self] type in
            guard let self = self else { return }
            if self.saveButton.title(for: .normal) != "Save" {
                self.saveButton.setTitle("Save", for: .normal)
            }
            self.deselectAllTypeButtons(except: type)
        }
        .store(in: &cancellables)
    }
    
    fileprivate func bindExerciseNameToTextField(_ viewModel: ExerciseTemplateCreationViewModel) {
        [UITextField.textDidChangeNotification,
         UITextField.textDidBeginEditingNotification,
         UITextField.textDidEndEditingNotification
        ].forEach({ notif in
            NotificationCenter.default.publisher(for: notif, object: textField)
            .map( { ($0.object as! UITextField).text } )
            .assign(to: \ExerciseTemplateCreationViewModel.exerciseName, on: viewModel)
            .store(in: &cancellables)
        })
    }
    
    @objc fileprivate func pushButtonSelected(_ notification: Notification) {
        viewModel?.selectedType(.push)
    }
    
    @objc fileprivate func pullButtonSelected(_ notification: Notification) {
        viewModel?.selectedType(.pull)
    }
    
    @objc fileprivate func legsButtonSelected(_ notification: Notification) {
        viewModel?.selectedType(.legs)
    }
    
    @objc fileprivate func touchDownSaveButton(_ notification: Notification) {
        save()
    }
    
    fileprivate func deselectAllTypeButtons(except: ExerciseType) {
        for type in [ExerciseType.push, ExerciseType.pull, ExerciseType.legs].filter({ $0 != except }) {
            buttonForType(type)?.releaseButton()
        }
    }
    
    fileprivate func styleButtons() {
        for btn in [saveButton, pushButton, pullButton, legsButton] {
            btn?.style()
        }
        saveButton.disable()
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
    
    fileprivate func setupExerciseTypeButtons() {
        for type in [ExerciseType.push, ExerciseType.pull, ExerciseType.legs] {
            let btn = buttonForType(type)
            btn?.setTitle(type.rawValue, for: .normal)
            btn?.exerciseType = type
        }
    }
    
    fileprivate func buttonForType(_ type: ExerciseType) -> ExerciseTypeButton? {
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
    
    fileprivate func hideExerciseType() {
        typeSelectionStackView.superview?.removeFromSuperview()
        parentStackView.removeConstraint(parentStackView.constraints.first(where: { $0.identifier == "height" })!)
        parentStackView
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

