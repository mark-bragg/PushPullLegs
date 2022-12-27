//
//  WorkoutViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/18/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

let ExerciseToDoCellReuseIdentifier = "ExerciseToDoCellReuseIdentifier"

class WorkoutViewController: PPLTableViewController {

    private var exerciseSelectionViewModel: ExerciseSelectionViewModel?
    private let section1 = 0
    private let section2 = 1
    @Published private(set) var popped = false
    private var firstLoad = true
    private var workoutEditViewModel: WorkoutEditViewModel? { viewModel as? WorkoutEditViewModel }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let workoutEditViewModel else { return }
        workoutEditViewModel.delegate = self
        if let type = workoutEditViewModel.exerciseType {
            navigationItem.title = workoutEditViewModel.exerciseType?.rawValue
            exerciseSelectionViewModel = ExerciseSelectionViewModel(withType: type, templateManagement: TemplateManagement())
        }
        tableView?.register(UINib(nibName: "ExerciseDataCell", bundle: nil), forCellReuseIdentifier: ExerciseDataCellReuseIdentifier)
        if let exerciseInProgressName = AppState.shared.exerciseInProgress {
            for i in 0..<workoutEditViewModel.rowCount(section: section2) {
                let indexPath = IndexPath(row: i, section: section2)
                if workoutEditViewModel.title(indexPath: indexPath) == exerciseInProgressName {
                    workoutEditViewModel.selectedIndex = indexPath
                }
            }
            navigateToExercise()
        }
        workoutEditViewModel.reload()
        reload()
        navigationItem.setLeftBarButton(UIBarButtonItem(barButtonSystemItem: viewModel?.rowCount(section: 1) == 0 ? .cancel : .done, target: self, action: #selector(pop)), animated: false)
        navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(presentNoteViewController)), animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        firstLoad = false
    }
    
    override func addAction(_ sender: Any) {
        super.addAction(sender)
        if let esvm = exerciseSelectionViewModel, esvm.rowCount(section: 0) > 0 {
            let vc = ExerciseTemplateSelectionViewController()
            vc.viewModel = exerciseSelectionViewModel
            vc.delegate = workoutEditViewModel
            navigationController?.pushViewController(vc, animated: true)
        } else if let type = workoutEditViewModel?.exerciseType {
            let vc = ExerciseTemplateCreationViewController()
            vc.showExerciseType = false
            vc.viewModel = ExerciseTemplateCreationViewModel(withType: type, management: TemplateManagement())
            vc.viewModel?.reloader = self
            vc.modalPresentationStyle = .pageSheet
            present(vc, animated: true, completion: nil)
        }
    }
    
    @objc override func pop() {
        if viewModel?.rowCount(section: 1) == 0 {
            deleteWorkoutAndPop()
        } else {
            presentFinishWorkoutPrompt()
        }
    }
    
    func presentFinishWorkoutPrompt() {
        if viewModel?.rowCount(section: 1) == 0 {
            workoutEditViewModel?.deleteWorkout()
            popFromNavStack()
            return
        }
        let alert = UIAlertController.init(title: "Complete Workout", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] action in
            self?.workoutEditViewModel?.finishWorkout()
            self?.popFromNavStack()
        })
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] action in
            self?.presentDeleteConfirmation()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func presentDeleteConfirmation() {
        let alert = UIAlertController.init(title: "Are you sure?", message: "Once you delete a workout, it is gone forever.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { [weak self] action in
            self?.deleteWorkoutAndPop()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] action in
            self?.presentFinishWorkoutPrompt()
        })
        present(alert, animated: true, completion: nil)
    }
    
    func deleteWorkoutAndPop() {
        workoutEditViewModel?.deleteWorkout()
        popFromNavStack()
    }
    
    fileprivate func popFromNavStack() {
        popped = true
        self.navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: PPLTableViewCellIdentifier) as? PPLTableViewCell,
            let rootView = cell.rootView
        else { return PPLTableViewCell() }
        let title = viewModel?.title(indexPath: indexPath)
        rootView.removeAllSubviews()
        if indexPath.section == 1 {
            let vc = ExerciseDataCellViewController()
            vc.exerciseName = title
            if let work = workoutEditViewModel?.detailText(indexPath: indexPath) {
                vc.workText = "Total work: \(work)"
            }
            vc.preferredContentSize = rootView.bounds.size
            rootView.addSubview(vc.view)
            vc.progress = workoutEditViewModel?.exerciseVolumeComparison(row: indexPath.row)
            cell.setSelected(true, animated: false)
        } else {
            let label = PPLNameLabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            rootView.addSubview(label)
            label.centerXAnchor.constraint(equalTo: rootView.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: rootView.centerYAnchor).isActive = true
            label.text = title
            label.textColor = PPLColor.text
        }
        cell.addDisclosureIndicator()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        workoutEditViewModel?.selectedIndex = indexPath
        navigateToExercise()
    }
    
    func navigateToExercise() {
        guard
            let selected = workoutEditViewModel?.getSelected(),
            let vc = ExerciseViewControllerFactory.getExerciseViewController(selected)
        else { return }
        (vc.viewModel as? ExerciseViewModel)?.delegate = workoutEditViewModel
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        tableHeaderViewContainer(titles: [section == 0 ? "TODO" : "DONE"], section: section)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let workoutEditViewModel else { return 0 }
        return workoutEditViewModel.rowCount(section: section) > 0 ? super.tableView(tableView, heightForHeaderInSection: section) : 0
    }
    
    override func noteText() -> String {
        workoutEditViewModel?.noteText() ?? ""
    }
    
    override func saveNote(_ text: String) {
        super.saveNote(text)
        workoutEditViewModel?.updateNote(text)
    }
}

extension WorkoutViewController: WorkoutEditViewModelDelegate {
    func workoutEditViewModelCompletedFirstExercise(_ model: WorkoutEditViewModel) {
        // no-op
    }
}

extension WorkoutViewController {
    override func reload() {
        workoutEditViewModel?.exerciseTemplatesAdded()
        tableView?.reloadData()
        if !firstLoad {
            super.reload()
        }
    }
}

extension UIView {
    func removeAllSubviews() {
        for v in subviews {
            for c in v.constraints {
                c.isActive = false
            }
            v.removeFromSuperview()
        }
    }
}
