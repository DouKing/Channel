//===----------------------------------------------------------*- Swift -*-===//
//
// Created by wuyikai on 2024/5/6.
// Copyright © 2024 wuyikai. All rights reserved.
//
//===----------------------------------------------------------------------===//

import Foundation

/// An object that encodes instances into URL-encoded query strings.
///
/// `ArrayEncoding` can be used to configure how `Array` values are encoded. By default, the `.brackets` encoding is
/// used, encoding array values with brackets for each value. e.g `array[]=1&array[]=2`.
///
/// `BoolEncoding` can be used to configure how `Bool` values are encoded. By default, the `.numeric` encoding is used,
/// encoding `true` as `1` and `false` as `0`.
///
/// `DataEncoding` can be used to configure how `Data` values are encoded. By default, the `.deferredToData` encoding is
/// used, which encodes `Data` values using their default `Encodable` implementation.
///
/// `DateEncoding` can be used to configure how `Date` values are encoded. By default, the `.deferredToDate`
/// encoding is used, which encodes `Date`s using their default `Encodable` implementation.
///
/// `KeyEncoding` can be used to configure how keys are encoded. By default, the `.useDefaultKeys` encoding is used,
/// which encodes the keys directly from the `Encodable` implementation.
///
/// `KeyPathEncoding` can be used to configure how paths within nested objects are encoded. By default, the `.brackets`
/// encoding is used, which encodes each sub-key in brackets. e.g. `parent[child][grandchild]=value`.
///
/// `NilEncoding` can be used to configure how `nil` `Optional` values are encoded. By default, the `.dropKey` encoding
/// is used, which drops `nil` key / value pairs from the output entirely.
///
/// `SpaceEncoding` can be used to configure how spaces are encoded. By default, the `.percentEscaped` encoding is used,
/// replacing spaces with `%20`.
///
/// This type is largely based on Vapor's [`url-encoded-form`](https://github.com/vapor/url-encoded-form) project.
public final class URLEncodedFormEncoder {
    /// Whether or not to sort the encoded key value pairs.
    ///
    /// - Note: This setting ensures a consistent ordering for all encodings of the same parameters. When set to `false`,
    ///         encoded `Dictionary` values may have a different encoded order each time they're encoded due to
    ///       ` Dictionary`'s random storage order, but `Encodable` types will maintain their encoded order.
    public let alphabetizeKeyValuePairs: Bool
    /// The `ArrayEncoding` to use.
    public let arrayEncoding: URLEncoding.ArrayEncoding
    /// The `BoolEncoding` to use.
    public let boolEncoding: URLEncoding.BoolEncoding
    /// THe `DataEncoding` to use.
    public let dataEncoding: URLEncoding.DataEncoding
    /// The `DateEncoding` to use.
    public let dateEncoding: URLEncoding.DateEncoding
    /// The `KeyEncoding` to use.
    public let keyEncoding: URLEncoding.KeyEncoding
    /// The `KeyPathEncoding` to use.
    public let keyPathEncoding: URLEncoding.KeyPathEncoding
    /// The `NilEncoding` to use.
    public let nilEncoding: URLEncoding.NilEncoding
    /// The `SpaceEncoding` to use.
    public let spaceEncoding: URLEncoding.SpaceEncoding
    /// The `CharacterSet` of allowed (non-escaped) characters.
    public var allowedCharacters: CharacterSet

