//
//  GraphData.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 1/22/23.
//  Copyright © 2023 Mark Bragg. All rights reserved.
//

import Combine

class GraphData: ObservableObject {
    @Published var name: String
    @Published var points: [GraphDataPoint] {
        didSet { updateDelineatedPoints() }
    }
    @Published var delineatedPoints: [GraphDataPoint] = []
    @Published var exerciseNames: [String]
    @Published var startDate: Date {
        didSet { updateDelineatedPoints() }
    }
    @Published var endDate: Date {
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
    
    func refresh(_ newData: GraphData) {
        name = newData.name
        points = newData.points
        updateDelineatedPoints()
        exerciseNames = newData.exerciseNames
        let endDate = points.last?.date ?? .now
        let startDate = Calendar.current.date(byAdding: DateComponents(day: -30), to: endDate) ?? endDate
        self.endDate = endDate
        self.startDate = startDate
    }
}

struct GraphDataPoint: Identifiable {
    var id = UUID()
    var date: Date
    var volume: Double
    var normalVolume: Double = 0
}
