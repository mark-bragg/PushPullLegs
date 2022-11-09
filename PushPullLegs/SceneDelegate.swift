//
//  SceneDelegate.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 2/15/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

@objc protocol ForegroundObserver {
    @objc func willEnterForeground()
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate, AdsRemovedResponder {

    var window: UIWindow?
    static var shared: SceneDelegate!
    weak var foregroundObserver: ForegroundObserver?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        SceneDelegate.shared = self
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        window?.makeKeyAndVisible()
        window?.rootViewController = PPLTabBarController()
        window?.overrideUserInterfaceStyle = .dark
    }
    
    func adsRemoved() {
        for subvc in window!.rootViewController!.children {
            guard let nvc = subvc as? UINavigationController else { break }
            if let responder = nvc.children.first as? AdsRemovedResponder {
                responder.adsRemoved()
            }
            subvc.view.setNeedsDisplay()
            subvc.view.setNeedsLayout()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
        CoreDataManager.shared.save()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        foregroundObserver?.willEnterForeground()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        CoreDataManager.shared.save()
    }


}

