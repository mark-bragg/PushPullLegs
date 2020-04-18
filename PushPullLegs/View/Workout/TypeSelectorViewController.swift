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

    @IBOutlet weak var pushButton: UIButton!
    @IBOutlet weak var pullButton: UIButton!
    @IBOutlet weak var legsButton: UIButton!
    var delegate: TypeSelectorDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pushButton.titleLabel?.text = ExerciseType.push.rawValue
        pullButton.titleLabel?.text = ExerciseType.pull.rawValue
        legsButton.titleLabel?.text = ExerciseType.legs.rawValue
    }
    
    @IBAction func selectPushType(_ sender: Any) {
        dismissWithType(ExerciseType.push)
    }
    
    @IBAction func selectPullType(_ sender: Any) {
        dismissWithType(ExerciseType.pull)
    }
    
    @IBAction func selectLegsType(_ sender: Any) {
        dismissWithType(ExerciseType.legs)
    }
    
    func dismissWithType(_ type: ExerciseType) {
        dismiss(animated: true, completion: { self.delegate?.select(type: type) })
    }
}
