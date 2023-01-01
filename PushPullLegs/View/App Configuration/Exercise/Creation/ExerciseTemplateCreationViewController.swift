//
//  NameSaverViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 3/21/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit
import Combine

class ExerciseTemplateCreationView: UIView {
    lazy var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 27)
        lbl.textAlignment = .center
        lbl.text = "New Exercise"
        return lbl
    }()
    lazy var textFieldContainer: UIView = {
        let cnt = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: parentStackView.frame.height / 3))
        
        
        return cnt
    }()
    var textField: UITextField {
        if let txt = textFieldContainer.subviews.first as? UITextField {
            return txt
        }
        let txt = UITextField()
        textFieldContainer.addSubview(txt)
        txt.translatesAutoresizingMaskIntoConstraints = false
        txt.centerXAnchor.constraint(equalTo: textFieldContainer.centerXAnchor).isActive = true
        txt.centerYAnchor.constraint(equalTo: textFieldContainer.centerYAnchor).isActive = true
        txt.heightAnchor.constraint(equalToConstant: 58).isActive = true
        txt.widthAnchor.constraint(equalToConstant: 250).isActive = true
        return txt
    }
    lazy var typeSelectionContainerView: UIView = {
        let cnt = UIView()
        return cnt
    }()
    weak var typeSelectionStackView: UIStackView?
    weak var pushButton: ExerciseTypeButton?
    weak var pullButton: ExerciseTypeButton?
    weak var legsButton: ExerciseTypeButton?
    lazy var saveButton: UIButton = {
        let btn = UIButton(configuration: saveButtonConfig)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btn.setTitle("Save", for: .normal)
        return btn
    }()
    var saveButtonConfig: UIButton.Configuration {
        var config = UIButton.Configuration.borderedProminent()
        config.baseBackgroundColor = .black
        config.buttonSize = UIButton.Configuration.Size.large
        return config
    }
    lazy var parentStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = NSLayoutConstraint.Axis.vertical
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.alignment = .fill
        return stack
    }()
    let parentStackPadding: CGFloat = 20
    let parentStackHeight: CGFloat = 300
    lazy var lateralTypeParentView: UIView = {
        return UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: parentStackView.frame.height / 3))
    }()
    weak var lateralTypeSegmentedControl: UISegmentedControl?
    private var firstLoad = true
    
    override func layoutSubviews() {
        guard firstLoad else { return }
        firstLoad = false
        addParentStackView()
        addSaveButton()
        styleTextField()
        if typeSelectionStackView == nil {
            addTypeStackView()
        }
        setupLateralTypeSegmentedControl()
        parentStackView.addArrangedSubview(titleLabel)
        parentStackView.addArrangedSubview(textFieldContainer)
        parentStackView.addArrangedSubview(typeSelectionContainerView)
        parentStackView.addArrangedSubview(lateralTypeParentView)
    }
    
    func addParentStackView() {
        addSubview(parentStackView)
        parentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: parentStackPadding).isActive = true
        parentStackView.topAnchor.constraint(equalTo: topAnchor, constant: parentStackPadding).isActive = true
        parentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -parentStackPadding).isActive = true
        let height = parentStackView.heightAnchor.constraint(equalToConstant: parentStackHeight)
        height.identifier = "height"
        height.isActive = true
    }
    
    func addSaveButton() {
        addSubview(saveButton)
        saveButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        saveButton.topAnchor.constraint(equalTo: parentStackView.bottomAnchor, constant: parentStackPadding).isActive = true
    }
    
    func styleTextField() {
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.placeholder = "Exercise Name"
        textField.autocapitalizationType = .words
        textField.keyboardType = .asciiCapable
    }
    
    func addTypeStackView() {
        let stack = UIStackView()
        typeSelectionContainerView.addSubview(stack)
        typeSelectionStackView = stack
        constrainTypeStackview(stack)
        styleTypeStackView(stack)
    }
    
    func constrainTypeStackview(_ stack: UIStackView) {
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.leadingAnchor.constraint(equalTo: typeSelectionContainerView.leadingAnchor, constant: 2).isActive = true
        stack.trailingAnchor.constraint(equalTo: typeSelectionContainerView.trailingAnchor, constant: -2).isActive = true
        stack.bottomAnchor.constraint(equalTo: typeSelectionContainerView.bottomAnchor).isActive = true
        stack.topAnchor.constraint(equalTo: typeSelectionContainerView.topAnchor).isActive = true
    }
    
    func styleTypeStackView(_ stack: UIStackView) {
        stack.distribution = .fillEqually
        stack.spacing = 12
        stack.alignment = .fill
    }
    
    func setupLateralTypeSegmentedControl() {
        let segmentedControl = UISegmentedControl.PPLSegmentedControl(titles: ["Bilateral", "Unilateral"])
        lateralTypeParentView.addSubview(segmentedControl)
        lateralTypeSegmentedControl = segmentedControl
        segmentedControl.selectedSegmentIndex = 0
        constrainSegmentedControl(segmentedControl)
    }
    
    func constrainSegmentedControl(_ segCon: UISegmentedControl) {
        segCon.translatesAutoresizingMaskIntoConstraints = false
        segCon.leadingAnchor.constraint(equalTo: lateralTypeParentView.leadingAnchor, constant: 24).isActive = true
        segCon.trailingAnchor.constraint(equalTo: lateralTypeParentView.trailingAnchor, constant: -24).isActive = true
        segCon.topAnchor.constraint(equalTo: lateralTypeParentView.topAnchor, constant: 4).isActive = true
        segCon.bottomAnchor.constraint(equalTo: lateralTypeParentView.bottomAnchor, constant: -4).isActive = true
    }
}

