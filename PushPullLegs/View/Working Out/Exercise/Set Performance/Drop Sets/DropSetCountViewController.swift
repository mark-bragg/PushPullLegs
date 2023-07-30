//
//  DropSetCountViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 7/22/23.
//  Copyright © 2023 Mark Bragg. All rights reserved.
//

class DropSetCountViewController: QuantityCollectionViewController {
    weak var dropSetDelegate: DropSetDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label?.text = "Number of Extra Drop Sets"
        button?.setTitle("Next", for: .normal)
        characterLimit = 1
        textField?.keyboardType = .asciiCapableNumberPad
        button?.isEnabled = false
    }
    
    override func buttonReleased(_ sender: Any) {
        guard let t = textField?.text,
              let setCount = Int(t)
        else { return }
        super.buttonReleased(sender)
        dropSetDelegate?.dropSetCount = setCount
    }
}
