//===----------------------------------------------------------*- swift -*-===//
//
// Created by Yikai Wu on 2024/3/24.
// Copyright © 2024 Yikai Wu. All rights reserved.
//
//===----------------------------------------------------------------------===//

import Foundation

extension HTTP {
    /// A representation of a single HTTP header's name / value pair.
    public struct Header: Hashable {
        /// Name of the header.
        public let name: String
        
        /// Value of the header.
        public let value: String
        
        /// Creates an instance from the given `name` and `value`.
        ///
        /// - Parameters:
        ///   - name:  The name of the header.
        ///   - value: The value of the header.
        public init(name: String, value: String) {
            self.name = name
            self.value = value
        }
    }
}

extension HTTP.Header: CustomStringConvertible {
    public var description: String {
        "\(name): \(value)"
    }
}

extension HTTP.Header {
    public struct Name: Hashable, Equatable, RawRepresentable, @unchecked Sendable {
        public let rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }
    }
    
    /// Creates an instance from the given `name` and `value`.
    ///
    /// - Parameters:
    ///   - name:  The name of the header.
    ///   - value: The value of the header.
    public init(name: Name, value: String) {
        self.init(name: name.rawValue, value: value)
    }
}

extension HTTP.Header.Name {
    /// Accept
    public static var accept = HTTP.Header.Name("Accept")
    /// Accept-Charset
    public static var acceptCharset = HTTP.Header.Name("Accept-Charset")
    /// Accept-Language
    public static var acceptLanguage = HTTP.Header.Name("Accept-Language")
    /// Accept-Encoding
    public static var acceptEncoding = HTTP.Header.Name("Accept-Encoding")
    /// Authorization
    public static var authorization = HTTP.Header.Name("Authorization")
    /// Content-Disposition
    public static var contentDisposition = HTTP.Header.Name("Content-Disposition")
    /// Content-Encoding
    public static var contentEncoding = HTTP.Header.Name("Content-Encoding")
    /// Content-Type
    public static var contentType = HTTP.Header.Name("Content-Type")
    /// User-Agent
    public static var userAgent = HTTP.Header.Name("User-Agent")
    /// Sec-WebSocket-Protocol
    public static var websocketProtocol = HTTP.Header.Name("Sec-WebSocket-Protocol")
}

extension HTTP.Header {
    /// Returns an `Accept` header.
    ///
    /// - Parameter value: The `Accept` value.
    /// - Returns:         The header.
    public static func accept(_ value: String) -> HTTP.Header {
        HTTP.Header(name: .accept, value: value)
    }
    
    /// Returns an `Accept-Charset` header.
    ///
    /// - Parameter value: The `Accept-Charset` value.
    /// - Returns:         The header.
    public static func acceptCharset(_ value: String) -> HTTP.Header {
        HTTP.Header(name: .acceptCharset, value: value)
    }
    
    /// Returns an `Accept-Language` header.
    ///
    /// Alamofire offers a default Accept-Language header that accumulates and encodes the system's preferred languages.
    /// Use `HTTPHeader.defaultAcceptLanguage`.
    ///
    /// - Parameter value: The `Accept-Language` value.
    ///
    /// - Returns:         The header.
    public static func acceptLanguage(_ value: String) -> HTTP.Header {
        HTTP.Header(name: .acceptLanguage, value: value)
    }
    
    /// Returns an `Accept-Encoding` header.
    ///
    /// Alamofire offers a default accept encoding value that provides the most common values. Use
    /// `HTTPHeader.defaultAcceptEncoding`.
    ///
    /// - Parameter value: The `Accept-Encoding` value.
    ///
    /// - Returns:         The header
    public static func acceptEncoding(_ value: String) -> HTTP.Header {
        HTTP.Header(name: .acceptEncoding, value: value)
    }
    
    /// Returns a `Basic` `Authorization` header using the `username` and `password` provided.
    ///
    /// - Parameters:
    ///   - username: The username of the header.
    ///   - password: The password of the header.
    ///
    /// - Returns:    The header.
    public static func authorization(username: String, password: String) -> HTTP.Header {
        let credential = Data("\(username):\(password)".utf8).base64EncodedString()
        
        return authorization("Basic \(credential)")
    }
    
    /// Returns a `Bearer` `Authorization` header using the `bearerToken` provided.
    ///
    /// - Parameter bearerToken: The bearer token.
    ///
    /// - Returns:               The header.
    public static func authorization(bearerToken: String) -> HTTP.Header {
        authorization("Bearer \(bearerToken)")
    }
    
    /// Returns an `Authorization` header.
    ///
    /// Alamofire provides built-in methods to produce `Authorization` headers. For a Basic `Authorization` header use
    /// `HTTPHeader.authorization(username:password:)`. For a Bearer `Authorization` header, use
    /// `HTTPHeader.authorization(bearerToken:)`.
    ///
    /// - Parameter value: The `Authorization` value.
    ///
    /// - Returns:         The header.
    public static func authorization(_ value: String) -> HTTP.Header {
        HTTP.Header(name: .authorization, value: value)
    }
    
