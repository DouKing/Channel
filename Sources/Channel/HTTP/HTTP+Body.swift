//===----------------------------------------------------------*- Swift -*-===//
//
// Created by wuyikai on 2024/5/6.
// Copyright © 2024 wuyikai. All rights reserved.
//
//===----------------------------------------------------------------------===//

import Foundation

extension HTTP {
    public typealias JSONObject = [String: Any]
    
    public protocol Body {
        func encode() throws -> Data
        var contentType: String { get }
    }
    
    public protocol Query {
        func encode() throws -> String
    }
}

extension HTTP.MultipartFormData: HTTP.Body {}

extension HTTP {
    public struct JSONData: HTTP.Body {
        public let encoder: JSONEncoder
        public let parameterable: Parameterable
        
        public var contentType: String {
            Header.Value.json.rawValue
        }
        
        public init(encoder: JSONEncoder = JSONEncoder(), parameterable: Parameterable) {
            self.encoder = encoder
            self.parameterable = parameterable
        }
        
        public func encode() throws -> Data {
            try self.parameterable.encode(use: self.encoder)
        }
    }
    
    public struct URLFormData: HTTP.Body, HTTP.Query {
        public let encoder: URLEncodedFormEncoder
        public let parameterable: Parameterable
        
        public var contentType: String {
            Header.Value.formUrlEncoded.rawValue
        }
        
        public init(encoder: URLEncodedFormEncoder = URLEncodedFormEncoder(),
                    parameterable: Parameterable) {
            self.encoder = encoder
            self.parameterable = parameterable
        }
        
        public func encode() throws -> Data {
            try self.parameterable.encode(use: self.encoder)
        }
        
        public func encode() throws -> String {
            let data = try self.parameterable.encode(use: self.encoder)
            return String(data: data, encoding: .utf8) ?? ""
        }
    }
}

extension HTTP {
    public protocol ParameterEncoder {
        func encode(encodable parameters: Encodable) throws -> Data
        func encode(json value: [String: Any]) throws -> String
    }
    
    public protocol Parameterable {
        func encode(use encoder: HTTP.ParameterEncoder) throws -> Data
    }
}

extension JSONEncoder: HTTP.ParameterEncoder {
    public func encode(json value: [String : Any]) throws -> String {
        guard JSONSerialization.isValidJSONObject(value) else {
            throw HTTP.Error.parameterEncodingFailed(reason: .jsonEncodingFailed(error: HTTP.Error.JSONEncodingError.invalidJSONObject))
        }
        let data = try JSONSerialization.data(withJSONObject: value)
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    public func encode(encodable parameters: any Encodable) throws -> Data {
        return try self.encode(parameters)
    }
}

extension URLEncodedFormEncoder: HTTP.ParameterEncoder {
    public func encode(json value: [String : Any]) throws -> String {
        return try self.encode(value)
    }
    
    public func encode(encodable parameters: any Encodable) throws -> Data {
        return try self.encode(parameters)
    }
}

extension HTTP.JSONObject: HTTP.Parameterable {
    public func encode(use encoder: any HTTP.ParameterEncoder) throws -> Data {
        let str = try encoder.encode(json: self)
        return str.data(using: .utf8) ?? Data()
    }
}

extension HTTP.Parameterable where Self: Encodable {
    public func encode(use encoder: any HTTP.ParameterEncoder) throws -> Data {
        return try encoder.encode(encodable: self)
    }
}
