//
//  HowToUseAppViewModel.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 10/28/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation
import UIKit

class HowToUseAppViewModel: NSObject, PPLTableViewModel {
    
    private var rowHeights = [Int: CGFloat]()
    private let sectionTitles = ["The Regimen", "Progressive Overload", "Initial Setup", "Working Out", "Observing Data"]
    
    private let regimenExplanation = "Start off with a Push workout the first day, followed by a Pull workout the next day, rest for one day, and start back up with a Legs workout on the fourth day, and finish it off with an Arms workout on the fifth day; spend the next two days resting, and then repeat the cycle starting with the Push workout again. This may not be the way you want to do it, so you can customize the pattern.\nFor example, you can start off with a Legs workout instead of a Push on your first day, or you can do Arms Legs Pull Push (this is what I do). Everybody is different, and you should customize the regimen if it works better for you. The main idea of the app is to separate your exercises and workouts into the categories of Push and Pull, and/or Arms and Legs. In order to see progress, you must adhere to one strict requirement: progressive overload.\n"
    
    private let progressiveOverloadExplanation = "This is crucial in order to make gains. As you continue down the path of lifting weights day after day, you need to increase your volume. Volume is a calculation of work done in a set with the following formula:\n\nv = weight • reps • Log4(time)\n\nIncreasing each of these three factors increases the volume. The total volume from each workout is compared to the previous workouts. This is progressive overload, consistently increasing your workout volume over time, and it is absolutely required in order to make gains. The reason time is modified with a logarithm is because as you increase your time on a lift, the amount of benefit it has on the workout begins to drop off. For instance, a heavy lift that takes 60 seconds to perform 15 reps till failure has a very high intensity and will likely result in some gain in strength as you recover. However, if you perform a lift with such lightweight that you can do it for minutes and minutes, you are not going to build any strength off of that performance. The reason the logarithm is base 4 is because the assumption is each rep should take about 4 seconds. As you look back on your workouts and exercises, make sure the volume is increasing along with the weight. Don't get frustrated if you have decreases now and then, some workouts you just perform better than others, but over time, the average volume per workout will increase. Just stick to the program. Real gains come with time as long as you are consistent!\n"
    
    private let initialSetupExplanation = "Before you can begin working out and performing sets, you need to add exercises to the app. You can do this in a few different ways. \n1. You can begin any workout, and from the workout screen, add a new exercise.\n2. You can navigate back from this screen to the Settings screen, and tap Edit Workout List, select the workout that you wish to edit, and add your exercises.\n3. Similar to step 2, navigate back from this screen to the Settings screen, but this time, tap Edit Exercise List, and add your exercises.\n"
    
    private let workingOutExplanation = "A workout is a collection of exercises, which are a collection of sets performed by you. Sets have a weight, a time under tension, and a rep count; you will fill these values in each time you perform a set. Complete any number of sets per exercise, and make sure to save your progress when you finish each workout.\n"
    
    private let observingDataExplanation = "You have two ways to observe your progress.\n1. You can view each workout and the exercises performed in the Workout Log.\n2. Or you can view the graphs for each workout and exercise that show the trends in your progression from day one.\n"
    
    private let script = "A workout consists of a collection of sets per each exercise you perform.\n1. Select your desired workout for the day.\n2. Select any exercise.\n3. Tap the add button in the bottom right corner of the screen, and the weight collection screen will display.\n4. Enter the weight and begin the set.\n5. Tap the completion button when you have completed your set, the time under tension will be recorded.\n6. Record the number of reps performed.\n7. Save the set.\n\nAt this point, you can exit back to the exercise list, but before doing so, you need to save the exercise, and your sets will be recorded.\nRepeat this process for the rest of the exercises you wish to perform for the workout.\nOnce you are done with every exercise for the workout, tap Done in the upper left corner, and save the workout."
    
    func rowCount(section: Int) -> Int {
        1
    }
    
    func sectionCount() -> Int {
        sectionTitles.count
    }
    
    func titleForSection(_ section: Int) -> String? {
        sectionTitles[section]
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
        "How to Use the App"
    }
    
    func setHeight(_ height: CGFloat, forSection section: Int) {
        rowHeights[section] = height
    }
    
    func heightForRow(_ row: Int) -> CGFloat {
        rowHeights[row] ?? 0
    }
    
}
