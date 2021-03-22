//
//  StoreObserver.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 1/25/21.
//  Copyright © 2021 Mark Bragg. All rights reserved.
//

import Foundation
import StoreKit

class StoreObserver: NSObject, SKPaymentTransactionObserver {

    static let shared = StoreObserver()
    @Published private(set) var restored: Bool!
    
    var isAuthorizedForPayments: Bool {
        SKPaymentQueue.canMakePayments()
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing: break
            case .purchased:
                StoreManager.shared.handlePurchased(transaction)
                
            case .failed:
                StoreManager.shared.handleFailure()
                
            case .restored:
                if transaction.original?.payment.productIdentifier == IAPProductId.kDisableAds.rawValue {
                    StoreManager.shared.restoreDisableAds(transaction)
                }
            default: fatalError("Messages.unknownPaymentTransaction")
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if StoreManager.shared.restoringAdsDisabled && PPLDefaults.instance.isAdsEnabled() {
            StoreManager.shared.runAdDisabler()
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        // no op
    }
    
}


