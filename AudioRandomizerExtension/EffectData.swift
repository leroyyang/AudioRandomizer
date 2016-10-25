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
        multiChannelBufferedDataArray = originDataArray
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
