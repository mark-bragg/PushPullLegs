//
//  WorkoutViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/18/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

let ExerciseToDoCellReuseIdentifier = "ExerciseToDoCellReuseIdentifier"

class PPLTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var viewModel: ViewModel!
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let count = viewModel.sectionCount?() else { return 1 }
        return count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.rowCount(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

class WorkoutViewController: PPLTableViewController {

    @IBOutlet weak var tableView: UITableView!
    private var exerciseSelectionViewModel: ExerciseSelectionViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        workoutEditViewModel().delegate = self
        navigationItem.title = workoutEditViewModel().exerciseType.rawValue
        exerciseSelectionViewModel = ExerciseSelectionViewModel(withType: workoutEditViewModel().exerciseType, templateManagement: TemplateManagement())
        tableView.register(UINib(nibName: "ExerciseDataCell", bundle: nil), forCellReuseIdentifier: ExerciseDataCellReuseIdentifier)
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(done(_:)))
    }
    
    func workoutEditViewModel() -> WorkoutEditViewModel {
        return viewModel as! WorkoutEditViewModel
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }
    
    @IBAction func addExercise(_ sender: Any) {
        if exerciseSelectionViewModel.rowCount(section: 0) > 0 {
            performSegue(withIdentifier: SegueIdentifier.addExerciseOnTheFly.rawValue, sender: self)
        } else {
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateExerciseViewController") as? ExerciseTemplateCreationViewController {
                vc.showExerciseType = false
                vc.viewModel = ExerciseTemplateCreationViewModel(withType: workoutEditViewModel().exerciseType, management: TemplateManagement())
                vc.viewModel?.reloader = self
                vc.modalPresentationStyle = .pageSheet
                present(vc, animated: true, completion: nil)
            }
        }
    }
    
    // TODO: present save confirmation alert vc to finish workout
    @IBAction func done(_ sender: Any) {
        guard viewModel.rowCount(section: 1) > 0 else {
            workoutEditViewModel().deleteWorkout()
            navigationController?.popViewController(animated: true)
            return
        }
        let alert = UIAlertController.init(title: "Workout Complete?", message: "Once you save a workout, you cannot edit it later.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (action) in
            if self.viewModel.rowCount(section: 1) == 0 {
                self.workoutEditViewModel().finishWorkout()
            }
            self.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
            self.workoutEditViewModel().deleteWorkout()
            self.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination
        if segue.identifier == SegueIdentifier.navigateToExerciseDetail.rawValue, let vc = vc as? ExerciseViewController {
            if let exerciseTemplate = workoutEditViewModel().getSelected() as? ExerciseTemplate {
                let vm = ExerciseViewModel(exerciseTemplate: exerciseTemplate)
                vc.viewModel = vm
                vm.reloader = vc
                vm.delegate = workoutEditViewModel()
            } else if let exercise = workoutEditViewModel().getSelected() as? Exercise {
                let vm = ExerciseViewModel(exercise: exercise)
                vc.viewModel = vm
                vm.reloader = vc
                vc.readOnly = true
            }
        } else if segue.identifier == SegueIdentifier.addExerciseOnTheFly.rawValue, let vc = vc as? ExerciseTemplateSelectionViewController {
            vc.viewModel = exerciseSelectionViewModel
            vc.delegate = workoutEditViewModel()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeuCell(section: indexPath.section)
        if indexPath.section == 1 {
            cell.detailTextLabel?.text = "Total volume: \(workoutEditViewModel().detailText(indexPath: indexPath)!)"
            cell.setWorkoutProgressionImage(workoutEditViewModel().exerciseVolumeComparison(row: indexPath.row))
        }
        cell.textLabel?.text = viewModel.title(indexPath: indexPath)
        return cell
    }
    
    func dequeuCell(section: Int) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: section == 0 ? ExerciseToDoCellReuseIdentifier : ExerciseDataCellReuseIdentifier)!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        workoutEditViewModel().selectedIndex = indexPath
        performSegue(withIdentifier: SegueIdentifier.navigateToExerciseDetail.rawValue, sender: self)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableHeaderView(titles: [section == 0 ? "TODO" : "DONE"])
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return workoutEditViewModel().rowCount(section: section) > 0 ? super.tableView(tableView, heightForHeaderInSection: section) : 0
    }
}

extension WorkoutViewController: WorkoutEditViewModelDelegate {
    func workoutEditViewModelCompletedFirstExercise(_ model: WorkoutEditViewModel) {
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(done(_:)))
    }
}

extension WorkoutViewController: ReloadProtocol {
    func reload() {
        workoutEditViewModel().exerciseTemplatesAdded()
        tableView.reloadData()
    }
}
