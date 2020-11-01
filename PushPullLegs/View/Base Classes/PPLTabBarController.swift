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

class PPLTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [
            workoutNavigationController(),
            workoutLogNavigationController(),
            trendsNavigationController(),
            appConfigurationNavigationController()
        ]
        for navigationController in viewControllers as! [UINavigationController] {
            navigationController.navigationBar.isTranslucent = false
            navigationController.navigationBar.barTintColor = PPLColor.darkGrey
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { (status) in
                print("status \(status.rawValue)")
            }
        }
    }
    
    fileprivate func workoutNavigationController() -> UINavigationController {
        let vc = UINavigationController(rootViewController: StartWorkoutViewController())
        vc.tabBarItem = .workoutTab
        return vc
    }
    
    fileprivate func trendsNavigationController() -> UINavigationController {
        let vc = UINavigationController(rootViewController: GraphTableViewController())
        vc.tabBarItem = .trendsTab
        return vc
    }
    
    fileprivate func workoutLogNavigationController() -> UINavigationController {
        let vc = UINavigationController(rootViewController: WorkoutLogViewController())
        vc.tabBarItem = .databaseTab
        return vc
    }
    
    fileprivate func appConfigurationNavigationController() -> UINavigationController {
        let vc = UINavigationController(rootViewController: AppConfigurationViewController())
        vc.tabBarItem = .settingsTab
        return vc
    }

}

extension UITabBarItem {
    static let workoutTab = UITabBarItem(title: EntityName.workout.rawValue, image: TabBarImage.forWorkoutTab(), selectedImage: nil)
    static let trendsTab = UITabBarItem(title: "Trends", image: TabBarImage.forTrendsTab(), selectedImage: nil)
    static let databaseTab = UITabBarItem(title: "Database", image: TabBarImage.forDatabaseTab(), selectedImage: nil)
    static let settingsTab = UITabBarItem(title: "Settings", image: TabBarImage.forSettingsTab(), selectedImage: nil)
}

