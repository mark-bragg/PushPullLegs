//
//  WorkoutDataViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 5/13/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

let ExerciseDataCellReuseIdentifier = "ExerciseDataCellReuseIdentifier"

class WorkoutDataViewController: DatabaseTableViewController {
    
    var exerciseSelectionViewModel: ExerciseSelectionViewModel?
    var workoutDataViewModel: WorkoutDataViewModel? { viewModel as? WorkoutDataViewModel }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dbViewModel.refresh()
    }
    
    override func getRightBarButtonItems() -> [UIBarButtonItem] {
        var items = super.getRightBarButtonItems()
        items.append(UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(presentNoteViewController)))
        return items
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let vm = viewModel else { return 0 }
        return vm.rowCount(section: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PPLTableViewCellIdentifier) as! PPLTableViewCell
        if let vm = workoutDataViewModel {
            cell.rootView.removeAllSubviews()
            let vc = ExerciseDataCellViewController()
            vc.preferredContentSize = cell.rootView.bounds.size
            vc.exerciseName = vm.title(indexPath: indexPath)
            vc.workText = "Total Work: \(vm.detailText(indexPath: indexPath)!)"
            vc.progress = vm.exerciseVolumeComparison(row: indexPath.row)
            cell.rootView.addSubview(vc.view)
            if !tableView.isEditing {
                cell.addDisclosureIndicator()
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        tableHeaderViewContainer(titles: ["Exercises"])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vm = workoutDataViewModel else { return }
        vm.selectedIndex = indexPath
        guard let vc = ExerciseViewControllerFactory.getExerciseViewController(vm.getSelected()) else { return }
        (vc.viewModel as! ExerciseViewModel).deletionObserver = vm
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func addAction(_ sender: Any) {
        super.addAction(sender)
        guard let vm = self.workoutDataViewModel else { return }
        let esvm = ExerciseSelectionViewModel(withType: vm.exerciseType, templateManagement: TemplateManagement(), dataSource: workoutDataViewModel)
        exerciseSelectionViewModel = esvm
        if esvm.rowCount(section: 0) > 0 {
            let vc = ExerciseTemplateSelectionViewController()
            esvm.dataSource = workoutDataViewModel
            vc.viewModel = esvm
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = ExerciseTemplateCreationViewController()
            vc.showExerciseType = false
            vc.viewModel = ExerciseTemplateCreationViewModel(withType: vm.exerciseType, management: TemplateManagement())
            vc.viewModel?.reloader = self
            vc.modalPresentationStyle = .pageSheet
            present(vc, animated: true, completion: nil)
        }
    }
    
    override func bannerAdUnitID() -> String {
        BannerAdUnitID.workoutDataVC
    }
    
    override func saveNote(_ text: String) {
        super.saveNote(text)
        guard let vm = workoutDataViewModel else { return }
        vm.updateNote(text)
    }
    
    override func noteText() -> String {
        return workoutDataViewModel?.noteText() ?? ""
    }
    
}

extension WorkoutDataViewController: ExerciseTemplateSelectionDelegate {
    func exerciseTemplatesAdded() {
        guard let esvm = exerciseSelectionViewModel else { return }
        let selectedNames = esvm.selectedExercises().compactMap({ $0.name! })
        addNewExercises(selectedNames)
        reload()
    }
    
    fileprivate func addNewExercises(_ names: [String]) {
        guard let vm = workoutDataViewModel else { return }
        vm.addObjectsWithNames(names)
    }
}
