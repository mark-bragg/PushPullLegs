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
        navigationItem.title = "Rep Count"
        label.text = "Enter Number of Reps"
        button.setTitle("Save Set", for: .normal)
        textField.keyboardType = .numberPad
        characterLimit = 3
    }
    
    override func buttonReleased(_ sender: Any) {
        if let t = textField.text, let reps = Int(t) {
            super.buttonReleased(sender)
            exerciseSetViewModel?.finishSetWithReps(reps)
        }
    }

}