    /// Creates an instance from the supplied parameters.
    ///
    /// - Parameters:
    ///   - alphabetizeKeyValuePairs: Whether or not to sort the encoded key value pairs. `true` by default.
    ///   - arrayEncoding:            The `ArrayEncoding` to use. `.brackets` by default.
    ///   - boolEncoding:             The `BoolEncoding` to use. `.numeric` by default.
    ///   - dataEncoding:             The `DataEncoding` to use. `.base64` by default.
    ///   - dateEncoding:             The `DateEncoding` to use. `.deferredToDate` by default.
    ///   - keyEncoding:              The `KeyEncoding` to use. `.useDefaultKeys` by default.
    ///   - nilEncoding:              The `NilEncoding` to use. `.drop` by default.
    ///   - spaceEncoding:            The `SpaceEncoding` to use. `.percentEscaped` by default.
    ///   - allowedCharacters:        The `CharacterSet` of allowed (non-escaped) characters. `.defaultURLQueryAllowed` by
    ///                               default.
    public init(alphabetizeKeyValuePairs: Bool = true,
                arrayEncoding: URLEncoding.ArrayEncoding = .brackets,
                boolEncoding: URLEncoding.BoolEncoding = .numeric,
                dataEncoding: URLEncoding.DataEncoding = .base64,
                dateEncoding: URLEncoding.DateEncoding = .deferredToDate,
                keyEncoding: URLEncoding.KeyEncoding = .useDefaultKeys,
                keyPathEncoding: URLEncoding.KeyPathEncoding = .brackets,
                nilEncoding: URLEncoding.NilEncoding = .dropKey,
                spaceEncoding: URLEncoding.SpaceEncoding = .percentEscaped,
                allowedCharacters: CharacterSet = .defaultURLQueryAllowed) {
        self.alphabetizeKeyValuePairs = alphabetizeKeyValuePairs
        self.arrayEncoding = arrayEncoding
        self.boolEncoding = boolEncoding
        self.dataEncoding = dataEncoding
        self.dateEncoding = dateEncoding
        self.keyEncoding = keyEncoding
        self.keyPathEncoding = keyPathEncoding
        self.nilEncoding = nilEncoding
        self.spaceEncoding = spaceEncoding
        self.allowedCharacters = allowedCharacters
    }
}

extension URLEncodedFormEncoder {
    func encode(_ value: Encodable) throws -> URLEncodedFormComponent {
        let context = URLEncodedFormContext(.object([]))
        let encoder = _URLEncodedFormEncoder(context: context,
                                             boolEncoding: boolEncoding,
                                             dataEncoding: dataEncoding,
                                             dateEncoding: dateEncoding,
                                             nilEncoding: nilEncoding)
        try value.encode(to: encoder)

        return context.component
    }

    /// Encodes the `value` as a URL form encoded `String`.
    ///
    /// - Parameter value: The `Encodable` value.
    ///
    /// - Returns:         The encoded `String`.
    /// - Throws:          An `Error` or `EncodingError` instance if encoding fails.
    public func encode(_ value: Encodable) throws -> String {
        let component: URLEncodedFormComponent = try encode(value)

        guard case let .object(object) = component else {
            throw URLEncoding.Error.invalidRootObject("\(component)")
        }

        let serializer = URLEncodedFormSerializer(alphabetizeKeyValuePairs: alphabetizeKeyValuePairs,
                                                  arrayEncoding: arrayEncoding,
                                                  keyEncoding: keyEncoding,
                                                  keyPathEncoding: keyPathEncoding,
                                                  spaceEncoding: spaceEncoding,
                                                  allowedCharacters: allowedCharacters)
        let query = serializer.serialize(object)

        return query
    }

    /// Encodes the value as `Data`. This is performed by first creating an encoded `String` and then returning the
    /// `.utf8` data.
    ///
    /// - Parameter value: The `Encodable` value.
    ///
    /// - Returns:         The encoded `Data`.
    ///
    /// - Throws:          An `Error` or `EncodingError` instance if encoding fails.
    public func encode(_ value: Encodable) throws -> Data {
        let string: String = try encode(value)

        return Data(string.utf8)
    }
    
    func queryComponent(_ any: Any) throws -> URLEncodedFormComponent {
        if let value = any as? Encodable {
            return try self.encode(value)
        }
        
        if let jsonArray = any as? [Any] {
            let array = try jsonArray.compactMap { try queryComponent($0) }
            return .array(array)
        }
        
        if let json = any as? [String: Any] {
            var objs: URLEncodedFormComponent.Object = []
            for (key, value) in json {
                objs.append((key, try queryComponent(value)))
            }
            return .object(objs)
        }
        
        throw URLEncoding.Error.invalidRootObject("\(any)")
    }

    /// Encodes the `value` as a URL form encoded `String`.
    ///
    /// - Parameter value: The `JSON` value.
    ///
    /// - Returns:         The encoded `String`.
    /// - Throws:          An `Error` or `EncodingError` instance if encoding fails.
    public func encode(_ value: [String: Any]) throws -> String {
        guard JSONSerialization.isValidJSONObject(value) else {
            throw URLEncoding.Error.invalidRootObject("\(value)")
        }

        let component = try queryComponent(value)
        
        guard case let .object(object) = component else {
            throw URLEncoding.Error.invalidRootObject("\(component)")
        }

        let serializer = URLEncodedFormSerializer(alphabetizeKeyValuePairs: alphabetizeKeyValuePairs,
                                                  arrayEncoding: arrayEncoding,
                                                  keyEncoding: keyEncoding,
                                                  keyPathEncoding: keyPathEncoding,
                                                  spaceEncoding: spaceEncoding,
                                                  allowedCharacters: allowedCharacters)
        let query = serializer.serialize(object)

        return query
    }
}

