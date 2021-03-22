//
//  IAPTransaction.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 3/21/21.
//  Copyright © 2021 Mark Bragg. All rights reserved.
//

import Foundation
import StoreKit

enum IAPTransactionState {
    case initiated
    case confirming
    case authorizing
    case completed
    case canceled
}

class IAPTransaction: Hashable {
    private(set) var product: SKProduct
    init(_ product: SKProduct) {
        self.product = product
    }
    
    func begin() {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    static func == (lhs: IAPTransaction, rhs: IAPTransaction) -> Bool {
        lhs.product.productIdentifier == rhs.product.productIdentifier
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(product.productIdentifier)
    }
}
