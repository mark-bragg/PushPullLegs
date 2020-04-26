//
//  RepsCollectionViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/25/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

class RepsCollectionViewController: QuantityCollectionViewController, ExercisingViewController {
    
    var exerciseSetViewModel: ExerciseSetViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = "Enter Number of Reps"
        button.setTitle("Save Set", for: .normal)
        textField.keyboardType = .numberPad
        characterLimit = 3
    }
    
    override func buttonTapped(_ sender: Any) {
        if let t = textField.text, let reps = Int(t) {
            exerciseSetViewModel?.finishSetWithReps(reps)
        }
    }

}
