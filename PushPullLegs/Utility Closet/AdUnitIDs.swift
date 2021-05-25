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
    static let exampleBannerAdUnitID = "ca-app-pub-3940256099942544/2934735716"
    static let exampleInterstitialAdUnitID = "ca-app-pub-3940256099942544/4411468910"
    
}

class BannerAdUnitID: AdUnitID {
    
    // MARK: Workout Flow
    static let startWorkoutVC = "ca-app-pub-3612249788893677/2514570821"
    static let workoutVC = "ca-app-pub-3612249788893677/8369532735"
    static let exerciseVC = "ca-app-pub-3612249788893677/8888407486"
    
    // MARK: DB Flow
    static let workoutLogVC = "ca-app-pub-3612249788893677/1843459317"
    static let workoutDataVC = "ca-app-pub-3612249788893677/3827652493"
    static let exerciseReadOnlyVC = "ca-app-pub-3612249788893677/7383754128"
    
    // MARK: Graph Flow
    static let graphTableVC = "ca-app-pub-3612249788893677/7575325813"
    
    // MARK: App Settings Flow
    static let appConfigurationVC = "ca-app-pub-3612249788893677/6262244145"
    static let exerciseTemplateListVC = "ca-app-pub-3612249788893677/9051865499"
    static let workoutTemplateListVC = "ca-app-pub-3612249788893677/9491042716"
    static let workoutTemplateEditVC = "ca-app-pub-3612249788893677/8177961043"
}

class InterstitialAdUnitID: AdUnitID {
    static let graphTableVC = "ca-app-pub-3612249788893677/6453815831"
}
