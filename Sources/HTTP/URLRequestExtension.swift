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
    public init(url: URL, method: HTTP.Method, headers: [HTTP.Header]? = nil) {
        self.init(url: url)
        
        httpMethod = method.rawValue
        allHTTPHeaderFields = headers?.headerFields
    }
    
    /// Set the `httpBody` for the instance
    /// - Parameter body: The `HTTP.Body`
    public mutating func setBody(_ body: HTTP.Body) throws {
        if self.headers[HTTP.Header.Name.contentType] == nil {
            self.headers.update(.contentType(body.contentType))
        }
        
        self.httpBody = try Result<Data, Error> { try body.encode() }
            .mapError { HTTP.Error.parameterEncodingFailed(reason: .encoderFailed(error: $0)) }
            .get()
    }
    
    /// Set the URL query parameters for the instance
    /// - Parameter query: The `HTTP.Query`
    public mutating func setQuery(_ query: HTTP.Query) throws {
        guard let url = self.url,
              var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else {
            throw HTTP.Error.parameterEncodingFailed(reason: .missingRequiredComponent(.url))
        }

        let queryString: String = try Result<String, Error> { try query.encode() }
            .mapError { HTTP.Error.parameterEncodingFailed(reason: .encoderFailed(error: $0)) }
            .get()
        
        let newQueryString = [components.percentEncodedQuery, queryString].compactMap { $0 }.joinedWithAmpersands()
        components.percentEncodedQuery = newQueryString.isEmpty ? nil : newQueryString

        guard let newURL = components.url else {
            throw HTTP.Error.parameterEncodingFailed(reason: .missingRequiredComponent(.url))
        }
        
        self.url = newURL
    }
}
