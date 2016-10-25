//
//  PresetModel.swift
//  AudioRandomizer
//
//  Created by leroy on 2016/9/23.
//  Copyright © 2016年 leroy. All rights reserved.
//

import Foundation

class PresetModel {
    static private var presets:[Int:RandomizerPreset] = [Int:RandomizerPreset]()
    static func getPreset(presetNumber:Int)->RandomizerPreset {
        return  presets[presetNumber]!
    }
    static func add(preset:RandomizerPreset,presetNumber:Int) {
        presets[presetNumber] = preset
    }
}
struct RandomizerPreset {
    var gain:Float = 1
    init(gain:Float) {
        self.gain = gain
    }
}
