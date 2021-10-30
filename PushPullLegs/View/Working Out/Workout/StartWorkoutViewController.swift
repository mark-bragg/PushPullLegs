//
//  StartWorkoutViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 10/28/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

protocol WorkoutSelectionDelegate: NSObject {
    func workoutSelectedWithType(_ type: ExerciseType)
}

class StartWorkoutViewController: PPLTableViewController {

    private var exerciseType: ExerciseType?
    private var didNavigateToWorkout: Bool = false
    weak var delegate: WorkoutSelectionDelegate?
    var splashVC: SplashViewController!
    private(set) var isFirstAppearence = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = StartWorkoutViewModel()
        rotateBackToPortrait()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presentSplash()
        hidesBottomBarWhenPushed = false
        if AppState.shared.workoutInProgress {
            self.navigateToNextWorkout()
        }
        if let _ = delegate {
            removeBanner()
            setTableViewY(0)
        }
        tableView?.isScrollEnabled = false
    }
    
    func presentSplash() {
        guard isFirstAppearence else { return }
        isFirstAppearence = false
        let splashVC = SplashViewController()
        splashVC.delegate = self
        UIApplication.shared.windows.first!.addSubview(splashVC.view)
        splashVC.view.frame = UIApplication.shared.windows.first!.bounds
        self.splashVC = splashVC
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PPLTableViewCellIdentifier) as! PPLTableViewCell
        cell.setWorkoutTitle(startWorkoutViewModel().title(indexPath: indexPath)!)
        cell.updateTitleText()
        cell.addDisclosureIndicator()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height / 3
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        exerciseType = (tableView.cellForRow(at: indexPath) as! PPLTableViewCell).exerciseType()
        if let del = delegate, let type = exerciseType {
            del.workoutSelectedWithType(type)
        } else {
            navigateToNextWorkout()
            exerciseType = nil
        }
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
    
    override func bannerAdUnitID() -> String {
        BannerAdUnitID.startWorkoutVC
    }
    
}

extension UIViewController {
    func rotateBackToPortrait() {
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
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
    
    func updateTitleText() {
        guard let lbl = rootView.viewWithTag(1) as? UILabel else { return }
        lbl.textColor = PPLColor.text
    }
    
    func exerciseType() -> ExerciseType {
        return ExerciseType(rawValue: title())!
    }
    
    func title() -> String {
        return (viewWithTag(1) as! UILabel).text!
    }
    
}

extension StartWorkoutViewController: SplashViewControllerDelegate {
    func splashViewControllerDidDisappear(_ splash: SplashViewController) {
        splashVC.view.removeFromSuperview()
        splashVC = nil
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
