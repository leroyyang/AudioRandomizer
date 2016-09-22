//
//  RandomizerCore.swift
//  AudioRandomizer
//
//  Created by leroy on 2016/9/22.
//  Copyright © 2016年 leroy. All rights reserved.
//

import Foundation
import Accelerate
class RandomizerCore {
    var gainParameter:GainParameter = GainParameter()
    
    func setGain(value:Float) {
        if value <= 1 && value >= 0 {
            gainParameter.value = value
        }
    }
    func getValue(address:UInt64)->Float {
        switch address {
        case GainParameter.address:
            return gainParameter.value
        default:
            return gainParameter.value
        }
    }
    func processAudioData(audioData:UnsafeMutablePointer<Float>,dataSize:Int) {
        vDSP_vsmul(audioData, 1, &gainParameter.value, audioData, 1, vDSP_Length(dataSize))
    }
    
}
