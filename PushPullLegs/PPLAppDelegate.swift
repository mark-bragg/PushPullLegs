//
//  AppDelegate.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 2/15/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit
import CoreData
import StoreKit
import Combine

@UIApplicationMain
class PPLAppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    private let defaults = PPLDefaults.instance
    var wipCancellable: AnyCancellable?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // MARK: NSInMemoryStoreType for testing purposes
        wipCancellable = AppState.shared.$workoutInProgress.sink { (inProgress) in
            application.isIdleTimerDisabled = inProgress
        }
        CoreDataManager.shared.setup(completion: nil)
        CoreDataManager.shared.backgroundContext.retainsRegisteredObjects = true
        let sdk: STAStartAppSDK = STAStartAppSDK.sharedInstance()
        sdk.appID = "208303813"
        
        // MARK: only on when testing
//        sdk.testAdsEnabled = true
        
        SKPaymentQueue.default().add(StoreObserver.shared)
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (b, e) in
            if b {
                UNUserNotificationCenter.current().delegate = self
            }
        }
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner, .sound])
        center.removeAllDeliveredNotifications()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Remove the observer.
        SKPaymentQueue.default().remove(StoreObserver.shared)
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }

}
