//===----------------------------------------------------------*- Swift -*-===//
//
// Created by Yikai Wu on 2024/3/28.
// Copyright © 2024 Yikai Wu. All rights reserved.
//
//===----------------------------------------------------------------------===//

import XCTest
import Channel

final class AmplitudesTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() async throws {
        var mockFloats = [Float]()
        for _ in 0...65 {
            mockFloats.append(Float.random(in: 0...0.1))
        }
        
        print(mockFloats)
        
        let amplitudes = await Channel.calculateAmplitudes(mockFloats)
        print(amplitudes)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
