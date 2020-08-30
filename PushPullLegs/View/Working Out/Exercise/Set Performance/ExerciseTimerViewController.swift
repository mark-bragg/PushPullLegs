//
//  ExerciseInProgressViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/23/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit
import Combine

class ExerciseTimerViewController: UIViewController, ExerciseSetTimerDelegate, ExercisingViewController {

    var exerciseSetViewModel: ExerciseSetViewModel?
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var finishButton: PPLButton!
    var cancellables = [AnyCancellable]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        finishButton.setTitle("Finish Set", for: .normal)
        finishButton.isEnabled = PPLDefaults.instance.countdown() == 0
        timerLabel.layer.borderColor = PPLColor.lightGrey!.cgColor
        timerLabel.layer.backgroundColor = PPLColor.darkGrey!.cgColor
        timerLabel.layer.borderWidth = 1.5
        timerLabel.layer.cornerRadius = timerLabel.frame.height / 12
        timerLabel.text = exerciseSetViewModel?.initialTimerText()
        exerciseSetViewModel?.$setBegan.sink(receiveValue: { [weak self] (exerciseBegan) in
            guard exerciseBegan, let self = self else { return }
            DispatchQueue.main.async {
                self.finishButton.isEnabled = exerciseBegan
            }
        }).store(in: &cancellables)
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
