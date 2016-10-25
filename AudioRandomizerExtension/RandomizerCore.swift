//
//  RandomizerCore.swift
//  AudioRandomizer
//
//  Created by leroy on 2016/9/22.
//  Copyright © 2016年 leroy. All rights reserved.
//

import Foundation
import Accelerate
import AudioUnit
class RandomizerCore {
    var gainParameter:AUParameter!
    var multichannelBufferedDataArray:[[Float]] = [[Float]]()
    var effectData:EffectData!
    var producedEffectDataArray:[[Float]]!
    var gotData = false
    let effectInterval = 200
    var effectIntervalIndex = 0
    let effectBlockSize = 81920
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
        setEffectData(audioDataPointer: audioDataPointer, dataSize: dataSize)
        if gotData && !usingRandomEffect {
            if effectIntervalIndex >= effectInterval && arc4random_uniform(100) > 91 {
                usingRandomEffect = true
                effectIndex = 0
                effectData = EffectData(originDataArray: multichannelBufferedDataArray)
                setEffectDataArray()
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
    
    func setEffectData(audioDataPointer:UnsafeMutableAudioBufferListPointer, dataSize:Int) {
        let blockSize = 1024
        if multichannelBufferedDataArray[0].count >= effectBlockSize {
            gotData = true
            multichannelBufferedDataArray[0].removeSubrange(0 ..< blockSize)
            multichannelBufferedDataArray[1].removeSubrange(0 ..< blockSize)
        }
        for channelIndex in 0 ..< audioDataPointer.count {
            let audioDataArray = UnsafeMutableBufferPointer(start:audioDataPointer[channelIndex].mData!.assumingMemoryBound(to: Float.self), count:dataSize)
            multichannelBufferedDataArray[channelIndex].append(contentsOf: Array<Float>(audioDataArray))
        }
    }
    
    func processEffectData(audioDataPointer:UnsafeMutableAudioBufferListPointer,dataSize:Int) {
        for channelIndex in 0 ..< audioDataPointer.count {
            let audioDataArray = UnsafeMutableBufferPointer(start:audioDataPointer[channelIndex].mData!.assumingMemoryBound(to: Float.self), count:dataSize)
            for i in 0 ..< dataSize {
                if effectIndex < producedEffectDataArray[channelIndex].count {
                    audioDataArray[i] = producedEffectDataArray[channelIndex][effectIndex+i]
                }
            }
            vDSP_vsmul(audioDataArray.baseAddress!, 1, &gainParameter.value, audioDataArray.baseAddress!, 1, vDSP_Length(dataSize))
        }
        effectIndex += dataSize
        if effectIndex >= producedEffectDataArray[0].count-1 || effectIndex >= effectBlockSize-1 {
            usingRandomEffect = false
        }
    }
    
    func setEffectDataArray() {
        let effectType = Int(arc4random_uniform(2))
        switch effectType {
        case 0:
            producedEffectDataArray = effectData.getOriginData()
        case 1:
            producedEffectDataArray = effectData.produceReversedDataArray()
        default:
            producedEffectDataArray = effectData.getOriginData()
        }
    }
}
