//
//  Population.swift
//  EvolutionModule
//
//  Created by Thom Jordan on 1/22/18.
//  Copyright © 2018 Thom Jordan. All rights reserved.
//

import Foundation
import Utilities
import Prelude

public class Population<EE> where EE: EvolutionEnvironment {
    public typealias ResPool = [Resident<EE>]
    public var env    : EE!
    public var pools  : [ResPool] = []
    public var params : EvoParams { return env.evoParams }

    public init(from ee: EE) {
        self.env    = ee
        self.pools += [generatePool()]
    }

    public func evolve(numcycles: Int, numPoolsToKeep: Int? = nil) {
        let numPoolsToKeep = numPoolsToKeep ?? numcycles
        for k in 0..<numcycles {
            print("Evolution round \(k+1) starting.")
            if let mostRecentPool = self.pools.last {
                let currentPool = doSingleRoundOfEvolution(inpool: mostRecentPool)
                self.pools += [currentPool]
            }
        }
        if let selectedPools = trimToMostEvolvedPools(numpools: numPoolsToKeep) {
            print("trimming to \(numPoolsToKeep) most-evolved pools...")
            self.pools = selectedPools
        }
    }
    
    func trimToMostEvolvedPools(numpools: Int) -> [ResPool]? {
        let maxpools = self.pools.count
        guard numpools <= maxpools else { return nil }
        var keeperPools: [ResPool] = []
        for i in (maxpools-numpools)..<maxpools {
            let sortedPool = poolSortByFitness(self.pools[i])
            //printPoolDescription(sortedPool)
            keeperPools += [sortedPool]
        }
        return keeperPools
    }
}


extension Population {
    
    func doSingleRoundOfEvolution(inpool: ResPool) -> ResPool {
        //let outpool = inpool |> getFilteredPool |> normalizeFitness |> stochasticUniversalSampling |> recombine
        //let outpool = inpool |> mergeFitness |> stochasticUniversalSampling |> recombine
        let outpool = inpool |> stochasticUniversalSampling |> recombine
        // printPoolDescription(outpool)
        // printDescriptionForFirstMemberOfPool(outpool)
        return outpool
    }
    
    func recombine(_ parents:ResPool) -> ResPool {
        var newpop : ResPool = []
        for _ in 0..<(params.population/2) {
            if rand() < params.recombination {
                let (child1, child2) = crossover(parents)
                newpop += [ makeNewMember <| child1,
                            makeNewMember <| child2.mutated <| params.mutation ]
            }
            else {
                newpop += [ makeNewMember <| parents.randomElement.genome.mutated <| params.mutation ]
                newpop += [ parents.randomElement ]
            }
        }
        return newpop
    }
    
    func crossover(_ parents:ResPool) -> (Genome, Genome) {
        let father = parents.randomElement.genome
        let mother = parents.randomElement.genome
        return father <||> mother
    }
    
    func mutatePool(inpool: ResPool) -> ResPool {
        print("Mutating entire pool to try for a better initial population.")
        var newpop : ResPool = []
        let rate = params.mutation // * params.selection
        for member in inpool {
            let newsubj : Resident = makeNewMember( member.genome.mutated(by: rate) )
            newpop += [ newsubj ]
        }
        return newpop
    }
    
    
    func stochasticUniversalSampling(_ subpool:ResPool) -> ResPool {
        var parents : ResPool = []
        let localPool = subpool.shuffled()
        let cdf = getcdf(localPool)
        //let totalFitness = localPool.map { $0.simpleFitness }.reduce(0.0) { $0 + $1 }
        let totalFitness = localPool.map { $0.normalFitness }.reduce(0.0) { $0 + $1 }
        let selectionSize = localPool.count |> { Float64($0) * params.selection } |> floor |> Int.init
        let skip  : Float64 = totalFitness / Float64(selectionSize)
        var value : Float64 = rand() * skip
        var idx = 0
        for _ in 0..<selectionSize {
            while cdf[idx] < value { idx += 1 }
            parents += [localPool[idx]]
            value += skip
        }
        return parents
    }
    
    func getcdf(_ subpool:ResPool) -> [Float64] {
        var sum : Float64 = 0.0
        let cdf = subpool.map { (sum += $0.normalFitness, sum).1 }
        return cdf
    }
    
}


extension Population {
    
    func makeNewMember(_ genome: Genome) -> Resident<EE> {
        return Resident(env, genome)
    }
    
    func generatePool() -> ResPool {
        var newPool: ResPool = []
        print("Generating new population of size \(params.population)")
        // print("GENOME SIZE = \(env.genomeSize)")
        for _ in 0..<params.population {
            let genome  = Genome.new(size: env.genomeSize)
            // print("GENOME = \(genome) : \(genome.count)")
            let newResident = makeNewMember(genome)
            newPool += [newResident]
        }
        return newPool
    }
    
    func printPoolDescription(_ inpool: ResPool) {
        for (i, m) in inpool.enumerated() {
            print("Member #\(i+1)")
            m.showDescription()
        }
    }
    
    func printDescriptionForFirstMemberOfPool(_ inpool: ResPool) {
        if let firstMember = inpool.first { firstMember.showDescription() }
        else { print("No first member -- Pool must be empty...")  }
    }
    
 
    func poolSortByFitness(_ inpool: ResPool) -> ResPool {
        //return inpool.sorted { l, r in l.simpleFitness > r.simpleFitness }
        return inpool.sorted { l, r in l.normalFitness > r.normalFitness }
    }
    
    func poolSortByRandom(_ inpool: ResPool) -> ResPool {
        return inpool.shuffled()
    }
}


//extension Population {
//
//    func normalizeFitness(inpop: ResPool) -> ResPool {
//        if inpop.count < 2 { return [] }
//        let _SLIDE_VALUE : Float64 = 0.382
//        let localpop : ResPool = inpop
//        let minimizedFitness = localpop.map { $0.simpleFitness }
//        let rangedFitness = minimizedFitness.normalizedRange
//        let slidedFitness = rangedFitness.map { $0 + _SLIDE_VALUE }
//        let sum  = Fitness.Value( slidedFitness.reduce(0.0) { Fitness.Value( $0 + $1 ) } )
//        let invertedFitness  = slidedFitness.map { sum / $0 }.map { Fitness.Value($0) }
//        let pairs = zip(localpop, invertedFitness)
//        let _ = pairs.map { $0.0.normalFitness = $0.1 }
//        return localpop
//    }
//
//    func getFilteredPool(_ thePool:ResPool) -> ResPool {
//        let scaledSize = params.population |> Float64.init |> { $0 * 0.125 } |> ceil |> Int.init
//        let minValidSize = scaledSize > 4 ? scaledSize : 4
//        let filteredPool = thePool.filter { $0.cutoffFitness > params.minimalR2 }
//        if filteredPool.count < minValidSize {
//            print("Filtering the current pool removed most of its contents; generating a fresh pool is required.")
//            return generatePool() }
//        else { return filteredPool }
//    }
//    
//    func mergeFitness(inpool: ResPool) -> ResPool {
//        var pool = inpool
//        for p in pool { p.normalFitness = p.simpleFitness * p.cutoffFitness }
//        return pool
//    }
//}
