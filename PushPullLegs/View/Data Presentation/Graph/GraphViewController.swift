//
//  GraphViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 8/3/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit
import Combine

class GraphViewController: UIViewController {

    var viewModel: WorkoutGraphViewModel!
    weak var containerView: UIView!
    weak var graphView: GraphView!
    weak var titleLabel: UILabel!
    weak var dateLabel: UILabel!
    weak var volumeLabel: UILabel!
    var isInteractive = true
    private var cancellables: Set<AnyCancellable> = []
    private var padding: CGFloat {
        get {
            return view.frame.width * 0.05
        }
    }
    private var frame: CGRect?
    weak var labelStack: UIStackView!
    
    init(type: ExerciseType, frame: CGRect? = nil) {
        super.init(nibName: nil, bundle: nil)
        viewModel = WorkoutGraphViewModel(type: type)
        self.frame = frame
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let frame = frame {
            view.frame = frame
        }
        view.backgroundColor = PPLColor.grey
        addViews()
        if isInteractive {
            bind()
        }
    }
    
    var needConstraints = true
    override func viewDidLayoutSubviews() {
        if needConstraints, let superview = view.superview {
            needConstraints = false
            view.translatesAutoresizingMaskIntoConstraints = false
            view.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
            view.leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
            view.trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
        }
    }
    
    func addViews() {
        addContainerView()
        addLabels()
        addGraphView()
    }
    
    func addContainerView() {
        let containerView = UIView(frame: view.frame)
        containerView.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        view.addSubview(containerView)
        self.containerView = containerView
    }
    
    func addGraphView() {
        let graph = GraphView(frame: CGRect(x: padding, y: yForGraph(), width: view.frame.width - padding * 2, height: heightForGraph()))
        containerView.addSubview(graph)
        containerView.backgroundColor = PPLColor.textBlue
        view.addSubview(graph)
        if isInteractive {
            graph.setInteractivity()
        }
        graphView = graph
        graph.backgroundColor = .clear
        graph.yValues = viewModel.volumes()
    }
    
    func yForGraph() -> CGFloat {
        return labelStack.frame.origin.y + labelStack.frame.height
    }
    
    func heightForGraph() -> CGFloat {
        return view.frame.height - yForGraph()
    }
    
    private func addLabels() {
        var labels = [UILabel]()
        titleLabel = label()
        titleLabel.text = viewModel.title()
        titleLabel.sizeToFit()
        titleLabel.textColor = .black
        labels.append(titleLabel)
        if isInteractive {
            dateLabel = label()
            dateLabel.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: titleLabel.frame.height)
            labels.append(dateLabel)
            volumeLabel = label()
            volumeLabel.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: titleLabel.frame.height)
            labels.append(volumeLabel)
        }
        let labelStack = UIStackView(arrangedSubviews: labels)
        labelStack.axis = .vertical
        labelStack.distribution = .fillEqually
        labelStack.frame = CGRect(x: 0, y: 8, width: view.frame.width, height: titleLabel.frame.height * CGFloat(labels.count))
        view.addSubview(labelStack)
        self.labelStack = labelStack
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
            volumeLabel.text = "volume: \(volume)"
        } else {
            dateLabel.text = nil
            volumeLabel.text = nil
        }
        
    }
    
    func label() -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 32, weight: .medium)
        view.addSubview(label)
        label.numberOfLines = 1
        label.textColor = .white
        return label
    }

}
