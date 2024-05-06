//===----------------------------------------------------------*- swift -*-===//
//
// Created by Yikai Wu on 2023/11/29.
// Copyright © 2023 Yikai Wu. All rights reserved.
//
//===----------------------------------------------------------------------===//

#if canImport(UIKit)
import XCTest
import Channel

@available(iOS 15.0, *)
final class UIColorFormatStyleTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let str = "#FF0000"
        let color = try! UIColorFormatStyle().parseStrategy.parse(str)
        XCTAssert(color == UIColor.red)
        XCTAssert(UIColorFormatStyle().format(color) == str)
        XCTAssert(UIColorFormatStyle().alpha(true).format(color) == str + "FF")
        
        if #available(iOS 15.0, *) {
            XCTAssert(color.formatted() == str)
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

#endif
