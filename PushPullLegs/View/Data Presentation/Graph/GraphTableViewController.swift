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
        view.backgroundColor = PPLColor.grey
        let tbv = UITableView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - (tabBarController?.tabBar.frame.height ?? 0)))
        tbv.backgroundColor = PPLColor.grey
        tbv.isScrollEnabled = false
        view.addSubview(tbv)
        tbv.dataSource = self
        tbv.delegate = self
        tbv.rowHeight = tbv.frame.height / 4.25
        let frame = CGRect(x: 8, y: 8, width: view.frame.width - 16, height: tbv.rowHeight - 16)
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
        let view = viewForRow(indexPath.row)
        cell.contentView.addSubview(view)
        cell.contentView.backgroundColor = PPLColor.grey
        if view.isKind(of: UILabel.self) {
            constrain(view, toInsideOf: cell.contentView)
        } else {
            addControlToCell(cell, indexPath.row)
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func viewForRow(_ row: Int) -> UIView {
        var view: UIView
        switch row {
        case 0:
            view = pushVc.view
        case 1:
            view = pullVc.view
        case 2:
            view = legsVc.view
        default:
            view = startNextWorkoutLabel()
        }
        return view
    }
    
    private func startNextWorkoutLabel() -> UILabel {
        let lbl = UILabel()
        lbl.text = "Start next workout"
        lbl.font = UIFont.systemFont(ofSize: 26, weight: .black)
        lbl.textAlignment = .center
        lbl.backgroundColor = PPLColor.lightGrey
        return lbl
    }
    
    func addControlToCell(_ cell: UITableViewCell, _ row: Int) {
        let control = UIControl()
        control.tag = row
        cell.addSubview(control)
        constrain(control, toInsideOf: cell)
        control.addTarget(self, action: #selector(showGraph(_:)), for: .touchUpInside)
    }
    
    @objc private func showGraph(_ control: UIControl) {
        guard let nav = navigationController else { return }
        let vc = GraphViewController(type: typeForRow(control.tag))
        vc.isInteractive = true
        vc.hidesBottomBarWhenPushed = true
        nav.show(vc, sender: self)
    }
    
    func typeForRow(_ row: Int) -> ExerciseType {
        switch row {
        case 0:
            return .push
        case 1:
            return .pull
        default:
            return .legs
        }
    }
    
}

extension GraphTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 3 {
            startWorkout()
        }
    }
}

extension UIViewController {
    func constrain(_ subview: UIView, toInsideOf superview: UIView, insets: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top).isActive = true
        subview.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -insets.bottom).isActive = true
        subview.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: insets.left).isActive = true
        subview.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -insets.right).isActive = true
    }
}

class GraphTableViewCell: UITableViewCell {
    
    
}
