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
        tbv.register(UINib(nibName: "PPLTableViewCell", bundle: nil), forCellReuseIdentifier: PPLTableViewCellIdentifier)
        tbv.backgroundColor = PPLColor.grey
        tbv.isScrollEnabled = false
        view.addSubview(tbv)
        tbv.dataSource = self
        tbv.delegate = self
        tbv.rowHeight = tbv.frame.height / 4.25
        tableView = tbv
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
        pushVc.view.setNeedsLayout()
        pullVc.view.setNeedsLayout()
        legsVc.view.setNeedsLayout()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: PPLTableViewCellIdentifier) as! PPLTableViewCell
        if indexPath.row == 3 {
            addStartNextWorkoutLabel(rootView: cell.rootView)
        } else {
            cell.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.rowHeight)
            let view = viewForRow(indexPath.row)
            cell.rootView.addSubview(view)
            addControlToCell(cell, indexPath.row)
        }
        cell.addDisclosureIndicator()
        return cell
    }
    
    func viewForRow(_ row: Int) -> UIView {
        var view: UIView
        switch row {
        case 0:
            view = pushVc.view
        case 1:
            view = pullVc.view
        default:
            view = legsVc.view
        }
        return view
    }
    
    private func addStartNextWorkoutLabel(rootView: UIView) {
        let lbl = UILabel()
        lbl.text = "Start next workout"
        lbl.font = UIFont.systemFont(ofSize: 26, weight: .black)
        lbl.textAlignment = .center
        lbl.textColor = PPLColor.textBlue
        lbl.backgroundColor = .clear
        rootView.addSubview(lbl)
        constrain(lbl, toInsideOf: rootView, insets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
    }
    
    func addControlToCell(_ cell: PPLTableViewCell, _ row: Int) {
        guard let control = cell.subviews.first(where: { $0.isKind(of: UIControl.self) }) as? UIControl else { return }
        control.tag = row
        constrain(control, toInsideOf: cell)
        control.addTarget(self, action: #selector(showGraph(_:)), for: .touchUpInside)
    }
    
    @objc private func showGraph(_ row: Int) {
        guard let nav = navigationController else { return }
        let vc = GraphViewController(type: typeForRow(row))
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
        } else {
            showGraph(indexPath.row)
        }
    }
}

extension UIViewController {
    func constrain(_ subview: UIView, toInsideOf superview: UIView, insets: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 20
        , right: 8)) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top).isActive = true
        subview.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -insets.bottom).isActive = true
        subview.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: insets.left).isActive = true
        subview.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -insets.right).isActive = true
    }
}
