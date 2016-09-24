//
//  AudioRandomizerTests.swift
//  AudioRandomizerTests
//
//  Created by leroy on 2016/9/25.
//  Copyright © 2016年 leroy. All rights reserved.
//

import XCTest
@testable import AudioRandomizer
class AudioRandomizerTests: XCTestCase {
    var effectData:EffectData!
    override func setUp() {
        super.setUp()
        var data1:[UnsafeMutableBufferPointer<Float>] = [UnsafeMutableBufferPointer<Float>]()
        var data2:[UnsafeMutableBufferPointer<Float>] = [UnsafeMutableBufferPointer<Float>]()
        for x in 0 ..< 2 {
            let ptr1 = UnsafeMutablePointer<Float>.allocate(capacity: Int(MemoryLayout<Float>.size)*2)
            let buffer1 = UnsafeMutableBufferPointer(start: ptr1, count: 2)
            for i in 0 ..< 2 {
                buffer1[i] = Float(i+x)
                print(buffer1[i])
            }
            
            data1.append(buffer1)
        }
        for x in 0 ..< 2 {
            let ptr1 = UnsafeMutablePointer<Float>.allocate(capacity: Int(MemoryLayout<Float>.size)*2)
            let buffer1 = UnsafeMutableBufferPointer(start: ptr1, count: 2)
            for i in 0 ..< 2 {
                buffer1[i] = Float(i+x*2)
            }
            data2.append(buffer1)
        }
        
        
        effectData = EffectData(originDataArray:[data1,data2])
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testEffectDataInit() {
        print(effectData.multiChannelBufferedDataArray.count)
        print(effectData.multiChannelBufferedDataArray[0][0][1])
        print(effectData.multiChannelBufferedDataArray[1][0][1])
        assert(effectData.multiChannelBufferedDataArray[0][0][1] == 1)
        assert(effectData.multiChannelBufferedDataArray[1][1][1] == 3 )
    }
    
    func testReversedData() {
        var reversedArray = effectData.produceReversedDataArray()
        assert(reversedArray[0][0][0] == 2)
        assert(reversedArray[1][1][1] == 0)
        assert(reversedArray[1][0][0] == 3)
    }
    
}
