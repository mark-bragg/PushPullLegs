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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let configVc = UIStoryboard(name: "DataPresentation", bundle: nil).instantiateInitialViewController() {
            let nvc = UINavigationController(rootViewController: configVc)
            viewControllers?.append(nvc)
        }
        if let workoutNavVC = UIStoryboard(name: "Workout", bundle: nil).instantiateInitialViewController() {
            viewControllers?.append(workoutNavVC)
        }
    }

}
