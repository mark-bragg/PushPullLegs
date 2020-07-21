//
//  ExerciseSelectionViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/19/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

protocol ExerciseTemplateSelectionDelegate: NSObject {
    func exerciseTemplatesAdded()
}

class ExerciseTemplateSelectionViewController: PPLTableViewController {
    weak var delegate: ExerciseTemplateSelectionDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: exerciseCellReuseIdentifier)
        navigationItem.title = "Select Exercises"
    }
    
    private func exerciseSelectionViewModel() -> ExerciseSelectionViewModel {
        viewModel as! ExerciseSelectionViewModel
    }
    
    @IBAction func done(_ sender: Any) {
        exerciseSelectionViewModel().commitChanges()
        delegate?.exerciseTemplatesAdded()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func createExerciseTemplate(_ sender: Any) {
        if let vc = UIStoryboard(name: StoryboardFileName.appConfiguration, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifier.createExerciseViewController) as? ExerciseTemplateCreationViewController {
            vc.viewModel = ExerciseTemplateCreationViewModel(withType: exerciseSelectionViewModel().exerciseType, management: TemplateManagement())
            vc.modalPresentationStyle = .formSheet
            present(vc, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: exerciseCellReuseIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: exerciseCellReuseIdentifier)
        }
        cell?.textLabel?.text = exerciseSelectionViewModel().title(indexPath: indexPath)
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.accessoryType == .none {
                exerciseSelectionViewModel().selected(row: indexPath.row)
                cell.accessoryType = .checkmark
            } else {
                exerciseSelectionViewModel().deselected(row: indexPath.row)
                cell.accessoryType = .none
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        0
    }

}