final class _URLEncodedFormEncoder {
    var codingPath: [CodingKey]
    // Returns an empty dictionary, as this encoder doesn't support userInfo.
    var userInfo: [CodingUserInfoKey: Any] { [:] }

    let context: URLEncodedFormContext

    private let boolEncoding: URLEncoding.BoolEncoding
    private let dataEncoding: URLEncoding.DataEncoding
    private let dateEncoding: URLEncoding.DateEncoding
    private let nilEncoding: URLEncoding.NilEncoding

    init(context: URLEncodedFormContext,
         codingPath: [CodingKey] = [],
         boolEncoding: URLEncoding.BoolEncoding,
         dataEncoding: URLEncoding.DataEncoding,
         dateEncoding: URLEncoding.DateEncoding,
         nilEncoding: URLEncoding.NilEncoding) {
        self.context = context
        self.codingPath = codingPath
        self.boolEncoding = boolEncoding
        self.dataEncoding = dataEncoding
        self.dateEncoding = dateEncoding
        self.nilEncoding = nilEncoding
    }
}

extension _URLEncodedFormEncoder: Encoder {
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
        let container = _URLEncodedFormEncoder.KeyedContainer<Key>(context: context,
                                                                   codingPath: codingPath,
                                                                   boolEncoding: boolEncoding,
                                                                   dataEncoding: dataEncoding,
                                                                   dateEncoding: dateEncoding,
                                                                   nilEncoding: nilEncoding)
        return KeyedEncodingContainer(container)
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        _URLEncodedFormEncoder.UnkeyedContainer(context: context,
                                                codingPath: codingPath,
                                                boolEncoding: boolEncoding,
                                                dataEncoding: dataEncoding,
                                                dateEncoding: dateEncoding,
                                                nilEncoding: nilEncoding)
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        _URLEncodedFormEncoder.SingleValueContainer(context: context,
                                                    codingPath: codingPath,
                                                    boolEncoding: boolEncoding,
                                                    dataEncoding: dataEncoding,
                                                    dateEncoding: dateEncoding,
                                                    nilEncoding: nilEncoding)
    }
}

final class URLEncodedFormContext {
    var component: URLEncodedFormComponent

    init(_ component: URLEncodedFormComponent) {
        self.component = component
    }
}

enum URLEncodedFormComponent {
    typealias Object = [(key: String, value: URLEncodedFormComponent)]

    case string(String)
    case array([URLEncodedFormComponent])
    case object(Object)

    /// Converts self to an `[URLEncodedFormData]` or returns `nil` if not convertible.
    var array: [URLEncodedFormComponent]? {
        switch self {
        case let .array(array): return array
        default: return nil
        }
    }

    /// Converts self to an `Object` or returns `nil` if not convertible.
    var object: Object? {
        switch self {
        case let .object(object): return object
        default: return nil
        }
    }

    /// Sets self to the supplied value at a given path.
    ///
    ///     data.set(to: "hello", at: ["path", "to", "value"])
    ///
    /// - parameters:
    ///     - value: Value of `Self` to set at the supplied path.
    ///     - path: `CodingKey` path to update with the supplied value.
    public mutating func set(to value: URLEncodedFormComponent, at path: [CodingKey]) {
        set(&self, to: value, at: path)
    }

    /// Recursive backing method to `set(to:at:)`.
    private func set(_ context: inout URLEncodedFormComponent, to value: URLEncodedFormComponent, at path: [CodingKey]) {
        guard !path.isEmpty else {
            context = value
            return
        }

        let end = path[0]
        var child: URLEncodedFormComponent
        switch path.count {
        case 1:
            child = value
        case 2...:
            if let index = end.intValue {
                let array = context.array ?? []
                if array.count > index {
                    child = array[index]
                } else {
                    child = .array([])
                }
                set(&child, to: value, at: Array(path[1...]))
            } else {
                child = context.object?.first { $0.key == end.stringValue }?.value ?? .object(.init())
                set(&child, to: value, at: Array(path[1...]))
            }
        default: fatalError("Unreachable")
        }

        if let index = end.intValue {
            if var array = context.array {
                if array.count > index {
                    array[index] = child
                } else {
                    array.append(child)
                }
                context = .array(array)
            } else {
                context = .array([child])
            }
        } else {
            if var object = context.object {
                if let index = object.firstIndex(where: { $0.key == end.stringValue }) {
                    object[index] = (key: end.stringValue, value: child)
                } else {
                    object.append((key: end.stringValue, value: child))
                }
                context = .object(object)
            } else {
                context = .object([(key: end.stringValue, value: child)])
            }
        }
    }
}

