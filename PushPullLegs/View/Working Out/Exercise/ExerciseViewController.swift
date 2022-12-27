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

class ExerciseViewController: DatabaseTableViewController, ExerciseSetViewModelDelegate, ExercisingViewController, UIAdaptivePresentationControllerDelegate, SetNavigationControllerDelegate {

    weak var weightCollector: WeightCollectionViewController?
    weak var exerciseTimer: ExerciseTimerViewController?
    weak var repsCollector: RepsCollectionViewController?
    var exerciseSetViewModel: ExerciseSetViewModel?
    var readOnly = false
    weak var restTimerView: RestTimerView?
    private let timerHeight: CGFloat = 150.0
    weak var setNavController: SetNavigationController?
    private var isLeftBarItemSetToDone = false
    private var exerciseViewModel: ExerciseViewModel? { viewModel as? ExerciseViewModel }
    private var isTimerViewHidden = true
    private var restTimerHeightConstraint: NSLayoutConstraint?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !readOnly {
            if ((viewModel?.hasData()) != nil) {
                hideNoDataView()
            }
        }
        tableView?.allowsSelection = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupRestTimerView()
    }
    
    override func getRightBarButtonItems() -> [UIBarButtonItem] {
        guard let exerciseViewModel else { return [] }
        return readOnly && exerciseViewModel.hasData() ? super.getRightBarButtonItems() : exercisingRightBarButtonItems()
    }
    
    private func exercisingRightBarButtonItems() -> [UIBarButtonItem] {
        var items = [UIBarButtonItem]()
        guard let exerciseViewModel else { return items }
        if exerciseViewModel.hasData() {
            items.append(UIBarButtonItem(barButtonSystemItem: isEditing ? .done : .edit, target: self, action: #selector(edit(_:))))
        }
        if exerciseViewModel.previousExercise != nil {
            items.append(UIBarButtonItem(title: "Previous", style: .plain, target: self, action: #selector(presentPreviousPerformance(_:))))
        }
        return items
    }
    
    @objc func presentPreviousPerformance(_ sender: Any?) {
        guard
            let exerciseViewModel,
            let previousExercise = exerciseViewModel.previousExercise,
            let tableView,
            let headerView = self.tableView(tableView, viewForHeaderInSection: 0)
        else { return }
        presentModally(PreviousPerformanceViewController(exercise: previousExercise, headerView: headerView))
    }
    
    func setupRestTimerView() {
        guard let tableView = tableView else { return }
        addRestTimerView()
        constrainRestTimerView(tableView)
        setRestTimerHeightConstraint()
    }
    
    private func addRestTimerView() {
        let rtv = RestTimerView()
        view.addSubview(rtv)
        restTimerView = rtv
    }
    
    private func constrainRestTimerView( _ tableView: PPLTableView) {
        restTimerView?.translatesAutoresizingMaskIntoConstraints = false
        restTimerView?.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        restTimerView?.topAnchor.constraint(equalTo: tableView.bottomAnchor).isActive = true
        restTimerView?.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        restTimerView?.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    private func setRestTimerHeightConstraint() {
        restTimerHeightConstraint = restTimerView?.heightAnchor.constraint(equalToConstant: 0)
        restTimerHeightConstraint?.identifier = "rest timer height"
        restTimerHeightConstraint?.isActive = true
    }
    
    private func showRestTimerView() {
        updateRestTimerViewTableViewConstraints(40)
    }

    private func backNavigationBarButtonItem() -> UIBarButtonItem.SystemItem {
        if viewModel?.rowCount(section: 1) == 0 {
            return .cancel
        }
        isLeftBarItemSetToDone = true
        return .done
    }
    
    override func addAction(_ sender: Any) {
        super.addAction(sender)
        prepareExerciseSetViewModel()
        let wc = WeightCollectionViewController()
        let setNavController = SetNavigationController(rootViewController: wc)
        wc.exerciseSetViewModel = exerciseSetViewModel
        presentModally(setNavController)
        self.setNavController = setNavController
        setNavController.setDelegate = self
        weightCollector = wc
        if let _ = restTimerView {
            hideRestTimerView()
        }
    }
    
    private func hideRestTimerView() {
        updateRestTimerViewTableViewConstraints(0)
    }
    
    private func updateRestTimerViewTableViewConstraints(_ constant: CGFloat) {
        guard
            let bottom = view.constraints.first(where: { $0.identifier == "bottom" }),
            let restTimerHeightConstraint = restTimerHeightConstraint
        else { return }
        bottom.constant = -constant
        restTimerHeightConstraint.constant = constant
    }
    
    private func prepareExerciseSetViewModel() {
        exerciseSetViewModel = ExerciseSetViewModel()
        exerciseSetViewModel?.delegate = self
        exerciseSetViewModel?.setCollector = exerciseViewModel
        exerciseSetViewModel?.defaultWeight = exerciseViewModel?.defaultWeight
    }
    
    func navigationController(_ navigationController: SetNavigationController, willPop viewController: UIViewController) {
        if viewController.isEqual(exerciseTimer) {
            try? exerciseSetViewModel?.revertState()
        } else if viewController.isEqual(repsCollector) {
            try? exerciseSetViewModel?.revertState()
            exerciseSetViewModel?.restartSet()
        }
    }
    
    func exerciseSetViewModelWillStartSet(_ viewModel: ExerciseSetViewModel) {
        let et = ExerciseTimerViewController()
        et.exerciseSetViewModel = self.exerciseSetViewModel
        setNavController?.pushViewController(et, animated: true)
        exerciseTimer = et
    }
    
    func exerciseSetViewModelStoppedTimer(_ viewModel: ExerciseSetViewModel) {
        let rc = RepsCollectionViewController()
        rc.exerciseSetViewModel = self.exerciseSetViewModel
        setNavController?.pushViewController(rc, animated: true)
        repsCollector = rc
    }
    
    func exerciseSetViewModelFinishedSet(_ viewModel: ExerciseSetViewModel) {
        dismiss(animated: true, completion: {
            self.reload()
            if let rtv = self.restTimerView {
                self.showRestTimerView()
                rtv.restartTimer()
            }
        })
        if let exerciseViewModel, exerciseViewModel.hasData() {
            AppState.shared.exerciseInProgress = !readOnly ? exerciseViewModel.title() : nil
            presentProgressNotification()
        }
    }
    
    func presentProgressNotification() {
        guard let exerciseViewModel, exerciseViewModel.isFirstTimePerformingExercise() && !readOnly else { return }
        let content = UNMutableNotificationContent()
        content.title = exerciseViewModel.progressTitle()
        content.body = exerciseViewModel.progressMessage()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print(error)
            }
        }
    }
    
    func exerciseSetViewModelCanceledSet(_ viewModel: ExerciseSetViewModel) {
        dismiss(animated: true) {
            if let _ = self.restTimerView, let exerciseViewModel = self.exerciseViewModel, exerciseViewModel.hasData(), !exerciseViewModel.isFirstSet {
                self.showRestTimerView()
            }
        }
        resetState()
    }
    
    func presentModally(_ vc: UIViewController) {
        vc.modalPresentationStyle = .formSheet
        present(vc, animated: true, completion: nil)
        vc.presentationController?.delegate = self
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        if let _ = presentationController.presentedViewController as? SetNavigationController, let exerciseSetViewModel {
            if exerciseSetViewModel.completedExerciseSet {

            } else {
                exerciseSetViewModel.cancel()
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
        guard let exerciseViewModel else { return nil }
        var titles = [String]()
        for i in 0...2 {
            titles.append(exerciseViewModel.headerLabelText(i))
        }
        let view = tableHeaderViewContainer(titles: titles, section: section)
        return view
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: PPLTableViewCellIdentifier) as? PPLTableViewCell,
            let exerciseViewModel
        else { return PPLTableViewCell() }
        let labels = cell.labels(width: tableView.frame.width / 3)
        labels.w.text = "\(exerciseViewModel.weightForIndexPath(indexPath))"
        labels.r.text = "\(exerciseViewModel.repsForIndexPath(indexPath))"
        labels.t.text = exerciseViewModel.durationForIndexPath(indexPath)
        return cell
    }
    
}

extension ExerciseViewController: ArrowHelperDataSource {
    func arrowCenterX() -> CGFloat {
        view.frame.width - 15 - addButtonSize.width/2
    }
}

protocol SetNavigationControllerDelegate {
    func navigationController(_ navigationController: SetNavigationController, willPop viewController: UIViewController)
}

class SetNavigationController: UINavigationController {
    var setDelegate: SetNavigationControllerDelegate?
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        navigationBar.backgroundColor = PPLColor.secondary
        navigationBar.barTintColor = PPLColor.secondary
        navigationBar.tintColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func popViewController(animated: Bool) -> UIViewController? {
        if let topViewController = topViewController {
            setDelegate?.navigationController(self, willPop: topViewController)
        }
        return super.popViewController(animated: animated)
    }
}

extension PPLTableViewCell {
    
    fileprivate var weightLabelTag: Int {123}
    fileprivate var durationLabelTag: Int {234}
    fileprivate var repsLabelTag: Int {345}
    
    func labels(width: CGFloat) -> (w: PPLNameLabel, r: PPLNameLabel, t: PPLNameLabel) {
        guard
            let weight = contentView.viewWithTag(weightLabelTag) as? PPLNameLabel,
            let reps = contentView.viewWithTag(repsLabelTag) as? PPLNameLabel,
            let time = contentView.viewWithTag(durationLabelTag) as? PPLNameLabel
        else { return insertLabels() }
        return (weight, reps, time)
    }
    
    fileprivate func insertLabels() -> (w: PPLNameLabel, r: PPLNameLabel, t: PPLNameLabel) {
        let weightLabel =  PPLNameLabel()
        weightLabel.tag = weightLabelTag
        let repsLabel = PPLNameLabel()
        repsLabel.tag = repsLabelTag
        let timeLabel = PPLNameLabel()
        timeLabel.tag = durationLabelTag
        guard let rootView else { return (weightLabel, repsLabel, timeLabel) }
        for lbl in [weightLabel, repsLabel, timeLabel] {
            lbl.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
            lbl.textColor = PPLColor.text
            lbl.textAlignment = .center
            rootView.addSubview(lbl)
            lbl.translatesAutoresizingMaskIntoConstraints = false
            lbl.topAnchor.constraint(equalTo: rootView.topAnchor).isActive = true
            lbl.bottomAnchor.constraint(equalTo: rootView.bottomAnchor).isActive = true
            lbl.widthAnchor.constraint(equalTo: rootView.widthAnchor, multiplier: 1/3).isActive = true
        }
        weightLabel.leadingAnchor.constraint(equalTo: rootView.leadingAnchor).isActive = true
        repsLabel.leadingAnchor.constraint(equalTo: weightLabel.trailingAnchor).isActive = true
        timeLabel.leadingAnchor.constraint(equalTo: repsLabel.trailingAnchor).isActive = true
        return (weightLabel, repsLabel, timeLabel)
    }
}
