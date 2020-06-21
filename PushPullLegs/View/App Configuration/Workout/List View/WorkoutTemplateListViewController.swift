//
//  AddWorkoutViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 3/19/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

let workoutTitleCellReuseIdentifier = "WorkoutTitleCell"

class WorkoutTemplateListViewController: PPLTableViewController {
    
    var firstLoad = true
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        viewModel = WorkoutTemplateListViewModel(withTemplateManagement: TemplateManagement())
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: workoutTitleCellReuseIdentifier)
    }
    
    private func workoutTemplateListViewModel() -> WorkoutTemplateListViewModel {
        return viewModel as! WorkoutTemplateListViewModel
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: workoutTitleCellReuseIdentifier)
        cell.textLabel?.text = viewModel.title(indexPath: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.frame = CGRect.update(height: tableView.frame.height / 3.0, rect: cell.frame)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !tableView.isEditing else {
            return
        }
        workoutTemplateListViewModel().select(indexPath)
        performSegue(withIdentifier: SegueIdentifier.editWorkout, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height / 3.0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifier.editWorkout, let vc = segue.destination as? WorkoutTemplateEditViewController {
            vc.viewModel = WorkoutTemplateEditViewModel(withType: workoutTemplateListViewModel().selectedType(), templateManagement: TemplateManagement())
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
}

extension CGRect {
    static func update(height: CGFloat , rect: CGRect) -> CGRect {
        return CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.size.width, height: height)
    }
}
