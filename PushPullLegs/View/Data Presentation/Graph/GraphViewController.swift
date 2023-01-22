//
//  GraphViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 5/27/21.
//  Copyright © 2021 Mark Bragg. All rights reserved.
//

import UIKit
import Combine
import SwiftUI

class WorkoutGraphViewController2: UIViewController, GraphViewDelegate {
    var viewModel: GraphViewModel?
    var data: GraphData?
    var isInteractive = true
    private var frame: CGRect?
    
    init(type: ExerciseType, frame: CGRect? = nil) {
        super.init(nibName: nil, bundle: nil)
        viewModel = WorkoutGraphViewModel(dataManager: WorkoutDataManager(), type: type)
        self.frame = frame
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let viewModel else { return }
        data = viewModel.data()
        if let frame = frame {
            view.frame = frame
        }
        addGraphView()
        addRightBarButtonItem()
    }
    
    private func addGraphView() {
        guard let data else { return }
        let graphHostingController = UIHostingController(
            rootView:GraphView(data: data, delegate: self, height: frame?.height ?? 240, isInteractive: frame == nil)
        )
        graphHostingController.preferredContentSize = frame?.size ?? .zero
        graphHostingController.view.frame = frame ?? .zero
        addGraphChildViewController(graphHostingController)
    }
    
    private func addGraphChildViewController(_ vc: UIViewController) {
        addChild(vc)
        view.addSubview(vc.view)
        constrain(vc.view, toInsideOf: view)
        vc.didMove(toParent: self)
    }
    
    private func addRightBarButtonItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .refresh, target: self, action: #selector(refresh(_:)))
    }
    
    @objc
    func refresh(_ sender: Any?) {
        guard let newData = viewModel?.data() else { return }
        data?.refresh(newData)
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        coordinator.animate(alongsideTransition: { (context) in
//            self.reload()
            self.view.setNeedsLayout()
            self.view.setNeedsDisplay()
        })
        
    }
    
    private var windowInterfaceOrientation: UIInterfaceOrientation? {
        PPLSceneDelegate.shared?.window?.windowScene?.interfaceOrientation
    }
    
    func didSelectExercise(name: String) {
        let names = exerciseNames().filter { $0 != name }
        let exerciseViewModel = ExerciseGraphViewModel(name: name, otherNames: names, type: type())
        guard let data = exerciseViewModel.data() else { return }
        self.data?.name = data.name
        self.data?.points = data.points
        self.data?.exerciseNames = names
    }
    
    func exerciseNames() -> [String] {
        var names = [String]()
        if let vm = viewModel as? WorkoutGraphViewModel {
            names = vm.getExerciseNames()
        }
        return names
    }
    
    func type() -> ExerciseType {
        (viewModel as? WorkoutGraphViewModel)?.type ?? .push
    }
}

extension UIView {
    func updateHeight(_ height: CGFloat) {
        frame = CGRect(origin: frame.origin, size: CGSize(width: frame.width, height: height))
    }
}