    /// Returns a `Content-Disposition` header.
    ///
    /// - Parameter value: The `Content-Disposition` value.
    ///
    /// - Returns:         The header.
    public static func contentDisposition(_ value: String) -> HTTP.Header {
        HTTP.Header(name: .contentDisposition, value: value)
    }
    
    /// Returns a `Content-Encoding` header.
    ///
    /// - Parameter value: The `Content-Encoding`.
    ///
    /// - Returns:         The header.
    public static func contentEncoding(_ value: String) -> HTTP.Header {
        HTTP.Header(name: .contentEncoding, value: value)
    }
    
    /// Returns a `Content-Type` header.
    ///
    /// All Alamofire `ParameterEncoding`s and `ParameterEncoder`s set the `Content-Type` of the request, so it may not
    /// be necessary to manually set this value.
    ///
    /// - Parameter value: The `Content-Type` value.
    ///
    /// - Returns:         The header.
    public static func contentType(_ value: String) -> HTTP.Header {
        HTTP.Header(name: .contentType, value: value)
    }
    
    /// Returns a `User-Agent` header.
    ///
    /// - Parameter value: The `User-Agent` value.
    ///
    /// - Returns:         The header.
    public static func userAgent(_ value: String) -> HTTP.Header {
        HTTP.Header(name: .userAgent, value: value)
    }
    
    /// Returns a `Sec-WebSocket-Protocol` header.
    ///
    /// - Parameter value: The `Sec-WebSocket-Protocol` value.
    /// - Returns:         The header.
    public static func websocketProtocol(_ value: String) -> HTTP.Header {
        HTTP.Header(name: .websocketProtocol, value: value)
    }
}

extension [HTTP.Header] {
    /// Case-insensitively find a header's value by name.
    ///
    /// - Parameter name: The name of the header to search for, case-insensitively.
    ///
    /// - Returns:        The value of header, if it exists.
    public func value(for name: String) -> String? {
        guard let index = index(of: name) else { return nil }
        
        return self[index].value
    }
    
    /// Case-insensitively find a header's value by name.
    ///
    /// - Parameter name: The name of the header to search for, case-insensitively.
    ///
    /// - Returns:        The value of header, if it exists.
    public func value(for name: HTTP.Header.Name) -> String? {
        value(for: name.rawValue)
    }
    
    /// Case-insensitively access the header with the given name.
    ///
    /// - Parameter name: The name of the header.
    public subscript(_ name: String) -> String? {
        get { value(for: name) }
        set {
            if let value = newValue {
                update(name: name, value: value)
            } else {
                remove(name: name)
            }
        }
    }
    
    /// Case-insensitively access the header with the given name.
    ///
    /// - Parameter name: The name of the header.
    public subscript(_ name: HTTP.Header.Name) -> String? {
        get { value(for: name) }
        set {
            if let value = newValue {
                update(name: name, value: value)
            } else {
                remove(name: name)
            }
        }
    }
    
    /// Case-insensitively updates or appends an `HTTP.Header` into the instance using the provided `name` and `value`.
    ///
    /// - Parameters:
    ///   - name:  The `HTTP.Header` name.
    ///   - value: The `HTTP.Header` value.
    public mutating func update(name: String, value: String) {
        update(HTTP.Header(name: name, value: value))
    }
    
    /// Case-insensitively updates or appends an `HTTP.Header` into the instance using the provided `name` and `value`.
    ///
    /// - Parameters:
    ///   - name:  The `HTTP.Header` name.
    ///   - value: The `HTTP.Header` value.
    public mutating func update(name: HTTP.Header.Name, value: String) {
        update(HTTP.Header(name: name, value: value))
    }
    
    /// Case-insensitively updates or appends the provided `HTTP.Header` into the instance.
    ///
    /// - Parameter header: The `HTTP.Header` to update or append.
    public mutating func update(_ header: HTTP.Header) {
        guard let index = index(of: header.name) else {
            append(header)
            return
        }
        
        replaceSubrange(index...index, with: [header])
    }
    
    /// Case-insensitively removes an `HTTP.Header`, if it exists, from the instance.
    ///
    /// - Parameter name: The name of the `HTTP.Header` to remove.
    public mutating func remove(name: String) {
        guard let index = index(of: name) else { return }
        
        remove(at: index)
    }
    
    /// Case-insensitively removes an `HTTP.Header`, if it exists, from the instance.
    ///
    /// - Parameter name: The name of the `HTTP.Header` to remove.
    public mutating func remove(name: HTTP.Header.Name) {
        guard let index = index(of: name) else { return }
        
        remove(at: index)
    }
    
    /// Case-insensitively finds the index of an `HTTP.Header` with the provided name, if it exists.
    func index(of name: HTTP.Header.Name) -> Int? {
        return index(of: name.rawValue)
    }
    
