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

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let workoutLogVC = WorkoutLogViewController()
            let nvc = UINavigationController(rootViewController: workoutLogVC)
            viewControllers?.append(nvc)
        if let workoutNavVC = UIStoryboard(name: "Workout", bundle: nil).instantiateInitialViewController() {
            viewControllers?.append(workoutNavVC)
        }
    }

}
