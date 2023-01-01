//
//  ExerciseTemplateCreationView.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 1/1/23.
//  Copyright © 2023 Mark Bragg. All rights reserved.
//

import UIKit

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