struct AnyCodingKey: CodingKey, Hashable {
    let stringValue: String
    let intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
        intValue = nil
    }

    init?(intValue: Int) {
        stringValue = "\(intValue)"
        self.intValue = intValue
    }

    init<Key>(_ base: Key) where Key: CodingKey {
        if let intValue = base.intValue {
            self.init(intValue: intValue)!
        } else {
            self.init(stringValue: base.stringValue)!
        }
    }
}

extension _URLEncodedFormEncoder {
    final class KeyedContainer<Key> where Key: CodingKey {
        var codingPath: [CodingKey]

        private let context: URLEncodedFormContext
        private let boolEncoding: URLEncoding.BoolEncoding
        private let dataEncoding: URLEncoding.DataEncoding
        private let dateEncoding: URLEncoding.DateEncoding
        private let nilEncoding: URLEncoding.NilEncoding

        init(context: URLEncodedFormContext,
             codingPath: [CodingKey],
             boolEncoding: URLEncoding.BoolEncoding,
             dataEncoding: URLEncoding.DataEncoding,
             dateEncoding: URLEncoding.DateEncoding,
             nilEncoding: URLEncoding.NilEncoding) {
            self.context = context
            self.codingPath = codingPath
            self.boolEncoding = boolEncoding
            self.dataEncoding = dataEncoding
            self.dateEncoding = dateEncoding
            self.nilEncoding = nilEncoding
        }

        private func nestedCodingPath(for key: CodingKey) -> [CodingKey] {
            codingPath + [key]
        }
    }
}

extension _URLEncodedFormEncoder.KeyedContainer: KeyedEncodingContainerProtocol {
    func encodeNil(forKey key: Key) throws {
        guard let nilValue = nilEncoding.encodeNil() else { return }

        try encode(nilValue, forKey: key)
    }

    func encodeIfPresent(_ value: Bool?, forKey key: Key) throws {
        try _encodeIfPresent(value, forKey: key)
    }

    func encodeIfPresent(_ value: String?, forKey key: Key) throws {
        try _encodeIfPresent(value, forKey: key)
    }

    func encodeIfPresent(_ value: Double?, forKey key: Key) throws {
        try _encodeIfPresent(value, forKey: key)
    }

    func encodeIfPresent(_ value: Float?, forKey key: Key) throws {
        try _encodeIfPresent(value, forKey: key)
    }

    func encodeIfPresent(_ value: Int?, forKey key: Key) throws {
        try _encodeIfPresent(value, forKey: key)
    }

    func encodeIfPresent(_ value: Int8?, forKey key: Key) throws {
        try _encodeIfPresent(value, forKey: key)
    }

    func encodeIfPresent(_ value: Int16?, forKey key: Key) throws {
        try _encodeIfPresent(value, forKey: key)
    }

    func encodeIfPresent(_ value: Int32?, forKey key: Key) throws {
        try _encodeIfPresent(value, forKey: key)
    }

    func encodeIfPresent(_ value: Int64?, forKey key: Key) throws {
        try _encodeIfPresent(value, forKey: key)
    }

    func encodeIfPresent(_ value: UInt?, forKey key: Key) throws {
        try _encodeIfPresent(value, forKey: key)
    }

    func encodeIfPresent(_ value: UInt8?, forKey key: Key) throws {
        try _encodeIfPresent(value, forKey: key)
    }

    func encodeIfPresent(_ value: UInt16?, forKey key: Key) throws {
        try _encodeIfPresent(value, forKey: key)
    }

    func encodeIfPresent(_ value: UInt32?, forKey key: Key) throws {
        try _encodeIfPresent(value, forKey: key)
    }

    func encodeIfPresent(_ value: UInt64?, forKey key: Key) throws {
        try _encodeIfPresent(value, forKey: key)
    }

