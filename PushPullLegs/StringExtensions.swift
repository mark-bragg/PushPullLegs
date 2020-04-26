//
//  StringExtensions.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/24/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation

extension String {
    
    func cleanupPeriods() -> String {
        guard self.contains(where: { CharacterSet.decimalDigits.contains(Unicode.Scalar.init($0.asciiValue!)) }) else { return "" }
        guard let firstIndex = self.firstIndex(where: { $0 == "." }), firstIndex != self.lastIndex(where: { $0 == "." }) else { return self }
        let range = Range<String.Index>(uncheckedBounds: (lower: self.index(after: firstIndex), upper: self.endIndex))
        let correctedText = self.replacingOccurrences(of: ".", with: "", options: [], range: range)
        return correctedText
    }
    
    func trimDecimalDigitsToTwo() -> String {
        guard var index = self.firstIndex(where: { $0 == "." }) else { return self }
        var string = self
        var indexCount = 0
        while self.endIndex != index && indexCount < 3 {
            index = self.index(after: index)
            indexCount += 1
        }
        guard indexCount == 3 else { return self }
        let range = Range<String.Index>(uncheckedBounds: (lower: index, upper: self.endIndex))
        string.removeSubrange(range)
        return string
    }
    
    func trimLeadingZeroes() -> String {
        guard self != "0" && self != "0." else { return self }
        guard first == "0" else { return self }
        var toCorrect = self
        while toCorrect.hasPrefix("0") && toCorrect.count > 1 {
            toCorrect.removeFirst(1)
        }
        if contains(".") {
            return "0\(toCorrect)"
        }
        return toCorrect
    }
    
    func reduceToCharacterLimit(_ limit: Int) -> String {
        guard limit > 0 else { return self }
        guard self.count > limit else { return self }
        var corrected = self
        corrected.removeLast()
        return corrected
    }
}
