//
//  SplashViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 8/21/21.
//  Copyright © 2021 Mark Bragg. All rights reserved.
//

import UIKit

@objc protocol SplashViewControllerDelegate {
    func splashViewControllerDidDisappear(_ splash: SplashViewController)
}

class SplashViewController: UIViewController {
    
    weak var backgroundView: UIView!
    weak var imageView: UIImageView!
    weak var delegate: SplashViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        addBackgroundView()
        addImageView()
        view.frame = view.superview?.bounds ?? .zero
    }
    
    private func addBackgroundView() {
        let bgv = UIView(frame: view.bounds)
        view.addSubview(bgv)
        backgroundView = bgv
        backgroundView.backgroundColor = .black
    }
    
    private func addImageView() {
        let imgv = UIImageView()
        view.addSubview(imgv)
        imageView = imgv
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(imageLiteralResourceName: "launch.png")
        imageView.frame = view.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: TimeInterval(0.67), delay: TimeInterval(0.33)) {
            self.backgroundView.alpha = 0
            self.imageView.frame = CGRect(x: self.view.frame.width/2, y: self.view.frame.height/2, width: 1, height: 1)
        } completion: { (b) in
            self.delegate?.splashViewControllerDidDisappear(self)
        }
    }

}
