//
//  ExerciseListViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/15/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

class ExerciseTemplateListViewController: PPLTableViewController, ReloadProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = ExerciseTemplateListViewModel(withTemplateManagement: TemplateManagement())
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: exerciseCellReuseIdentifier)
    }
    
    private func exerciseTemplateListViewModel() -> ExerciseTemplateListViewModel {
        return viewModel as! ExerciseTemplateListViewModel
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifier.createTemplateExercise,
            let vc = segue.destination as? ExerciseTemplateCreationViewController {
            vc.showExerciseType = true
            vc.viewModel = ExerciseTemplateCreationViewModel(management: exerciseTemplateListViewModel().templateManagement)
            vc.viewModel?.reloader = self
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let title = exerciseTemplateListViewModel().titleForSection(section) else {
            return nil
        }
        return tableHeaderView(titles: [title])
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: exerciseCellReuseIdentifier)
        cell.textLabel?.text = viewModel.title(indexPath: indexPath)
        cell.textLabel?.textAlignment = .center
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            exerciseTemplateListViewModel().deleteExercise(indexPath: indexPath)
            reload()
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func reload() {
        exerciseTemplateListViewModel().reload()
        tableView.reloadData()
    }
    
}
