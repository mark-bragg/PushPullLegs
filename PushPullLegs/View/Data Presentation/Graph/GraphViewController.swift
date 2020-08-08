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

    var viewModel: WorkoutGraphViewModel!
    weak var containerView: UIView!
    weak var graphView: GraphView!
    weak var titleLabel: UILabel!
    weak var dateLabel: UILabel!
    weak var volumeLabel: UILabel!
    var isInteractive = true
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: remove this line
        viewModel = WorkoutGraphViewModel(type: .push)
        // TODO: you better remove it!
        
        addViews()
        bind()
    }
    
    func addViews() {
        addContainerView()
        addGraphView()
        addLabels()
    }
    
    func addContainerView() {
        let containerView = UIView(frame: view.frame)
        view.addSubview(containerView)
        self.containerView = containerView
    }
    
    func addGraphView() {
        let graph = GraphView(frame: CGRect(x: view.frame.width * 0.05, y: view.frame.height * 0.245, width: view.frame.width * 0.95, height: view.frame.height * 0.695))
        graph.dataSource = self
        containerView.addSubview(graph)
        containerView.backgroundColor = PPLColor.textBlue
        view.addSubview(graph)
        graphView = graph
        graph.backgroundColor = .clear
    }
    
    private func addLabels() {
        self.titleLabel = label(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 65))
        self.titleLabel.text = viewModel.title()
        self.dateLabel = label(frame: CGRect(x: 0, y: 65, width: view.frame.width, height: 65))
        self.volumeLabel = label(frame: CGRect(x: 0, y: 130, width: view.frame.width, height: 65))
    }
    
    func bind() {
        graphView.$index.sink { [weak self] index in
            guard let self = self else { return }
            self.updateLabels(index)
        }.store(in: &cancellables)
    }
    
    func updateLabels(_ index: Int?) {
        if let index = index, let date = viewModel.date(index), let volume = viewModel.volume(index) {
            dateLabel.text = date
            volumeLabel.text = "volume: \(volume)"
        } else {
            dateLabel.text = nil
            volumeLabel.text = nil
        }
        
    }
    
    func numberOfDataPoints() -> Int {
        return viewModel.pointCount()
    }
    
    func y(for index: Int) -> CGFloat {
        guard let volume = viewModel.volume(index) else { return 0 }
        return CGFloat(volume)
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
