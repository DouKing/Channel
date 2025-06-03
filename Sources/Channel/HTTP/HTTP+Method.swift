//===----------------------------------------------------------*- swift -*-===//
//
// Created by Yikai Wu on 2024/3/24.
// Copyright © 2024 Yikai Wu. All rights reserved.
//
//===----------------------------------------------------------------------===//

import Foundation

extension HTTP {
    /// Type representing HTTP methods. Raw `String` value is stored and compared case-sensitively, so
    /// `HTTP.Method.get != HTTP.Method(rawValue: "get")`.
    ///
    /// See https://tools.ietf.org/html/rfc7231#section-4.3
    public struct Method: RawRepresentable, Equatable, Hashable, Sendable {
        /// `CONNECT` method.
        public static let connect = Method(rawValue: "CONNECT")
        /// `DELETE` method.
        public static let delete = Method(rawValue: "DELETE")
        /// `GET` method.
        public static let get = Method(rawValue: "GET")
        /// `HEAD` method.
        public static let head = Method(rawValue: "HEAD")
        /// `OPTIONS` method.
        public static let options = Method(rawValue: "OPTIONS")
        /// `PATCH` method.
        public static let patch = Method(rawValue: "PATCH")
        /// `POST` method.
        public static let post = Method(rawValue: "POST")
        /// `PUT` method.
        public static let put = Method(rawValue: "PUT")
        /// `QUERY` method.
        public static let query = Method(rawValue: "QUERY")
        /// `TRACE` method.
        public static let trace = Method(rawValue: "TRACE")
        
        public let rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}
