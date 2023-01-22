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

class GraphViewController: UIViewController, GraphViewDelegate {
    var viewModel: GraphViewModel?
    var isInteractive = true
    private var height: CGFloat?
    
    init(type: ExerciseType, height: CGFloat? = nil) {
        super.init(nibName: nil, bundle: nil)
        viewModel = GraphViewModel(type: type)
        self.height = height
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGraphView()
        addRightBarButtonItem()
    }
    
    private func addGraphView() {
        guard let data = viewModel?.data else { return }
        let graphHostingController = UIHostingController(
            rootView:GraphView(data: data, delegate: self, height: height ?? 240, isInteractive: height == nil)
        )
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
        viewModel?.setToWorkoutData()
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        coordinator.animate(alongsideTransition: { (context) in
            self.view.setNeedsLayout()
            self.view.setNeedsDisplay()
        })
        
    }
    
    private var windowInterfaceOrientation: UIInterfaceOrientation? {
        PPLSceneDelegate.shared?.window?.windowScene?.interfaceOrientation
    }
    
    func didSelectExercise(name: String) {
        viewModel?.updateToExerciseData(name)
    }
}

extension UIView {
    func updateHeight(_ height: CGFloat) {
        frame = CGRect(origin: frame.origin, size: CGSize(width: frame.width, height: height))
    }
}
