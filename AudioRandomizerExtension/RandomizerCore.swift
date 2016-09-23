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
    var bufferedDataArray:[UnsafeMutableBufferPointer<Float>] = [UnsafeMutableBufferPointer<Float>]()
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
        
        for index in 0 ..< audioDataPointer.count {
            let audioDataArray = UnsafeMutableBufferPointer(start:audioDataPointer[index].mData?.assumingMemoryBound(to: Float.self), count:dataSize)
            if bufferedDataArray.count < 10 {
                bufferedDataArray.append(audioDataArray)
            } else {
                let randNum = arc4random_uniform(9)
                bufferedDataArray.remove(at: Int(randNum))
                bufferedDataArray.append(audioDataArray)
            }
            let threshold:Float = 0.25
            var randChoose = false
            if  arc4random_uniform(10) > 3 && bufferedDataArray.count == 10 {
                randChoose = true
            }
            let randChooseIndex = Int(arc4random_uniform(9))
            for i in 0 ..< audioDataArray.count {
                /*if audioDataArray[i] > 0 {
                    audioDataArray[i] = fmin(audioDataArray[i], threshold)
                } else {
                    audioDataArray[i] = fmax(audioDataArray[i], -threshold)
                }
                audioDataArray[i] /= threshold
                audioDataArray[i] = 1.5*audioDataArray[i] - 0.5*audioDataArray[i]*audioDataArray[i]*audioDataArray[i]*/
                if randChoose {
                    audioDataArray[i] = (1+k)*bufferedDataArray[randChooseIndex][i] / (1+k*abs(bufferedDataArray[randChooseIndex][i]))
                } else {
                
                    audioDataArray[i] = (1+k)*audioDataArray[i] / (1+k*abs(audioDataArray[i]))
                }
                /*let randNum = arc4random_uniform(30)
                if randNum < 10 {
                    audioDataArray[i] *= 0.2
                } else if randNum > 20 {
                    audioDataArray[i] *= 1.3
                    if audioDataArray[i] > 1 {
                        audioDataArray[i] *= 0.75
                    }
                }*/
            }
            vDSP_vsmul(audioDataArray.baseAddress!, 1, &gainParameter.value, audioDataArray.baseAddress!, 1, vDSP_Length(dataSize))
        }
        
        
        
        
    }
    
}