    /// Case-insensitively finds the index of an `HTTP.Header` with the provided name, if it exists.
    func index(of name: String) -> Int? {
        let lowercasedName = name.lowercased()
        return firstIndex { $0.name.lowercased() == lowercasedName }
    }
    
    var headerFields: [String: String] {
        reduce(into: [String: String](), { partialResult, header in
            partialResult[header.name] = header.value
        })
    }
}

extension HTTP.Header {
    /// Returns Alamofire's default `Accept-Encoding` header, appropriate for the encodings supported by particular OS
    /// versions.
    ///
    /// See the [Accept-Encoding HTTP header documentation](https://tools.ietf.org/html/rfc7230#section-4.2.3) .
    public static let defaultAcceptEncoding: HTTP.Header = {
        let encodings: [String]
        if #available(iOS 11.0, macOS 10.13, tvOS 11.0, watchOS 4.0, *) {
            encodings = ["br", "gzip", "deflate"]
        } else {
            encodings = ["gzip", "deflate"]
        }
        
        return .acceptEncoding(encodings.qualityEncoded())
    }()
    
    /// Returns Alamofire's default `Accept-Language` header, generated by querying `Locale` for the user's
    /// `preferredLanguages`.
    ///
    /// See the [Accept-Language HTTP header documentation](https://tools.ietf.org/html/rfc7231#section-5.3.5).
    public static let defaultAcceptLanguage: HTTP.Header = .acceptLanguage(Locale.preferredLanguages.prefix(6).qualityEncoded())
    
    /// Returns Alamofire's default `User-Agent` header.
    ///
    /// See the [User-Agent header documentation](https://tools.ietf.org/html/rfc7231#section-5.5.3).
    ///
    /// Example: `iOS Example/1.0 (org.channel.iOS-Example; build:1; iOS 13.0.0) Channel/5.0.0`
    public static let defaultUserAgent: HTTP.Header = {
        let info = Bundle.main.infoDictionary
        let executable = (info?["CFBundleExecutable"] as? String) ??
        (ProcessInfo.processInfo.arguments.first?.split(separator: "/").last.map(String.init)) ??
        "Unknown"
        let bundle = info?["CFBundleIdentifier"] as? String ?? "Unknown"
        let appVersion = info?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let appBuild = info?["CFBundleVersion"] as? String ?? "Unknown"
        
        let osNameVersion: String = {
            let version = ProcessInfo.processInfo.operatingSystemVersion
            let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
            let osName: String = {
#if os(iOS)
#if targetEnvironment(macCatalyst)
                return "macOS(Catalyst)"
#else
                return "iOS"
#endif
#elseif os(watchOS)
                return "watchOS"
#elseif os(tvOS)
                return "tvOS"
#elseif os(macOS)
#if targetEnvironment(macCatalyst)
                return "macOS(Catalyst)"
#else
                return "macOS"
#endif
#elseif swift(>=5.9.2) && os(visionOS)
                return "visionOS"
#elseif os(Linux)
                return "Linux"
#elseif os(Windows)
                return "Windows"
#elseif os(Android)
                return "Android"
#else
                return "Unknown"
#endif
            }()
            
            return "\(osName) \(versionString)"
        }()
        
        let channelVersion = "\(ChannelInfo.name)/\(ChannelInfo.version)"
        
        let userAgent = "\(executable)/\(appVersion) (\(bundle); build:\(appBuild); \(osNameVersion)) \(channelVersion)"
        
        return .userAgent(userAgent)
    }()
}

extension Collection<String> {
    func qualityEncoded() -> String {
        enumerated().map { index, encoding in
            let quality = 1.0 - (Double(index) * 0.1)
            return "\(encoding);q=\(quality)"
        }.joined(separator: ", ")
    }
}

// MARK: - System Type Extensions

extension URLRequest {
    /// Returns `allHTTPHeaderFields` as `[HTTP.Header]`.
    public var headers: [HTTP.Header] {
        get { (allHTTPHeaderFields ?? [:]).map { HTTP.Header(name: $0.0, value: $0.1) } }
        set {
            allHTTPHeaderFields = newValue.reduce(into: [String: String](), { partialResult, header in
                partialResult[header.name] = header.value
            })
        }
    }
}

extension HTTPURLResponse {
    /// Returns `allHeaderFields` as `[HTTP.Header]`.
    public var headers: [HTTP.Header] {
        ((allHeaderFields as? [String: String]) ?? [:]).map{ HTTP.Header(name: $0.0, value: $0.1) }
    }
}

extension URLSessionConfiguration {
    /// Returns `httpAdditionalHeaders` as `[HTTP.Header]`.
    public var headers: [HTTP.Header] {
        get { ((httpAdditionalHeaders as? [String: String]) ?? [:]).map{ HTTP.Header(name: $0.0, value: $0.1) } }
        set {
            httpAdditionalHeaders = newValue.reduce(into: [String: String](), { partialResult, header in
                partialResult[header.name] = header.value
            })
        }
    }
}
