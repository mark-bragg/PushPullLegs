//
//  GraphData.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 1/22/23.
//  Copyright © 2023 Mark Bragg. All rights reserved.
//

import Combine

class GraphData: ObservableObject {
    var name: String
    private(set) var points: [GraphDataPoint] {
        didSet { updateDelineatedPoints() }
    }
    var delineatedPoints: [GraphDataPoint] = []
    var exerciseNames: [String]
    var startDate: Date {
        didSet { updateDelineatedPoints() }
    }
    var endDate: Date {
        didSet { updateDelineatedPoints() }
    }
    @Published var selectedElement: (day: Date, volume: Double)? = nil
    
    init(name: String, points: [GraphDataPoint], exerciseNames: [String]) {
        self.name = name
        self.points = points
        self.exerciseNames = exerciseNames
        let endDate = points.last?.date ?? .now
        let startDate = Calendar.current.date(byAdding: DateComponents(day: -30), to: endDate) ?? endDate
        self.endDate = endDate
        self.startDate = startDate
        updateDelineatedPoints()
    }
    
    private func updateDelineatedPoints() {
        delineatedPoints = points.filter { point in
            point.date >= startDate && point.date <= endDate
        }
        selectedElement = nil
    }
}

struct GraphDataPoint: Identifiable {
    var id = UUID()
    var date: Date
    var volume: Double
}
