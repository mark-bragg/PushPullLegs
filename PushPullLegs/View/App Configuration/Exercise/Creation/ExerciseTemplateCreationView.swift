//
//  ExerciseTemplateCreationView.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 1/1/23.
//  Copyright © 2023 Mark Bragg. All rights reserved.
//

import UIKit

class ExerciseTemplateCreationView: UIView {
    private lazy var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 27)
        lbl.textAlignment = .center
        lbl.text = "New Exercise"
        return lbl
    }()
    private lazy var textFieldContainer: UIView = {
        UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: parentStackView.frame.height / 3))
    }()
    var textField: UITextField {
        if let txt = textFieldContainer.subviews.first as? UITextField {
            return txt
        }
        let txt = UITextField()
        textFieldContainer.addSubview(txt)
        constrainTextField(txt)
        styleTextField()
        return txt
    }
    private func constrainTextField(_ txt: UITextField) {
        txt.translatesAutoresizingMaskIntoConstraints = false
        txt.centerXAnchor.constraint(equalTo: textFieldContainer.centerXAnchor).isActive = true
        txt.centerYAnchor.constraint(equalTo: textFieldContainer.centerYAnchor).isActive = true
        txt.heightAnchor.constraint(equalToConstant: 58).isActive = true
        txt.widthAnchor.constraint(equalToConstant: 250).isActive = true
    }
    private lazy var typeSelectionContainerView: UIView = {
        UIView()
    }()
    private weak var typeSelectionStackView: UIStackView?
    weak var pushButton: ExerciseTypeButton?
    weak var pullButton: ExerciseTypeButton?
    weak var legsButton: ExerciseTypeButton?
    weak var armsButton: ExerciseTypeButton?
    var typeButtons: [ExerciseTypeButton?] {
        [pushButton, pullButton, legsButton, armsButton]
    }
    lazy var saveButton: UIButton = {
        let btn = UIButton(configuration: saveButtonConfig)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btn.setTitle("Save", for: .normal)
        return btn
    }()
    private var saveButtonConfig: UIButton.Configuration {
        var config = UIButton.Configuration.borderedProminent()
        config.baseBackgroundColor = .black
        config.buttonSize = UIButton.Configuration.Size.large
        return config
    }
    private lazy var parentStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = NSLayoutConstraint.Axis.vertical
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.alignment = .fill
        return stack
    }()
    private let parentStackPadding: CGFloat = 20
    private var parentStackHeight: CGFloat {
        showExerciseType ? 300 : 225
    }
    private lazy var lateralTypeParentView: UIView = {
        UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: parentStackView.frame.height / 3))
    }()
    weak var lateralTypeSegmentedControl: UISegmentedControl?
    private var firstLoad = true
    private var showExerciseType = true
    
    init(showExerciseType: Bool = true) {
        self.showExerciseType = showExerciseType
        super.init(frame: .zero)
        backgroundColor = .primary
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        guard firstLoad else { return }
        firstLoad = false
        addParentStackView()
        addSaveButton()
        styleTextField()
        setupLateralTypeSegmentedControl()
        fillStack()
    }
    
    private func addParentStackView() {
        addSubview(parentStackView)
        parentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: parentStackPadding).isActive = true
        parentStackView.topAnchor.constraint(equalTo: topAnchor, constant: parentStackPadding).isActive = true
        parentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -parentStackPadding).isActive = true
        let height = parentStackView.heightAnchor.constraint(equalToConstant: parentStackHeight)
        height.identifier = "height"
        height.isActive = true
    }
    
    private func addSaveButton() {
        addSubview(saveButton)
        saveButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        saveButton.topAnchor.constraint(equalTo: parentStackView.bottomAnchor, constant: parentStackPadding).isActive = true
    }
    
    private func styleTextField() {
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.placeholder = "Exercise Name"
        textField.autocapitalizationType = .words
        textField.keyboardType = .asciiCapable
        textField.autocorrectionType = .no
        textField.backgroundColor = PPLColor.quaternary
    }
    
    private func addTypeStackView() {
        let stack = UIStackView()
        typeSelectionContainerView.addSubview(stack)
        typeSelectionStackView = stack
        constrainTypeStackview(stack)
        styleTypeStackView(stack)
    }
    
    private func constrainTypeStackview(_ stack: UIStackView) {
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: typeSelectionContainerView.leadingAnchor, constant: 2),
            stack.trailingAnchor.constraint(equalTo: typeSelectionContainerView.trailingAnchor, constant: -2),
            stack.bottomAnchor.constraint(equalTo: typeSelectionContainerView.bottomAnchor),
            stack.topAnchor.constraint(equalTo: typeSelectionContainerView.topAnchor)
        ])
    }
    
    private func styleTypeStackView(_ stack: UIStackView) {
        stack.distribution = .fillEqually
        stack.spacing = 12
        stack.alignment = .fill
    }
    
    private func setupExerciseTypeButtons() {
        for type in ExerciseTypeName.allCases {
            setButton(newButtonForType(type))
        }
    }
    
    private func newButtonForType(_ type: ExerciseTypeName) -> ExerciseTypeButton {
        let btn = ExerciseTypeButton()
        btn.setTitle(type.rawValue, for: .normal)
        btn.exerciseType = type
        btn.setBackgroundColor(color: .black, forState: .highlighted)
        btn.setBackgroundColor(color: .quaternary, forState: .normal)
        typeSelectionStackView?.addArrangedSubview(btn)
        return btn
    }
    
    private func setupLateralTypeSegmentedControl() {
        let segmentedControl = UISegmentedControl.PPLSegmentedControl(titles: ["Bilateral", "Unilateral"])
        lateralTypeParentView.addSubview(segmentedControl)
        lateralTypeSegmentedControl = segmentedControl
        segmentedControl.selectedSegmentIndex = 0
        constrainSegmentedControl(segmentedControl)
    }
    
    private func setButton(_ button: ExerciseTypeButton) {
        switch button.exerciseType {
        case .push:
            pushButton = button
        case .pull:
            pullButton = button
        case .legs:
            legsButton = button
        case .arms:
            armsButton = button
        default:
            break
        }
    }
    
    func button(for type: ExerciseTypeName) -> ExerciseTypeButton? {
        typeButtons.first(where: { $0?.exerciseType == type }) ?? nil
    }
    
    private func constrainSegmentedControl(_ segCon: UISegmentedControl) {
        segCon.translatesAutoresizingMaskIntoConstraints = false
        segCon.leadingAnchor.constraint(equalTo: lateralTypeParentView.leadingAnchor, constant: 24).isActive = true
        segCon.trailingAnchor.constraint(equalTo: lateralTypeParentView.trailingAnchor, constant: -24).isActive = true
        segCon.topAnchor.constraint(equalTo: lateralTypeParentView.topAnchor, constant: 4).isActive = true
        segCon.bottomAnchor.constraint(equalTo: lateralTypeParentView.bottomAnchor, constant: -4).isActive = true
    }
    
    private func fillStack() {
        parentStackView.addArrangedSubview(titleLabel)
        parentStackView.addArrangedSubview(textFieldContainer)
        if typeSelectionStackView == nil && showExerciseType {
            addTypeStackView()
            setupExerciseTypeButtons()
            parentStackView.addArrangedSubview(typeSelectionContainerView)
        }
        parentStackView.addArrangedSubview(lateralTypeParentView)
    }
}
