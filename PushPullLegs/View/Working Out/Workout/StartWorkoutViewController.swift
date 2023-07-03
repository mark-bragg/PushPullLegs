//
//  StartWorkoutViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 10/28/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

protocol WorkoutSelectionDelegate: NSObject {
    func workoutSelectedWithType(_ type: ExerciseTypeName)
}

class StartWorkoutViewController: PPLTableViewController {

    private var exerciseType: ExerciseTypeName?
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
        #if !DEBUG
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
        #endif
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCellIdentifier) else {
            return UITableViewCell()
        }
        cell.setWorkoutTitle(startWorkoutViewModel()?.title(indexPath: indexPath))
        cell.updateTitleText()
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.frame.height / CGFloat(ExerciseTypeName.allCases.count)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let exerciseType = tableView.cellForRow(at: indexPath)?.exerciseType() else { return }
        if let del = delegate {
            del.workoutSelectedWithType(exerciseType)
        } else {
            navigateToNextWorkout(exerciseType)
        }
    }
    
    func navigateToNextWorkout(_ type: ExerciseTypeName) {
        didNavigateToWorkout = true
        let vc = WorkoutViewController()
        vc.viewModel = WorkoutEditViewModel(withType: type)
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

fileprivate extension UITableViewCell {
    
    func setWorkoutTitle(_ title: String?) {
        if let lbl = contentView.viewWithTag(1) as? UILabel {
            lbl.text = title
            lbl.sizeToFit()
            return
        }
        let lbl = PPLNameLabel()
        lbl.font = UIFont.systemFont(ofSize: 64, weight: .medium)
        lbl.tag = 1
        lbl.text = title
        lbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(lbl)
        lbl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        lbl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        lbl.sizeToFit()
    }
    
    func updateTitleText() {
        guard let lbl = contentView.viewWithTag(1) as? UILabel else { return }
        lbl.textColor = PPLColor.text
    }
    
    func exerciseType() -> ExerciseTypeName? {
        guard let title = title() else { return nil }
        return ExerciseTypeName(rawValue: title)
    }
    
    func title() -> String? {
        (viewWithTag(1) as? UILabel)?.text
    }
    
}

extension StartWorkoutViewController: SplashViewControllerDelegate {
    func splashViewControllerDidDisappear(_ splash: SplashViewController) {
        splash.view.removeFromSuperview()
        splashVC = nil
        let launchCount = PPLDefaults.instance.launchCount()
        if launchCount == 5 || (launchCount < 105 && launchCount % 13 == 0) {
            StoreManager.shared.prepareToDisableAds(self)
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
        controller.addAction(UIAlertAction(title: "No", style: .cancel, handler: { [weak self] action in
            self?.presentHowToDisableAlert()
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
    private var workoutNames: [ExerciseTypeName] { ExerciseTypeName.allCases }
    
    func rowCount(section: Int = 0) -> Int {
        workoutNames.count
    }
    
    func title(indexPath: IndexPath) -> String? {
        workoutNames[indexPath.row].rawValue
    }
    
    func title() -> String? {
        "Start Next Workout"
    }
    
}
