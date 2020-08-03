//
//  ExerciseDataCellViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 7/12/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

class ExerciseDataCellViewController: UIViewController {

    var exerciseName: String? {
        willSet {
            if titleLabel == nil { return }
            titleLabel.text = newValue
        }
    }
    
    var workText: String? {
        willSet {
            if totalWorkTextLabel == nil { return }
            totalWorkTextLabel.text = newValue
        }
    }
    
    var progress: ExerciseVolumeComparison? {
        willSet {
            if progressIndicatorImageView == nil { return }
            
        }
    }
    
    @IBOutlet weak var progressIndicatorImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var totalWorkTextLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = exerciseName
        totalWorkTextLabel.text = workText
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        totalWorkTextLabel.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        setWorkoutProgressionImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.frame = CGRect(origin: .zero, size: preferredContentSize)
    }
    
    func setWorkoutProgressionImage() {
        var imageName: String
        var tint: UIColor
        if progress == .increase {
            imageName = "arrow.up"
            tint = .green
        } else {
            imageName = "arrow.down"
            tint = .red
        }
        progressIndicatorImageView.image = UIImage.init(systemName: imageName)?.withRenderingMode(.alwaysTemplate)
        progressIndicatorImageView.tintColor = tint
    }

}
