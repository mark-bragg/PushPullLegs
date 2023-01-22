//
//  GraphChart.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 1/22/23.
//  Copyright © 2023 Mark Bragg. All rights reserved.
//

import SwiftUI
import Charts

struct GraphChart: View {
    @ObservedObject var data: GraphData
    var body: some View {
        Chart {
            ForEach(data.delineatedPoints) { datum in
                LineMark(
                    x: .value("date", datum.date),
                    y: .value("volume", datum.normalVolume)
                )
                .interpolationMethod(.stepStart)
            }
        }
        .previewDisplayName(data.name)
        .monospacedDigit()
        .chartYScale(domain: .automatic(includesZero: false), range: .plotDimension)
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartOverlay { proxy in
            GeometryReader { nthGeometryItem in
                Rectangle().fill(.clear).contentShape(Rectangle())
                    .gesture(
                        SpatialTapGesture()
                            .onEnded { value in
                                let element = findElement(location: value.location, proxy: proxy, geometry: nthGeometryItem)
                                if data.selectedElement?.day == element?.day {
                                    // If tapping the same element, clear the selection.
                                    data.selectedElement = nil
                                } else {
                                    data.selectedElement = element
                                }
                            }
                            .exclusively(
                                before: DragGesture()
                                    .onChanged { value in
                                        data.selectedElement = findElement(location: value.location, proxy: proxy, geometry: nthGeometryItem)
                                    }
                            )
                    )
            }
        }
    }
    
    func findElement(location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) -> (day: Date, volume: Double)? {
        let relativeXPosition = location.x - geometry[proxy.plotAreaFrame].origin.x
        let points = data.points
        if let date = proxy.value(atX: relativeXPosition) as Date? {
            // Find the closest date element.
            var minDistance: TimeInterval = .infinity
            var index: Int? = nil
            for datum in points.indices {
                let nthSalesDataDistance = points[datum].date.distance(to: date)
                if abs(nthSalesDataDistance) < minDistance {
                    minDistance = abs(nthSalesDataDistance)
                    index = datum
                }
            }
            if let index = index {
                return (points[index].date, points[index].volume)
            }
        }
        return nil
    }
}
