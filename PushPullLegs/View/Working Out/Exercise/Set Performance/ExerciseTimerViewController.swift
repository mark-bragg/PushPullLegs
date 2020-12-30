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
        navigationItem.title = "Timer"
        finishButton.setTitle("Finish Set", for: .normal)
        finishButton.isEnabled = PPLDefaults.instance.countdown() == 0
        styleTimerLabel()
        addTimerLabelTap()
        timerLabel.text = exerciseSetViewModel?.initialTimerText()
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if timerLabel.text == "0:00" {
            self.showStartText()
        }
    }
    
    fileprivate func styleTimerLabel() {
        timerLabel.layer.borderColor = PPLColor.lightGrey!.cgColor
        timerLabel.layer.backgroundColor = PPLColor.cellBackgroundBlue!.cgColor
        timerLabel.layer.borderWidth = 1.5
        timerLabel.layer.cornerRadius = timerLabel.frame.height / 12
    }
    
    fileprivate func addTimerLabelTap() {
        timerLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(timerTapped)))
        timerLabel.isUserInteractionEnabled = true
    }
    
    @objc fileprivate func timerTapped() {
        timerLabel.isUserInteractionEnabled = false
        exerciseSetViewModel?.cancelCountdown()
    }
    
    func showStartText() {
        let lbl = startLabel()
        let diameter = view.frame.width * 0.75
        view.addSubview(lbl)
        constrainStartLabel(lbl, diameter)
        styleStartLabel(lbl, diameter)
        animateStartLabel(lbl)
    }
    
    fileprivate func startLabel() -> UILabel {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Start!"
        lbl.font = UIFont.systemFont(ofSize: 72, weight: .bold)
        lbl.textColor = .textGreen
        lbl.textAlignment = .center
        return lbl
    }
    
    fileprivate func styleStartLabel(_ lbl: UILabel, _ diameter: CGFloat) {
        let color = UIColor(red: 151/255, green: 251/255, blue: 152/255, alpha: 1.0).cgColor
        lbl.layer.backgroundColor = color
        lbl.layer.cornerRadius = diameter / 2
        lbl.layer.shadowPath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: diameter, height: diameter)).cgPath
        lbl.layer.shadowColor = color
        lbl.layer.shadowOpacity = 1.0
        lbl.layer.shadowRadius = 10
    }
    
    fileprivate func constrainStartLabel(_ lbl: UILabel, _ diameter: CGFloat) {
        lbl.widthAnchor.constraint(equalToConstant: diameter).isActive = true
        lbl.heightAnchor.constraint(equalToConstant: diameter).isActive = true
        lbl.centerYAnchor.constraint(equalTo: finishButton.centerYAnchor).isActive = true
        lbl.centerXAnchor.constraint(equalTo: finishButton.centerXAnchor).isActive = true
    }
    
    fileprivate func animateStartLabel(_ lbl: UILabel) {
        UIView.animate(withDuration: 1.0, delay: 0.5, options: .transitionFlipFromTop, animations: {
            lbl.alpha = 0
        }) { (b) in
            for c in lbl.constraints {
                c.isActive = false
            }
            lbl.removeFromSuperview()
        }
    }
    
    fileprivate func bind() {
        exerciseSetViewModel?.$setBegan.sink(receiveValue: { [weak self] (exerciseBegan) in
            guard let exerciseBegan = exerciseBegan, exerciseBegan, let self = self else { return }
            DispatchQueue.main.async {
                self.finishButton.isEnabled = exerciseBegan
            }
        }).store(in: &cancellables)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    @IBAction func finishWorkout(_ sender: Any) {
        exerciseSetViewModel?.stopTimer()
    }
    
    func timerUpdate(_ text: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let lbl = self.timerLabel else { return }
            lbl.text = text
            if text == "0:00" {
                self.showStartText()
            }
        }
    }
    
}
