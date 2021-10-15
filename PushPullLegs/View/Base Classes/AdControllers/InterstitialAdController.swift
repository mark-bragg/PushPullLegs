//
//  InterstitialAdController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 1/4/21.
//  Copyright © 2021 Mark Bragg. All rights reserved.
//

import Foundation

@objc protocol InterstitialAdController {
    @objc func createAndLoadInterstitial() -> STAStartAppAd?
    @objc func presentAdLoadingView()
    @objc func interstitialWillDismiss()
}

extension UIViewController: InterstitialAdController, STADelegateProtocol {
    
    func createAndLoadInterstitial() -> STAStartAppAd? {
        let interstitial = STAStartAppAd()
        interstitial?.load(withDelegate: self)
        return interstitial
    }
    
    func presentAdLoadingView() {
        // no op
    }
    
    func interstitialWillDismiss() {
        // no op
    }
    
    public func didLoad(_ ad: STAAbstractAd!) {
        guard let ad = ad as? STAStartAppAd else { return }
        ad.show()
    }
    
    public func failedLoad(_ ad: STAAbstractAd!, withError error: Error!) {
        print("failure")
    }
    
    public func didClose(_ ad: STAAbstractAd!) {
        print("did close")
    }
    
    public func failedShow(_ ad: STAAbstractAd!, withError error: Error!) {
        print("failed to show")
    }
    
    public func didShow(_ ad: STAAbstractAd!) {
        print("did show")
    }
    
    
}
