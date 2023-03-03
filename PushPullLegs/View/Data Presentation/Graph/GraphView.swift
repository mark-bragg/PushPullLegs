//
//  GraphView.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 1/22/23.
//  Copyright © 2023 Mark Bragg. All rights reserved.
//

import SwiftUI

@objc
protocol GraphViewDelegate: NSObjectProtocol {
    func didSelectExercise(name: String)
}

struct GraphView: View {
    @ObservedObject var viewModel: GraphViewModel
    private var data: GraphData { viewModel.data }
    @Environment(\.layoutDirection) var layoutDirection
    weak var delegate: GraphViewDelegate?
    var height: CGFloat
    var isInteractive: Bool

    var body: some View {
        VStack(alignment: .leading) {
            if !isInteractive {
                VStack(alignment: .leading) {
                    Text(data.name)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
            GraphChart(data: data)
                .frame(height: height)
        }
        .chartBackground { proxy in
            ZStack(alignment: .topLeading) {
                GeometryReader { nthGeoItem in
                    if let selectedElement = data.selectedElement {
                        let dateInterval = Calendar.current.dateInterval(of: .day, for: selectedElement.day)!
                        let startPositionX1 = proxy.position(forX: dateInterval.start) ?? 0
                        let startPositionX2 = proxy.position(forX: dateInterval.end) ?? 0
                        let midStartPositionX = (startPositionX1 + startPositionX2) / 2 + nthGeoItem[proxy.plotAreaFrame].origin.x

                        let lineX = layoutDirection == .rightToLeft ? nthGeoItem.size.width - midStartPositionX : midStartPositionX
                        let lineHeight = nthGeoItem[proxy.plotAreaFrame].maxY
                        let boxWidth: CGFloat = 150
                        let boxOffset = max(0, min(nthGeoItem.size.width - boxWidth, lineX - boxWidth / 2))

                        Rectangle()
                            .fill(.quaternary)
                            .frame(width: 2, height: lineHeight)
                            .position(x: lineX, y: lineHeight / 2)

                        VStack(alignment: .leading) {
                            Text("\(selectedElement.day, format: .dateTime.year().month().day())")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                            Text("\(selectedElement.volume, format: .number) Volume")
                                .font(.title2.bold())
                                .foregroundColor(.primary)
                        }
                        .frame(width: boxWidth, alignment: .leading)
                        .background {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.background)
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.quaternary.opacity(0.7))
                            }
                            .padding([.leading, .trailing], -8)
                            .padding([.top, .bottom], -4)
                        }
                        .offset(x: boxOffset)
                    }
                }
            }
        }
        if isInteractive {
            HStack {
                DatePicker("", selection: $viewModel.data.startDate, displayedComponents: [.date])
                    .labelsHidden()
                Spacer()
                DatePicker("", selection: $viewModel.data.endDate, displayedComponents: [.date])
                    .labelsHidden()
            }
            List {
                ForEach(data.exerciseNames) { name in
                    HStack {
                        Text(name)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        delegate?.didSelectExercise(name: name)
                        data.selectedElement = nil
                    }
                }
            }
        }
    }
}

extension String: Identifiable {
    public typealias ID = Int
    public var id: Int {
        return hash
    }
}
