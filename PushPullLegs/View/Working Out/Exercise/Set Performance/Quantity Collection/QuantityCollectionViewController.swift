//
//  QuantityCollectionViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/23/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

extension UIViewController {
    var spacer: UIView { UIView() }
}

class QuantityCollectionViewController: UIViewController, UITextFieldDelegate {
    weak var stackView: UIStackView?
    weak var label: UILabel?
    weak var textField: UITextField?
    weak var button: UIButton?
    let height: CGFloat = 308
    
    private var performingTextCorrection = false
    var characterLimit = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = PPLColor.primary
        addStackView()
        constrainStackView()
        styleStackView()
    }
    
    func addStackView() {
        let stack = UIStackView(arrangedSubviews: [spacer, getLabel(), getTextField(), getButton(), spacer])
        view.addSubview(stack)
        stackView = stack
    }
    
    func constrainStackView() {
        stackView?.translatesAutoresizingMaskIntoConstraints = false
        stackView?.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackView?.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        stackView?.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        stackView?.heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    func styleStackView() {
        stackView?.alignment = UIStackView.Alignment.center
        stackView?.axis = NSLayoutConstraint.Axis.vertical
        stackView?.distribution = UIStackView.Distribution.equalCentering
        stackView?.spacing = 14
    }
    
    func getLabel() -> UILabel {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 28)
        label = lbl
        return lbl
    }
    
    func getTextField() -> UIView {
        let txtContainer = UIView(frame: textFieldContainerFrame())
        let txtFld = UITextField()
        txtContainer.addSubview(txtFld)
        textField = txtFld
        prepareTextField()
        return txtContainer
    }
    
    func textFieldContainerFrame() -> CGRect {
        CGRect(x: 0, y: 0, width: view.frame.width, height: height/3)
    }
    
    func prepareTextField() {
        constraintTextField()
        styleTextField()
        textField?.delegate = self
        textField?.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
    }
    
    func constraintTextField() {
        guard let container = textField?.superview else { return }
        textField?.translatesAutoresizingMaskIntoConstraints = false
        textField?.widthAnchor.constraint(equalToConstant: 180).isActive = true
        textField?.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        textField?.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
    }
    
    func styleTextField() {
        textField?.borderStyle = .roundedRect
        textField?.textAlignment = .center
        textField?.font = UIFont.systemFont(ofSize: 32)
        textField?.backgroundColor = PPLColor.quaternary
        textField?.autocorrectionType = .no
    }
    
    func getButton() -> UIView {
        let btn = UIButton(configuration: buttonConfig())
        btn.backgroundColor = .primary
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btn.addTarget(self, action: #selector(buttonReleased(_:)), for: .touchUpInside)
        button = btn
        return btn
    }
    
    func buttonConfig() -> UIButton.Configuration {
        var config = UIButton.Configuration.borderedProminent()
        config.baseBackgroundColor = .black
        config.buttonSize = UIButton.Configuration.Size.large
        return config
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        button?.isEnabled = textField?.text != nil && textField?.text != ""
        textField?.becomeFirstResponder()
    }
    
    @objc
    func editingChanged(_ sender: Any) {
        guard let textField = sender as? UITextField, let text = textField.text, !text.isEmpty else {
            button?.isEnabled = false
            return
        }
        handleTextCorrection(textField, text)
        guard let textFinal = textField.text, !textFinal.isEmpty else {
            button?.isEnabled = false
            return
        }
        button?.isEnabled = buttonIsEnabledAfterTextIsCorrected()
    }
    
    func handleTextCorrection(_ textField: UITextField, _ text: String) {
        if !performingTextCorrection {
            performingTextCorrection = true
            performTextFieldCorrection(textField, text)
            performingTextCorrection = false
        }
    }
    
    func buttonIsEnabledAfterTextIsCorrected() -> Bool {
        true
    }
    
    func performTextFieldCorrection(_ textField: UITextField, _ text: String) {
        guard let uiRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument) else { return }
        let correctedText = text.reduceToCharacterLimit(characterLimit).cleanupPeriods().trimLeadingZeroes().trimDecimalDigitsToTwo()
        textField.replace(uiRange, withText: correctedText)
    }
    
    @objc func buttonReleased(_ sender: Any) {
        // no-op
    }
}

extension UIViewController {
    func yPositionWithinScreen() -> CGFloat {
        return UIScreen.main.bounds.height - view.frame.height
    }
}
