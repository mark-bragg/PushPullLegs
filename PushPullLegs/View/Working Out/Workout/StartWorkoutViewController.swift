//
//  StartWorkoutViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 10/28/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

class StartWorkoutViewController: PPLTableViewController {

    private var exerciseType: ExerciseType?
    private var didNavigateToWorkout: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = StartWorkoutViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hidesBottomBarWhenPushed = false
        if AppState.shared.workoutInProgress {
            self.navigateToNextWorkout()
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PPLTableViewCellIdentifier) as! PPLTableViewCell
        cell.setWorkoutTitle(startWorkoutViewModel().title(indexPath: indexPath)!)
        cell.addDisclosureIndicator()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height / 3
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        exerciseType = (tableView.cellForRow(at: indexPath) as! PPLTableViewCell).exerciseType()
        navigateToNextWorkout()
        exerciseType = nil
    }
    
    func navigateToNextWorkout() {
        didNavigateToWorkout = true
        let vc = WorkoutViewController()
        vc.viewModel = WorkoutEditViewModel(withType: exerciseType)
        vc.$popped.sink { (popped) in
            PPLDefaults.instance.setWorkoutInProgress(false)
        }.store(in: &cancellables)
        AppState.shared.workoutInProgress = true
        vc.hidesBottomBarWhenPushed = true
        navigationController!.pushViewController(vc, animated: true)
    }
    
    func startWorkoutViewModel() -> StartWorkoutViewModel {
        return viewModel as! StartWorkoutViewModel
    }
    
}


fileprivate extension PPLTableViewCell {
    
    func setWorkoutTitle(_ title: String) {
        if let lbl = rootView.viewWithTag(1) as? UILabel {
            lbl.text = title
            lbl.sizeToFit()
            return
        }
        let lbl = PPLNameLabel()
        lbl.font = UIFont.systemFont(ofSize: 64, weight: .medium)
        lbl.tag = 1
        lbl.text = title
        lbl.translatesAutoresizingMaskIntoConstraints = false
        rootView.addSubview(lbl)
        lbl.centerYAnchor.constraint(equalTo: rootView.centerYAnchor).isActive = true
        lbl.centerXAnchor.constraint(equalTo: rootView.centerXAnchor).isActive = true
        lbl.sizeToFit()
    }
    
    func exerciseType() -> ExerciseType {
        return ExerciseType(rawValue: title())!
    }
    
    func title() -> String {
        return (viewWithTag(1) as! UILabel).text!
    }
    
}

class StartWorkoutViewModel: NSObject, PPLTableViewModel {
    func rowCount(section: Int = 0) -> Int {
        3
    }
    
    func title(indexPath: IndexPath) -> String? {
        switch indexPath.row {
        case 0:
            return "Push"
        case 1:
            return "Pull"
        default:
            return "Legs"
        }
    }
    
    func title() -> String? {
        return "Start Next Workout"
    }
    
}
