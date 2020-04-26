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
        label.text = "Enter Weight"
        button.setTitle("Begin Set", for: .normal)
        textField.keyboardType = .decimalPad
        characterLimit = 7
    }
    
    override func buttonTapped(_ sender: Any) {
        if let t = textField.text, let weight = Double(t) {
            exerciseSetViewModel?.startSetWithWeight(weight)
        }
    }
    
}
