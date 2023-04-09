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
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        AppState.isLaunch() || isGraphPresented ? .allButUpsideDown : .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DefaultColorUpdate.addObserver(self)
        viewControllers = [
            workoutNavigationController(),
            workoutLogNavigationController(),
            trendsNavigationController(),
            appConfigurationNavigationController()
        ]
        guard let viewControllers = viewControllers as? [PPLNavigationController] else { return }
        for navigationController in viewControllers {
            navigationController.navigationBar.isTranslucent = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ATTrackingManager.requestTrackingAuthorization { self.handleTrackingAuthorization(status: $0) }
    }
    
    private func handleTrackingAuthorization(status: ATTrackingManager.AuthorizationStatus) {
        DispatchQueue.main.async {
            let authorized = status == .authorized
            STAStartAppSDK.sharedInstance().handleExtras { dict in
                dict?["IABUSPrivacy_String"] = authorized ? "1---" : "1YNN"
            }
            STAStartAppSDK.sharedInstance().setUserConsent(authorized, forConsentType: "pas", withTimestamp: Int(Date.now.timeIntervalSince1970))
            self.requestNotificationAuthorization()
        }
    }
    
    private func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { self.handleNotificationAuthorization(status: $0, error: $1) }
    }
    
    private func handleNotificationAuthorization(status: Bool, error: Error?) {
        guard status
        else { return }
        DispatchQueue.main.async {
            UNUserNotificationCenter.current().delegate = UIApplication.shared.delegate as? UNUserNotificationCenterDelegate
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
