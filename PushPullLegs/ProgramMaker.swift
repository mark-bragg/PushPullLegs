//
//  ProgramMaker.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 2/17/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation

struct ProgramStruct {
    init(name: String, workoutNames: [String], workoutTypes: [WorkoutType], exerciseNames: [[String]], exerciseTypes:[[ExerciseType]]) {
        assert(workoutNames.count == workoutTypes.count && workoutTypes.count == exerciseNames.count, "count of workout names/workout types/exercise names unequal in program creation")
        self.name = name
        self.workoutNames = workoutNames
        self.workoutTypes = workoutTypes
        self.exerciseNames = exerciseNames
        self.exerciseTypes = exerciseTypes
    }
    var name: String
    var workoutNames: [String]
    var workoutTypes: [WorkoutType]
    var exerciseNames: [[String]]
    var exerciseTypes: [[ExerciseType]]
}

class ProgramMaker {
    
    let manager: ProgramManager
    let support: TemplateManagement
    
    init(withManager manager: ProgramManager, support: TemplateManagement) {
        self.manager = manager
        self.support = support
    }
    
    // TODO: throw errors when program/template is already in db
    func makeProgram(program: ProgramStruct) throws {
        assert(program.workoutNames.count == program.exerciseNames.count, "count of workout names and exercise names unequal in program creation")
        try manager.addProgram(name: program.name, workoutNames: program.workoutNames)
        for i in 0..<program.workoutNames.count {
            try? support.addWorkoutTemplate(name: program.workoutNames[i], type: program.workoutTypes[i], exerciseNames: program.exerciseNames[i])
            for j in 0..<program.exerciseNames[i].count {
                try? support.addExerciseTemplate(name: program.exerciseNames[i][j], type: program.exerciseTypes[i][j])
            }
        }
    }
    
    
    
}
