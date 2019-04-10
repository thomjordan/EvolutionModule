//
//  Mapper.swift
//  EvolutionModule
//
//  Created by Thom Jordan on 1/22/18.
//  Copyright © 2018 Thom Jordan. All rights reserved.
//

import Foundation

public protocol EvolutionEnvironment {
    associatedtype Mapping
    associatedtype Phenome
    var  genomeSize : UInt32 { get }
    var  evoParams  : EvoParams { get }
    func doMapping(from g: Genome) -> Mapping
    func genPhenome(mapping: Mapping) -> Phenome?
    func calcFitness(for phenome: Phenome, withWeights weights: [Float64]) -> (simple: Fitness.Value, cutoff: Fitness.Value)
    func showDescription(for phenome: Phenome?)
}




