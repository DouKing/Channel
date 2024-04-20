//===----------------------------------------------------------*- swift -*-===//
//
// Created by Yikai Wu on 2024/3/24.
// Copyright © 2024 Yikai Wu. All rights reserved.
//
//===----------------------------------------------------------------------===//

import Foundation.NSURLRequest

extension URLRequest {
    /// Creates an instance with the specified `url`, `method`, and `headers`.
    ///
    /// - Parameters:
    ///   - url:     The `URL` value.
    ///   - method:  The `HTTP.Method`.
    ///   - headers: The `[HTT.PHeader]`, `nil` by default.
    /// - Throws:    Any error thrown while converting the `URLConvertible` to a `URL`.
    public init(url: URL, method: HTTP.Method, headers: [HTTP.Header]? = nil) throws {
        self.init(url: url)
        
        httpMethod = method.rawValue
        allHTTPHeaderFields = headers?.headerFields
    }
}
