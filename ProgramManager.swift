//
//  ProgramManager.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 2/17/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation
import CoreData

class ProgramManager {
    
    private var programManager: DataManager!
    
    init(backgroundContext: NSManagedObjectContext = CoreDataManager.shared.backgroundContext) {
        programManager = DataManager(backgroundContext: backgroundContext)
        programManager.entityName = ProgramEntityName
    }
    
    func addProgram(name: String, workoutNames: [String]) throws {
        if programManager.exists(name: name) {
            throw ProgramError.duplicateProgram
        }
        programManager.create(name: name, keyValuePairs: ["workoutNames": workoutNames])
    }
    
    func program(name: String) -> Program? {
        programManager.getProgram(name: name)
    }
    
    func update(_ program: Program, workoutNames: [String]) {
        programManager.update(program, keyValuePairs: ["workoutNames": workoutNames])
    }
    
}

extension DataManager {
    func getProgram(name: String) -> Program? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: ProgramEntityName)
        request.predicate = NSPredicate(format: "name == %@", argumentArray: [name])
        
        guard let programs = try? self.backgroundContext.fetch(request) else {
            // handle error: object doesn't exist
            return nil
        }
        if programs.count > 1 {
            // handle error: multiple programs in db with same name
        }
        return programs.first as? Program
    }
}
