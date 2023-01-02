//
//  DurationCollectionViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/3/21.
//  Copyright © 2021 Mark Bragg. All rights reserved.
//

import UIKit

class DurationCollectionViewController: UIViewController {

    var durationView: DurationCollectionView? { view as? DurationCollectionView }
    var exerciseSetViewModel: ExerciseSetViewModel?
    var prevText = "00:00"
    var characters = ["", "", "", ""]
    
    override func loadView() {
        view = DurationCollectionView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = PPLColor.primary
        navigationItem.title = "Duration"
        durationView?.button.setTitle("Submit", for: .normal)
        durationView?.button.addTarget(self, action: #selector(buttonReleased(_:)), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        exerciseSetViewModel?.startSet()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        durationView?.timeLabel.becomeFirstResponder()
    }
    
    @objc func buttonReleased(_ sender: Any) {
        guard let lbl = durationView?.timeLabel.label, let durationText = lbl.text else { return }
        exerciseSetViewModel?.collectDuration(durationText)
    }
}
