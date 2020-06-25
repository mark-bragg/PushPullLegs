//
//  StartWorkoutViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/18/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit
import GoogleMobileAds

class StartWorkoutViewController: UIViewController, TypeSelectorDelegate {

    private var exerciseType: ExerciseType?
    private var interstitial: GADInterstitial?
    private var didNavigateToWorkout: Bool = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if AppState.shared.workoutInProgress {
            self.navigateToNextWorkout()
        }
        if AppState.shared.isAdEnabled {
            if let interstitial = interstitial, interstitial.isReady && didNavigateToWorkout {
                interstitial.present(fromRootViewController: self)
            } else {
                interstitial = createAndLoadInterstitial()
            }
        }
        didNavigateToWorkout = false
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
      let interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
      interstitial.load(GADRequest())
      return interstitial
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
        didNavigateToWorkout = true
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
