//
//  PPLTabBarControllerViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/21/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    fileprivate func workoutNavigationController() -> UINavigationController {
        let vc = UINavigationController(rootViewController: StartWorkoutViewController())
        vc.tabBarItem = UITabBarItem(title: EntityName.workout.rawValue, image: UIImage(named: "curlbar"), selectedImage: nil)
        return vc
    }
    
    fileprivate func trendsNavigationController() -> UINavigationController {
        let vc = UINavigationController(rootViewController: GraphTableViewController())
        vc.tabBarItem = UITabBarItem(title: "Trends", image: UIImage(named: "line_graph"), selectedImage: nil)
        return vc
    }
    
    fileprivate func workoutLogNavigationController() -> UINavigationController {
        let vc = UINavigationController(rootViewController: WorkoutLogViewController())
        vc.tabBarItem = UITabBarItem(title: "Database", image: UIImage(named: "database"), selectedImage: nil)
        return vc
    }
    
    fileprivate func appConfigurationNavigationController() -> UINavigationController {
        let vc = UINavigationController(rootViewController: AppConfigurationViewController())
        vc.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(named: "gear"), selectedImage: nil)
        return vc
    }

}

