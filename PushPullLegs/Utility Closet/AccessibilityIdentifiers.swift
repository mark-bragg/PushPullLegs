//
//  AccessibilityIdentifiers.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 12/27/22.
//  Copyright © 2022 Mark Bragg. All rights reserved.
//

import Foundation

protocol AccessibilityIdentifier {
    static var add: String { get }
    static var note: String { get }
    static var edit: String { get }
}

extension String: AccessibilityIdentifier {
    static var add: String { "Add" }
    static var note: String { "Note" }
    static var edit: String { "Edit" }
}
