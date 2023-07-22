//
//  SuperSetWeightCollectionViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 7/22/23.
//  Copyright © 2023 Mark Bragg. All rights reserved.
//

protocol SuperSetDelegate: NSObjectProtocol {
    func superSetSelected()
    func secondExerciseSelected(_ name: String)
}

class SuperSetWeightCollectionViewController: WeightCollectionViewController {
    override func addSuperSetBarButtonItem() {
        // no op
    }
    
    override func addDropSetBarButtonItem() {
        // no op
    }
}
