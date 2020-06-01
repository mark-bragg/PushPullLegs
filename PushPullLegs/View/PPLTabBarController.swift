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
        var controllers = [UIViewController]()
        if let workoutNavVC = UIStoryboard(name: "Workout", bundle: nil).instantiateInitialViewController() {
            controllers.append(workoutNavVC)
        }
        
        controllers.append(UINavigationController(rootViewController: WorkoutLogViewController()))
            
        if let appConfigNavVC = UIStoryboard(name: "AppConfiguration", bundle: nil).instantiateInitialViewController() {
            controllers.append(appConfigNavVC)
        }
        viewControllers = controllers
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

}
