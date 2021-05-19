//
//  DatabaseViewModel.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 3/23/21.
//  Copyright © 2021 Mark Bragg. All rights reserved.
//

import Foundation
import CoreData

@objc protocol DeletionObserver {
    @objc func objectDeleted(_ object: NSManagedObject)
}

@objc protocol DatabaseDeletionAlertModel {
    @objc var objectToDelete: IndexPath? { get set }
    @objc func deletionAlertTitle() -> String
    @objc func deletionAlertMessage() -> String?
    @objc func deleteDatabaseObject()
    @objc func addObjectsWithNames(_ names: [String])
}

class DatabaseViewModel: NSObject, PPLTableViewModel, DeletionObserver {
    
    var objectToDelete: IndexPath?
    var dataManager: DataManager!
    var dbObjects = [NSManagedObject]()
    weak var deletionObserver: DeletionObserver?
    
    func rowCount(section: Int) -> Int {
        0
    }
    
    func title(indexPath: IndexPath) -> String? {
        nil
    }
    
    func delete(indexPath: IndexPath) {
        dataManager.delete(dbObjects[indexPath.row])
    }
    
    // MARK: DatabaseDeletionAlertModel
    func deletionAlertTitle() -> String {
        "Are you sure?"
    }
    
    func deletionAlertMessage() -> String? {
        nil
    }
    
    func deleteDatabaseObject() {
        guard let indexPath = objectToDelete else { return }
        delete(indexPath: indexPath)
    }
    
    func refresh() {
        // no op
    }
    
    func objectDeleted(_ object: NSManagedObject) {
        // no op
    }
    
    func addObjectsWithNames(_ names: [String]) {
        // no op
    }
}
