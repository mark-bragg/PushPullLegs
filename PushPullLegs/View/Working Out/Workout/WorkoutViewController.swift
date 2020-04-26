//
//  WorkoutViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/18/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

class WorkoutViewController: UIViewController, ReloadProtocol {

    @IBOutlet weak var tableView: UITableView!
    var viewModel: WorkoutViewModel!
    private var exerciseSelectionViewModel: ExerciseSelectionViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: exerciseCellReuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        navigationItem.title = viewModel.getExerciseType().rawValue
        exerciseSelectionViewModel = ExerciseSelectionViewModel(withType: viewModel.getExerciseType(), templateManagement: TemplateManagement())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }
    
    @IBAction func addExercise(_ sender: Any) {
        if exerciseSelectionViewModel.rowCount() > 0 {
            performSegue(withIdentifier: AddExerciseOnTheFlySegue, sender: self)
        } else {
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateExerciseViewController") as? ExerciseTemplateCreationViewController {
                vc.showExerciseType = false
                vc.viewModel = ExerciseTemplateCreationViewModel(withType: viewModel.getExerciseType(), management: TemplateManagement())
                vc.viewModel?.reloader = self
                vc.modalPresentationStyle = .pageSheet
                present(vc, animated: true, completion: nil)
            }
        }
    }
    
    
    @IBAction func done(_ sender: Any) {
        viewModel.finishWorkout()
        navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination
        if segue.identifier == NavigateToExerciseDetailSegue, let vc = vc as? ExerciseViewController {
            // TODO: open already performed Exercise instead of creating a new ExerciseTemplate
            if let exerciseTemplate = viewModel.getSelectedExerciseTemplate() {
                let vm = ExerciseViewModel(exerciseTemplate: exerciseTemplate)
                vc.viewModel = vm
                vm.reloader = vc
                vm.delegate = viewModel
            } else if let exercise = viewModel.getSelectedExercise() {
                let vm = ExerciseViewModel(exercise: exercise)
                vc.viewModel = vm
                vm.reloader = vc
                vc.readOnly = true
            }
        } else if segue.identifier == AddExerciseOnTheFlySegue, let vc = vc as? ExerciseTemplateSelectionViewController {
            vc.viewModel = exerciseSelectionViewModel
            vc.delegate = viewModel
        }
    }
    
    func reload() {
        tableView.reloadData()
    }

}

extension WorkoutViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sectionCount()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.rowsForSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: exerciseCellReuseIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: exerciseCellReuseIdentifier)
        }
        cell?.textLabel?.text = viewModel.titleForIndexPath(indexPath)
        cell?.accessoryType =  indexPath.section == 0 ? .disclosureIndicator : .checkmark
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selected(indexPath: indexPath)
        performSegue(withIdentifier: NavigateToExerciseDetailSegue, sender: self)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "to do"
        }
        return "done"
    }
}
