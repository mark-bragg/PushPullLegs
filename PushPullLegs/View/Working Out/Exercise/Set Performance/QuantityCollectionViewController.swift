//
//  QuantityCollectionViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/23/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

class QuantityCollectionViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var button: PPLButton!
    
    private var performingTextCorrection = false
    var characterLimit = 0
    
    init() {
        super.init(nibName: "QuantityCollectionViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.delegate = self
        button.disable()
        view.backgroundColor = .backgroundBlue
        textField.becomeFirstResponder()
        label.textColor = .cellBackgroundBlue
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func editingChanged(_ sender: Any) {
        guard let text = textField.text, !text.isEmpty else {
            button.disable()
            return
        }
        if !performingTextCorrection {
            performingTextCorrection = true
            performTextFieldCorrection(text)
        }
        performingTextCorrection = false
        guard let textFinal = textField.text, !textFinal.isEmpty else {
            button.disable()
            return
        }
        button.enable()
    }
    
    func performTextFieldCorrection(_ text: String) {
        guard let uiRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument) else { return }
        let correctedText = text.reduceToCharacterLimit(characterLimit).cleanupPeriods().trimLeadingZeroes().trimDecimalDigitsToTwo()
        textField.replace(uiRange, withText: correctedText)
    }
    
    @IBAction func buttonReleased(_ sender: Any) {
        // no-op
    }
}

extension UIViewController {
    func yPositionWithinScreen() -> CGFloat {
        return UIScreen.main.bounds.height - view.frame.height
    }
}
