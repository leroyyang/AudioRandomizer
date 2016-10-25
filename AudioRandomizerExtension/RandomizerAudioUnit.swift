//
//  RandomizerAudioUnit.swift
//  AudioRandomizer
//
//  Created by leroy on 2016/9/21.
//  Copyright © 2016年 leroy. All rights reserved.
//

import Foundation
import AudioUnit
import AVFoundation
class RandomizerAudioUnit:AUAudioUnit {
    private let maxChannels = 2
    private var _inputBusses: AUAudioUnitBusArray!
    private var _outputBusses: AUAudioUnitBusArray!
    private var _parameterTree: AUParameterTree!
    private let randomizerCore = RandomizerCore()
    private var inputBuffer:UnsafeMutablePointer<AudioBufferList>!
    private var _factoryPresets: [AUAudioUnitPreset]?
    private var currentPresetNumber = 0

    override public var inputBusses: AUAudioUnitBusArray {
        return _inputBusses
    }
    override public var outputBusses: AUAudioUnitBusArray {
        return _outputBusses
    }
    override public var parameterTree: AUParameterTree? {
        return _parameterTree
    }
    override public var factoryPresets: [AUAudioUnitPreset]? {
        return _factoryPresets
    }
    private func setUpBusses() throws {
        let defaultFormat = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)
        let inputBus = try AUAudioUnitBus(format: defaultFormat)
        let outputBus = try AUAudioUnitBus(format: defaultFormat)
        
        outputBus.maximumChannelCount = AUAudioChannelCount(maxChannels)
        _inputBusses = AUAudioUnitBusArray(audioUnit: self, busType: AUAudioUnitBusType.input, busses: [inputBus])
        _outputBusses = AUAudioUnitBusArray(audioUnit: self, busType: AUAudioUnitBusType.output, busses: [outputBus])
    }
    override init(componentDescription: AudioComponentDescription, options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)
        setupParameterTree()
        setupFactoryPresets()
        try setUpBusses()
        
    }
    
    override func allocateRenderResources() throws {
        try super.allocateRenderResources()
    }
    private func setupParameterTree() {
        let gainParameter = AUParameterTree.createParameter(withIdentifier: GainParameter.name, name: GainParameter.name, address: GainParameter.address, min: GainParameter.minValue, max: GainParameter.maxValue, unit: AudioUnitParameterUnit.percent, unitName: nil, flags: [], valueStrings: nil, dependentParameters: nil)
        gainParameter.value = GainParameter.defaultValue
        randomizerCore.gainParameter = gainParameter
        _parameterTree = AUParameterTree.createTree(withChildren: [gainParameter])
        
        
    }
    
    //MARK: - preset
    private func setupFactoryPresets() {
        let preset = AUAudioUnitPreset()
        preset.number = 0
        preset.name = "loud"
        PresetModel.add(preset:RandomizerPreset(gain: 1),presetNumber: 0)
        let preset2 = AUAudioUnitPreset()
        preset2.number = 1
        preset2.name = "mid"
        PresetModel.add(preset:RandomizerPreset(gain: 0.5),presetNumber: 1)
        let preset3 = AUAudioUnitPreset()
        preset3.number = 2
        preset3.name = "quiet"
        PresetModel.add(preset:RandomizerPreset(gain: 0.1),presetNumber: 2)
        _factoryPresets = [preset,preset2,preset3]
        self.currentPreset = preset
    }
    
    override var currentPreset: AUAudioUnitPreset? {
        didSet {
            currentPresetNumber = currentPreset == nil ? currentPresetNumber : currentPreset!.number
            let preset = PresetModel.getPreset(presetNumber: currentPresetNumber)
            randomizerCore.setGain(value: preset.gain)
        }
    }
    
    func setGain(value:Float) {
        randomizerCore.setGain(value: value)
    }
    
    //MARK: - render
    override public var internalRenderBlock: AUInternalRenderBlock {
        return { [weak self] actionFlags, timestamp, frameCount, outputBusNumber, outputData, realtimeEventListHead, pullInputBlock in
            guard let strongSelf = self, let pullBlock = pullInputBlock else {
                return kAudioUnitErr_NoConnection
            }
            let dataByteSize = outputData.pointee.mBuffers.mDataByteSize
            let data1 = malloc(Int(dataByteSize))
            let data2 = malloc(Int(dataByteSize))
            let bufferListPointer = AudioBufferList.allocate(maximumBuffers: Int(outputData.pointee.mNumberBuffers))
            bufferListPointer[0] = AudioBuffer.init(mNumberChannels: 1, mDataByteSize: dataByteSize, mData: data1)
            bufferListPointer[1] = AudioBuffer.init(mNumberChannels: 1, mDataByteSize: dataByteSize, mData: data2)
            
            let status = pullBlock(actionFlags, timestamp, frameCount, outputBusNumber, bufferListPointer.unsafeMutablePointer);
            let bufferedOutput = UnsafeMutableAudioBufferListPointer(outputData)
            strongSelf.randomizerCore.processAudioData(audioDataPointer:bufferListPointer , dataByteSize: Int(dataByteSize))
            for i in 0 ..< bufferedOutput.count {
                memcpy(bufferedOutput[i].mData, bufferListPointer[i].mData,Int(dataByteSize))
            }
            return status
            
        }
    }

}
