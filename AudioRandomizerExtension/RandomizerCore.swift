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
    var gainParameter:AUParameter!
    var multichannelBufferedDataArray:[[UnsafeMutableBufferPointer<Float>]] = [[UnsafeMutableBufferPointer<Float>]]()
    var effectData:EffectData!
    var gotData = false
    init() {
        multichannelBufferedDataArray.append([UnsafeMutableBufferPointer<Float>]())
        multichannelBufferedDataArray.append([UnsafeMutableBufferPointer<Float>]())
    }
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
    func processAudioData(audioDataPointer:UnsafeMutableAudioBufferListPointer,dataSize:Int) {
        let drive = 0.7
        let a = sin( ((drive + 1)/101) / (Double.pi/2))
        let k:Float = Float(2*a/(1-a))
        checkEffectData(audioDataPointer: audioDataPointer, dataSize: dataSize)
        for index in 0 ..< audioDataPointer.count {
            let audioDataArray = UnsafeMutableBufferPointer(start:audioDataPointer[index].mData?.assumingMemoryBound(to: Float.self), count:dataSize)
            for i in 0 ..< audioDataArray.count {
                audioDataArray[i] = (1+k)*audioDataArray[i] / (1+k*abs(audioDataArray[i]))
                
            }
            vDSP_vsmul(audioDataArray.baseAddress!, 1, &gainParameter.value, audioDataArray.baseAddress!, 1, vDSP_Length(dataSize))
        }
    }
    
    func checkEffectData(audioDataPointer:UnsafeMutableAudioBufferListPointer, dataSize:Int) {
        if multichannelBufferedDataArray.count < 10 || !gotData  {
            for index in 0 ..< audioDataPointer.count {
                let audioDataArray = UnsafeMutableBufferPointer(start:audioDataPointer[index].mData?.assumingMemoryBound(to: Float.self), count:dataSize)
                multichannelBufferedDataArray[index].append(audioDataArray)
            }
        } else {
            effectData = EffectData(originDataArray: multichannelBufferedDataArray)
            multichannelBufferedDataArray[0].removeAll()
            multichannelBufferedDataArray[1].removeAll()
            gotData = true
        }
    }
    
    
    
}
