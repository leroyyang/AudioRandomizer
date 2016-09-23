//
//  AudioUnitViewController.swift
//  AudioRandomizerExtension
//
//  Created by leroy on 2016/9/21.
//  Copyright © 2016年 leroy. All rights reserved.
//

import CoreAudioKit

public class AudioUnitViewController: AUViewController, AUAudioUnitFactory {
    var audioUnit: RandomizerAudioUnit?
    
    @IBOutlet weak var gainSlider: UISlider!
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if audioUnit == nil {
            return
        }
        
        // Get the parameter tree and add observers for any parameters that the UI needs to keep in sync with the AudioUnit
    }
    
    
    @IBAction func gainValueChanged(_ sender: AnyObject) {
        audioUnit?.setGain(value: gainSlider.value)
        
    }
    
    public func createAudioUnit(with componentDescription: AudioComponentDescription) throws -> AUAudioUnit {
        audioUnit = try RandomizerAudioUnit(componentDescription: componentDescription, options: [])
        
        return audioUnit!
    }
    
    
}
