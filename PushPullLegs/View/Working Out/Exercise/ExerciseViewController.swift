//
//  ExercisingViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/18/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

let ExerciseSetReuseIdentifier = "ExerciseSetReuseIdentifier"

protocol ExercisingViewController: UIViewController {
    var exerciseSetViewModel: ExerciseSetViewModel? { get set }
}

class ExerciseViewController: PPLTableViewController, ExerciseSetViewModelDelegate, ExercisingViewController, UIAdaptivePresentationControllerDelegate, SetNavigationControllerDelegate {

    weak var weightCollector: WeightCollectionViewController!
    weak var exerciseTimer: ExerciseTimerViewController!
    weak var repsCollector: RepsCollectionViewController!
    var exerciseSetViewModel: ExerciseSetViewModel?
    var readOnly = false
    weak var restTimerView: RestTimerView!
    private let timerHeight: CGFloat = 150.0
    weak var setNavController: SetNavigationController!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !readOnly && addButton == nil {
            setupAddButton()
        }
        tableView.allowsSelection = false
    }
    
    override func pop() {
        if readOnly || exerciseViewModel().rowCount(section: 0) == 0 {
            super.pop()
            AppState.shared.exerciseInProgress = nil
        } else {
            presentExerciseCompletionConfirmation()
        }
    }
    
    override func insertAddButtonInstructions() {
        super.insertAddButtonInstructions()
        addButtonHelperVc!.message = "Tap to start the next set!"
    }
    
    func exerciseViewModel() -> ExerciseViewModel {
        return viewModel as! ExerciseViewModel
    }
    
    override func addAction(_ sender: Any) {
        super.addAction(sender)
        exerciseSetViewModel = ExerciseSetViewModel()
        exerciseSetViewModel?.delegate = self
        exerciseSetViewModel?.setCollector = exerciseViewModel()
        let wc = WeightCollectionViewController()
        let setNavController = SetNavigationController(rootViewController: wc)
        wc.exerciseSetViewModel = exerciseSetViewModel
        presentModally(setNavController)
        self.setNavController = setNavController
        setNavController.setDelegate = self
        weightCollector = wc
        if let v = restTimerView {
            v.isHidden = true
        }
        removeAddButtonInstructions()
    }
    
    func presentExerciseCompletionConfirmation() {
        let alert = UIAlertController(title: "Exercise Completed?", message: "A completed exercise cannot be edited", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { (action) in
            self.navigationController?.popViewController(animated: true)
            AppState.shared.exerciseInProgress = nil
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Default action"), style: .cancel))
        present(alert, animated: true, completion: nil)
    }
    
    func navigationController(_ navigationController: SetNavigationController, willPop viewController: UIViewController) {
        if viewController.isEqual(exerciseTimer) {
            try? exerciseSetViewModel?.revertState()
        } else if viewController.isEqual(repsCollector) {
            try? exerciseSetViewModel?.revertState()
            exerciseSetViewModel?.restartSet()
        }
    }
    
    func exerciseSetViewModelStartedSet(_ viewModel: ExerciseSetViewModel) {
        let et = ExerciseTimerViewController()
        et.exerciseSetViewModel = self.exerciseSetViewModel
        et.exerciseSetViewModel?.timerDelegate = et
        self.setNavController.pushViewController(et, animated: true)
        self.exerciseTimer = et
    }
    
    func exerciseSetViewModelStoppedTimer(_ viewModel: ExerciseSetViewModel) {
        let rc = RepsCollectionViewController()
        rc.exerciseSetViewModel = self.exerciseSetViewModel
        self.setNavController.pushViewController(rc, animated: true)
        self.repsCollector = rc
    }
    
    func exerciseSetViewModelFinishedSet(_ viewModel: ExerciseSetViewModel) {
        dismiss(animated: true, completion: { self.reload() })
        setupRestTimerView()
        if exerciseViewModel().rowCount() > 0 {
            AppState.shared.exerciseInProgress = !readOnly ? exerciseViewModel().title() : nil
        }
    }
    
    func exerciseSetViewModelCanceledSet(_ viewModel: ExerciseSetViewModel) {
        dismiss(animated: true, completion: nil)
        resetState()
        if exerciseViewModel().rowCount() == 0 {
            insertAddButtonInstructions()
        }
        if let v = restTimerView, v.isHidden {
            v.isHidden = false
        }
    }
    
    func setupRestTimerView() {
        if let v = restTimerView {
            v.removeFromSuperview()
        }
        var yOffset: CGFloat = 15
        if (AppState.shared.isAdEnabled) {
            yOffset += bannerView.frame.size.height
            positionBannerView(yOffset: 0)
        }
        let timerView = RestTimerView(frame: CGRect(x: 15, y: view.frame.height - timerHeight - yOffset, width: timerHeight, height: timerHeight))
        view.addSubview(timerView)
        restTimerView = timerView
        restTimerView.restartTimer()
    }
    
    func presentModally(_ vc: UIViewController) {
        vc.modalPresentationStyle = .formSheet
        present(vc, animated: true, completion: nil)
        vc.presentationController?.delegate = self
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        if let _ = presentationController.presentedViewController as? SetNavigationController {
            if exerciseSetViewModel!.completedExerciseSet {

            } else {
                exerciseSetViewModel?.cancel()
            }
        }
        reload()
    }
    
    func resetState() {
        exerciseSetViewModel = nil
    }
    
    override func reload() {
        super.reload()
        hideNoDataView()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var titles = [String]()
        for i in 0...2 {
            titles.append(exerciseViewModel().headerLabelText(i))
        }
        let view = tableHeaderView(titles: titles)
        return view
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PPLTableViewCellIdentifier) as! PPLTableViewCell
        let labels = cell.labels(width: tableView.frame.width / 3)
        labels.w.text = "\(exerciseViewModel().weightForRow(indexPath.row))"
        labels.r.text = "\(exerciseViewModel().repsForRow(indexPath.row))"
        labels.t.text = exerciseViewModel().durationForRow(indexPath.row)
        return cell
    }
    
}

