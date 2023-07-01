//
//  ExerciseTemplateMigrationFromTypeToTypes.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 7/1/23.
//  Copyright © 2023 Mark Bragg. All rights reserved.
//

import Foundation
import CoreData

class ExerciseTemplateMigrationFromTypeToTypes: NSEntityMigrationPolicy {
    override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        // Create a new ExerciseTemplate instance in the destination context.
        let newExerciseTemplate = NSEntityDescription.insertNewObject(forEntityName: "ExerciseTemplate", into: manager.destinationContext)

        // Get the type string from the source ExerciseTemplate.
        guard let typeString = sInstance.value(forKey: "type") as? String else { return }

        // Check if the type already exists. If it does skip next step
//        let req = ExerciseType.fetchRequest()
        
        // Create a new Type instance for the type string.
        let newType = NSEntityDescription.insertNewObject(forEntityName: "Type", into: manager.destinationContext)
        newType.setValue(typeString, forKey: "name")

        // Add the new Type instance to the types relationship of the new ExerciseTemplate.
        newExerciseTemplate.setValue(NSSet(object: newType), forKey: "types")

        // Associate the source and destination instances.
        manager.associate(sourceInstance: sInstance, withDestinationInstance: newExerciseTemplate, for: mapping)
    }
}
