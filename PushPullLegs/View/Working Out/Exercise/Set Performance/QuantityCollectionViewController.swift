//
//  QuantityCollectionViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/23/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

class QuantityCollectionViewController: UIViewController, UITextFieldDelegate, PPLButtonDelegate {
    weak var stackView: UIStackView?
    weak var label: UILabel?
    weak var textField: UITextField?
    weak var button: UIButton?
    private let height: CGFloat = 308
    private var spacer: UIView { UIView() }
    
    private var performingTextCorrection = false
    var characterLimit = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isUserInteractionEnabled = true
        addStackView()
    }
    
    func addStackView() {
        let stack = UIStackView(arrangedSubviews: [spacer, getLabel(), getTextField(), getButton(), spacer])
        stack.isUserInteractionEnabled = true
        stack.alignment = UIStackView.Alignment.center
        stack.axis = NSLayoutConstraint.Axis.vertical
        stack.distribution = UIStackView.Distribution.equalCentering
        stack.spacing = 14
        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stack.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        stack.heightAnchor.constraint(equalToConstant: height).isActive = true
        stackView = stack
    }
    
    func getLabel() -> UILabel {
        let lbl = UILabel()
        lbl.text = "Enter Weight"
        lbl.font = UIFont.systemFont(ofSize: 28)
        label = lbl
        return lbl
    }
    func getTextField() -> UIView {
        let txtContainer = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: height/3))
        let txtFld = UITextField()
        txtFld.borderStyle = .roundedRect
        txtFld.textAlignment = .center
        txtFld.translatesAutoresizingMaskIntoConstraints = false
        txtFld.widthAnchor.constraint(equalToConstant: 180).isActive = true
        txtFld.font = UIFont.systemFont(ofSize: 40)
        txtContainer.addSubview(txtFld)
        txtFld.centerXAnchor.constraint(equalTo: txtContainer.centerXAnchor).isActive = true
        txtFld.centerYAnchor.constraint(equalTo: txtContainer.centerYAnchor).isActive = true
        textField = txtFld
        return txtContainer
    }
    func getButton() -> UIView {
        var config = UIButton.Configuration.borderedProminent()
        config.baseBackgroundColor = .black
        config.buttonSize = UIButton.Configuration.Size.large
        let btn = UIButton(configuration: config)
        btn.backgroundColor = .primary
        btn.isUserInteractionEnabled = true
        btn.addTarget(self, action: #selector(buttonReleased(_:)), for: .touchUpInside)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        btn.translatesAutoresizingMaskIntoConstraints = false
        button = btn
        return btn
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField?.delegate = self
        textField?.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        textField?.autocorrectionType = .no
        button?.isEnabled = textField?.text != nil
        view.backgroundColor = PPLColor.primary
        textField?.backgroundColor = PPLColor.quaternary
        textField?.becomeFirstResponder()
        label?.textColor = UIColor.white
        textField?.superview?.sizeToFit()
        button?.superview?.sizeToFit()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @objc func editingChanged(_ sender: Any) {
        guard let text = textField?.text, !text.isEmpty else {
            button?.isEnabled = false
            return
        }
        if !performingTextCorrection {
            performingTextCorrection = true
            performTextFieldCorrection(text)
            performingTextCorrection = false
        }
        guard let textFinal = textField?.text, !textFinal.isEmpty else {
            button?.isEnabled = false
            return
        }
        button?.isEnabled = true
    }
    
    func performTextFieldCorrection(_ text: String) {
        guard let textField, let uiRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument) else { return }
        let correctedText = text.reduceToCharacterLimit(characterLimit).cleanupPeriods().trimLeadingZeroes().trimDecimalDigitsToTwo()
        textField.replace(uiRange, withText: correctedText)
    }
    
    func buttonReleased(_ sender: Any) {
        // no-op
    }
}

extension UIViewController {
    func yPositionWithinScreen() -> CGFloat {
        return UIScreen.main.bounds.height - view.frame.height
    }
}
