//
//  EffectData.swift
//  AudioRandomizer
//
//  Created by leroy on 2016/9/25.
//  Copyright © 2016年 leroy. All rights reserved.
//

import Foundation
class EffectData {
    var multiChannelBufferedDataArray:[[[Float]]] = [[[Float]]]()
    
    init(originDataArray:[[UnsafeMutableBufferPointer<Float>]]) {
        process(originDataArray: originDataArray)
    }
    
    func process(originDataArray:[[UnsafeMutableBufferPointer<Float>]]) {
        multiChannelBufferedDataArray.removeAll()
        for index in 0 ..< originDataArray.count {
            multiChannelBufferedDataArray.append([[Float]]())
            for originData in originDataArray[index] {
                let dataArray = Array<Float>(originData)
                
                multiChannelBufferedDataArray[index].append(dataArray)
            }
        }
    }
    
    func produceReversedDataArray()->[[[Float]]] {
        var reversedArray:[[[Float]]] = [[[Float]]]()
        
        for i in 0 ..< multiChannelBufferedDataArray.count {
            var oneChannelArray:[[Float]] = multiChannelBufferedDataArray[i].reversed()
            for j in 0 ..< oneChannelArray.count {
                oneChannelArray[j].reverse()
            }
            reversedArray.append(oneChannelArray)
        }
        return reversedArray
    }
}
