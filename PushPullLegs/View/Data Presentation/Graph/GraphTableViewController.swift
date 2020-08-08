//
//  GraphTableViewViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 8/7/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit
import GoogleMobileAds

class GraphTableViewController: UIViewController, TypeSelectorDelegate {
    
    weak var tableView: UITableView!
    var pushVc: GraphViewController!
    var pullVc: GraphViewController!
    var legsVc: GraphViewController!
    private var exerciseType: ExerciseType?
    private var interstitial: GADInterstitial?
    private var didNavigateToWorkout: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        let tbv = UITableView(frame: view.frame)
        tbv.isScrollEnabled = false
        view.addSubview(tbv)
        tbv.dataSource = self
        tbv.delegate = self
        tbv.rowHeight = view.frame.height / 4.25
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: tbv.rowHeight)
        pushVc = GraphViewController(type: .push, frame: frame)
        pullVc = GraphViewController(type: .pull, frame: frame)
        legsVc = GraphViewController(type: .legs, frame: frame)
        pushVc.isInteractive = false
        pullVc.isInteractive = false
        legsVc.isInteractive = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if AppState.shared.isAdEnabled {
            if interstitial == nil || interstitial!.hasBeenUsed {
                interstitial = createAndLoadInterstitial()
            }
            if let interstitial = interstitial,
                interstitial.isReady && didNavigateToWorkout {
                interstitial.present(fromRootViewController: self)
            }
            didNavigateToWorkout = false
        }
        if AppState.shared.workoutInProgress {
            self.navigateToNextWorkout()
        }
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
      let interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
      interstitial.load(GADRequest())
      return interstitial
    }
    
    func startWorkout() {
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
        present(typeVC, animated: true, completion: nil)
    }
    
    func navigateToNextWorkout() {
        didNavigateToWorkout = true
        let vc = WorkoutViewController()
        vc.viewModel = WorkoutEditViewModel(withType: exerciseType)
        AppState.shared.workoutInProgress = true
        vc.hidesBottomBarWhenPushed = true
        navigationController!.pushViewController(vc, animated: true)
    }
    
    func select(type: ExerciseType) {
        exerciseType = type
        navigateToNextWorkout()
        exerciseType = nil
    }

}

extension GraphTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.contentView.addSubview(viewForRow(indexPath.row))
        return cell
    }
    
    func viewForRow(_ row: Int) -> UIView {
        switch row {
        case 0:
            return pushVc.view
        case 1:
            return pullVc.view
        case 2:
            return legsVc.view
        default:
            let lbl = UILabel()
            lbl.text = "Start next workout"
            lbl.sizeToFit()
            return lbl
        }
    }
}

extension GraphTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        startWorkout()
    }
}

class GraphTableViewCell: UITableViewCell {
    
    
}
