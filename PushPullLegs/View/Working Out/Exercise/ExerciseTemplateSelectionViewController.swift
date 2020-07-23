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
    
    override func pop() {
        super.pop()
        exerciseSelectionViewModel().commitChanges()
        delegate?.exerciseTemplatesAdded()
    }
    
    @IBAction func done(_ sender: Any) {
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: PPLTableViewCellIdentifier) as! PPLTableViewCell
        cell.rootView.removeAllSubviews()
        let label = UILabel(frame: cell.rootView.bounds)
        label.text = exerciseSelectionViewModel().title(indexPath: indexPath)
        cell.rootView.addSubview(label)
        label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        label.textAlignment = .center
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        if let cell = tableView.cellForRow(at: indexPath) {
            if exerciseSelectionViewModel().isSelected(row: indexPath.row) {
                exerciseSelectionViewModel().deselected(row: indexPath.row)
                cell.setHighlighted(false, animated: true)
            } else {
                exerciseSelectionViewModel().selected(row: indexPath.row)
                cell.setHighlighted(true, animated: true)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        0
    }

}
