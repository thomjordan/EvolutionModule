//
//  Resident.swift
//  EvolutionModule
//
//  Created by Thom Jordan on 1/27/18.
//  Copyright © 2018 Thom Jordan. All rights reserved.
//

import Foundation
import Utilities

// should be a class of memberwise structs
public class Resident<EE> where EE: EvolutionEnvironment {
    public var env     : EE
    public var mapping : EE.Mapping
    public var phenome : EE.Phenome?
    public var genome  : Genome
    public var fitness : Fitness = Fitness()
    
    init(_ ee: EE, _ g: Genome) {
        self.env     = ee
        self.genome  = g
        self.mapping = env.doMapping(from: g)
        genPhenome()
        calcFitness(withWeights: env.evoParams.weights)
    }
    
    func genPhenome() { self.phenome = env.genPhenome(mapping: mapping) }
    
    func calcFitness(withWeights weights: [Float64]) {
        guard let thePhenome = self.phenome else { return }
        let result = env.calcFitness(for: thePhenome, withWeights: weights)
        simpleFitness = result.simple // sets simpleFitness via lens
        cutoffFitness = result.cutoff // sets cutoffFitness via lens
        normalFitness = result.simple * result.cutoff
    }
    
    func showDescription() { env.showDescription(for: phenome) }
}

extension Resident {

    public var simpleFitness : Fitness.Value {
        get { return Fitness.simpleValLens.get(self.fitness) ?? 1.0 }
        set(newValue) { self.fitness = Fitness.simpleValLens.set(newValue)(self.fitness) }
    }
    public var cutoffFitness : Fitness.Value {
        get { return Fitness.cutoffValLens.get(self.fitness) ?? 1.0 }
        set(newValue) { self.fitness = Fitness.cutoffValLens.set(newValue)(self.fitness) }
    }
    public var normalFitness : Fitness.Value {
        get { return Fitness.normalValLens.get(self.fitness) ?? 0.0001 }
        set(newValue) { self.fitness = Fitness.normalValLens.set(newValue)(self.fitness) }
    }
    
}

 
