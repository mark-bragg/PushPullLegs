//
//  TypeSelectorViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/6/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

protocol TypeSelectorDelegate {
    func select(type: ExerciseType)
}

class TypeSelectorViewController: UIViewController {

    @IBOutlet weak var pushButton: ExerciseTypeButton!
    @IBOutlet weak var pullButton: ExerciseTypeButton!
    @IBOutlet weak var legsButton: ExerciseTypeButton!
    var delegate: TypeSelectorDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = PPLColor.grey
        for (btn, type) in [(pushButton, ExerciseType.push), (pullButton, ExerciseType.pull), (legsButton, ExerciseType.legs)] {
            btn?.titleLabel?.text = type.rawValue
            btn?.exerciseType = type
        }
    }
    
    @IBAction func typeSelected(_ sender: ExerciseTypeButton) {
        sender.selection()
        dismissWithType(sender.exerciseType)
    }
    
    func dismissWithType(_ type: ExerciseType) {
        dismiss(animated: true, completion: { self.delegate?.select(type: type) })
    }
}
