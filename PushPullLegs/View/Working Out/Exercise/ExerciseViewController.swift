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

    weak var weightCollector: WeightCollectionViewController!
    weak var exerciseTimer: ExerciseTimerViewController!
    weak var repsCollector: RepsCollectionViewController!
    var exerciseSetViewModel: ExerciseSetViewModel?
    var readOnly = false
    weak var restTimerView: RestTimerView!
    private let timerHeight: CGFloat = 150.0
    weak var setNavController: SetNavigationController!
    private var isLeftBarItemSetToDone = false
    private var exerciseViewModel: ExerciseViewModel { viewModel as! ExerciseViewModel }
    private var isTimerViewHidden = true
    private var restTimerHeightConstraint: NSLayoutConstraint!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !readOnly && addButton == nil {
            setupAddButton()
            if ((viewModel?.hasData()) != nil) {
                hideNoDataView()
            }
        }
        tableView?.allowsSelection = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupRestTimerView()
        repositionAddButton()
    }
    
    func setupRestTimerView() {
        guard let tableView = tableView else { return }
        
        // add rest timer view
        let rtv = RestTimerView()
        view.addSubview(rtv)
        restTimerView = rtv
        rtv.translatesAutoresizingMaskIntoConstraints = false
        rtv.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        rtv.topAnchor.constraint(equalTo: tableView.bottomAnchor).isActive = true
        rtv.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        rtv.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        restTimerHeightConstraint = rtv.heightAnchor.constraint(equalToConstant: 0)
        restTimerHeightConstraint.identifier = "rest timer height"
        restTimerHeightConstraint.isActive = true
    }
    
    private func showRestTimerView() {
        updateRestTimerViewTableViewConstraints(40)
    }
    
    private func repositionAddButton() {
        addButton.removeConstraints(addButton.constraints)
        positionAddButton()
    }
    
    override func positionAddButton() {
        guard let restTimerView = restTimerView else { return }
        let y: CGFloat = -15
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.widthAnchor.constraint(equalToConstant: addButtonSize.width).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: addButtonSize.height).isActive = true
        addButton.bottomAnchor.constraint(equalTo: restTimerView.topAnchor, constant: y).isActive = true
        addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: y).isActive = true
        view.bringSubviewToFront(addButton)
    }

    private func backNavigationBarButtonItem() -> UIBarButtonItem.SystemItem {
        if viewModel?.rowCount(section: 1) == 0 {
            return .cancel
        }
        isLeftBarItemSetToDone = true
        return .done
    }
    
    override func insertAddButtonInstructions(_ dataSource: ArrowHelperDataSource? = nil) {
        guard !readOnly else { return }
        super.insertAddButtonInstructions(self)
        addButtonHelperVc!.message = "Tap to start the next set!"
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
        removeAddButtonInstructions()
    }
    
    private func hideRestTimerView() {
        updateRestTimerViewTableViewConstraints(0)
    }
    
    private func updateRestTimerViewTableViewConstraints(_ constant: CGFloat) {
        guard
            let bottom = view.constraints.first(where: { $0.identifier == "bottom" })
        else { return }
        bottom.constant = -constant
        restTimerHeightConstraint.constant = constant
        repositionAddButton()
    }
    
    private func prepareExerciseSetViewModel() {
        exerciseSetViewModel = ExerciseSetViewModel()
        exerciseSetViewModel?.delegate = self
        exerciseSetViewModel?.setCollector = exerciseViewModel
        exerciseSetViewModel?.defaultWeight = exerciseViewModel.defaultWeight
    }
    
    override func setupRightBarButtonItems() {
        guard !readOnly else {
            return super.setupRightBarButtonItems()
        }
        
        navigationItem.rightBarButtonItem = exerciseViewModel.hasData() ? UIBarButtonItem(barButtonSystemItem: isEditing ? .done : .edit, target: self, action: #selector(edit(_:))) : nil
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
        dismiss(animated: true, completion: {
            self.reload()
            self.showRestTimerView()
            self.restTimerView.restartTimer()
        })
        if exerciseViewModel.rowCount() > 0 {
            AppState.shared.exerciseInProgress = !readOnly ? exerciseViewModel.title() : nil
            presentProgressNotification()
        }
    }
    
    func presentProgressNotification() {
        guard exerciseViewModel.isFirstTimePerformingExercise() && !readOnly else { return }
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
            if let _ = self.restTimerView {
                self.showRestTimerView()
            }
        }
        resetState()
        if exerciseViewModel.rowCount() == 0 {
            insertAddButtonInstructions()
        }
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
            titles.append(exerciseViewModel.headerLabelText(i))
        }
        let view = tableHeaderViewContainer(titles: titles, section: section)
        return view
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PPLTableViewCellIdentifier) as! PPLTableViewCell
        let labels = cell.labels(width: tableView.frame.width / 3)
        labels.w.text = "\(exerciseViewModel.weightForIndexPath(indexPath))"
        labels.r.text = "\(exerciseViewModel.repsForIndexPath(indexPath))"
        labels.t.text = exerciseViewModel.durationForIndexPath(indexPath)
        return cell
    }
    
    override func bannerAdUnitID() -> String {
        BannerAdUnitID.exerciseVC
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

fileprivate extension PPLTableViewCell {
    
    var weightLabelTag: Int {123}
    var durationLabelTag: Int {234}
    var repsLabelTag: Int {345}
    
    func labels(width: CGFloat) -> (w: PPLNameLabel, r: PPLNameLabel, t: PPLNameLabel) {
        guard
            let weight = contentView.viewWithTag(weightLabelTag) as? PPLNameLabel,
            let reps = contentView.viewWithTag(repsLabelTag) as? PPLNameLabel,
            let time = contentView.viewWithTag(durationLabelTag) as? PPLNameLabel
        else { return insertLabels() }
        return (weight, reps, time)
    }
    
    func insertLabels() -> (w: PPLNameLabel, r: PPLNameLabel, t: PPLNameLabel) {
        let weightLabel =  PPLNameLabel()
        weightLabel.tag = weightLabelTag
        let repsLabel = PPLNameLabel()
        repsLabel.tag = repsLabelTag
        let timeLabel = PPLNameLabel()
        timeLabel.tag = durationLabelTag
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
