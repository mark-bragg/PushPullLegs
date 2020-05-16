//
//  WorkoutViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/18/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

let ExerciseToDoCellReuseIdentifier = "ExerciseToDoCellReuseIdentifier"

class WorkoutViewController: UIViewController, ReloadProtocol {

    @IBOutlet weak var tableView: UITableView!
    var viewModel: WorkoutEditViewModel!
    private var exerciseSelectionViewModel: ExerciseSelectionViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        navigationItem.title = viewModel.exerciseType.rawValue
        exerciseSelectionViewModel = ExerciseSelectionViewModel(withType: viewModel.exerciseType, templateManagement: TemplateManagement())
        tableView.register(UINib(nibName: "ExerciseDataCell", bundle: nil), forCellReuseIdentifier: ExerciseDataCellReuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }
    
    @IBAction func addExercise(_ sender: Any) {
        if exerciseSelectionViewModel.rowCount() > 0 {
            performSegue(withIdentifier: SegueIdentifier.addExerciseOnTheFly.rawValue, sender: self)
        } else {
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateExerciseViewController") as? ExerciseTemplateCreationViewController {
                vc.showExerciseType = false
                vc.viewModel = ExerciseTemplateCreationViewModel(withType: viewModel.exerciseType, management: TemplateManagement())
                vc.viewModel?.reloader = self
                vc.modalPresentationStyle = .pageSheet
                present(vc, animated: true, completion: nil)
            }
        }
    }
    
    // TODO: present save confirmation alert vc to finish workout
    @IBAction func done(_ sender: Any) {
        viewModel.finishWorkout()
        navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination
        if segue.identifier == SegueIdentifier.navigateToExerciseDetail.rawValue, let vc = vc as? ExerciseViewController {
            // TODO: open already performed Exercise instead of creating a new ExerciseTemplate
            if let exerciseTemplate = viewModel.getSelected() as? ExerciseTemplate {
                let vm = ExerciseViewModel(exerciseTemplate: exerciseTemplate)
                vc.viewModel = vm
                vm.reloader = vc
                vm.delegate = viewModel
            } else if let exercise = viewModel.getSelected() as? Exercise {
                let vm = ExerciseViewModel(exercise: exercise)
                vc.viewModel = vm
                vm.reloader = vc
                vc.readOnly = true
            }
        } else if segue.identifier == SegueIdentifier.addExerciseOnTheFly.rawValue, let vc = vc as? ExerciseTemplateSelectionViewController {
            vc.viewModel = exerciseSelectionViewModel
            vc.delegate = viewModel
        }
    }
    
    func reload() {
        viewModel.exerciseTemplatesAdded()
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
        let cell = dequeuCell(section: indexPath.section)
        if indexPath.section == 1 {
            cell.detailTextLabel?.text = "Total volume: \(viewModel.detailText(indexPath: indexPath)!)"
            let color: UIColor = viewModel.exerciseVolumeComparison(row: indexPath.row) == .increase ? .green : .red
            cell.imageView?.image = color.getImage(size: CGSize(width: 20, height: 20))
        }
        cell.textLabel?.text = viewModel.titleForIndexPath(indexPath)
        return cell
    }
    
    func dequeuCell(section: Int) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: section == 0 ? ExerciseToDoCellReuseIdentifier : ExerciseDataCellReuseIdentifier)!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectedIndex = indexPath
        performSegue(withIdentifier: SegueIdentifier.navigateToExerciseDetail.rawValue, sender: self)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "to do"
        }
        return "done"
    }
}

extension UIColor {
func getImage(size: CGSize) -> UIImage {
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image(actions: { rendererContext in
        self.setFill()
        rendererContext.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
    })
}}
