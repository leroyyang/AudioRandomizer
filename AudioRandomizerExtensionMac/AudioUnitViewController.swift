//
//  AudioUnitViewController.swift
//  AudioRandomizerExtensionMac
//
//  Created by leroy on 2016/9/22.
//  Copyright © 2016年 leroy. All rights reserved.
//

import CoreAudioKit

public class MacAudioUnitViewController: AUViewController, AUAudioUnitFactory {
    var audioUnit: AUAudioUnit?
    
  
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if audioUnit == nil {
            return
        }
    }

    public func createAudioUnit(with componentDescription: AudioComponentDescription) throws -> AUAudioUnit {
        @IBAction func gainValueChanged(_ sender: AnyObject) {
        }
        audioUnit = try RandomizerAudioUnit(componentDescription: componentDescription, options: [])
        
        return audioUnit!
    }

}
