//
//  ExerciseInProgressViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/23/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

class ExerciseTimerViewController: UIViewController, ExerciseSetTimerDelegate, ExercisingViewController {

    var exerciseSetViewModel: ExerciseSetViewModel?
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var finishButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        finishButton.setTitle("Finish Set", for: .normal)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        exerciseSetViewModel?.timerDelegate = nil
    }
    
    @IBAction func finishWorkout(_ sender: Any) {
        exerciseSetViewModel?.stopTimer()
    }
    
    func timerUpdate(_ text: String) {
        DispatchQueue.main.async { [weak self] in
            self!.timerLabel.text = text
        }
    }
    
}
