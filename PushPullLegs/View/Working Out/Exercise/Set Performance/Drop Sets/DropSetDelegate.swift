//
//  DropSetDelegate.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 7/22/23.
//  Copyright © 2023 Mark Bragg. All rights reserved.
//

protocol DropSetDelegate: NSObjectProtocol {
    func dropSetSelected()
    var dropSetCount: Int { get set }
    func dropSetsStarted(with weights: [Double])
    func startNextDropSet()
    func collectDropSet(duration: Int)
    func dropSetCompleted(with reps: Double)
}
