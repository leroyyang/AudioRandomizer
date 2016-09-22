//
//  AudioParameter.swift
//  AudioRandomizer
//
//  Created by leroy on 2016/9/22.
//  Copyright © 2016年 leroy. All rights reserved.
//

import Foundation

protocol AudioParameter {
    static var name:String {get}
    static var minValue:Float {get}
    static var maxValue:Float {get}
    static var address:UInt64 {get}
    static var defaultValue:Float {get}
    var value:Float {get set}
}

struct GainParameter:AudioParameter {
    static let address: UInt64 = 1
    static let maxValue: Float = 1
    static let minValue: Float = 0
    static let name: String = "Gain"
    static var defaultValue: Float = 1
    var value:Float = 1
}

class AudioParamterGetter {
    static func getParameter(address:Int)->AudioParameter {
        switch(address) {
        case Int(GainParameter.address):
            return GainParameter()
        default:
            return GainParameter()
        }
        
    }
}
