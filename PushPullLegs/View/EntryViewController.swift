//
//  EntryViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 2/12/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

let workoutSegueId = "SEGUE_TO_WORKOUT_SCENE"

class EntryViewController: UIViewController {
    
    
    @IBOutlet weak var container: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier, id == workoutSegueId {
            print("segue to workout scene")
        }
    }
    

}
