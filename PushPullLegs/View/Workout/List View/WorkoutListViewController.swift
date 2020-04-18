//
//  AddWorkoutViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 3/19/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

let workoutTitleCellReuseIdentifier = "WorkoutTitleCell"
let editWorkoutSegue = "EditWorkoutSegue"
let startWorkoutSegue = "StartWorkoutSegue"

class WorkoutListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var viewModel = WorkoutListViewModel(withTemplateManagement: TemplateManagement(backgroundContext: CoreDataManager.shared.backgroundContext))
    var firstLoad = true
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: workoutTitleCellReuseIdentifier)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.rowCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: workoutTitleCellReuseIdentifier)
        cell.textLabel?.text = viewModel.workoutTitleForRow(indexPath.row)
        cell.accessoryType = .disclosureIndicator
        cell.frame = CGRect.update(height: tableView.frame.height / 3.0, rect: cell.frame)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !tableView.isEditing else {
            return
        }
        viewModel.select(indexPath)
        performSegue(withIdentifier: editWorkoutSegue, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height / 3.0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == editWorkoutSegue, let vc = segue.destination as? WorkoutEditViewController {
            vc.viewModel = WorkoutEditViewModel(withType: viewModel.selectedType(), templateManagement: TemplateManagement(backgroundContext: CoreDataManager.shared.backgroundContext))
        }
    }
}

extension CGRect {
    static func update(height: CGFloat , rect: CGRect) -> CGRect {
        return CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.size.width, height: height)
    }
}
