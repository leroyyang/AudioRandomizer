//
//  EffectData.swift
//  AudioRandomizer
//
//  Created by leroy on 2016/9/25.
//  Copyright © 2016年 leroy. All rights reserved.
//

import Foundation
class EffectData {
    var multiChannelBufferedDataArray:[[Float]] = [[Float]]()
    
    init(originDataArray:[[Float]]) {
        process(originDataArray: originDataArray)
    }
    
    func process(originDataArray:[[Float]]) {
        multiChannelBufferedDataArray = originDataArray
       /* multiChannelBufferedDataArray.removeAll()
        for i in 0 ..< originDataArray.count {
            multiChannelBufferedDataArray.append(originDataArray[i])
        }*/
        
        
    }
    
    func produceReversedDataArray()->[[Float]] {
        var reversedArray:[[Float]] = [[Float]]()
        
        for i in 0 ..< multiChannelBufferedDataArray.count {
            let oneChannelArray:[Float] = multiChannelBufferedDataArray[i].reversed()
            
            reversedArray.append(oneChannelArray)
        }
        return reversedArray
    }
    
    func getOriginData()->[[Float]] {
        return multiChannelBufferedDataArray
    }
}
