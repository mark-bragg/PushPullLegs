//
//  PPLGraphViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/26/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit
import Charts

class PPLGraphViewController: UIViewController {

    weak var barChartView: BarChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let bc = BarChartView(frame: view.frame)
        view.addSubview(bc)
        barChartView = bc
        barChartView.noDataText = "AAAAAAARRRRRGGGGGHHHHHHHHHH!"
        setupGraph()
    }
    
    func setupGraph() {
        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        var dataEntries: [BarChartDataEntry] = []
        let exercises = ExerciseDataManager().exercises(withName: "pulleys")
        for i in 0..<exercises.count {
            let volume = calculateVolume(exercises[i])
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(volume))
            dataEntries.append(dataEntry)
        }
                
        let chartDataSet = [BarChartDataSet(entries: dataEntries, label: "pulleys performed")]
        let chartData = BarChartData(dataSets: chartDataSet)
        barChartView.data = chartData
    }
    
    func calculateVolume(_ exercise: Exercise) -> Int {
        return Int.random(in: 5...100)
    }

}
