//
//  GraphViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 5/27/21.
//  Copyright © 2021 Mark Bragg. All rights reserved.
//

import UIKit
import Combine

class GraphViewController: UIViewController {
    var viewModel: GraphViewModel!
    weak var containerView: UIView!
    weak var graphView: GraphView!
    weak var dateLabel: UILabel!
    weak var volumeLabel: UILabel!
    weak var labelStack: UIStackView!
    var firstLoad = true
    private var cancellables: Set<AnyCancellable> = []
    var padding: CGFloat { view.frame.width * 0.05 }
    var needConstraints = true
    var isInteractive = true
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard firstLoad else { return }
        let lbl = UILabel()
        lbl.text = viewModel.title()
        lbl.font = titleLabelFont()
        navigationItem.titleView = lbl
        firstLoad = false
        addViews()
        if isInteractive {
            bind()
        }
    }
    
    func reload() {
        viewModel.reload()
        graphView.removeFromSuperview()
        addGraphView()
    }
    
    func yForGraph() -> CGFloat {
        return labelStack.frame.origin.y + labelStack.frame.height
    }
    
    func heightForGraph() -> CGFloat {
        return containerView.frame.height - yForGraph() - padding
    }
    
    func bind() {
        graphView.$index.sink { [weak self] index in
            guard let self = self else { return }
            self.updateLabels(index)
        }.store(in: &cancellables)
    }
    
    func updateLabels(_ index: Int?) {
        if let index = index, let date = viewModel.dates()?[index], let volume = viewModel.volumes()?[index] {
            dateLabel.text = date
            volumeLabel.text = "volume: \(volume)".trimDecimalDigitsToTwo()
        } else {
            dateLabel.text = nil
            volumeLabel.text = nil
        }
        
    }
    
    func addViews() {
        addContainerView()
        addLabels()
        addGraphView()
    }
    
    func addContainerView() {
        let containerView = UIView(frame: view.frame)
        view.addSubview(containerView)
        self.containerView = containerView
        addConstraints()
    }
    
    func addConstraints() {
        if needConstraints, let view = isInteractive ? containerView : self.view, let superview = view.superview {
            needConstraints = false
            view.translatesAutoresizingMaskIntoConstraints = false
            let insets = superview.safeAreaInsets
            if !isInteractive {
                view.topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top).isActive = true
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -insets.bottom).isActive = true
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
                containerView.translatesAutoresizingMaskIntoConstraints = false
                containerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1.0, constant: padding).isActive = true
                containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9, constant: 0).isActive = true
                containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
                containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            } else {
                let guide = view.safeAreaLayoutGuide
                self.view.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
                self.view.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
                self.view.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
                view.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -insets.bottom).isActive = true
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
            }
            
        }
    }
    
    func addGraphView() {
        let graph = GraphView(frame: CGRect(x: padding, y: yForGraph(), width: containerView.frame.width - padding * 2, height: heightForGraph()))
        graph.smallDisplay = !isInteractive
        containerView.addSubview(graph)
        if isInteractive {
            graph.setInteractivity()
            graph.backgroundColor = .cellBackgroundBlue
            containerView.backgroundColor = .backgroundBlue
        } else {
            containerView.backgroundColor = .clear
            graph.translatesAutoresizingMaskIntoConstraints = false
            graph.topAnchor.constraint(equalTo: labelStack.bottomAnchor).isActive = true
            graph.widthAnchor.constraint(equalTo: containerView.widthAnchor, constant: -16).isActive = true
            graph.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20).isActive = true
            graph.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8).isActive = true
            graph.backgroundColor = .clear
        }
        graphView = graph
        graph.yValues = viewModel.volumes()
    }
    
    override func viewDidLayoutSubviews() {
        viewModel.reload()
        graphView.yValues = viewModel.volumes()
    }
    
    func addLabels() {
        var labels = [UILabel]()
        if !isInteractive {
            labels.append(titleLabel())
        } else {
            dateLabel = label()
            dateLabel.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 75)
            labels.append(dateLabel)
            volumeLabel = label()
            volumeLabel.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 75)
            labels.append(volumeLabel)
        }
        let labelStack = UIStackView(arrangedSubviews: labels)
        labelStack.axis = .vertical
        labelStack.distribution = .fillEqually
        labelStack.frame = CGRect(x: 0, y: 8, width: view.frame.width, height: 75 * CGFloat(labels.count))
        containerView.addSubview(labelStack)
        self.labelStack = labelStack
    }
    
    private func titleLabel() -> UILabel {
        let lbl = label()
        lbl.text = viewModel.title()
        lbl.sizeToFit()
        return lbl
    }
    
    func label() -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 32, weight: .medium)
        view.addSubview(label)
        label.numberOfLines = 1
        label.textColor = isInteractive ? .white : .pplTextBlue
        return label
    }
}
