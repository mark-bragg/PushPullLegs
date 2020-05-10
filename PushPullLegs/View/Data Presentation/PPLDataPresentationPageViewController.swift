//
//  PPLDataPresentationPageViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 5/3/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

class PPLDataPresentationPageViewController: UIPageViewController, UIPageViewControllerDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        setViewControllers([PPLGraphViewController(withGraphModel: WeightExerciseGraphModel())], direction: .forward, animated: true, completion: nil)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return nil
    }

}
