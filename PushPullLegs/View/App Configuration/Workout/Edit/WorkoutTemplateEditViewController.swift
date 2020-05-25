//
//  WorkoutEditViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/7/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

let exerciseCellReuseIdentifier = "ExerciseCell"

class WorkoutTemplateEditViewController: PPLTableViewController, ReloadProtocol {

    @IBOutlet weak var tableView: UITableView!
    var currentSegueId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: exerciseCellReuseIdentifier)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? ExerciseTemplateCreationViewController,
            let id = segue.identifier else {
            print("ERROR")
            return
        }
        currentSegueId = id
        let vm = ExerciseTemplateCreationViewModel(withType: workoutTemplateEditViewModel().type(), management: workoutTemplateEditViewModel().templateManagement)
        vm.reloader = self
        vc.viewModel = vm
    }
    
    private func workoutTemplateEditViewModel() -> WorkoutTemplateEditViewModel {
        return viewModel as! WorkoutTemplateEditViewModel
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let text = workoutTemplateEditViewModel().title(indexPath: indexPath)
        let cell = UITableViewCell(style: .default, reuseIdentifier: exerciseCellReuseIdentifier)
        cell.textLabel?.text = text
        cell.textLabel?.textAlignment = .left
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.setSelected(false, animated: true)
            if indexPath.section == 0 {
                if workoutTemplateEditViewModel().sectionCount() == 2 { workoutTemplateEditViewModel().selected(indexPath: indexPath) } else {
                    workoutTemplateEditViewModel().selected(indexPath: indexPath)
                }
            } else {
                workoutTemplateEditViewModel().selected(indexPath: indexPath)
            }
            reload()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let title = workoutTemplateEditViewModel().titleForSection(section) else { return nil }
        return tableHeaderView(titles: [title])
    }
    
    func reload() {
        workoutTemplateEditViewModel().reload()
        tableView.reloadData()
    }
    
}
