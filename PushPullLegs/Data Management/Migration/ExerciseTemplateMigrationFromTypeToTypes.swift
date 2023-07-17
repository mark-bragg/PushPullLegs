//
//  ExerciseTemplateMigrationFromTypeToTypes.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 7/1/23.
//  Copyright © 2023 Mark Bragg. All rights reserved.
//

import Foundation
import CoreData

enum MigrationErrorV2: Error {
    case failedToCreateNewExerciseTemplate,
         failedToGetSourceInstanceType,
         failedToAddNewExerciseType,
         failedToGetDestinationEntityName
}

// MARK: Note to Self -
/// you cannot use the actual types in the code. all of the code has to be `NSManagedObject`
class ExerciseTemplateMigrationFromTypeToTypes: NSEntityMigrationPolicy {
    override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        // Create a new ExerciseTemplate instance in the destination context.
        guard let destinationEntityName = mapping.destinationEntityName
        else { throw MigrationErrorV2.failedToGetDestinationEntityName }
        
        let dInstance = NSEntityDescription.insertNewObject(forEntityName: destinationEntityName, into: manager.destinationContext)
        
        // update original values that didn't change in the new model version
        let sourceKeys = sInstance.entity.attributesByName.keys.map { String($0) }
        let sourceValues = sInstance.dictionaryWithValues(forKeys: sourceKeys)
        
        for key in dInstance.entity.attributesByName.keys {
            guard let value = sourceValues[key] else { continue }
            if let _ = value as? NSNull { continue }
            dInstance.setValue(value, forKey: key)
        }

        // Get the type string from the source ExerciseTemplate.
        guard let typeString = sInstance.value(forKey: "type") as? String
        else { throw MigrationErrorV2.failedToGetSourceInstanceType }

        // Check if the type already exists; create it if it doesn't.
        var type: NSManagedObject?
        let req = NSFetchRequest<NSManagedObject>(entityName: EntityName.exerciseType.rawValue)
        if let types = try? manager.destinationContext.fetch(req) {
            if let indexOfType = types.firstIndex(where: { ($0.value(forKey: "name") as? String) ?? "" == typeString }) {
                type = types[indexOfType]
            } else {
                type = addNewType(typeString, manager)
            }
        } else {
            type = addNewType(typeString, manager)
        }
        guard let type else { throw MigrationErrorV2.failedToAddNewExerciseType }

        // Add the new Type instance to the types relationship of the new ExerciseTemplate.
        dInstance.setValue(NSSet(object: type), forKey: "types")

        // Associate the source and destination instances.
        manager.associate(sourceInstance: sInstance, withDestinationInstance: dInstance, for: mapping)
    }
    
    private func addNewType(_ typeString: String, _ manager: NSMigrationManager) -> NSManagedObject {
        // Create a new Type instance for the type string.
        let newType = NSEntityDescription.insertNewObject(forEntityName: EntityName.exerciseType.rawValue, into: manager.destinationContext)
        newType.setValue(typeString, forKey: "name")
        return newType
    }
}
