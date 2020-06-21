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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if AppState.shared.workoutInProgress {
            self.navigateToNextWorkout()
        }
    }
    
    @IBAction func startWorkout(_ sender: Any) {
        if PPLDefaults.instance.workoutTypePromptSwitchValue() {
            presentTypeSelector()
        } else {
            navigateToNextWorkout()
        }
    }
    
    func presentTypeSelector() {
        let typeVC = TypeSelectorViewController()
        typeVC.delegate = self
        typeVC.modalPresentationStyle = .pageSheet
        typeVC.isModalInPresentation = true
        present(typeVC, animated: true, completion: nil)
    }
    
    func navigateToNextWorkout() {
        performSegue(withIdentifier: SegueIdentifier.startWorkout, sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TypeSelectorViewController {
            vc.delegate = self
            vc.isModalInPresentation = true
        } else if segue.identifier == SegueIdentifier.startWorkout, let vc = segue.destination as? WorkoutViewController {
            vc.viewModel = WorkoutEditViewModel(withType: exerciseType)
            AppState.shared.workoutInProgress = true
            vc.hidesBottomBarWhenPushed = true
        }
    }
    
    func select(type: ExerciseType) {
        exerciseType = type
        performSegue(withIdentifier: SegueIdentifier.startWorkout, sender: self)
        exerciseType = nil
    }

}
