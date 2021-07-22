//
//  WeightCollectionViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/26/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

class WeightCollectionViewController: QuantityCollectionViewController, ExercisingViewController {

    var exerciseSetViewModel: ExerciseSetViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Weight"
        label.text = PPLDefaults.instance.isKilograms() ? "Kilograms" : "Pounds"
        button.setTitle(exerciseSetViewModel?.weightCollectionButtonText(), for: .normal)
        textField.keyboardType = .decimalPad
        characterLimit = 7
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let text = textField.text, text != ""  {
            button.enable()
        } else if let defaultWeight = exerciseSetViewModel?.defaultWeight {
            textField.text = "\(defaultWeight)".trimTrailingZeroes()
            button.enable()
        }
        
    }
    
    override func buttonReleased(_ sender: Any) {
        if let t = textField.text, let weight = Double(t) {
            super.buttonReleased(sender)
            let converter = PPLDefaults.instance.isKilograms() ? 2.20462 : 1.0
            exerciseSetViewModel?.willStartSetWithWeight(weight * converter)
        }
    }
    
}
