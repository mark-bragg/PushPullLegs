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

class ExerciseViewController: DatabaseTableViewController, ExerciseSetViewModelDelegate, ExercisingViewController, SetNavigationControllerDelegate {

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
    private var superSetExerciseViewModel: ExerciseViewModel?
    private var isTimerViewHidden = true
    private var restTimerHeightConstraint: NSLayoutConstraint?
    var dropSetViewModel: ExerciseDropSetViewModel?
    var headerViewHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addHeaderView()
    }
    
    private func addHeaderView() {
        guard let exerciseViewModel else { return }
        let header = normalSetHeaderView(exerciseViewModel, -1)
        headerViewHeight = header.frame.height
        view.addSubview(header)
        header.translatesAutoresizingMaskIntoConstraints = false
        header.heightAnchor.constraint(equalToConstant: headerViewHeight).isActive = true
        header.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        header.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !readOnly {
            if let viewModel, viewModel.hasData() {
                hideNoDataView()
            }
        }
        tableView?.allowsSelection = true
    }
    
    override func constrainTableView() {
        let guide = view.safeAreaLayoutGuide
        guard let tableView = tableView else { return }
        tableView.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
        setTableViewY(bannerContainerHeight() + headerViewHeight)
        let bottom = tableView.bottomAnchor.constraint(equalTo: guide.bottomAnchor)
        bottom.identifier = "bottom"
        bottom.isActive = true
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
        items.append(addButtonItem())
        if exerciseViewModel.hasData() {
            items.append(editItem())
        }
        if exerciseViewModel.previousExercise != nil {
            items.append(previousItem())
        }
        return items
    }
    
    private func editItem() -> UIBarButtonItem {
        let item = UIBarButtonItem(barButtonSystemItem: isEditing ? .done : .edit, target: self, action: #selector(edit))
        item.accessibilityIdentifier = .edit
        return item
    }
    
    private func previousItem() -> UIBarButtonItem {
        let item = UIBarButtonItem(title: "Previous", style: .plain, target: self, action: #selector(presentPreviousPerformance))
        item.accessibilityIdentifier = item.title
        return item
    }
    
    @objc func presentPreviousPerformance() {
        guard
            let exerciseViewModel,
            let previousExercise = exerciseViewModel.previousExercise
        else { return }
        presentModally(PreviousPerformanceViewController(exercise: previousExercise, headerView: normalSetHeaderView(exerciseViewModel, -1)))
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
    
    override func addAction() {
        super.addAction()
        prepareExerciseSetViewModel()
        let wc = WeightCollectionViewController()
        wc.superSetDelegate = self
        wc.dropSetDelegate = self
        wc.thereAreOtherExercises = exerciseViewModel?.canSuperSet ?? false
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
        et.exerciseSetViewModel = exerciseSetViewModel
        setNavController?.pushViewController(et, animated: true)
        exerciseTimer = et
    }
    
    func exerciseSetViewModelStoppedTimer(_ viewModel: ExerciseSetViewModel) {
        let rc = RepsCollectionViewController()
        rc.exerciseSetViewModel = exerciseSetViewModel
        setNavController?.pushViewController(rc, animated: true)
        repsCollector = rc
    }
    
    func exerciseSetViewModelFinishedSet(_ viewModel: ExerciseSetViewModel?) {
        dismiss(animated: true, completion: {
            if self.superSetIsInProgress() {
                self.startSuperSetSecondSet()
            } else if let rtv = self.restTimerView {
                self.showRestTimerView()
                rtv.restartTimer()
                if let evm = self.exerciseViewModel, evm.hasData() {
                    AppState.shared.exerciseInProgress = !self.readOnly ? evm.title() : nil
                    self.presentProgressNotification()
                }
                self.reload()
            }
        })
    }
    
    func superSetIsInProgress() -> Bool {
        guard let exerciseViewModel else { return false }
        return exerciseViewModel.isPerformingSuperSet
    }
    
    func startSuperSetSecondSet() {
        prepareExerciseSetViewModel()
        prepareSuperSetExerciseSetViewModel()
        let wc = SuperSetWeightCollectionViewController()
        if let secondName = exerciseViewModel?.superSetSecondExerciseName {
            wc.navItemTitle = "Weight for \(secondName)"
        }
        wc.superSetDelegate = self
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
    
    private func prepareSuperSetExerciseSetViewModel() {
        exerciseSetViewModel = ExerciseSetViewModel()
        exerciseSetViewModel?.delegate = self
        exerciseSetViewModel?.superSetCollector = exerciseViewModel
        guard let exName = exerciseViewModel?.superSetSecondExerciseName,
              let template = TemplateManagement().exerciseTemplate(name: exName)
        else { return }
        exerciseSetViewModel?.defaultWeight = ExerciseViewModel(exerciseTemplate: template).defaultWeight
    }
    
    private func prepareExerciseSetViewModel() {
        exerciseSetViewModel = ExerciseSetViewModel()
        exerciseSetViewModel?.delegate = self
        exerciseSetViewModel?.setCollector = exerciseViewModel
        exerciseSetViewModel?.defaultWeight = exerciseViewModel?.defaultWeight
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
    
    // MARK: - UIAdaptivePresentationControllerDelegate
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        viewModel?.sectionCount?() ?? 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let exerciseViewModel,
              section != 0,
              exerciseViewModel.rowCount(section: section) > 0
        else { return nil }
        return section == 1 ? dropSetHeaderView(exerciseViewModel) : superSetHeaderView(exerciseViewModel)
    }
    
    private func normalSetHeaderView(_ exerciseViewModel: ExerciseViewModel, _ section: Int) -> UIView {
        var titles = [String]()
        for i in 0...2 {
            titles.append(exerciseViewModel.headerLabelText(i))
        }
        let view = tableHeaderViewContainer(titles: titles, section: section)
        return view
    }
    
    private func dropSetHeaderView(_ exerciseViewModel: ExerciseViewModel) -> UIView {
        tableHeaderViewContainer(titles: ["Drop Sets"], section: 1)
    }
    
    private func superSetHeaderView(_ exerciseViewModel: ExerciseViewModel) -> UIView {
        tableHeaderViewContainer(titles: ["Super Sets"], section: 2)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCellIdentifier),
            let exerciseViewModel
        else { return UITableViewCell() }
        cell.selectionStyle = indexPath.section == 2 ? .default : .none
        cell.accessoryType = indexPath.section == 2 ? .disclosureIndicator : .none
        let labels = cell.labels(width: tableView.frame.width / 3)
        labels.w.text = "\(exerciseViewModel.weightForIndexPath(indexPath))"
        labels.r.text = "\(exerciseViewModel.repsForIndexPath(indexPath))"
        labels.t.text = exerciseViewModel.durationForIndexPath(indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 2 else { return }
        presentSuperSet(indexPath.row)
    }
    
    private func presentSuperSet(_ index: Int) {
        guard let superSet = exerciseViewModel?.superSet(at: index)
        else { return }
        let ssvm = SuperSetDataViewModel(superSet: superSet)
        let ssvc = SuperSetDataViewController()
        ssvc.viewModel = ssvm
        navigationController?.pushViewController(ssvc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == -1 {
            return 20
        }
        guard section != 0,
             (exerciseViewModel?.rowCount(section: section) ?? 0) > 0
        else { return 0 }
        return super.tableView(tableView, heightForHeaderInSection: section)
    }
}

class SuperSetDataViewModel: NSObject, PPLTableViewModel {
    private let superSet: SuperSet
    lazy var sets: (ExerciseSet, ExerciseSet)? = {
        superSet.exerciseSets()
    }()
    
    init(superSet: SuperSet) {
        self.superSet = superSet
    }
    
    func sectionCount() -> Int {
        2
    }
    
    func rowCount(section: Int) -> Int {
        1
    }
    
    func title(indexPath: IndexPath) -> String? {
        indexPath.section == 0 ?
        sets?.0.exercise?.name :
        sets?.1.exercise?.name
    }
    
    func title() -> String? {
        "Super Set"
    }
}

class SuperSetDataViewController: PPLTableViewController {
    private var superSetViewModel: SuperSetDataViewModel? { viewModel as? SuperSetDataViewModel }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        viewModel?.title(indexPath: IndexPath(row: 0, section: section))
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: defaultCellIdentifier),
              let set = indexPath.section == 0 ? superSetViewModel?.sets?.0 : superSetViewModel?.sets?.1
        else { return UITableViewCell() }
        let data = FinishedSetDataModel(withExerciseSet: set)
        let labels = cell.labels(width: tableView.frame.width)
        labels.r.text = "\(data.reps)"
        labels.t.text = String.format(seconds: data.duration)
        labels.w.text = "\(data.weight)"
        return cell
    }
}

extension ExerciseViewController: SuperSetDelegate {
    func superSetSelected() {
        guard let exerciseName = exerciseViewModel?.exerciseName,
              let typeName = exerciseViewModel?.type,
              let type = ExerciseTypeName(rawValue: typeName)
        else { return }
        let esvm = SuperSetExerciseSelectionViewModel(withType: type, templateManagement: TemplateManagement(), minus: exerciseName)
        let ssvc = SuperSetViewController()
        ssvc.viewModel = esvm
        ssvc.superSetDelegate = self
        ssvc.isModalInPresentation = true
        weightCollector?.present(ssvc, animated: true)
    }
    
    func secondExerciseSelected(_ name: String) {
        exerciseViewModel?.prepareForSuperSet(name)
        weightCollector?.superSetIsReady = true
        weightCollector?.exerciseSetViewModel?.superSetCollector = exerciseViewModel
        weightCollector?.dismiss(animated: true)
    }
}

extension ExerciseViewController: DropSetDelegate {
    var dropSetCount: Int {
        get { 0 }
        set { presentDropSetWeightCollection(newValue) }
    }
    
    func presentDropSetWeightCollection(_ setCount: Int) {
        guard setCount > 0 else {
            presentMoreThanOneSetNeededForDropSetsAlert()
            return
        }
        dismiss(animated: true) {
            let dswc = DropSetWeightCollectionViewController()
            dswc.dropSetCount = setCount + 1
            dswc.dropSetDelegate = self
            self.presentModally(dswc)
        }
    }
    
    func presentMoreThanOneSetNeededForDropSetsAlert() {
        let alert = UIAlertController(title: "You can't have zero drop sets", message: "That would just be a regular set.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        presentedViewController?.present(alert, animated: true)
    }
    
    func dropSetSelected() {
        let dscc = DropSetCountViewController()
        dscc.dropSetDelegate = self
        dismiss(animated: true) {
            self.presentModally(dscc)
        }
    }
    
    func dropSetsStarted(with weights: [Double]) {
        let dropSetModel = DropSetModel()
        dropSetModel.weightsPerSet = weights
        startNextDropSet(dropSetModel)
    }
    
    func collectDropSet(duration: Int) {
        dropSetViewModel?.dropSetModel.durationsPerSet.append(duration)
        let rcvc = RepsCollectionViewController()
        rcvc.exerciseSetViewModel = dropSetViewModel
        dismiss(animated: true) {
            self.presentModally(rcvc)
        }
    }
    
    func dropSetCompleted(with reps: Double) {
        guard let dropSetModel = dropSetViewModel?.dropSetModel else { return }
        dropSetModel.repsPerSet.append(reps)
        guard dropSetModel.isComplete else {
            return startNextDropSet(dropSetModel)
        }
        collectDropSetData(dropSetModel)
    }
    
    func startNextDropSet(_ dropSetModel: DropSetModel) {
        let timer = ExerciseTimerViewController()
        dropSetViewModel = ExerciseDropSetViewModel(dropSetModel: dropSetModel)
        dropSetViewModel?.dropSetDelegate = self
        timer.exerciseSetViewModel = dropSetViewModel
        dismiss(animated: true) {
            self.presentModally(timer)
        }
    }
    
    func collectDropSetData(_ dropSetModel: DropSetModel) {
        var sets = [(Int, Double, Double)]()
        for i in 0..<dropSetModel.weightsPerSet.count {
            sets.append((dropSetModel.durationsPerSet[i], dropSetModel.weightsPerSet[i], dropSetModel.repsPerSet[i]))
        }
        exerciseViewModel?.collectDropSets(sets)
        dismiss(animated: true)
        reload()
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

extension UITableViewCell {
    
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
        for lbl in [weightLabel, repsLabel, timeLabel] {
            lbl.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
            lbl.textColor = PPLColor.text
            lbl.textAlignment = .center
            contentView.addSubview(lbl)
            lbl.translatesAutoresizingMaskIntoConstraints = false
            lbl.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            lbl.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            lbl.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1/3).isActive = true
        }
        weightLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        repsLabel.leadingAnchor.constraint(equalTo: weightLabel.trailingAnchor).isActive = true
        timeLabel.leadingAnchor.constraint(equalTo: repsLabel.trailingAnchor).isActive = true
        return (weightLabel, repsLabel, timeLabel)
    }
}
