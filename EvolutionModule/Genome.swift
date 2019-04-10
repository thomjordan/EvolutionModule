//
//  Genome.swift
//  EvolutionModule
//
//  Created by Thom Jordan on 1/16/18.
//  Copyright © 2018 Thom Jordan. All rights reserved.
//

import Foundation
import Utilities 

infix operator <||>: MultiplicationPrecedence

public struct Genome {
    
    let data  : [Int]
    let range : UInt32
    var count : Int { return data.count }
    
    public static func new(size: UInt32, limit: UInt32 = 384) -> Genome {
        var temp : [Int] = []
        for _ in 0..<size {
            let allele = limit.randomized
            temp.append(allele)
        }
        let result = Genome(data: temp, range: limit)
        return result
    }
    
    public subscript(index: Int) -> Int {
        get { return data[index % data.count] }
    }
    
    // Two-point crossover ("Essentials of Metaheuristics" p.37)
    public static func <||>(left: Genome, right: Genome) -> (Genome, Genome) {
        guard left.count == right.count && left.range == right.range else { return (left, right) }
        let size  = left.count
        let range = left.range
        var resultL = left.data
        var resultR = right.data
        let c = size.randomized
        let d = size.randomized
        let interval = c < d ? c..<d : d..<c
        for idx in interval {
            resultL[idx] = resultR[idx]
            resultR[idx] = left[idx]
        }
        return ( Genome(data: resultL, range: range), Genome(data: resultR, range: range) )
    }
    
    public func mutated(by rate: Float64) -> Genome {
        let mrate = abs(rate).truncatingRemainder(dividingBy: 1.00) 
        var newdata : [Int] = []
        for allele in self.data {
            if rand() < mrate { newdata += [range.randomized] }
            else { newdata.append(allele) }
        }
        return Genome(data: newdata, range: range)
    }
}

