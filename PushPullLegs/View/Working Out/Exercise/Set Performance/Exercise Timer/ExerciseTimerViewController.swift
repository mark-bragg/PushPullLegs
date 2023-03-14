//
//  ExerciseInProgressViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/23/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit
import Combine

class ExerciseTimerViewController: UIViewController, ExercisingViewController {
    var timerView: ExerciseTimerView? { view as? ExerciseTimerView }
    var exerciseSetViewModel: ExerciseSetViewModel?
    private var cancellables = [AnyCancellable]()
    private var isShowingStartText: Bool {
        timerView?.startLabel != nil
    }
    private var shouldShowStartText: Bool {
        timerView?.timerLabel.text == "00:00" && !isShowingStartText
    }
    private var didShowStartText = false
    
    override func loadView() {
        view = ExerciseTimerView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Timer"
        addTimerLabelTap()
        timerView?.timerLabel.text = exerciseSetViewModel?.initialTimerText()
        timerView?.finishButton.setTitle("Finish Set", for: .normal)
        timerView?.finishButton.isEnabled = PPLDefaults.instance.countdown() == 0
        bind()
        exerciseSetViewModel?.startSet()
        handleAds()
        didShowStartText = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if shouldShowStartText {
            timerView?.showStartText()
        }
    }
    
    override func viewDidLayoutSubviews() {
        timerView?.finishButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchDown)
        timerView?.finishButton.addTarget(self, action: #selector(buttonReleased(_:)), for: .touchUpInside)
    }
    
    private func addTimerLabelTap() {
        timerView?.timerLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(timerTapped)))
        timerView?.timerLabel.isUserInteractionEnabled = true
    }
    
    @objc private func timerTapped() {
        timerView?.timerLabel.isUserInteractionEnabled = false
        guard !didShowStartText
        else { return }
        exerciseSetViewModel?.cancelCountdown()
    }
    
    private func bind() {
        exerciseSetViewModel?.$setBegan.sink(receiveValue: { [weak self] (exerciseBegan) in
            guard let exerciseBegan = exerciseBegan, exerciseBegan, let self = self else { return }
            DispatchQueue.main.async {
                self.timerView?.finishButton.isEnabled = exerciseBegan
            }
        }).store(in: &cancellables)
        exerciseSetViewModel?.stopWatch = PPLStopWatch(withHandler: { [weak self] (seconds) in
            guard let self = self else { return }
            self.timerUpdate(String.format(seconds: self.exerciseSetViewModel?.currentTime(seconds) ?? 0, minuteDigits: 2))
        })
    }
    
    @objc private func buttonPressed(_ sender: Any) {
        if PPLDefaults.instance.areTimerSoundsEnabled() {
            SoundManager.shared.silenceNextNoise = true
        }
    }
    
    @objc private func buttonReleased(_ sender: Any) {
        exerciseSetViewModel?.stopTimer()
    }
    
    private func timerUpdate(_ text: String) {
        DispatchQueue.main.async {
            guard let lbl = self.timerView?.timerLabel else { return }
            lbl.text = text
            if self.shouldShowStartText {
                self.timerView?.showStartText()
            }
        }
    }
    
}

extension ExerciseTimerViewController {
    func handleAds() {
        timerView?.bannerContainerView.constraints.first(where: { $0.identifier == "height" })?.constant = bannerContainerHeight(size: STA_MRecAdSize_300x250)
        addBannerView(size: STA_MRecAdSize_300x250)
        addBannerRefresher()
    }
    
    private func addBannerRefresher() {
//        let refresher = Timer.publish(every: 15, on: .main, in: .default)
//            .autoconnect()
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] _ in
//                print("refreshing timer view banner ad")
//                self?.refreshBanner()
//            }
//        cancellables.append(refresher)
    }
    
    override func bannerContainerView(_ height: CGFloat) -> UIView {
        timerView?.bannerContainerView ?? UIView ()
    }
    
    override func bannerWidth() -> CGFloat {
        timerView?.bannerContainerView.frame.width ?? 0
    }
}
