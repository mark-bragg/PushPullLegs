//
//  StartWorkoutViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/18/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

class StartWorkoutViewController: UIViewController, TypeSelectorDelegate {

    private var exerciseType: ExerciseType?
    
    @IBAction func startWorkout(_ sender: Any) {
        if PPLDefaults.instance.workoutTypePromptSwitchValue() {
            let typeVC = TypeSelectorViewController()
            typeVC.delegate = self
            typeVC.modalPresentationStyle = .pageSheet
            typeVC.isModalInPresentation = true
            present(typeVC, animated: true, completion: nil)
        } else {
            performSegue(withIdentifier: SegueIdentifier.startWorkout.rawValue, sender: self)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TypeSelectorViewController {
            vc.delegate = self
            vc.isModalInPresentation = true
        } else if segue.identifier == SegueIdentifier.startWorkout.rawValue, let vc = segue.destination as? WorkoutViewController {
            vc.viewModel = WorkoutEditViewModel(withType: exerciseType)
            vc.hidesBottomBarWhenPushed = true
        }
    }
    
    func select(type: ExerciseType) {
        exerciseType = type
        performSegue(withIdentifier: SegueIdentifier.startWorkout.rawValue, sender: self)
        exerciseType = nil
    }

}
