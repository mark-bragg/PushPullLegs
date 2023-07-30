//
//  PreviousUnilateralPerformanceViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 11/27/22.
//  Copyright © 2022 Mark Bragg. All rights reserved.
//

class PreviousUnilateralPerformanceViewController: PreviousPerformanceViewController {
    private var headerViews: [UIView]
    private var unilateralExercise: UnilateralIsolationExercise? { exercise as? UnilateralIsolationExercise }
    private var uniSets: [UnilateralIsolationExerciseSet] {
        unilateralExercise?.sets?.array as? [UnilateralIsolationExerciseSet] ?? []
    }
    private var leftSets: [ExerciseSet] { uniSets.filter { $0.isLeftSide } }
    private var rightSets: [ExerciseSet] { uniSets.filter { !$0.isLeftSide } }
    
    init(exercise: Exercise, headerViews: [UIView]) {
        self.headerViews = headerViews
        super.init(exercise: exercise, headerView: headerViews[0])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        section < headerViews.count ? headerViews[section] : nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        section == 0 ? headerHeightWith(leftSets) : headerHeightWith(rightSets)
    }
    
    func headerHeightWith(_ sets: [ExerciseSet]) -> CGFloat {
        sets.count > 0 ? 40 : 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: defaultCellIdentifier) else { return UITableViewCell() }
        let set = indexPath.section == 0 ? leftSets[indexPath.row] : rightSets[indexPath.row]
        let (w, r, d) = cell.labels(width: cell.frame.width)
        w.text = "\(set.weight)"
        r.text = "\(set.reps)"
        d.text = "\(set.duration)"
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? leftSets.count : rightSets.count
    }
}