class ExerciseTemplateCreationViewController: UIViewController, UITextFieldDelegate {
    var creationView: ExerciseTemplateCreationView {
        (view as? ExerciseTemplateCreationView) ?? ExerciseTemplateCreationView()
    }
    private var cancellables: Set<AnyCancellable> = []
    var showExerciseType: Bool = false
    var viewModel: ExerciseTemplateCreationViewModel?
    
    override func loadView() {
        view = ExerciseTemplateCreationView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = PPLColor.primary
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        creationView.textField.autocorrectionType = .no
        creationView.textField.textAlignment = .center
        creationView.textField.backgroundColor = PPLColor.quaternary
        creationView.textField.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if showExerciseType && creationView.pushButton == nil {
            setupExerciseTypeButtons()
//            creationView.saveButton.setTitle("Select Type", for: .normal)
        } else {
            hideExerciseType()
        }
        bind()
        setupLateralTypeSegmentedControl()
    }
    
    fileprivate func bind() {
        bindButtons()
        bindViewModel()
    }
    
    fileprivate func bindButtons() {
        NotificationCenter.default.addObserver(self, selector: #selector(pushButtonSelected(_:)), name: PPLButton.touchDownNotificationName(), object: creationView.pushButton)
        NotificationCenter.default.addObserver(self, selector: #selector(pullButtonSelected(_:)), name: PPLButton.touchDownNotificationName(), object: creationView.pullButton)
        NotificationCenter.default.addObserver(self, selector: #selector(legsButtonSelected(_:)), name: PPLButton.touchDownNotificationName(), object: creationView.legsButton)
        NotificationCenter.default.addObserver(self, selector: #selector(touchDownSaveButton(_:)), name: PPLButton.touchDownNotificationName(), object: creationView.saveButton)
    }
    
    fileprivate func bindViewModel() {
        guard let viewModel = viewModel else { return }
        bindSaveButtonToViewModel(viewModel)
        bindSanitizerToTextField(viewModel)
        bindTypeButtonDeselectionToViewModel(viewModel)
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
    
    fileprivate func bindTypeButtonDeselectionToViewModel(_ viewModel: ExerciseTemplateCreationViewModel) {
        viewModel.$exerciseType.sink { [weak self] type in
            guard let btn = self?.creationView.saveButton else { return }
            if btn.title(for: .normal) != "Save" {
                btn.setTitle("Save", for: .normal)
            }
            self?.deselectAllTypeButtons(except: type)
        }
        .store(in: &cancellables)
    }
    
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
    
    @IBAction func save() {
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
    
    fileprivate func setupExerciseTypeButtons() {
        for type in [ExerciseType.push, ExerciseType.pull, ExerciseType.legs] {
            let btn = buttonForType(type) ?? newButtonForType(type)
            btn.setTitle(type.rawValue, for: .normal)
            btn.exerciseType = type
        }
    }
    
    func newButtonForType(_ type: ExerciseType) -> ExerciseTypeButton {
        let btn = ExerciseTypeButton()
        btn.setTitle(type.rawValue, for: .normal)
        btn.exerciseType = type
        creationView.typeSelectionStackView?.addArrangedSubview(btn)
        creationView.typeSelectionStackView?.isUserInteractionEnabled = true
        creationView.lateralTypeParentView.isUserInteractionEnabled = true
        switch type {
        case .push:
            creationView.pushButton = btn
        case .pull:
            creationView.pullButton = btn
        case .legs:
            creationView.legsButton = btn
        case .error: break
            // no op
        }
        return btn
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

