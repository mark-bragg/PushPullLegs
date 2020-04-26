//
//  KeyboardObserver.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/24/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation
import UIKit

protocol KeyboardObserver: NSObject {
    func keyboardHeight(_ height: CGFloat)
}

class KeyboardObserving: NSObject {
    static let instance = KeyboardObserving()
    private var observers = [KeyboardObserver]()
    
    override private init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            notifyObservers(with: keyboardFrame.cgRectValue.height)
        }
    }
    
    private func notifyObservers(with keyboardHeight: CGFloat) {
        for observer in observers {
            observer.keyboardHeight(keyboardHeight)
        }
    }
    
    func addKeyboardObserver(_ observer: KeyboardObserver) {
        observers.append(observer)
    }
    
    func removeKeyboardObserver(_ observer: KeyboardObserver) {
        if let index = observers.firstIndex(where: { $0 == observer }) {
            observers.remove(at: index)
        }
    }
    
}
