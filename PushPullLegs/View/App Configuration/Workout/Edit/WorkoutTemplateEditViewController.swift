//
//  WorkoutEditViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/7/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

let exerciseCellReuseIdentifier = "ExerciseCell"
let AppConfigurationCellReuseIdentifier = "AppConfigurationCellReuseIdentifier"

class WorkoutTemplateEditViewController: PPLTableViewController {

    var currentSegueId: String!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupAddButton()
    }
    
    override func addAction(_ sender: Any) {
        super.addAction(sender)
        let vc = ExerciseTemplateCreationViewController()
        let vm = ExerciseTemplateCreationViewModel(withType: workoutTemplateEditViewModel().type(), management: workoutTemplateEditViewModel().templateManagement)
        vm.reloader = self
        vc.viewModel = vm
        vc.modalPresentationStyle = .pageSheet
        present(vc, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? ExerciseTemplateCreationViewController,
            let id = segue.identifier else {
            print("ERROR")
            return
        }
        currentSegueId = id
        
    }
    
    private func workoutTemplateEditViewModel() -> WorkoutTemplateEditViewModel {
        return viewModel as! WorkoutTemplateEditViewModel
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PPLTableViewCellIdentifier) as! PPLTableViewCell
        label(forCell: cell).text = workoutTemplateEditViewModel().title(indexPath: indexPath)
        cell.setHighlighted(workoutTemplateEditViewModel().isSelected(indexPath), animated: true)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        if indexPath.section == 0 {
            if workoutTemplateEditViewModel().sectionCount() == 2 { workoutTemplateEditViewModel().selected(indexPath: indexPath) } else {
                workoutTemplateEditViewModel().selected(indexPath: indexPath)
            }
        } else {
            workoutTemplateEditViewModel().selected(indexPath: indexPath)
        }
        reload()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let title = workoutTemplateEditViewModel().titleForSection(section) else { return nil }
        return tableHeaderView(titles: [title])
    }
    
    override func reload() {
        workoutTemplateEditViewModel().reload()
        super.reload()
    }
    
}
