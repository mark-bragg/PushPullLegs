//
//  DropSetModel.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 7/22/23.
//  Copyright © 2023 Mark Bragg. All rights reserved.
//

class DropSetModel {
    var weightsPerSet = [Double]()
    var setCount: Int { weightsPerSet.count }
    var currentSet: Int = 0
    var repsPerSet = [Double]()
    var durationsPerSet = [Int]()
    var isComplete: Bool { repsPerSet.count == setCount }
}
