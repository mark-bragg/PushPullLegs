//
//  ExerciseSelectionViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/19/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

protocol ExerciseTemplateSelectionDelegate: NSObject {
    func exerciseTemplatesAdded()
}

class ExerciseTemplateSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var viewModel: ExerciseSelectionViewModel!
    weak var delegate: ExerciseTemplateSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: exerciseCellReuseIdentifier)
    }
    
    @IBAction func done(_ sender: Any) {
        viewModel.commitChanges()
        delegate?.exerciseTemplatesAdded()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func createExerciseTemplate(_ sender: Any) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: StoryboardIdentifiers.createExerciseViewController.rawValue) as? ExerciseTemplateCreationViewController {
            vc.viewModel = ExerciseTemplateCreationViewModel(withType: viewModel.exerciseType, management: TemplateManagement())
            vc.modalPresentationStyle = .formSheet
            present(vc, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.rowCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: exerciseCellReuseIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: exerciseCellReuseIdentifier)
        }
        cell?.textLabel?.text = viewModel.titleForRow(indexPath.row)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.accessoryType == .none {
                viewModel.selected(row: indexPath.row)
                cell.accessoryType = .checkmark
            } else {
                viewModel.deselected(row: indexPath.row)
                cell.accessoryType = .none
            }
        }
    }

}
