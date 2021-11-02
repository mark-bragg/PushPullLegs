//
//  StringExtensionsTests.swift
//  PushPullLegsTests
//
//  Created by Mark Bragg on 4/7/21.
//  Copyright © 2021 Mark Bragg. All rights reserved.
//

import XCTest
//import PushPullLegs

class StringExtensionsTests: XCTestCase {

    let zeroString = "0"
    let emptyString = ""
    let zeroPointZero = "0.0"
    let zeroPointZeroZero = "0.00"

    // MARK: cleanupPeriods
    func testCleanupPeriods_emptyString_noChange() {
        XCTAssert(emptyString.cleanupPeriods() == emptyString)
    }
    
    func testCleanupPeriods_zeroString_noChange() {
        XCTAssert(zeroString.cleanupPeriods() == zeroString)
    }
    
    func testCleanupPeriods_zeroPointZero_noChange() {
        XCTAssert(zeroPointZero.cleanupPeriods() == zeroPointZero)
    }
    
    func testCleanupPeriods_zeroPointZeroPontZero_zeroPointZero() {
        let sut = "0.0.0"
        XCTAssert(sut.cleanupPeriods() == zeroPointZeroZero)
    }
    
    func testCleanupPeriods_zeroPointZeroPontZeroEtc_zeroPointZero() {
        let sut = "0.0.0.0.0.0.0.0"
        XCTAssert(sut.cleanupPeriods() == "0.0000000")
    }
    
    // MARK: trimDecimalDigitsToTwo
    func testTrimDecimalDigitsToTwo_emptyString_noChange() {
        XCTAssert(emptyString.trimDecimalDigitsToTwo() == emptyString)
    }
    
    func testTrimDecimalDigitsToTwo_zeroString_noChange() {
        XCTAssert(zeroString.trimDecimalDigitsToTwo() == zeroString)
    }
    
    func testTrimDecimalDigitsToTwo_zeroPointZero_noChange() {
        XCTAssert(zeroPointZero.trimDecimalDigitsToTwo() == zeroPointZero)
    }
    
    func testTrimDecimalDigitsToTwo_zeroPointZeroZero_noChange() {
        XCTAssert(zeroPointZeroZero.trimDecimalDigitsToTwo() == zeroPointZeroZero)
    }
    
    func testTrimDecimalDigitsToTwo_zeroPointZeroZeroEtc_zeroPointZeroZero() {
        XCTAssert("0.0000000".trimDecimalDigitsToTwo() == zeroPointZeroZero)
    }
    
    // MARK: trimLeadingZeroes
    func testTrimLeadingZeroes_emptyString_noChange() {
        XCTAssert(emptyString.trimLeadingZeroes() == emptyString)
    }
    
    func testTrimLeadingZeroes_zeroString_noChange() {
        XCTAssert(zeroString.trimLeadingZeroes() == zeroString)
    }
    
    func testTrimLeadingZeroes_zeroPointZero_noChange() {
        XCTAssert(zeroPointZero.trimLeadingZeroes() == zeroPointZero)
    }
    
    func testTrimLeadingZeroes_0001_1() {
        XCTAssert("0001".trimLeadingZeroes() == "1")
    }
    
    func testTrimLeadingZeroes_10001_noChange() {
        let sut = "10001"
        XCTAssert(sut.trimLeadingZeroes() == sut)
    }
    
    // MARK: trimTrailingZeroes
    func testTrimTrailingZeroes_emptyString_noChange() throws {
        XCTAssert(emptyString.trimTrailingZeroes() == emptyString)
    }
    
    func testTrimTrailingZeroes_zeroString_noChange() throws {
        XCTAssert(zeroString.trimTrailingZeroes() == zeroString)
    }
    
    func testTrimTrailingZeroes_zeroWithDecimalPointAndZero_zeroStringReturned() throws {
        XCTAssert(zeroPointZero.trimTrailingZeroes() == zeroString)
    }
    
    func testTrimTrailingZeroes_zeroWithDecimalPointAndTwoZeroes_noChange() throws {
        XCTAssert(zeroPointZeroZero.trimTrailingZeroes() == zeroString)
    }
    
    func testTrimTrailingZeroes_zeroPointZeroOne_noChange() throws {
        let sut = "0.01"
        XCTAssert(sut.trimTrailingZeroes() == sut)
    }
    
    func testTrimTrailingZeroes_zeroPointZeroOneZero_zeroPointZeroOne() throws {
        let sut = "0.010"
        XCTAssert(sut.trimTrailingZeroes() == "0.01")
    }
    
    // MARK: reduceToCharacterLimit
    func testReduceToCharacterLimit_emptyString_multipleLimits_noChanges() {
        for i in 0...9 {
            XCTAssert(emptyString.reduceToCharacterLimit(i) == emptyString)
        }
    }
    
    func testReduceToCharacterLimit_zeroString_limit1_noChange() {
        XCTAssert(zeroString.reduceToCharacterLimit(1) == zeroString)
    }
    
    func testReduceToCharacterLimit_zeroString_limit2_noChange() {
        XCTAssert(zeroString.reduceToCharacterLimit(2) == zeroString)
    }
    
    func testReduceToCharacterLimit_zeroString_limit0_noChange() {
        XCTAssert(zeroString.reduceToCharacterLimit(0) == zeroString)
    }
    
    func testReduceToCharacterLimit_zeroPointZeroZero_limit3_zeroPointZero() {
        XCTAssert(zeroPointZeroZero.reduceToCharacterLimit(3) == zeroPointZero)
    }
    
    // MARK: format(seconds:)
    func testFormatSeconds_0to59() {
        for i in 0...59 {
            if i < 10 {
                XCTAssert(String.format(seconds: i) == "0:0\(i)")
            } else {
                XCTAssert(String.format(seconds: i) == "0:\(i)")
            }
        }
    }
    
    func testFormatSeconds_multiplesOf60() {
        for i in 0...10 {
            XCTAssert(String.format(seconds: 60 * i) == "\(i):00")
        }
    }
    
    func testFormatSeconds_0to59Minutes_0to59Seconds() {
        for minutes in 0...59 {
            for seconds in 0...59 {
                let totalSeconds = 60 * minutes + seconds
                if seconds < 10 {
                    XCTAssert(String.format(seconds: totalSeconds) == "\(minutes):0\(seconds)")
                } else {
                    XCTAssert(String.format(seconds: totalSeconds) == "\(minutes):\(seconds)")
                }
            }
        }
    }
    
    // MARK: unformat(minutesAndSeconds:)
    func testUnformatMinutesAndSeconds_zero_zero() {
        XCTAssert(String.unformat(minutesAndSeconds: "0:00") == 0)
    }
    
    func testUnformatMinutesAndSeconds_zeroMinutes_0to59Seconds() {
        for seconds in 0...59 {
            if seconds < 10 {
                XCTAssert(String.unformat(minutesAndSeconds: "0:0\(seconds)") == seconds)
            } else {
                XCTAssert(String.unformat(minutesAndSeconds: "0:\(seconds)") == seconds)
            }
        }
    }
    
    func testUnformatMinutesAndSeconds_0to59Minutes_0to59Seconds() {
        for minutes in 0...59 {
            for seconds in 0...59 {
                let totalSeconds = 60 * minutes + seconds
                if seconds < 10 {
                    XCTAssert(String.unformat(minutesAndSeconds: "\(minutes):0\(seconds)") == totalSeconds)
                } else {
                    XCTAssert(String.unformat(minutesAndSeconds: "\(minutes):\(seconds)") == totalSeconds)
                }
            }
        }
    }

}
