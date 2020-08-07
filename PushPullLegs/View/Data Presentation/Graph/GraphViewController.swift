//
//  GraphViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 8/3/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit
import Combine

@objc protocol GraphViewDataSource {
    func numberOfDataPoints() -> Int
    func y(for index: Int) -> CGFloat
}

class GraphViewController: UIViewController, GraphViewDataSource {

    weak var graphView: GraphView!
    weak var titleLabel: UILabel!
    weak var dateLabel: UILabel!
    weak var volumeLabel: UILabel!
    private let formatter = DateFormatter()
    var isInteractive = true
    var dates = [Date]()
    var volumes: [CGFloat] = [
        1,1,1,1,2,2,3,3,3,4,6,6,6,5,6,7,7,8,8,9,9,9,9,9,9,8,8,8,9,10,10,10
    ]
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for _ in 0..<volumes.count {
            dates.append(Date())
        }
        let frame = view.frame
        let containerView = UIView(frame: frame)
        view.addSubview(containerView)
        let graph = GraphView(frame: CGRect(x: view.frame.width * 0.05, y: view.frame.height * 0.245, width: frame.width * 0.95, height: view.frame.height * 0.695))
        graph.dataSource = self
        containerView.addSubview(graph)
        containerView.backgroundColor = PPLColor.textBlue
        view.addSubview(graph)
        graphView = graph
        graph.backgroundColor = PPLColor.textBlue
        self.titleLabel = label(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 65))
        self.titleLabel.text = "Workout Name"
        self.dateLabel = label(frame: CGRect(x: 0, y: 65, width: view.frame.width, height: 65))
        self.volumeLabel = label(frame: CGRect(x: 0, y: 130, width: view.frame.width, height: 65))
        formatter.dateFormat = "MM/dd/YY"
        bind()
    }
    
    func bind() {
        graphView.$index.sink { [weak self] index in
            guard let self = self else { return }
            self.updateLabels(index)
        }.store(in: &cancellables)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func numberOfDataPoints() -> Int {
        return volumes.count
    }
    
    func y(for index: Int) -> CGFloat {
        return volumes[index]
    }
    
    func addGraphView() {
        
    }
    
    func updateLabels(_
        index: Int?) {
        if let index = index {
            dateLabel.text = formatter.string(from: dates[index])
            volumeLabel.text = "volume: \(volumes[index])"
        } else {
            dateLabel.text = nil
            volumeLabel.text = nil
        }
        
    }
    
    func label(frame: CGRect) -> UILabel {
        let label = UILabel(frame: frame)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 32, weight: .medium)
        view.addSubview(label)
        label.numberOfLines = 1
        label.textColor = .white
        return label
    }

}
