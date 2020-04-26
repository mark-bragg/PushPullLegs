//
//  QuantityCollectionViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/23/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

class QuantityCollectionViewController: UIViewController, UITextFieldDelegate, KeyboardObserver {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var button: UIButton!
    
    private var performingTextCorrection = false
    var characterLimit = 0
    
    init() {
        super.init(nibName: "QuantityCollectionViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        KeyboardObserving.instance.addKeyboardObserver(self)
        button.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        KeyboardObserving.instance.removeKeyboardObserver(self)
    }
    
    @IBAction func editingChanged(_ sender: Any) {
        guard let text = textField.text, !text.isEmpty else {
            button.isEnabled = false
            return
        }
        if !performingTextCorrection {
            performingTextCorrection = true
            performTextFieldCorrection(text)
        }
        performingTextCorrection = false
        button.isEnabled = true
    }
    
    func performTextFieldCorrection(_ text: String) {
        guard let uiRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument) else { return }
        let correctedText = text.reduceToCharacterLimit(characterLimit).cleanupPeriods().trimLeadingZeroes().trimDecimalDigitsToTwo()
        textField.replace(uiRange, withText: correctedText)
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
    }
    
    func keyboardHeight(_ height: CGFloat) {
        if let heightConstraint = stackView.constraints.first(where: { $0.identifier == "height" }) {
            heightConstraint.constant = view.frame.height - yPositionWithinScreen() - height
        }
    }
}

extension UIViewController {
    func yPositionWithinScreen() -> CGFloat {
        return UIScreen.main.bounds.height - view.frame.height
    }
}
