//===----------------------------------------------------------*- Swift -*-===//
//
// Created by wuyikai on 2024/5/6.
// Copyright © 2024 wuyikai. All rights reserved.
//
//===----------------------------------------------------------------------===//

import XCTest
import Channel

struct QueryParameter: Encodable, HTTP.Parameterable {
    var age = 10
    var foo = "foo"
}

let queryJSON: HTTP.JSONObject = [
    "age": 10,
    "foo": "foo"
]

struct BodyParameter: Encodable, HTTP.Parameterable {
    var bar = "bar"
    var list = [1, 2, 3]
}

let bodyJSON: HTTP.JSONObject = [
    "bar": "bar",
    "list": [1, 2, 3]
]

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

    func testHTTPParameters() throws {
        var request = URLRequest(url: URL(string: "https://nonexistent-domain.org")!, method: .post)
        
        let query = HTTP.URLFormData(parameterable: QueryParameter())
        try request.setQuery(query)
        
        print(request.url!)
        XCTAssertEqual(request.url!.absoluteString, "https://nonexistent-domain.org?age=10&foo=foo")
        
        let body = HTTP.JSONData.init(parameterable: BodyParameter())
        try request.setBody(body)
        
        let str = String(data: request.httpBody!, encoding: .utf8)!
        print(str) // {"bar":"bar","list":[1,2,3]}
        XCTAssertEqual(str, "{\"bar\":\"bar\",\"list\":[1,2,3]}")
    }

    func testHTTPJSONParameters() throws {
        var request = URLRequest(url: URL(string: "https://nonexistent-domain.org")!, method: .post)
        
        let query = HTTP.URLFormData(parameterable: queryJSON)
        try request.setQuery(query)
        
        print(request.url!)
        XCTAssertEqual(request.url!.absoluteString, "https://nonexistent-domain.org?age=10&foo=foo")
        
        let body = HTTP.JSONData.init(parameterable: bodyJSON)
        try request.setBody(body)
        
        let str = String(data: request.httpBody!, encoding: .utf8)!
        print(str) // {"bar":"bar","list":[1,2,3]}
        XCTAssertEqual(str, "{\"bar\":\"bar\",\"list\":[1,2,3]}")
    }
}