    func encodeIfPresent<Value>(_ value: Value?, forKey key: Key) throws where Value: Encodable {
        try _encodeIfPresent(value, forKey: key)
    }

    func _encodeIfPresent<Value>(_ value: Value?, forKey key: Key) throws where Value: Encodable {
        if let value {
            try encode(value, forKey: key)
        } else {
            try encodeNil(forKey: key)
        }
    }

    func encode<T>(_ value: T, forKey key: Key) throws where T: Encodable {
        var container = nestedSingleValueEncoder(for: key)
        try container.encode(value)
    }

    func nestedSingleValueEncoder(for key: Key) -> SingleValueEncodingContainer {
        let container = _URLEncodedFormEncoder.SingleValueContainer(context: context,
                                                                    codingPath: nestedCodingPath(for: key),
                                                                    boolEncoding: boolEncoding,
                                                                    dataEncoding: dataEncoding,
                                                                    dateEncoding: dateEncoding,
                                                                    nilEncoding: nilEncoding)

        return container
    }

    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        let container = _URLEncodedFormEncoder.UnkeyedContainer(context: context,
                                                                codingPath: nestedCodingPath(for: key),
                                                                boolEncoding: boolEncoding,
                                                                dataEncoding: dataEncoding,
                                                                dateEncoding: dateEncoding,
                                                                nilEncoding: nilEncoding)

        return container
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        let container = _URLEncodedFormEncoder.KeyedContainer<NestedKey>(context: context,
                                                                         codingPath: nestedCodingPath(for: key),
                                                                         boolEncoding: boolEncoding,
                                                                         dataEncoding: dataEncoding,
                                                                         dateEncoding: dateEncoding,
                                                                         nilEncoding: nilEncoding)

        return KeyedEncodingContainer(container)
    }

    func superEncoder() -> Encoder {
        _URLEncodedFormEncoder(context: context,
                               codingPath: codingPath,
                               boolEncoding: boolEncoding,
                               dataEncoding: dataEncoding,
                               dateEncoding: dateEncoding,
                               nilEncoding: nilEncoding)
    }

    func superEncoder(forKey key: Key) -> Encoder {
        _URLEncodedFormEncoder(context: context,
                               codingPath: nestedCodingPath(for: key),
                               boolEncoding: boolEncoding,
                               dataEncoding: dataEncoding,
                               dateEncoding: dateEncoding,
                               nilEncoding: nilEncoding)
    }
}

extension _URLEncodedFormEncoder {
    final class SingleValueContainer {
        var codingPath: [CodingKey]

        private var canEncodeNewValue = true

        private let context: URLEncodedFormContext
        private let boolEncoding: URLEncoding.BoolEncoding
        private let dataEncoding: URLEncoding.DataEncoding
        private let dateEncoding: URLEncoding.DateEncoding
        private let nilEncoding: URLEncoding.NilEncoding

        init(context: URLEncodedFormContext,
             codingPath: [CodingKey],
             boolEncoding: URLEncoding.BoolEncoding,
             dataEncoding: URLEncoding.DataEncoding,
             dateEncoding: URLEncoding.DateEncoding,
             nilEncoding: URLEncoding.NilEncoding) {
            self.context = context
            self.codingPath = codingPath
            self.boolEncoding = boolEncoding
            self.dataEncoding = dataEncoding
            self.dateEncoding = dateEncoding
            self.nilEncoding = nilEncoding
        }

        private func checkCanEncode(value: Any?) throws {
            guard canEncodeNewValue else {
                let context = EncodingError.Context(codingPath: codingPath,
                                                    debugDescription: "Attempt to encode value through single value container when previously value already encoded.")
                throw EncodingError.invalidValue(value as Any, context)
            }
        }
    }
}

extension _URLEncodedFormEncoder.SingleValueContainer: SingleValueEncodingContainer {
    func encodeNil() throws {
        guard let nilValue = nilEncoding.encodeNil() else { return }

        try encode(nilValue)
    }

    func encode(_ value: Bool) throws {
        try encode(value, as: String(boolEncoding.encode(value)))
    }

    func encode(_ value: String) throws {
        try encode(value, as: value)
    }

    func encode(_ value: Double) throws {
        try encode(value, as: String(value))
    }

    func encode(_ value: Float) throws {
        try encode(value, as: String(value))
    }

    func encode(_ value: Int) throws {
        try encode(value, as: String(value))
    }

