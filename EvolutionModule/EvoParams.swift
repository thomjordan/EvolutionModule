//
//  EvoParams.swift
//  EvolutionModule
//
//  Created by Thom Jordan on 3/30/19.
//  Copyright © 2019 Thom Jordan. All rights reserved.
//

import Foundation

public struct EvoParams {
    var population    : Int
    var selection     : Float64
    var recombination : Float64
    var mutation      : Float64
    var weights       : [Float64]
    
    public init(
        population    : Int       = 128,
        selection     : Float64   = 0.5,
        recombination : Float64   = 0.618,
        mutation      : Float64   = 0.02,
        weights       : [Float64] = [0,1,1,0,1,1,1,0]) {
        self.population    = population
        self.selection     = selection
        self.recombination = recombination
        self.mutation      = mutation
        self.weights       = weights
    }
}

