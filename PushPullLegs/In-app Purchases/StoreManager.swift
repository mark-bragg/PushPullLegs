//
//  StoreManager.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 1/29/21.
//  Copyright © 2021 Mark Bragg. All rights reserved.
//

import Foundation
import StoreKit

enum IAPProductId: String {
    case kDisableAds = "com.braggbuilds.ppl.disableAdvertisements"
}

enum ReceiptValidationError: Error {
    case receiptNotFound
    case jsonResponseIsNotValid(description: String)
    case notBought
    case expired
}

class StoreManager: NSObject, SKProductsRequestDelegate {
    
    static let shared = StoreManager()
    private var request: SKProductsRequest!
    private var availableTransactions: Set<IAPTransaction>!
    private let certificate = "AppleIncRootCertificate"
    private var adDisabler: (() -> Void)?
    private var failedPurchaseHandler: (() -> Void)?
    private var preparingToDisableAds = false
    private(set) var restoringAdsDisabled = false
    private(set) var isPurchasing = false
    
    // MARK: purchase
    
    func prepareToDisableAds() {
        guard PPLDefaults.instance.isAdsEnabled() else { return }
        preparingToDisableAds = true
        request = SKProductsRequest(productIdentifiers: [IAPProductId.kDisableAds.rawValue])
        request.delegate = self
        request.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        guard !response.products.isEmpty else { return }
        if preparingToDisableAds, let product = response.products.first(where: { $0.productIdentifier == IAPProductId.kDisableAds.rawValue }) {
            prepareTransaction(product)
            preparingToDisableAds = false
        }
    }
    
    private func prepareTransaction(_ product: SKProduct) {
        availableTransactions = Set()
        availableTransactions.insert(IAPTransaction(product))
    }
    
    func startDisableAdsTransaction() {
        isPurchasing = true
        guard let transaction = availableTransactions.first(where: { $0.product.productIdentifier == IAPProductId.kDisableAds.rawValue }) else { return }
        transaction.begin()
    }
    
    func handlePurchased(_ transaction: SKPaymentTransaction) {
        guard isPurchasing, let purchase = availableTransactions.first(where: { $0.product.productIdentifier == transaction.payment.productIdentifier }) else { return }
        availableTransactions.remove(purchase)
        SKPaymentQueue.default().finishTransaction(transaction)
        if purchase.product.productIdentifier == IAPProductId.kDisableAds.rawValue {
            PPLDefaults.instance.disableAds()
        }
    }
    
    // MARK: restoration
    
    func restoreDisabledAds(_ adDisabler: @escaping () -> Void, failure failedHandler: @escaping () -> Void) {
        self.restoringAdsDisabled = true
        self.adDisabler = adDisabler
        self.failedPurchaseHandler = failedHandler
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func runAdDisabler() {
        if let runAdDisabler = self.adDisabler {
            runAdDisabler()
        }
    }
    
    func handleFailure() {
        if let handleFailure = self.failedPurchaseHandler {
            handleFailure()
        }
    }
    
    func restoreDisableAds(_ transaction: SKPaymentTransaction) {
        if PPLDefaults.instance.isAdsEnabled() {
            PPLDefaults.instance.disableAds()
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    func requestDidFinish(_ request: SKRequest) {
        print("finished")
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("failure")
    }
}
