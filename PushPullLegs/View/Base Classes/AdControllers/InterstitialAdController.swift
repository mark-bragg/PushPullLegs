//
//  InterstitialAdController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 1/4/21.
//  Copyright © 2021 Mark Bragg. All rights reserved.
//

import Foundation
import GoogleMobileAds

@objc protocol InterstitialAdController {
    @objc func createAndLoadInterstitial(adUnitID: String) -> GADInterstitial?
    @objc func presentAdLoadingView()
    @objc func interstitialWillDismiss()
}

extension UIViewController: InterstitialAdController {
    func createAndLoadInterstitial(adUnitID: String) -> GADInterstitial? {
        guard AppState.shared.isAdEnabled else { return nil }
        let interstitial = GADInterstitial(adUnitID: adUnitID)
        interstitial.load(GADRequest())
        return interstitial
    }
    
    func presentAdLoadingView() {
        // no op
    }
    
    func interstitialWillDismiss() {
        // no op
    }
}

extension UIViewController: GADInterstitialDelegate {
    public func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        ad.present(fromRootViewController: self)
    }
    
    public func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        interstitialWillDismiss()
    }
}
