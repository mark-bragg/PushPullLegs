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
    var selectedIndices = [Int]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: exerciseCellReuseIdentifier)
        tableView.allowsMultipleSelection = true
        navigationItem.title = "Select Exercises"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(pop))
    }
    
    private func exerciseSelectionViewModel() -> ExerciseSelectionViewModel {
        viewModel as! ExerciseSelectionViewModel
    }
    
    @objc override func pop() {
        super.pop()
        exerciseSelectionViewModel().commitChanges()
        delegate?.exerciseTemplatesAdded()
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
        cell.autoDeselect = false
        var textLabel = cell.rootView.subviews.first(where: { $0.isKind(of: PPLNameLabel.self) }) as? PPLNameLabel
        if textLabel == nil {
            textLabel = PPLNameLabel()
            textLabel?.textAlignment = .center
            cell.rootView.addSubview(textLabel!)
            textLabel?.translatesAutoresizingMaskIntoConstraints = false
            textLabel?.trailingAnchor.constraint(equalTo: cell.rootView.trailingAnchor, constant: 10).isActive = true
            textLabel?.leadingAnchor.constraint(equalTo: cell.rootView.leadingAnchor, constant: -10).isActive = true
            textLabel?.centerYAnchor.constraint(equalTo: cell.rootView.centerYAnchor, constant: 0).isActive = true
        }
        textLabel!.text = exerciseSelectionViewModel().title(indexPath: indexPath)
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        super.tableHeaderView(titles: ["Select Exercises To Add"])
    }

}
