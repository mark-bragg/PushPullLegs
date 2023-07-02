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
         failedToAddNewExerciseType
}

class ExerciseTemplateMigrationFromTypeToTypes: NSEntityMigrationPolicy {
    override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        // Create a new ExerciseTemplate instance in the destination context.
        guard let newExerciseTemplate = NSEntityDescription.insertNewObject(forEntityName: "ExerciseTemplate", into: manager.destinationContext) as? ExerciseTemplate
        else { throw MigrationErrorV2.failedToCreateNewExerciseTemplate }

        // Get the type string from the source ExerciseTemplate.
        guard let typeString = sInstance.value(forKey: "type") as? String
        else { throw MigrationErrorV2.failedToGetSourceInstanceType }

        // Check if the type already exists; create it if it doesn't.
        var type: ExerciseType?
        let req = ExerciseType.fetchRequest()
        if let types = try? manager.destinationContext.fetch(req){
            if let indexOfType = types.firstIndex(where: { $0.name == typeString }) {
                type = types[indexOfType]
            } else {
                type = addNewType(typeString, manager)
            }
        } else {
            type = addNewType(typeString, manager)
        }
        guard let type else { throw MigrationErrorV2.failedToAddNewExerciseType }

        // Add the new Type instance to the types relationship of the new ExerciseTemplate.
        newExerciseTemplate.addToTypes(type)

        // Associate the source and destination instances.
        manager.associate(sourceInstance: sInstance, withDestinationInstance: newExerciseTemplate, for: mapping)
    }
    
    private func addNewType(_ typeString: String, _ manager: NSMigrationManager) -> ExerciseType? {
        // Create a new Type instance for the type string.
        let newType = NSEntityDescription.insertNewObject(forEntityName: "Type", into: manager.destinationContext) as? ExerciseType
        newType?.name = typeString
        return newType
    }
}
