//
//  CoreDataHelpers.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 10/31/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation

typealias WorkoutSortDescriptor = NSSortDescriptor
extension WorkoutSortDescriptor {
    static let dateCreated = NSSortDescriptor(key: "dateCreated", ascending: false)
}

typealias PPLPredicate = NSPredicate
extension PPLPredicate {
    static func priorToDate(_ date: Date) -> PPLPredicate {
        NSPredicate(format: "dateCreated < %@", argumentArray: [date])
    }
    static func nameIsEqualTo(_ name: String) -> PPLPredicate {
        NSPredicate(format: "name == %@", argumentArray: [name])
    }
    static func typeIsEqualTo(_ type: ExerciseTypeName) -> PPLPredicate {
        NSPredicate(format: "type == %@", argumentArray: [type.rawValue])
    }
}

typealias DBAttributeKey = String
extension DBAttributeKey {
    static let name = "name"
    static let reps = "reps"
    static let weight = "weight"
    static let duration = "duration"
    static let type = "type"
    static let exerciseNames = "exerciseNames"
    static let unilateral = "unilateral"
}

let persistentContainerName = "PushPullLegs"
