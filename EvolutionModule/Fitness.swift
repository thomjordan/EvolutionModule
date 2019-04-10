//
//  Fitness.swift
//  EvolutionModule
//
//  Created by Thom Jordan on 2/1/18.
//  Copyright © 2018 Thom Jordan. All rights reserved.
//

import Foundation
import Utilities

public struct Fitness {
    public typealias Value = Float64
    
    public var simpleValue : Value?
    public var cutoffValue : Value?
    public var normalValue : Value?
    
    public init() { }
}

extension Fitness {
    static var simpleValLens : Lens<Fitness, Value?> { return (\Fitness.simpleValue).lens }
    static var cutoffValLens : Lens<Fitness, Value?> { return (\Fitness.cutoffValue).lens }
    static var normalValLens : Lens<Fitness, Value?> { return (\Fitness.normalValue).lens }
}
