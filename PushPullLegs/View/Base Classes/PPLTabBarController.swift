//
//  PPLTabBarControllerViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/21/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit
import AppTrackingTransparency
import AdSupport

class PPLTabBarController: UITabBarController, DefaultColorUpdateResponder {
    
    var isGraphPresented = false
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { isGraphPresented ? .allButUpsideDown : .portrait }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DefaultColorUpdate.addObserver(self)
        viewControllers = [
            workoutNavigationController(),
            workoutLogNavigationController(),
            trendsNavigationController(),
            appConfigurationNavigationController()
        ]
        for navigationController in viewControllers as! [PPLNavigationController] {
            navigationController.navigationBar.isTranslucent = false
            navigationController.navigationBar.barTintColor = PPLColor.secondary
            navigationController.navigationBar.tintColor = .white
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if #available(iOS 14, *), PPLDefaults.instance.isAdsEnabled() {
            ATTrackingManager.requestTrackingAuthorization { (status) in
                print("status \(status.rawValue)")
            }
        }
    }
    
    fileprivate func workoutNavigationController() -> PPLNavigationController {
        let vc = PPLNavigationController(rootViewController: StartWorkoutViewController())
        vc.tabBarItem = .workoutTab
        return vc
    }
    
    fileprivate func trendsNavigationController() -> PPLNavigationController {
        let vc = PPLNavigationController(rootViewController: GraphTableViewController())
        vc.tabBarItem = .trendsTab
        return vc
    }
    
    fileprivate func workoutLogNavigationController() -> PPLNavigationController {
        let vc = PPLNavigationController(rootViewController: WorkoutLogViewController())
        vc.tabBarItem = .databaseTab
        return vc
    }
    
    fileprivate func appConfigurationNavigationController() -> PPLNavigationController {
        let vc = PPLNavigationController(rootViewController: AppConfigurationViewController())
        vc.tabBarItem = .settingsTab
        return vc
    }
    
    func handleDefaultColorUpdate() {
        guard let viewControllers = viewControllers as? [PPLNavigationController] else { return }
        
        for navController in viewControllers {
            navController.navigationBar.barTintColor = PPLColor.secondary
            if let defaultColorObserver = navController.viewControllers.first as? PPLTableViewController {
                defaultColorObserver.reload()
            }
        }
    }

}

extension UITabBarItem {
    static let workoutTab = UITabBarItem(title: EntityName.workout.rawValue, image: TabBarImage.forWorkoutTab(), selectedImage: nil)
    static let trendsTab = UITabBarItem(title: "Trends", image: TabBarImage.forTrendsTab(), selectedImage: nil)
    static let databaseTab = UITabBarItem(title: "Database", image: TabBarImage.forDatabaseTab(), selectedImage: nil)
    static let settingsTab = UITabBarItem(title: "Settings", image: TabBarImage.forSettingsTab(), selectedImage: nil)
}

class PPLNavigationController: UINavigationController {
    override func popViewController(animated: Bool) -> UIViewController? {
        let vc = super.popViewController(animated: animated)
        if let _ = vc as? ExerciseViewController {
            AppState.shared.exerciseInProgress = nil
        }
        return vc
    }
}
