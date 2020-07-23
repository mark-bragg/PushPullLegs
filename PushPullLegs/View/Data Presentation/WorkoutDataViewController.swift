//
//  WorkoutDataViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 5/13/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

let ExerciseDataCellReuseIdentifier = "ExerciseDataCellReuseIdentifier"

class WorkoutDataViewController: PPLTableViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.navigationBar.backgroundColor = PPLColor.Grey
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let vm = viewModel else { return 0 }
        return vm.rowCount(section: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PPLTableViewCellIdentifier) as! PPLTableViewCell
        if let vm = workoutReadViewModel() {
            let vc = ExerciseDataCellViewController()
            vc.preferredContentSize = cell.rootView.bounds.size
            vc.exerciseName = vm.title(indexPath: indexPath)
            vc.workText = "Total Work: \(vm.detailText(indexPath: indexPath)!)"
            vc.progress = vm.exerciseVolumeComparison(row: indexPath.row)
            cell.rootView.addSubview(vc.view)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        tableHeaderView(titles: ["Exercises"])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        guard let vm = workoutReadViewModel() else { return }
        vm.selectedIndex = indexPath
        let exerciseVm = ExerciseViewModel(exercise: vm.getSelected() as! Exercise)
        let vc = ExerciseViewController()
        vc.readOnly = true
        vc.viewModel = exerciseVm
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func workoutReadViewModel() -> WorkoutReadViewModel? {
        return viewModel as? WorkoutReadViewModel
    }

}
