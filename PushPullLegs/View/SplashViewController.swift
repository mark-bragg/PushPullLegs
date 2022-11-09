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
    private var splashPreferences: STASplashPreferences {
        let splashPreferences = STASplashPreferences()
        splashPreferences.splashMode = STASplashModeTemplate
        splashPreferences.splashTemplateTheme = STASplashTemplateThemeOcean;
        splashPreferences.splashLoadingIndicatorType = STASplashLoadingIndicatorTypeDots;
        splashPreferences.splashTemplateIconImageName = "512 x 512";
        splashPreferences.splashTemplateAppName = "Push Pull Legs";
        return splashPreferences
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addBackgroundView()
        addImageView()
        view.frame = view.superview?.bounds ?? .zero
        showSplashAd()
    }
    
    private func showSplashAd() {
        guard
            PPLDefaults.instance.isAdvertisingEnabled(),
            let sdk = STAStartAppSDK.sharedInstance()
        else { return }
        sdk.showSplashAd(withDelegate: self, with: splashPreferences)
    }
    
    override func failedLoad(_ ad: STAAbstractAd!, withError error: Error!) {
        disappear()
    }
    
    override func failedShow(_ ad: STAAbstractAd!, withError error: Error!) {
        disappear()
    }
    
    override func didClose(_ ad: STAAbstractAd!) {
        disappear()
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
        imageView.frame = imageViewFrame
    }
    
    private var imageViewFrame: CGRect {
        let width = view.frame.width - insets.left
        let height = view.frame.height - insets.top
        return CGRect(x: insets.left, y: view.safeAreaInsets.top, width: width + insets.right, height: height + insets.bottom)
    }
    
    private var insets: UIEdgeInsets {
        var i = view.safeAreaInsets
        i.bottom = -view.safeAreaInsets.bottom
        i.right = -view.safeAreaInsets.right
        return i
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !PPLDefaults.instance.isAdvertisingEnabled() {
            disappear()
        }
    }
    
    private func disappear() {
        UIView.animate(withDuration: TimeInterval(0.67), delay: TimeInterval(0.33)) {
            self.backgroundView.alpha = 0
            self.imageView.frame = CGRect(x: self.view.frame.width/2, y: self.view.frame.height/2, width: 1, height: 1)
        } completion: { (b) in
            self.delegate?.splashViewControllerDidDisappear(self)
        }
    }

}
