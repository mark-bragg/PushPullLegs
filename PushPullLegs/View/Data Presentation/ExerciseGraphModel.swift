//
//  ExerciseGraphModel.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/27/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit
import Charts

struct ExerciseGraphData: Equatable {
    static func == (lhs: ExerciseGraphData, rhs: ExerciseGraphData) -> Bool {
        var setsAreEqual = true
        for set in lhs.sets {
            if !rhs.sets.contains(where: { (setData) -> Bool in
                return setData.weight == set.weight && setData.duration == set.duration && setData.reps == set.reps
            }) { setsAreEqual = false; break }
        }
        return setsAreEqual && lhs.date == rhs.date
    }
    
    let sets: [(weight: Double, reps: Int, duration: Int)]
    let date: Date
}

protocol ExerciseGraphModelDelegate: NSObject {
    func exerciseGraphModel(_ graphModel: ExerciseGraphModel, dataPoints: [String], values: [Double])
}

class ExerciseGraphModel: NSObject, IAxisValueFormatter {
    
    // TODO: implement getYear() (displayed above the graph)
    
    private var exerciseDataManager: ExerciseDataManager
    private var templateManagement: TemplateManagement
    var selectedExercises: [Exercise]?
    private var selectedExerciseDateStrings: [String]!
    private let sorter: ((Exercise, Exercise) -> Bool) = { $0.workout!.dateCreated!.compare($1.workout!.dateCreated!) == .orderedAscending }
    private var _filter: ((Exercise, Exercise) -> Bool)?
    weak var delegate: ExerciseGraphModelDelegate?
    let dateFormatter = DateFormatter()
    
    init(withCoreDataManager manager: CoreDataManagement = CoreDataManager.shared) {
        exerciseDataManager = ExerciseDataManager(backgroundContext: manager.backgroundContext)
        templateManagement = TemplateManagement(coreDataManager: manager)
        dateFormatter.dateFormat = "MM/dd"
        super.init()
    }
    
    func filter() -> ((Exercise, Exercise) -> Bool)? {
        return _filter
    }
    
    func setFilter(_ filter: ((Exercise, Exercise) -> Bool)?) {
        _filter = filter
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return selectedExerciseDateStrings[Int(value)]
    }
    
    func getExerciseNames() -> [String] {
        var templates = [ExerciseTemplate]()
        for type in [ExerciseType.push, ExerciseType.pull, ExerciseType.legs] {
            if let templatesToAdd = templateManagement.exerciseTemplates(withType: type) {
                templates.append(contentsOf: templatesToAdd)
            }
        }
        return templates.map( { $0.name! } )
    }
    
    func select(name: String) {
        selectedExercises = exerciseDataManager.exercises(withName: name).sorted(by: sorter)
        selectedExerciseDateStrings = getSelectedExerciseDates()?.map({ dateFormatter.string(from: $0) })
        setupChartData()
    }
    
    func getSelectedExerciseDates() -> [Date]? {
        if let selectedExercises = selectedExercises {
            return selectedExercises.map({ $0.workout!.dateCreated! })
        }
        return nil
    }
    
    func getSelectedExerciseName() -> String? {
        if let selectedExercises = selectedExercises {
            return selectedExercises.first!.name!
        }
        return nil
    }
    
    func getSelectedExerciseData() -> [ExerciseGraphData]? {
        if let selectedExercises = selectedExercises {
            return selectedExercises.map { (exercise) -> ExerciseGraphData in
                var setData = [(Double, Int, Int)]()
                for set in exercise.sets!.array as! [ExerciseSet] {
                    setData.append((set.weight, Int(set.reps), Int(set.duration)))
                }
                return ExerciseGraphData(sets: setData, date: exercise.workout!.dateCreated!)
            }
        }
        return nil
    }
    
    private func setupChartData() {
        guard let delegate = delegate, let (dataPoints, values) = dataPointsAndValues() else {
            return
        }
        delegate.exerciseGraphModel(self, dataPoints: dataPoints, values: values)
    }
    
    func dataPointsAndValues() -> ([String], [Double])? {
        return nil
    }
}

class WeightExerciseGraphModel: ExerciseGraphModel {
    
    override func dataPointsAndValues() -> ([String], [Double])? {
        guard let data = getSelectedExerciseData() else { return nil }
        
        var dataPoints = [String]()
        var values = [Double]()
        
        for dat in data {
            var maxWeight = 0.0
            for set in dat.sets {
                if set.weight > maxWeight { maxWeight = set.weight }
            }
            values.append(maxWeight)
            dataPoints.append(dateFormatter.string(from: dat.date))
        }
        return (dataPoints, values)
    }
    
}


