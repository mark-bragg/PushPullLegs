//
//  ExerciseListViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/15/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

class ExerciseTemplateListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ReloadProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    private let viewModel = ExerciseTemplateListViewModel(withTemplateManagement: TemplateManagement())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: exerciseCellReuseIdentifier)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifier.createTemplateExercise.rawValue,
            let vc = segue.destination as? ExerciseTemplateCreationViewController {
            vc.showExerciseType = true
            vc.viewModel = ExerciseTemplateCreationViewModel(management: viewModel.templateManagement)
            vc.viewModel?.reloader = self
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableHeaderView(titles: [viewModel.titleForSection(section)])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.rowCount(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: exerciseCellReuseIdentifier)
        cell.textLabel?.text = viewModel.title(indexPath: indexPath)
        cell.textLabel?.textAlignment = .center
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.deleteExercise(indexPath: indexPath)
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
        viewModel.reload()
        tableView.reloadData()
    }
    
}
