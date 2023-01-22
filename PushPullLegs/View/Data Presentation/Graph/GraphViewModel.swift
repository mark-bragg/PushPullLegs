//
//  GraphViewModel.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 5/27/21.
//  Copyright © 2021 Mark Bragg. All rights reserved.
//

import Foundation
import UIKit

class GraphViewModel: NSObject, ReloadProtocol {
    var yValues = [CGFloat]()
    var xValues = [String]()
    var dataManager: DataManager?
    var hasEllipsis: Bool = false
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter
    }()
    var startDate: Date?
    var endDate: Date?
    var earliestPossibleDate: Date? {
        nil
    }
    var lastPossibleDate: Date? {
        nil
    }
    private(set) var type: ExerciseType
    
    init(dataManager: DataManager, type: ExerciseType) {
        self.type = type
        super.init()
        self.dataManager = dataManager
        reload()
    }
    
    func title() -> String {
        ""
    }
    
    func pointCount() -> Int {
        xValues.count
    }
    
    func dates() -> [String]? {
        guard pointCount() > 0 else { return nil }
        return xValues
    }
    
    func volumes() -> [CGFloat]? {
        guard pointCount() > 0 else { return nil }
        return yValues
    }
    
    func reload() {
        yValues.removeAll()
        xValues.removeAll()
    }
    
    func refreshWithDates(_ startDate: Date, _ endDate: Date) {
        self.startDate = startDate
        self.endDate = endDate
        reload()
    }
    
    func data() -> GraphData? {
        nil
    }
    
    func getExerciseNames() -> [String] {
        guard let temps = TemplateManagement().exerciseTemplates(withType: type) else { return [] }
        return temps.filter {
            $0.name != nil && $0.name != ""
        }.map {
            $0.name ?? ""
        }.filter {
            ExerciseDataManager().exists(name: $0)
        }
    }
}
