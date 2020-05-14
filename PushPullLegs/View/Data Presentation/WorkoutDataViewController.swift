//
//  WorkoutDataViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 5/13/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

let ExerciseDataCellReuseIdentifier = "ExerciseDataCellReuseIdentifier"

class WorkoutDataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var viewModel: WorkoutReadViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ExerciseDataCell", bundle: nil), forCellReuseIdentifier: ExerciseDataCellReuseIdentifier)
        navigationItem.title = "Exercises"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let vm = viewModel else { return 0 }
        return vm.rowsForSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ExerciseDataCellReuseIdentifier)!
        if let vm = viewModel {
            cell.textLabel?.text = vm.titleForIndexPath(indexPath)
            cell.textLabel?.font = UIFont.systemFont(ofSize: 25, weight: .medium)
            cell.detailTextLabel?.text = "Total volume: \(vm.detailText(indexPath: indexPath)!)"
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 20, weight: .regular)
            var imageName: String
            var tint: UIColor
            if vm.exerciseVolumeComparison(row: indexPath.row) == .increase {
                imageName = "arrow.up"
                tint = .green
            } else {
                imageName = "arrow.down"
                tint = .red
            }
            cell.imageView?.image = UIImage.init(systemName: imageName)?.withRenderingMode(.alwaysTemplate)//.withTintColor(tint)
            cell.imageView?.tintColor = tint
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vm = viewModel else { return }
        vm.selectedIndex = indexPath
        let exerciseVm = ExerciseViewModel(exercise: vm.getSelected() as! Exercise)
        let vc = ExerciseViewController()
        vc.viewModel = exerciseVm
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
