//
//  MonetizedAdUnitIDs.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 1/3/21.
//  Copyright © 2021 Mark Bragg. All rights reserved.
//

import Foundation

class AdUnitID {
    // MARK: Demonetized Unit IDs
    
}

class BannerAdUnitID: AdUnitID {
    
    // MARK: Workout Flow
    static let startWorkoutVC = test// "ca-app-pub-3612249788893677/2514570821"//
    static let workoutVC = test// "ca-app-pub-3612249788893677/8369532735"//
    static let exerciseVC = test// "ca-app-pub-3612249788893677/8888407486"//
    static let exerciseTemplateSelectionVC = test// "ca-app-pub-3612249788893677/5175761630"//
    static let exerciseTimerVC = test// "ca-app-pub-3612249788893677/1156278464"//
    
    // MARK: DB Flow
    static let workoutLogVC = test// "ca-app-pub-3612249788893677/1843459317"//
    static let workoutDataVC = test// "ca-app-pub-3612249788893677/3827652493"//
    static let exerciseReadOnlyVC = test// "ca-app-pub-3612249788893677/7383754128"//
    
    // MARK: Graph Flow
    static let graphTableVC = test// "ca-app-pub-3612249788893677/7575325813"//
    
    // MARK: App Settings Flow
    static let appConfigurationVC = test// "ca-app-pub-3612249788893677/6262244145"//
    static let exerciseTemplateListVC = test// "ca-app-pub-3612249788893677/9051865499"//
    static let workoutTemplateListVC = test// "ca-app-pub-3612249788893677/9491042716"//
    static let workoutTemplateEditVC = test// "ca-app-pub-3612249788893677/8177961043"//
    
    private static let test = "ca-app-pub-3940256099942544/2934735716"
}

class InterstitialAdUnitID: AdUnitID {
    static let graphTableVC = test// "ca-app-pub-3612249788893677/6453815831"//
    private static let test = "ca-app-pub-3940256099942544/4411468910"
}
