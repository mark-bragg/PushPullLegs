//
//  PPLGraphViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/26/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit
import Charts

class PPLGraphViewController: UIViewController, DropdownTableViewControllerDelegate, ExerciseGraphModelDelegate {

    @IBOutlet weak var lineChartView: LineChartView!
    var model: ExerciseGraphModel
    @IBOutlet weak var dropdown: UILabel!
    
    init(withGraphModel: ExerciseGraphModel) {
        model = WeightExerciseGraphModel()
        super.init(nibName: nil, bundle: nil)
        model.delegate = self
    }
    
    required init?(coder: NSCoder) {
        model = WeightExerciseGraphModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lineChartView.noDataText = "Select Exercise"
        lineChartView.xAxis.valueFormatter = model
        setupDropdown()
    }
    
    func setupDropdown() {
        dropdown.text = "Select Exercise"
        dropdown.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showDropdown(_:))))
        dropdown.isUserInteractionEnabled = true
    }
    
    @objc func showDropdown(_ sender: Any?) {
        let dropdownVC = DropdownTableViewController()
        dropdownVC.delegate = self
        dropdownVC.modalPresentationStyle = .popover
        dropdownVC.preferredContentSize = CGSize(width: lineChartView.frame.width - 40, height: lineChartView.frame.height - 40)
        dropdownVC.popoverPresentationController?.sourceView = dropdown
        dropdownVC.popoverPresentationController?.sourceRect = dropdown.frame
        dropdownVC.cellTitles = model.getExerciseNames()
        present(dropdownVC, animated: true, completion: nil)
    }
    
    func exerciseGraphModel(_ graphModel: ExerciseGraphModel, dataPoints: [String], values: [Double]) {
        setChart(dataPoints: dataPoints, values: values)
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: values[i], data: dataPoints[i])
            dataEntries.append(dataEntry)
        }
        
        let lineChartDataSet = LineChartDataSet(entries: dataEntries, label: "Maximum Weight")
        let lineChartData = LineChartData(dataSet: lineChartDataSet)
        lineChartView.data = lineChartData
//        lineChartView.setLabel
        lineChartView.maxVisibleCount = values.count
    }
    
    func dropdownController(_ dropdownController: DropdownTableViewController, didSelectName name: String) {
        dropdown.text = name
        dismiss(animated: true, completion: { self.model.select(name: name) })
    }

}

protocol DropdownTableViewControllerDelegate: NSObject {
    func dropdownController(_ dropdownController: DropdownTableViewController, didSelectName name: String)
}

class DropdownTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    weak var tableView: UITableView!
    weak var delegate: DropdownTableViewControllerDelegate?
    private var rowCount: Int!
    var cellTitles = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rowCount = cellTitles.count
        let tblv = UITableView()
        view.insertSubview(tblv, at: 0)
        tblv.layer.cornerRadius = 10.0
        tableView = tblv
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 44
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.frame = view.frame
    }
    
    func height() -> CGFloat {
        return view.frame.height
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = cellTitles[indexPath.row]
        cell.textLabel?.textAlignment = .center
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.dropdownController(self, didSelectName: cellTitles[indexPath.row])
    }
}
