//
//  PreviousPerformanceViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 11/27/22.
//  Copyright © 2022 Mark Bragg. All rights reserved.
//

class PreviousPerformanceViewController: PPLTableViewController {
    private(set) var exercise: Exercise
    private var sets: [ExerciseSet] { exercise.sets?.array as? [ExerciseSet] ?? [] }
    private var titleViewHeight: CGFloat { 75 }
    private weak var titleView: UIView? {
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: titleViewHeight))
        titleView.addSubview(titleLabel)
        titleView.backgroundColor = .systemBackground
        return titleView
    }
    private var titleFontSize: CGFloat { 25 }
    private var titleLabelFrame: CGRect {
        CGRect(x: 0, y: 0, width: view.frame.width, height: titleViewHeight)
    }
    private var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        return formatter
    }
    private var dateString: String {
        var dateString = ""
        if let date = exercise.workout?.dateCreated {
            dateString = formatter.string(from: date)
        }
        return dateString
    }
    private var titleLabel: UILabel {
        let titleLabel = UILabel(frame: titleLabelFrame)
        titleLabel.numberOfLines = 2
        titleLabel.text = "\(dateString)\n\(exercise.name ?? "")"
        titleLabel.font = UIFont.systemFont(ofSize: titleFontSize)
        titleLabel.textAlignment = .center
        return titleLabel
    }
    private var headerView: UIView
    
    init(exercise: Exercise, headerView: UIView) {
        self.exercise = exercise
        self.headerView = headerView
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let titleView {
            view.addSubview(titleView)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupTableView() {
        guard tableView == nil else { return }
        let tbvFrame = CGRect(x: 0, y: titleViewHeight, width: view.frame.width, height: view.frame.height - titleViewHeight)
        let tbv = PPLTableView(frame: tbvFrame, style: .plain)
        tbv.separatorStyle = .none
        tbv.dataSource = self
        tbv.delegate = self
        tbv.register(PPLTableViewCell.nib(), forCellReuseIdentifier: defaultCellIdentifier)
        view.addSubview(tbv)
        tableView = tbv
    }
    
    override func addNoDataView() {
        // no op
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sets.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        headerView.frame.height
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: defaultCellIdentifier) as? PPLTableViewCell else { return UITableViewCell() }
        let set = sets[indexPath.row]
        let (w, r, d) = cell.labels(width: cell.frame.width)
        w.text = "\(set.weight)"
        r.text = "\(set.reps)"
        d.text = "\(set.duration)"
        return cell
    }
    
    // MARK: BannerAdController
    override func addBannerView(size: STABannerSize) {
        // no op
    }
    
    override func bannerContainerHeight(size: STABannerSize) -> CGFloat {
        0
    }
}
