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
    let backgroundContext: NSManagedObjectContext
    var entityName: EntityName!
    weak var deletionObserver: DeletionObserver?
    init(backgroundContext: NSManagedObjectContext = CoreDataManager.shared.backgroundContext) {
        self.backgroundContext = backgroundContext
    }
    
    func delete(_ object: NSManagedObject) {
        let objectId = object.objectID
        backgroundContext.performAndWait {
            if let objectInContext = try? backgroundContext.existingObject(with: objectId) {
                backgroundContext.delete(objectInContext)
                do {
                    try backgroundContext.save()
                    creation = nil
                    deletionObserver?.objectDeleted(objectInContext)
                } catch {
                    
                }
            }
        }
    }
    
    func exists(name: String) -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityNameString())
        request.predicate = PPLPredicate.nameIsEqualTo(name)
        do {
            let result = try backgroundContext.fetch(request)
            return result.count > 0
        } catch {
            // TODO: handle error
        }
        return false
    }
    
    func create(name: String?, keyValuePairs pairs: [String: Any] = [:]) {
        backgroundContext.performAndWait {
            let object = NSEntityDescription.insertNewObject(forEntityName: entityNameString(), into: backgroundContext)
            if let name = name {
                object.setValue(name, forKey: PPLObjectKey.name)
            }
            if pairs.count > 0 {
                for (key, value) in pairs {
                    object.setValue(value, forKey: key)
                }
            }
            do {
                try backgroundContext.save()
                creation = backgroundContext.registeredObject(for: object.objectID)
            } catch {
                print(error)
            }
        }
    }
    
    func fetch(_ object: NSManagedObject) -> Any? {
        fetch(object.objectID)
    }
    
    func fetch(_ objectId: NSManagedObjectID) -> Any? {
        return try? backgroundContext.existingObject(with: objectId)
    }
    
    func update(_ object: NSManagedObject, keyValuePairs pairs: [String: Any]) {
        backgroundContext.performAndWait {
            guard pairs.count > 0 else {
                // error
                return
            }
            for (key, value) in pairs {
                object.setValue(value, forKey: key)
            }
            do {
                try backgroundContext.save()
            }
            catch {
                print(error)
            }
        }
    }
    
    func entityNameString() -> String {
        return entityName.rawValue
    }
}
