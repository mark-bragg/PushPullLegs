//
//  AboutViewModel.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 10/28/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation
import UIKit

class AboutViewModel: NSObject, PPLTableViewModel {
    
    private var rowHeights = [Int:CGFloat]()
    private let sectionTitles = ["The Regimen", "Progressive Overload", "Initial Setup", "Working Out", "Observing Data"]
    private var sectionExpansions = Array(repeating: false, count: 5)
    
    private let regimenExplanation = "This app is based on the basic workout regimen of Push Pull Legs where you perform a collection of each type of exercises (push/pull/legs) each day that you work out. The general approach to this regimen is to start off with a Push workout the first day, followed by a Pull workout the next day, and then a Legs workout on the third day; spend the next day resting, and then repeat the cycle starting with the Push workout again. This is just the general form, and may not be the way you want to do it, so you can switch it up however you want.\nFor example, you can start off with a Pull workout or a Legs workout instead of a Push on your first day, or you can alternate between all three every time you repeat the cycle. You can also spend your rest days however you want; maybe you need more rest and you wait two days till you repeat the cycle, or maybe you want to rest for a day after each workout. It doesn't really matter how you customize the regimen, as long as it works for you and the gains don't stop. The main idea of the app is to separate your exercises and workouts into the categories of Push Pull Legs because it is one of the most effective methods of weightlifting for gaining strength with one strict requirement: progressive overload.\n"
    
    private let progressiveOverloadExplanation = "This is crucial in order to make gains. As you continue down the path of lifting weights day after day, you need to increase the amount of work you do, or, as I like to call it, volume. Volume is a calculation of work done in a set/exercise/workout. Volume is calculated with the following formula:\n\nweight • time • reps\n\nIncreasing any of these three factors increases the volume and thus the load compared to the last performance. This is progressive overload, consistently increasing your workout volume over time, and it is necessary to make gains. As you look back on your workouts and exercises, make sure the volume is increasing. Last, don't get frustrated if you have decreases now and then, that'll happen, no worries; just make sure you keep up the consistency, and the gains will follow.\n"
    
    private let initialSetupExplanation = "Before you can begin working out and performing sets, you need to add exercises to the app. You can do this in a few different ways. \n1. You can begin any workout, and from the workout screen, you can add a new exercise.\n2. You can navigate back from this screen to the Settings screen, and tap Edit Workout List, select the workout that you wish to edit, and add your exercises.\n3. Similar to step 2, navigate back from this screen to the Settings screen, but this time, tap Edit Exercise List, and add your exercises.\n"
    
    private let workingOutExplanation = "A workout is a collection of exercises, which are a collection of sets performed by you. Sets have a weight, a time under tension, and a rep count; you will fill these values in each time you perform a set. Complete any number sets per exercise, and make sure to save your progress when you finish each workout.\n"
    
    private let observingDataExplanation = "You have two ways to observe your progress.\n1. You can view each workout and the exercises performed in the Workout Log.\n2. Or you can view the graphs for each workout that show the trends in your progression from day one.\n"
    
    private let script = "A workout consists of a collection of sets per each exercise you perform.\n1. Select your desired workout for the day.\n2. Select any exercise.\n3. Tap the add button in the bottom right corner of the screen, and the weight collection screen will display.\n4. Enter the weight and begin the set.\n5. Tap the completion button when you have completed your set, the time under tension will be recorded.\n6. Record the number of reps performed.\n7. Save the set.\n\nAt this point, you can exit back to the exercise list, but before doing so, you need to save the exercise, and your sets will be recorded.\nRepeat this process for the rest of the exercises you wish to perform for the workout.\nOnce you are done with every exercise for the workout, tap Done in the upper left corner, and save the workout."
    
    func rowCount(section: Int) -> Int {
        1
    }
    
    func sectionCount() -> Int {
        return sectionTitles.count
    }
    
    func titleForSection(_ section: Int) -> String? {
        return sectionTitles[section]
    }
    
    func title(indexPath: IndexPath) -> String? {
        switch indexPath.section {
        case 0:
            return regimenExplanation
        case 1:
            return progressiveOverloadExplanation
        case 2:
            return initialSetupExplanation
        case 3:
            return workingOutExplanation
        case 4:
            return observingDataExplanation
        default:
            return "title for indexPath"
        }
    }
    
    func title() -> String? {
        return "About the App"
    }
    
    func setHeight(_ height: CGFloat, forRow row: Int) {
        rowHeights[row] = height
    }
    
    func heightForRow(_ row: Int) -> CGFloat {
        guard let height = rowHeights[row] else { return 0 }
        return height
    }
    
    func isSectionExpanded(_ section: Int) -> Bool {
        return sectionExpansions[section]
    }
    
    func expandSection(_ section: Int) {
        sectionExpansions[section] = true
    }
    
    func collapseSection(_ section: Int) {
        sectionExpansions[section] = false
    }
}
