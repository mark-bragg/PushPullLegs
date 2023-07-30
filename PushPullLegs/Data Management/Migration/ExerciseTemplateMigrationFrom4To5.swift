//
//  ExerciseTemplateMigrationFrom4To5.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 7/29/23.
//  Copyright © 2023 Mark Bragg. All rights reserved.
//

import Foundation

//override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
//    // Create a new ExerciseTemplate instance in the destination context.
//    guard let destinationEntityName = mapping.destinationEntityName
//    else { throw MigrationErrorV2.failedToGetDestinationEntityName }
//
//    let dInstance = NSEntityDescription.insertNewObject(forEntityName: destinationEntityName, into: manager.destinationContext)
//
//    // update original values that didn't change in the new model version
//    let sourceKeys = sInstance.entity.attributesByName.keys.map { String($0) }
//    let sourceValues = sInstance.dictionaryWithValues(forKeys: sourceKeys)
//
//    for key in dInstance.entity.attributesByName.keys {
//        guard let value = sourceValues[key] else { continue }
//        if let _ = value as? NSNull { continue }
//        dInstance.setValue(value, forKey: key)
//    }
//
//    // Set the new instance isolation value to the same value as unilateral
//    if let isolation = sourceValues[DBAttributeKey.unilateral] as? Bool {
//        dInstance.setValue(isolation, forKey: DBAttributeKey.isolation)
//    }
//
//    // Associate the source and destination instances.
//    manager.associate(sourceInstance: sInstance, withDestinationInstance: dInstance, for: mapping)
//}