protocol SetNavigationControllerDelegate {
    func navigationController(_ navigationController: SetNavigationController, willPop viewController: UIViewController)
}

class SetNavigationController: UINavigationController {
    var setDelegate: SetNavigationControllerDelegate?
    override func popViewController(animated: Bool) -> UIViewController? {
        setDelegate?.navigationController(self, willPop: topViewController!)
        return super.popViewController(animated: animated)
    }
}

extension PPLTableViewCell {
    
    fileprivate static let WEIGHT_LABEL_TAG = 123
    fileprivate static let DURATION_LABEL_TAG = 234
    fileprivate static let REPS_LABEL_TAG = 345
    
    fileprivate func labels(width: CGFloat) -> (w: PPLNameLabel, r: PPLNameLabel, t: PPLNameLabel) {
        guard
            let weight = contentView.viewWithTag(PPLTableViewCell.WEIGHT_LABEL_TAG) as? PPLNameLabel,
            let reps = contentView.viewWithTag(PPLTableViewCell.REPS_LABEL_TAG) as? PPLNameLabel,
            let time = contentView.viewWithTag(PPLTableViewCell.DURATION_LABEL_TAG) as? PPLNameLabel
        else { return insertLabels(width) }
        return (weight, reps, time)
    }
    
    fileprivate func insertLabels(_ width: CGFloat) -> (w: PPLNameLabel, r: PPLNameLabel, t: PPLNameLabel) {
        let weightLabel =  PPLNameLabel(frame: CGRect(x: 0, y: 0, width: width, height: rootView.frame.height))
        weightLabel.tag = PPLTableViewCell.WEIGHT_LABEL_TAG
        let repsLabel = PPLNameLabel(frame: CGRect(x: width, y: 0, width: width, height: rootView.frame.height))
        repsLabel.tag = PPLTableViewCell.REPS_LABEL_TAG
        let timeLabel = PPLNameLabel(frame: CGRect(x: width * 2, y: 0, width: width, height: rootView.frame.height))
        timeLabel.tag = PPLTableViewCell.DURATION_LABEL_TAG
        for lbl in [weightLabel, repsLabel, timeLabel] {
            lbl.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
            lbl.textAlignment = .center
            rootView.addSubview(lbl)
        }
        return (weightLabel, repsLabel, timeLabel)
    }
}

extension UILabel {
    static func headerLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        return label
    }
}
