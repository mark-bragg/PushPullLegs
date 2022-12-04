//
//  WorkoutLogViewModel.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 3/23/21.
//  Copyright © 2021 Mark Bragg. All rights reserved.
//

import Foundation
import CoreData

class WorkoutLogViewModel: DatabaseViewModel {
    let formatter = DateFormatter()
    static var ascending = false
    weak var reloader: ReloadProtocol?
    
    override init() {
        super.init()
        formatter.dateFormat = "MM/dd/yy"
        dataManager = WorkoutDataManager()
        dataManager?.deletionObserver = self
        dbObjects = workoutManager.workouts()
        if WorkoutLogViewModel.ascending {
            dbObjects.reverse()
        }
    }
    
    private var workoutManager: WorkoutDataManager {
        dataManager as? WorkoutDataManager ?? WorkoutDataManager()
    }
    
    override func rowCount(section: Int) -> Int {
        return dbObjects.count
    }
    
    func title() -> String? {
        return "Workout Log"
    }
    
    override func title(indexPath: IndexPath) -> String? {
        guard let workout = dbObjects[indexPath.row] as? Workout else { return nil }
        return workout.name
    }
    
    func dateLabel(indexPath: IndexPath) -> String? {
        guard
            let workout = dbObjects[indexPath.row] as? Workout,
            let date = workout.dateCreated
        else { return nil }
        return formatter.string(from: date)
    }
    
    func tableHeaderTitles() -> [String] {
        return ["Name", "Date"]
    }
    
    override func objectDeleted(_ object: NSManagedObject) {
        guard let workout = object as? Workout else { return }
        dbObjects = dbObjects.filter({ $0.objectID != workout.objectID })
        reloader?.reload()
    }
}