    func encode(_ value: Int8) throws {
        try encode(value, as: String(value))
    }

    func encode(_ value: Int16) throws {
        try encode(value, as: String(value))
    }

    func encode(_ value: Int32) throws {
        try encode(value, as: String(value))
    }

    func encode(_ value: Int64) throws {
        try encode(value, as: String(value))
    }

    func encode(_ value: UInt) throws {
        try encode(value, as: String(value))
    }

    func encode(_ value: UInt8) throws {
        try encode(value, as: String(value))
    }

    func encode(_ value: UInt16) throws {
        try encode(value, as: String(value))
    }

    func encode(_ value: UInt32) throws {
        try encode(value, as: String(value))
    }

    func encode(_ value: UInt64) throws {
        try encode(value, as: String(value))
    }

    private func encode<T>(_ value: T, as string: String) throws where T: Encodable {
        try checkCanEncode(value: value)
        defer { canEncodeNewValue = false }

        context.component.set(to: .string(string), at: codingPath)
    }

    func encode<T>(_ value: T) throws where T: Encodable {
        switch value {
        case let date as Date:
            guard let string = try dateEncoding.encode(date) else {
                try attemptToEncode(value)
                return
            }

            try encode(value, as: string)
        case let data as Data:
            guard let string = try dataEncoding.encode(data) else {
                try attemptToEncode(value)
                return
            }

            try encode(value, as: string)
        case let decimal as Decimal:
            // Decimal's `Encodable` implementation returns an object, not a single value, so override it.
            try encode(value, as: String(describing: decimal))
        default:
            try attemptToEncode(value)
        }
    }

    private func attemptToEncode<T>(_ value: T) throws where T: Encodable {
        try checkCanEncode(value: value)
        defer { canEncodeNewValue = false }

        let encoder = _URLEncodedFormEncoder(context: context,
                                             codingPath: codingPath,
                                             boolEncoding: boolEncoding,
                                             dataEncoding: dataEncoding,
                                             dateEncoding: dateEncoding,
                                             nilEncoding: nilEncoding)
        try value.encode(to: encoder)
    }
}

extension _URLEncodedFormEncoder {
    final class UnkeyedContainer {
        var codingPath: [CodingKey]

        var count = 0
        var nestedCodingPath: [CodingKey] {
            codingPath + [AnyCodingKey(intValue: count)!]
        }

        private let context: URLEncodedFormContext
        private let boolEncoding: URLEncoding.BoolEncoding
        private let dataEncoding: URLEncoding.DataEncoding
        private let dateEncoding: URLEncoding.DateEncoding
        private let nilEncoding: URLEncoding.NilEncoding

        init(context: URLEncodedFormContext,
             codingPath: [CodingKey],
             boolEncoding: URLEncoding.BoolEncoding,
             dataEncoding: URLEncoding.DataEncoding,
             dateEncoding: URLEncoding.DateEncoding,
             nilEncoding: URLEncoding.NilEncoding) {
            self.context = context
            self.codingPath = codingPath
            self.boolEncoding = boolEncoding
            self.dataEncoding = dataEncoding
            self.dateEncoding = dateEncoding
            self.nilEncoding = nilEncoding
        }
    }
}

extension _URLEncodedFormEncoder.UnkeyedContainer: UnkeyedEncodingContainer {
    func encodeNil() throws {
        guard let nilValue = nilEncoding.encodeNil() else { return }

        try encode(nilValue)
    }

    func encode<T>(_ value: T) throws where T: Encodable {
        var container = nestedSingleValueContainer()
        try container.encode(value)
    }

    func nestedSingleValueContainer() -> SingleValueEncodingContainer {
        defer { count += 1 }

        return _URLEncodedFormEncoder.SingleValueContainer(context: context,
                                                           codingPath: nestedCodingPath,
                                                           boolEncoding: boolEncoding,
                                                           dataEncoding: dataEncoding,
                                                           dateEncoding: dateEncoding,
                                                           nilEncoding: nilEncoding)
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        defer { count += 1 }
        let container = _URLEncodedFormEncoder.KeyedContainer<NestedKey>(context: context,
                                                                         codingPath: nestedCodingPath,
                                                                         boolEncoding: boolEncoding,
                                                                         dataEncoding: dataEncoding,
                                                                         dateEncoding: dateEncoding,
                                                                         nilEncoding: nilEncoding)

        return KeyedEncodingContainer(container)
    }

    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        defer { count += 1 }

