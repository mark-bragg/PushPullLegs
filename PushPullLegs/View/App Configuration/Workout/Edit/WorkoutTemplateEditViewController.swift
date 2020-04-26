//
//  WorkoutEditViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/7/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

let exerciseCellReuseIdentifier = "ExerciseCell"

class WorkoutTemplateEditViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ReloadProtocol {

    @IBOutlet weak var tableView: UITableView!
    var viewModel: WorkoutTemplateEditViewModel!
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
        let vm = ExerciseTemplateCreationViewModel(withType: viewModel.type(), management: viewModel.templateManagement)
        vm.reloader = self
        vc.viewModel = vm
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.rowCount(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let text = viewModel.title(indexPath: indexPath)
        let cell = UITableViewCell(style: .default, reuseIdentifier: exerciseCellReuseIdentifier)
        cell.textLabel?.text = text
        cell.textLabel?.textAlignment = .left
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.setSelected(false, animated: true)
            if indexPath.section == 0 {
                viewModel.unselected(indexPath: indexPath)
            } else {
                viewModel.selected(indexPath: indexPath)
            }
            reload()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.titleForSection(section)
    }
    
    func reload() {
        viewModel.reload()
        tableView.reloadData()
    }
    
}
