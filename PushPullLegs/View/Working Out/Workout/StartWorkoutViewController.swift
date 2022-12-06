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
    var splashVC: SplashViewController?
    private static var isFirstAppearence = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = StartWorkoutViewModel()
        rotateBackToPortrait()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presentSplash()
        hidesBottomBarWhenPushed = false
        if let wipType = AppState.shared.workoutInProgress {
            exerciseType = wipType
            navigateToNextWorkout()
        }
        if let _ = delegate {
            removeBanner()
            setTableViewY(0)
        }
        tableView?.isScrollEnabled = false
    }
    
    func presentSplash() {
        guard StartWorkoutViewController.isFirstAppearence else { return }
        StartWorkoutViewController.isFirstAppearence = false
        let splashVC = SplashViewController()
        splashVC.delegate = self
        PPLSceneDelegate.shared?.window?.addSubview(splashVC.view)
        splashVC.view.frame = PPLSceneDelegate.shared?.window?.bounds ?? .zero
        self.splashVC = splashVC
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PPLTableViewCellIdentifier) as? PPLTableViewCell else {
            return PPLTableViewCell()
        }
        cell.setWorkoutTitle(startWorkoutViewModel()?.title(indexPath: indexPath))
        cell.updateTitleText()
        cell.addDisclosureIndicator()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height / 3
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        exerciseType = (tableView.cellForRow(at: indexPath) as? PPLTableViewCell)?.exerciseType()
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
            PPLDefaults.instance.setWorkoutInProgress(nil)
        }.store(in: &cancellables)
        AppState.shared.workoutInProgress = exerciseType
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func startWorkoutViewModel() -> StartWorkoutViewModel? {
        viewModel as? StartWorkoutViewModel
    }
    
}

extension UIViewController {
    func rotateBackToPortrait() {
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
    }
}

fileprivate extension PPLTableViewCell {
    
    func setWorkoutTitle(_ title: String?) {
        guard let rootView else { return }
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
        guard let lbl = rootView?.viewWithTag(1) as? UILabel else { return }
        lbl.textColor = PPLColor.text
    }
    
    func exerciseType() -> ExerciseType? {
        guard let title = title() else { return nil }
        return ExerciseType(rawValue: title)
    }
    
    func title() -> String? {
        (viewWithTag(1) as? UILabel)?.text
    }
    
}

extension StartWorkoutViewController: SplashViewControllerDelegate {
    func splashViewControllerDidDisappear(_ splash: SplashViewController) {
        splash.view.removeFromSuperview()
        splashVC = nil
        StoreManager.shared.delegate = self
        let launchCount = PPLDefaults.instance.launchCount()
        if launchCount == 1 || (launchCount < 100 && launchCount % 10 == 0) {
            StoreManager.shared.prepareToDisableAds()
        }
    }
}

extension StartWorkoutViewController: StoreManagerDelegate {
    
    func storeManagerPreparedDisableAdsSuccessfully(_ manager: StoreManager) {
        DispatchQueue.main.async {
            self.offerUserAdFreeExperience()
        }
    }
    
    func offerUserAdFreeExperience() {
        let title = "Tired of Ads?"
        let message = "Try an ad free experience for only 99 cents."
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            StoreManager.shared.startDisableAdsTransaction()
        }))
        controller.addAction(UIAlertAction(title: "No", style: .cancel, handler: { [unowned self] action in
            self.presentHowToDisableAlert()
        }))
        present(controller, animated: true, completion: nil)
    }
    
    func presentHowToDisableAlert() {
        let title = "In case you change your mind"
        let message = "Go to settings in the tab bar, and you can disable ads there."
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(controller, animated: true, completion: nil)
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
