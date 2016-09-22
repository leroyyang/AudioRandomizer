//
//  AudioUnitViewController.swift
//  AudioRandomizerExtensionMac
//
//  Created by leroy on 2016/9/22.
//  Copyright © 2016年 leroy. All rights reserved.
//

import CoreAudioKit

public class AudioUnitViewController: AUViewController, AUAudioUnitFactory {
    var audioUnit: AUAudioUnit?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if audioUnit == nil {
            return
        }
        
        // Get the parameter tree and add observers for any parameters that the UI needs to keep in sync with the AudioUnit
    }
    public override func beginRequest(with context: NSExtensionContext) {
        print("a")
    }
    public func createAudioUnit(with componentDescription: AudioComponentDescription) throws -> AUAudioUnit {
        audioUnit = try RandomizerAudioUnit(componentDescription: componentDescription, options: [])
        
        return audioUnit!
    }
    
}
