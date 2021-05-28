//
//  ExerciseDropdownViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 5/27/21.
//  Copyright © 2021 Mark Bragg. All rights reserved.
//

import UIKit

protocol ExerciseDropdownViewControllerDelegate {
    func didSelectName(_ name: String)
}

class ExerciseDropdownViewController: UIViewController {

    var names: [String]!
    var delegate: ExerciseDropdownViewControllerDelegate?
    private let rowHeight: CGFloat = 40
    private let maxTableHeight: CGFloat = 300
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = PPLColor.cellBackgroundBlue
        let tblv = UITableView()
        tblv.backgroundColor = PPLColor.cellBackgroundBlue
        tblv.delegate = self
        tblv.dataSource = self
        constrainTableView(tblv)
        tblv.rowHeight = rowHeight
        let tableHeight = rowHeight * CGFloat(names.count) > 300 ? 300 : rowHeight * CGFloat(names.count)
        preferredContentSize = CGSize(width: 200, height: tableHeight)
    }
    
    func constrainTableView(_ tblv: UITableView) {
        view.addSubview(tblv)
        tblv.translatesAutoresizingMaskIntoConstraints = false
        tblv.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        tblv.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 10).isActive = true
        tblv.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tblv.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }

}

extension ExerciseDropdownViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectName(names[indexPath.item])
    }
}

extension ExerciseDropdownViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        names.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = names[indexPath.item]
        cell.textLabel?.textColor = PPLColor.pplTextBlue
        cell.backgroundColor = .clear
        return cell
    }
}
