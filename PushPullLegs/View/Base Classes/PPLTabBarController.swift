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
            appConfigurationNavigationController()
        ]
        for navigationController in viewControllers as! [UINavigationController] {
            navigationController.setNavigationBarHidden(true, animated: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    fileprivate func workoutNavigationController() -> UINavigationController {
        let vc = UIStoryboard(name: StoryboardFileName.workout, bundle: nil).instantiateInitialViewController() as! UINavigationController
        vc.tabBarItem = UITabBarItem(title: EntityName.workout.rawValue, image: UIImage(named: "curlbar"), selectedImage: nil)
        vc.tabBarItem.badgeColor = PPLColor.Green
        return vc
    }
    
    fileprivate func workoutLogNavigationController() -> UINavigationController {
        let vc = UINavigationController(rootViewController: WorkoutLogViewController())
        vc.tabBarItem = UITabBarItem(title: "Database", image: UIImage(named: "database"), selectedImage: nil)
        vc.tabBarItem.badgeColor = PPLColor.Green
        return vc
    }
    
    fileprivate func appConfigurationNavigationController() -> UINavigationController {
        let vc = UIStoryboard(name: StoryboardFileName.appConfiguration, bundle: nil).instantiateInitialViewController() as! UINavigationController
        vc.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(named: "gear"), selectedImage: nil)
        vc.tabBarItem.badgeColor = PPLColor.Green
        return vc
    }

}
