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
    var multichannelBufferedDataArray:[[Float]] = [[Float]]()
    var effectData:EffectData!
    var reversedEffectData:[[Float]]!
    var gotData = false
    var effectInterval = 300
    var effectIntervalIndex = 0
    private var usingRandomEffect = false
    private var effectIndex = 0
    init() {
        multichannelBufferedDataArray.append([Float]())
        multichannelBufferedDataArray.append([Float]())
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
    func processAudioData(audioDataPointer:UnsafeMutableAudioBufferListPointer,dataByteSize:Int) {
        let dataSize = dataByteSize/MemoryLayout<Float>.size
        checkEffectData(audioDataPointer: audioDataPointer, dataSize: dataSize)
        if gotData && !usingRandomEffect {
            if effectIntervalIndex >= effectInterval && arc4random_uniform(100) > 93 {
                usingRandomEffect = true
                effectIndex = 0
                reversedEffectData = effectData.produceReversedDataArray()
                print("effect")
                effectIntervalIndex = 0
            } else {
                effectIntervalIndex += 1
            }
        }
        if usingRandomEffect {
            processEffectData(audioDataPointer: audioDataPointer, dataSize: dataSize)
        } else {
            
            for index in 0 ..< audioDataPointer.count {
                let audioDataArray = UnsafeMutableBufferPointer(start:audioDataPointer[index].mData?.assumingMemoryBound(to: Float.self), count:dataSize)
               
                vDSP_vsmul(audioDataArray.baseAddress!, 1, &gainParameter.value, audioDataArray.baseAddress!, 1, vDSP_Length(dataSize))
                
            }
        }
        
    }
    
    func checkEffectData(audioDataPointer:UnsafeMutableAudioBufferListPointer, dataSize:Int) {
        if multichannelBufferedDataArray[0].count < 102400 {
            for channelIndex in 0 ..< audioDataPointer.count {
                let audioDataArray = UnsafeMutableBufferPointer(start:audioDataPointer[channelIndex].mData!.assumingMemoryBound(to: Float.self), count:dataSize)
                multichannelBufferedDataArray[channelIndex].append(contentsOf: Array<Float>(audioDataArray))
            }
        } else {
            effectData = EffectData(originDataArray: multichannelBufferedDataArray)
            multichannelBufferedDataArray[0].removeAll()
            multichannelBufferedDataArray[1].removeAll()
            gotData = true
        }
    }
    
    func processEffectData(audioDataPointer:UnsafeMutableAudioBufferListPointer,dataSize:Int) {
        
        for channelIndex in 0 ..< audioDataPointer.count {
            let audioDataArray = UnsafeMutableBufferPointer(start:audioDataPointer[channelIndex].mData!.assumingMemoryBound(to: Float.self), count:dataSize)
            for i in 0 ..< dataSize {
                if effectIndex < reversedEffectData[channelIndex].count {
                    audioDataArray[i] = reversedEffectData[channelIndex][effectIndex+i]
                    
                }
            }
          //  vDSP_vsmul(audioDataArray.baseAddress!, 1, &gainParameter.value, audioDataArray.baseAddress!, 1, vDSP_Length(dataSize))
        }
        effectIndex += dataSize
        if effectIndex >= reversedEffectData[0].count-1 {
            usingRandomEffect = false
        }
    }
    
    
}