        return _URLEncodedFormEncoder.UnkeyedContainer(context: context,
                                                       codingPath: nestedCodingPath,
                                                       boolEncoding: boolEncoding,
                                                       dataEncoding: dataEncoding,
                                                       dateEncoding: dateEncoding,
                                                       nilEncoding: nilEncoding)
    }

    func superEncoder() -> Encoder {
        defer { count += 1 }

        return _URLEncodedFormEncoder(context: context,
                                      codingPath: codingPath,
                                      boolEncoding: boolEncoding,
                                      dataEncoding: dataEncoding,
                                      dateEncoding: dateEncoding,
                                      nilEncoding: nilEncoding)
    }
}

final class URLEncodedFormSerializer {
    private let alphabetizeKeyValuePairs: Bool
    private let arrayEncoding: URLEncoding.ArrayEncoding
    private let keyEncoding: URLEncoding.KeyEncoding
    private let keyPathEncoding: URLEncoding.KeyPathEncoding
    private let spaceEncoding: URLEncoding.SpaceEncoding
    private let allowedCharacters: CharacterSet

    init(alphabetizeKeyValuePairs: Bool,
         arrayEncoding: URLEncoding.ArrayEncoding,
         keyEncoding: URLEncoding.KeyEncoding,
         keyPathEncoding: URLEncoding.KeyPathEncoding,
         spaceEncoding: URLEncoding.SpaceEncoding,
         allowedCharacters: CharacterSet) {
        self.alphabetizeKeyValuePairs = alphabetizeKeyValuePairs
        self.arrayEncoding = arrayEncoding
        self.keyEncoding = keyEncoding
        self.keyPathEncoding = keyPathEncoding
        self.spaceEncoding = spaceEncoding
        self.allowedCharacters = allowedCharacters
    }

    func serialize(_ object: URLEncodedFormComponent.Object) -> String {
        var output: [String] = []
        for (key, component) in object {
            let value = serialize(component, forKey: key)
            output.append(value)
        }
        output = alphabetizeKeyValuePairs ? output.sorted() : output

        return output.joinedWithAmpersands()
    }

    func serialize(_ component: URLEncodedFormComponent, forKey key: String) -> String {
        switch component {
        case let .string(string): return "\(escape(keyEncoding.encode(key)))=\(escape(string))"
        case let .array(array): return serialize(array, forKey: key)
        case let .object(object): return serialize(object, forKey: key)
        }
    }

    func serialize(_ object: URLEncodedFormComponent.Object, forKey key: String) -> String {
        var segments: [String] = object.map { subKey, value in
            let keyPath = keyPathEncoding.encodeKeyPath(subKey)
            return serialize(value, forKey: key + keyPath)
        }
        segments = alphabetizeKeyValuePairs ? segments.sorted() : segments

        return segments.joinedWithAmpersands()
    }

    func serialize(_ array: [URLEncodedFormComponent], forKey key: String) -> String {
        var segments: [String] = array.enumerated().map { index, component in
            let keyPath = arrayEncoding.encode(key, atIndex: index)
            return serialize(component, forKey: keyPath)
        }
        segments = alphabetizeKeyValuePairs ? segments.sorted() : segments

        return segments.joinedWithAmpersands()
    }

    func escape(_ query: String) -> String {
        var allowedCharactersWithSpace = allowedCharacters
        allowedCharactersWithSpace.insert(charactersIn: " ")
        let escapedQuery = query.addingPercentEncoding(withAllowedCharacters: allowedCharactersWithSpace) ?? query
        let spaceEncodedQuery = spaceEncoding.encode(escapedQuery)

        return spaceEncodedQuery
    }
}

extension [String] {
    func joinedWithAmpersands() -> String {
        joined(separator: "&")
    }
}

extension CharacterSet {
    /// Creates a CharacterSet from RFC 3986 allowed characters.
    ///
    /// RFC 3986 states that the following characters are "reserved" characters.
    ///
    /// - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
    /// - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="
    ///
    /// In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to allow
    /// query strings to include a URL. Therefore, all "reserved" characters with the exception of "?" and "/"
    /// should be percent-escaped in the query string.
    public static let defaultURLQueryAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        let encodableDelimiters = CharacterSet(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")

        return CharacterSet.urlQueryAllowed.subtracting(encodableDelimiters)
    }()
}
