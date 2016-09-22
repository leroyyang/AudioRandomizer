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
    private var gainParameter:AUParameter!
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
        gainParameter = AUParameterTree.createParameter(withIdentifier: GainParameter.name, name: GainParameter.name, address: GainParameter.address, min: GainParameter.minValue, max: GainParameter.maxValue, unit: AudioUnitParameterUnit.percent, unitName: nil, flags: [], valueStrings: nil, dependentParameters: nil)
        gainParameter.value = GainParameter.defaultValue
        _parameterTree = AUParameterTree.createTree(withChildren: [gainParameter])
        _parameterTree.implementorValueProvider = {(parameter) in
            return self.randomizerCore.getValue(address: parameter.address)
        }
        
    }
    //MARK: - preset
    
    private func setupFactoryPresets() {
        let preset = AUAudioUnitPreset()
        preset.number = 0
        preset.name = "first"
        let preset2 = AUAudioUnitPreset()
        preset2.number = 1
        preset2.name = "second"
        let preset3 = AUAudioUnitPreset()
        preset3.number = 2
        preset3.name = "third"
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
    
    
    //MARK: - render
    override public var internalRenderBlock: AUInternalRenderBlock {
        return { [weak self] actionFlags, timestamp, frameCount, outputBusNumber, outputData, realtimeEventListHead, pullInputBlock in
            guard let s = self, let pullBlock = pullInputBlock else {
                return kAudioUnitErr_NoConnection
            }
            let dataSize = UInt32(outputData.pointee.mBuffers.mNumberChannels * UInt32(Int(MemoryLayout<Float>.size)) * frameCount)
           
            let data = malloc(Int(dataSize))
            var buffer = AudioBuffer.init(mNumberChannels: outputData.pointee.mBuffers.mNumberChannels, mDataByteSize: dataSize, mData: data)
            var bufferList = AudioBufferList.init(mNumberBuffers: outputData.pointee.mNumberBuffers, mBuffers: buffer)
            //var bufferList:UnsafeMutablePointer<AudioBufferList>  = UnsafeMutablePointer<AudioBufferList>.allocate(capacity: 1)
           /* var audioBuffer = AudioBuffer()
            audioBuffer.mDataByteSize = outputData.pointee.mBuffers.mDataByteSize
            audioBuffer.mNumberChannels = outputData.pointee.mBuffers.mNumberChannels
            audioBuffer.mData = malloc(Int(frameCount)*Int(MemoryLayout<Float>.size))
            var bufferList = AudioBufferList(mNumberBuffers: outputData.pointee.mNumberBuffers, mBuffers:audioBuffer )
            */
            let status = pullBlock(actionFlags, timestamp, frameCount, 0, &bufferList);
            
            
            if bufferList.mBuffers.mData != nil {
            self?.randomizerCore.processAudioData(audioData: (bufferList.mBuffers.mData!.assumingMemoryBound(to: Float.self)), dataSize: Int(bufferList.mBuffers.mDataByteSize)/MemoryLayout<Float>.size)
            }
            let dataArray = UnsafeBufferPointer(start: bufferList.mBuffers.mData?.assumingMemoryBound(to: Float.self), count:  Int(bufferList.mBuffers.mDataByteSize)/MemoryLayout<Float>.size)
            memcpy(outputData.pointee.mBuffers.mData, bufferList.mBuffers.mData, Int(dataSize))
            return status
            
        }
    }

}
