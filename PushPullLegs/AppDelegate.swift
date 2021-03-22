//
//  AppDelegate.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 2/15/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds
import StoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private let defaults = PPLDefaults.instance
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // MARK: NSInMemoryStoreType for testing purposes
        CoreDataManager.shared.setup(completion: nil)
        CoreDataManager.shared.backgroundContext.retainsRegisteredObjects = true
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        SKPaymentQueue.default().add(StoreObserver.shared)
        return true
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

}
