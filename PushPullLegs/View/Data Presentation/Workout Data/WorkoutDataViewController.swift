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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dbViewModel.refresh()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let vm = viewModel else { return 0 }
        return vm.rowCount(section: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PPLTableViewCellIdentifier) as! PPLTableViewCell
        if let vm = workoutDataViewModel() {
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
        guard let vm = workoutDataViewModel() else { return }
        vm.selectedIndex = indexPath
        let exerciseVm = ExerciseViewModel(exercise: vm.getSelected() as! Exercise)
        exerciseVm.deletionObserver = vm
        let vc = ExerciseViewController()
        vc.readOnly = true
        vc.viewModel = exerciseVm
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func workoutDataViewModel() -> WorkoutDataViewModel? {
        return viewModel as? WorkoutDataViewModel
    }

}
