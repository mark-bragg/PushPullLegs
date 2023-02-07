//
//  DataManager.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 1/28/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation
import CoreData

class DataManager {
    var creation: Any?
    let context: NSManagedObjectContext
    var entityName: EntityName?
    var entityNameString: String? {
        entityName?.rawValue
    }
    weak var deletionObserver: DeletionObserver?
    init(context: NSManagedObjectContext = CoreDataManager.shared.mainContext) {
        self.context = context
    }
    
    func delete(_ object: NSManagedObject) {
        let objectId = object.objectID
        context.performAndWait {
            if let objectInContext = try? context.existingObject(with: objectId) {
                context.delete(objectInContext)
                do {
                    try context.save()
                    creation = nil
                    deletionObserver?.objectDeleted(objectInContext)
                } catch {
                    
                }
            }
        }
    }
    
    func exists(name: String) -> Bool {
        guard let entityNameString else { return false }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityNameString)
        request.predicate = PPLPredicate.nameIsEqualTo(name)
        do {
            let result = try context.fetch(request)
            return result.count > 0
        } catch {
            // TODO: handle error
        }
        return false
    }
    
    func create(name: String?, keyValuePairs pairs: [String: Any] = [:]) {
        guard let entityNameString else { return }
        context.performAndWait {
            let object = NSEntityDescription.insertNewObject(forEntityName: entityNameString, into: context)
            if let name = name {
                object.setValue(name, forKey: DBAttributeKey.name)
            }
            if pairs.count > 0 {
                for (key, value) in pairs {
                    object.setValue(value, forKey: key)
                }
            }
            do {
                try context.save()
                creation = context.registeredObject(for: object.objectID)
            } catch {
                print(error)
            }
        }
    }
    
    func fetch(_ object: NSManagedObject?) -> Any? {
        guard let objectID = object?.objectID else {
            return nil
        }
        return fetch(objectID)
    }
    
    func fetch(_ objectId: NSManagedObjectID) -> Any? {
        return try? context.existingObject(with: objectId)
    }
    
    func update(_ object: NSManagedObject, keyValuePairs pairs: [String: Any]) {
        context.performAndWait {
            guard pairs.count > 0 else {
                // error
                return
            }
            for (key, value) in pairs {
                object.setValue(value, forKey: key)
            }
            do {
                try context.save()
            }
            catch {
                print(error)
            }
        }
    }
}
