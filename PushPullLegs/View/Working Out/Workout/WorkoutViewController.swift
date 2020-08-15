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

    private var exerciseSelectionViewModel: ExerciseSelectionViewModel!
    private let section1 = 0
    private let section2 = 1
    
    func workoutEditViewModel() -> WorkoutEditViewModel {
        return viewModel as! WorkoutEditViewModel
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        workoutEditViewModel().delegate = self
        navigationItem.title = workoutEditViewModel().exerciseType.rawValue
        exerciseSelectionViewModel = ExerciseSelectionViewModel(withType: workoutEditViewModel().exerciseType, templateManagement: TemplateManagement())
        tableView.register(UINib(nibName: "ExerciseDataCell", bundle: nil), forCellReuseIdentifier: ExerciseDataCellReuseIdentifier)
        if let exerciseInProgressName = AppState.shared.exerciseInProgress {
            for i in 0..<workoutEditViewModel().rowCount(section: section2) {
                let indexPath = IndexPath(row: i, section: section2)
                if workoutEditViewModel().title(indexPath: indexPath) == exerciseInProgressName {
                    workoutEditViewModel().selectedIndex = indexPath
                }
            }
            navigateToExercise()
        }
        setupAddButton()
        reload()
    }
    
    override func addAction(_ sender: Any) {
        super.addAction(sender)
        if exerciseSelectionViewModel.rowCount(section: 0) > 0 {
            let vc = ExerciseTemplateSelectionViewController()
            vc.viewModel = exerciseSelectionViewModel
            vc.delegate = workoutEditViewModel()
            navigationController?.pushViewController(vc, animated: true)
        } else {
            if let vc = UIStoryboard(name: StoryboardFileName.appConfiguration, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifier.createExerciseViewController) as? ExerciseTemplateCreationViewController {
                vc.showExerciseType = false
                vc.viewModel = ExerciseTemplateCreationViewModel(withType: workoutEditViewModel().exerciseType, management: TemplateManagement())
                vc.viewModel?.reloader = self
                vc.modalPresentationStyle = .pageSheet
                present(vc, animated: true, completion: nil)
            }
        }
    }
    
    override func pop() {
        if viewModel.rowCount(section: 1) > 0 {
            presentFinishWorkoutPrompt()
        } else {
            cancel(self)
        }
    }
    
    func presentFinishWorkoutPrompt() {
        guard viewModel.rowCount(section: 1) > 0 else {
            workoutEditViewModel().deleteWorkout()
            navigationController?.popViewController(animated: true)
            return
        }
        let alert = UIAlertController.init(title: "Workout Complete?", message: "Once you save a workout, you cannot edit it later.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (action) in
            self.workoutEditViewModel().finishWorkout()
            self.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
            self.cancel(self)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func cancel(_ sender: Any) {
        self.workoutEditViewModel().deleteWorkout()
        self.navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PPLTableViewCellIdentifier) as! PPLTableViewCell
        let title = viewModel.title(indexPath: indexPath)
        cell.rootView.removeAllSubviews()
        if indexPath.section == 1 {
            let vc = ExerciseDataCellViewController()
            vc.exerciseName = title
            vc.workText = "Total work: \(workoutEditViewModel().detailText(indexPath: indexPath)!)"
            vc.preferredContentSize = cell.rootView.bounds.size
            cell.rootView.addSubview(vc.view)
            cell.setSelected(true, animated: false)
        } else {
            let label = PPLNameLabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            cell.rootView.addSubview(label)
            label.centerXAnchor.constraint(equalTo: cell.rootView.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: cell.rootView.centerYAnchor).isActive = true
            label.text = title
        }
        cell.addDisclosureIndicator()
        return cell
    }
    
    func dequeuCell(section: Int) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: section == 0 ? ExerciseToDoCellReuseIdentifier : ExerciseDataCellReuseIdentifier)!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        workoutEditViewModel().selectedIndex = indexPath
        navigateToExercise()
    }
    
    func navigateToExercise() {
        let vc = ExerciseViewController()
        if let exerciseTemplate = workoutEditViewModel().getSelected() as? ExerciseTemplate {
            let vm = ExerciseViewModel(exerciseTemplate: exerciseTemplate)
            vc.viewModel = vm
            vm.reloader = vc
            vm.delegate = workoutEditViewModel()
        } else if let exercise = workoutEditViewModel().getSelected() as? Exercise {
            let vm = ExerciseViewModel(exercise: exercise)
            vc.viewModel = vm
            vm.reloader = vc
            vc.readOnly = AppState.shared.exerciseInProgress == nil
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableHeaderView(titles: [section == 0 ? "TODO" : "DONE"])
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return workoutEditViewModel().rowCount(section: section) > 0 ? super.tableView(tableView, heightForHeaderInSection: section) : 0
    }
}

extension WorkoutViewController: WorkoutEditViewModelDelegate {
    func workoutEditViewModelCompletedFirstExercise(_ model: WorkoutEditViewModel) {
        // no-op
    }
}

extension WorkoutViewController: ReloadProtocol {
    func reload() {
        workoutEditViewModel().exerciseTemplatesAdded()
        tableView.reloadData()
    }
}

extension UIView {
    func removeAllSubviews() {
        for v in subviews {
            v.removeFromSuperview()
        }
    }
}
