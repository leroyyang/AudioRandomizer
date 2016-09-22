//
//  PresetModel.swift
//  AudioRandomizer
//
//  Created by leroy on 2016/9/23.
//  Copyright © 2016年 leroy. All rights reserved.
//

import Foundation

class PresetModel {
    static private let presets:[RandomizerPreset] = [ RandomizerPreset(gain: 1),RandomizerPreset(gain: 0.5),RandomizerPreset(gain: 0.1)]
    static func getPreset(presetNumber:Int)->RandomizerPreset {
        if presetNumber < presets.count {
           return  presets[presetNumber]
        } else {
            return presets[0]
        }
    }
}
struct RandomizerPreset {
    var gain:Float = 1
    init(gain:Float) {
        self.gain = gain
    }
}
