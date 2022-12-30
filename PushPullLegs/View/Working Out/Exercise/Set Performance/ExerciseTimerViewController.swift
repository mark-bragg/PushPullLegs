//
//  ExerciseInProgressViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/23/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit
import Combine

class ExerciseTimerViewController: UIViewController, ExercisingViewController, PPLButtonDelegate {
    var exerciseSetViewModel: ExerciseSetViewModel?
    weak var stackView: UIStackView?
    weak var timerLabel: UILabel?
    weak var finishButton: UIButton?
    weak var bannerContainerView: UIView?
    var cancellables = [AnyCancellable]()
    private var isShowingStartText = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = PPLColor.primary
        addStackView()
        constrainStackView()
        styleStackView()
        addBannerContainer()
    }
    
    func addBannerContainer() {
        let v = UIView()
        view.addSubview(v)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -view.safeAreaInsets.bottom).isActive = true
        v.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        v.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        let height = v.heightAnchor.constraint(equalToConstant: 0)
        height.identifier = "height"
        height.isActive = true
        bannerContainerView = v
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = PPLColor.primary
        navigationItem.title = "Timer"
        finishButton?.setTitle("Finish Set", for: .normal)
        finishButton?.isEnabled = PPLDefaults.instance.countdown() == 0
        finishButton?.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchDown)
        finishButton?.addTarget(self, action: #selector(buttonReleased(_:)), for: .touchUpInside)
        styleTimerLabel()
        addTimerLabelTap()
        timerLabel?.text = exerciseSetViewModel?.initialTimerText()
        timerLabel?.font = UIFont.monospacedDigitSystemFont(ofSize: 48, weight: .regular)
        bind()
        exerciseSetViewModel?.startSet()
        handleAds()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if shouldShowStartText() {
            showStartText()
        }
    }
    
    func addStackView() {
        let stack = UIStackView(arrangedSubviews: [spacer, getTimerLabel(), getButton(), spacer])
        view.addSubview(stack)
        stackView = stack
    }
    
    func constrainStackView() {
        stackView?.translatesAutoresizingMaskIntoConstraints = false
        stackView?.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        stackView?.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 20).isActive = true
        stackView?.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        stackView?.heightAnchor.constraint(equalToConstant: 300).isActive = true
    }
    
    func styleStackView() {
        stackView?.alignment = UIStackView.Alignment.center
        stackView?.axis = NSLayoutConstraint.Axis.vertical
        stackView?.distribution = UIStackView.Distribution.equalCentering
        stackView?.spacing = 14
    }
    
    func getTimerLabel() -> UIView {
        let lbl = UILabel()
        lbl.text = "0:00"
        lbl.font = UIFont.monospacedDigitSystemFont(ofSize: 56, weight: UIFont.Weight.regular)
        timerLabel = lbl
        return lbl
    }
    
    func getButton() -> UIView {
        let btn = UIButton(configuration: buttonConfig())
        btn.backgroundColor = .primary
        btn.addTarget(self, action: #selector(buttonReleased(_:)), for: .touchUpInside)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        finishButton = btn
        return btn
    }
    
    func buttonConfig() -> UIButton.Configuration {
        var config = UIButton.Configuration.borderedProminent()
        config.baseBackgroundColor = .black
        config.buttonSize = UIButton.Configuration.Size.large
        return config
    }
    
    fileprivate func styleTimerLabel() {
        guard let timerLabel else { return }
        timerLabel.layer.borderColor = PPLColor.tertiary.cgColor
        timerLabel.layer.backgroundColor = PPLColor.quaternary.cgColor
        timerLabel.textColor = PPLColor.text
        timerLabel.layer.borderWidth = 1.5
        timerLabel.layer.cornerRadius = timerLabel.frame.height / 12
    }
    
    fileprivate func addTimerLabelTap() {
        timerLabel?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(timerTapped)))
        timerLabel?.isUserInteractionEnabled = true
    }
    
    @objc fileprivate func timerTapped() {
        timerLabel?.isUserInteractionEnabled = false
        exerciseSetViewModel?.cancelCountdown()
    }
    
    func showStartText() {
        isShowingStartText = true
        let lbl = startLabel()
        let diameter = view.frame.width * 0.75
        view.addSubview(lbl)
        constrainStartLabel(lbl, diameter)
        styleStartLabel(lbl, diameter)
        animateStartLabel(lbl)
        timerLabel?.isUserInteractionEnabled = false
    }
    
    fileprivate func startLabel() -> UILabel {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Start!"
        lbl.font = UIFont.systemFont(ofSize: 72, weight: .bold)
        lbl.textColor = PPLColor.primary
        lbl.textAlignment = .center
        return lbl
    }
    
    fileprivate func styleStartLabel(_ lbl: UILabel, _ diameter: CGFloat) {
        let color = PPLColor.tertiary.cgColor
        lbl.layer.backgroundColor = color
        lbl.layer.cornerRadius = diameter / 2
        lbl.layer.shadowPath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: diameter, height: diameter)).cgPath
        lbl.layer.shadowColor = color
        lbl.layer.shadowOpacity = 1.0
        lbl.layer.shadowRadius = 10
    }
    
    fileprivate func constrainStartLabel(_ lbl: UILabel, _ diameter: CGFloat) {
        guard let finishButton else { return }
        lbl.widthAnchor.constraint(equalToConstant: diameter).isActive = true
        lbl.heightAnchor.constraint(equalToConstant: diameter).isActive = true
        lbl.centerYAnchor.constraint(equalTo: finishButton.centerYAnchor).isActive = true
        lbl.centerXAnchor.constraint(equalTo: finishButton.centerXAnchor).isActive = true
    }
    
    fileprivate func animateStartLabel(_ lbl: UILabel) {
        UIView.animate(withDuration: 0.2, delay: 0.7, options: .curveEaseOut, animations: {
            lbl.alpha = 0
        }) { (b) in
            for c in lbl.constraints {
                c.isActive = false
            }
            lbl.removeFromSuperview()
            self.isShowingStartText = false
        }
    }
    
    fileprivate func bind() {
        exerciseSetViewModel?.$setBegan.sink(receiveValue: { [weak self] (exerciseBegan) in
            guard let exerciseBegan = exerciseBegan, exerciseBegan, let self = self else { return }
            DispatchQueue.main.async {
                self.finishButton?.isEnabled = exerciseBegan
            }
        }).store(in: &cancellables)
        exerciseSetViewModel?.stopWatch = PPLStopWatch(withHandler: { [weak self] (seconds) in
            guard let self = self else { return }
            self.timerUpdate(String.format(seconds: self.exerciseSetViewModel?.currentTime(seconds) ?? 0))
        })
    }
    
    @objc func buttonPressed(_ sender: Any) {
        if PPLDefaults.instance.areTimerSoundsEnabled() {
            SoundManager.shared.silenceNextNoise = true
        }
    }
    
    @objc func buttonReleased(_ sender: Any) {
        exerciseSetViewModel?.stopTimer()
    }
    
    func timerUpdate(_ text: String) {
        DispatchQueue.main.async {
            guard let lbl = self.timerLabel else { return }
            lbl.text = text
            if self.shouldShowStartText() {
                self.showStartText()
            }
        }
    }
    
    func shouldShowStartText() -> Bool {
        timerLabel?.text == "0:00" && !isShowingStartText
    }
    
}

extension ExerciseTimerViewController {
    func handleAds() {
        bannerContainerView?.constraints.first(where: { $0.identifier == "height" })?.constant = bannerContainerHeight(size: STA_MRecAdSize_300x250)
        addBannerView(size: STA_MRecAdSize_300x250)
    }
    
    override func bannerContainerView(_ height: CGFloat) -> UIView {
        bannerContainerView ?? UIView ()
    }
    
    override func bannerWidth() -> CGFloat {
        bannerContainerView?.frame.width ?? 0
    }
}
