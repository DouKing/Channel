//===----------------------------------------------------------*- Swift -*-===//
//
// Created by wuyikai on 2024/5/6.
// Copyright © 2024 wuyikai. All rights reserved.
//
//===----------------------------------------------------------------------===//

import XCTest
import Channel

final class HTTPTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testURLEncode() throws {
        let encoder = URLEncodedFormEncoder()
        
        let data: String = try! encoder.encode(["a": 1, "b": true, "c": [2, 3]])
        print(data)
        XCTAssertEqual(data, "a=1&b=1&c%5B%5D=2&c%5B%5D=3")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
