//
//  StringExtensions.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/24/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation

let interstitialAdID = "ca-app-pub-8150464109183976/1732105336"

extension String {
    
    func cleanupPeriods() -> String {
        guard filter({ $0.asciiValue != nil })
            .contains(where: { CharacterSet.decimalDigits.contains(Unicode.Scalar.init($0.asciiValue!)) }) else { return "" }
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
    
    func trimTrailingZeroes() -> String {
        guard self.contains(".") else { return self }
        var toCorrect = self
        var removedDecimalPoint = false
        while (toCorrect.hasSuffix("0") || toCorrect.hasSuffix(".")) && !removedDecimalPoint {
            removedDecimalPoint = toCorrect.removeLast() == "."
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
    
    static func format(seconds: Int, minuteDigits: Int = 1) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        let formatString = minuteDigits == 1 ? "%01d:%02d" : "%02d:%02d"
        return String(format: formatString, minutes, seconds)
    }
    
    static func unformat(minutesAndSeconds mAndS: String) -> Int {
        let minAndSec = mAndS.components(separatedBy: ":")
        guard
        let minutes = Int(minAndSec[0]),
        let seconds = Int(minAndSec[1])
        else { return 0 }
        let totalSeconds = minutes * 60 + seconds
        return totalSeconds
    }
}
