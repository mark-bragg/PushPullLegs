//
//  PPLTabBarControllerViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/21/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

class PPLTabBarControllerViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let dataVc = UIStoryboard(name: "DataPresentation", bundle: nil).instantiateInitialViewController() {
            viewControllers?.append(dataVc)
        }
        if let workoutNavVC = UIStoryboard(name: "Workout", bundle: nil).instantiateInitialViewController() {
            viewControllers?.append(workoutNavVC)
        }
    }

}
