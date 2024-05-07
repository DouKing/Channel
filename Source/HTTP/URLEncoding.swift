//===----------------------------------------------------------*- Swift -*-===//
//
// Created by wuyikai on 2024/5/6.
// Copyright © 2024 wuyikai. All rights reserved.
//
//===----------------------------------------------------------------------===//

import Foundation

public struct URLEncoding {
    /// `URLEncodedFormEncoder` error.
    public enum Error: Swift.Error {
        /// An invalid root object was created by the encoder. Only keyed values are valid.
        case invalidRootObject(String)

        var localizedDescription: String {
            switch self {
            case let .invalidRootObject(object):
                return "URLEncodedFormEncoder requires keyed root object. Received \(object) instead."
            }
        }
    }

    /// Encoding to use for `Array` values.
    public enum ArrayEncoding {
        /// An empty set of square brackets ("[]") are appended to the key for every value. This is the default encoding.
        case brackets
        /// No brackets are appended to the key and the key is encoded as is.
        case noBrackets
        /// Brackets containing the item index are appended. This matches the jQuery and Node.js behavior.
        case indexInBrackets
        /// Provide a custom array key encoding with the given closure.
        case custom((_ key: String, _ index: Int) -> String)

        /// Encodes the key according to the encoding.
        ///
        /// - Parameters:
        ///     - key:   The `key` to encode.
        ///     - index: When this enum instance is `.indexInBrackets`, the `index` to encode.
        ///
        /// - Returns:   The encoded key.
        func encode(_ key: String, atIndex index: Int) -> String {
            switch self {
            case .brackets: return "\(key)[]"
            case .noBrackets: return key
            case .indexInBrackets: return "\(key)[\(index)]"
            case let .custom(encoding): return encoding(key, index)
            }
        }
    }

    /// Encoding to use for `Bool` values.
    public enum BoolEncoding {
        /// Encodes `true` as `1`, `false` as `0`.
        case numeric
        /// Encodes `true` as "true", `false` as "false". This is the default encoding.
        case literal

        /// Encodes the given `Bool` as a `String`.
        ///
        /// - Parameter value: The `Bool` to encode.
        ///
        /// - Returns:         The encoded `String`.
        func encode(_ value: Bool) -> String {
            switch self {
            case .numeric: return value ? "1" : "0"
            case .literal: return value ? "true" : "false"
            }
        }
    }

    /// Encoding to use for `Data` values.
    public enum DataEncoding {
        /// Defers encoding to the `Data` type.
        case deferredToData
        /// Encodes `Data` as a Base64-encoded string. This is the default encoding.
        case base64
        /// Encode the `Data` as a custom value encoded by the given closure.
        case custom((Data) throws -> String)

        /// Encodes `Data` according to the encoding.
        ///
        /// - Parameter data: The `Data` to encode.
        ///
        /// - Returns:        The encoded `String`, or `nil` if the `Data` should be encoded according to its
        ///                   `Encodable` implementation.
        func encode(_ data: Data) throws -> String? {
            switch self {
            case .deferredToData: return nil
            case .base64: return data.base64EncodedString()
            case let .custom(encoding): return try encoding(data)
            }
        }
    }

    /// Encoding to use for `Date` values.
    public enum DateEncoding {
        /// ISO8601 and RFC3339 formatter.
        private static let iso8601Formatter: ISO8601DateFormatter = {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = .withInternetDateTime
            return formatter
        }()

        /// Defers encoding to the `Date` type. This is the default encoding.
        case deferredToDate
        /// Encodes `Date`s as seconds since midnight UTC on January 1, 1970.
        case secondsSince1970
        /// Encodes `Date`s as milliseconds since midnight UTC on January 1, 1970.
        case millisecondsSince1970
        /// Encodes `Date`s according to the ISO8601 and RFC3339 standards.
        case iso8601
        /// Encodes `Date`s using the given `DateFormatter`.
        case formatted(DateFormatter)
        /// Encodes `Date`s using the given closure.
        case custom((Date) throws -> String)

        /// Encodes the date according to the encoding.
        ///
        /// - Parameter date: The `Date` to encode.
        ///
        /// - Returns:        The encoded `String`, or `nil` if the `Date` should be encoded according to its
        ///                   `Encodable` implementation.
        func encode(_ date: Date) throws -> String? {
            switch self {
            case .deferredToDate:
                return nil
            case .secondsSince1970:
                return String(date.timeIntervalSince1970)
            case .millisecondsSince1970:
                return String(date.timeIntervalSince1970 * 1000.0)
            case .iso8601:
                return DateEncoding.iso8601Formatter.string(from: date)
            case let .formatted(formatter):
                return formatter.string(from: date)
            case let .custom(closure):
                return try closure(date)
            }
        }
    }

    /// Encoding to use for keys.
    ///
    /// This type is derived from [`JSONEncoder`'s `KeyEncodingStrategy`](https://github.com/apple/swift/blob/6aa313b8dd5f05135f7f878eccc1db6f9fbe34ff/stdlib/public/Darwin/Foundation/JSONEncoder.swift#L128)
    /// and [`XMLEncoder`s `KeyEncodingStrategy`](https://github.com/MaxDesiatov/XMLCoder/blob/master/Sources/XMLCoder/Encoder/XMLEncoder.swift#L102).
    public enum KeyEncoding {
        /// Use the keys specified by each type. This is the default encoding.
        case useDefaultKeys
        /// Convert from "camelCaseKeys" to "snake_case_keys" before writing a key.
        ///
        /// Capital characters are determined by testing membership in
        /// `CharacterSet.uppercaseLetters` and `CharacterSet.lowercaseLetters`
        /// (Unicode General Categories Lu and Lt).
        /// The conversion to lower case uses `Locale.system`, also known as
        /// the ICU "root" locale. This means the result is consistent
        /// regardless of the current user's locale and language preferences.
        ///
        /// Converting from camel case to snake case:
        /// 1. Splits words at the boundary of lower-case to upper-case
        /// 2. Inserts `_` between words
        /// 3. Lowercases the entire string
        /// 4. Preserves starting and ending `_`.
        ///
        /// For example, `oneTwoThree` becomes `one_two_three`. `_oneTwoThree_` becomes `_one_two_three_`.
        ///
        /// - Note: Using a key encoding strategy has a nominal performance cost, as each string key has to be converted.
        case convertToSnakeCase
        /// Same as convertToSnakeCase, but using `-` instead of `_`.
        /// For example `oneTwoThree` becomes `one-two-three`.
        case convertToKebabCase
        /// Capitalize the first letter only.
        /// For example `oneTwoThree` becomes  `OneTwoThree`.
        case capitalized
        /// Uppercase all letters.
        /// For example `oneTwoThree` becomes  `ONETWOTHREE`.
        case uppercased
        /// Lowercase all letters.
        /// For example `oneTwoThree` becomes  `onetwothree`.
        case lowercased
        /// A custom encoding using the provided closure.
        case custom((String) -> String)

        func encode(_ key: String) -> String {
            switch self {
            case .useDefaultKeys: return key
            case .convertToSnakeCase: return convertToSnakeCase(key)
            case .convertToKebabCase: return convertToKebabCase(key)
            case .capitalized: return String(key.prefix(1).uppercased() + key.dropFirst())
            case .uppercased: return key.uppercased()
            case .lowercased: return key.lowercased()
            case let .custom(encoding): return encoding(key)
            }
        }

        private func convertToSnakeCase(_ key: String) -> String {
            convert(key, usingSeparator: "_")
        }

        private func convertToKebabCase(_ key: String) -> String {
            convert(key, usingSeparator: "-")
        }

        private func convert(_ key: String, usingSeparator separator: String) -> String {
            guard !key.isEmpty else { return key }

            var words: [Range<String.Index>] = []
            // The general idea of this algorithm is to split words on
            // transition from lower to upper case, then on transition of >1
            // upper case characters to lowercase
            //
            // myProperty -> my_property
            // myURLProperty -> my_url_property
            //
            // It is assumed, per Swift naming conventions, that the first character of the key is lowercase.
            var wordStart = key.startIndex
            var searchRange = key.index(after: wordStart)..<key.endIndex

            // Find next uppercase character
            while let upperCaseRange = key.rangeOfCharacter(from: .uppercaseLetters, options: [], range: searchRange) {
                let untilUpperCase = wordStart..<upperCaseRange.lowerBound
                words.append(untilUpperCase)

                // Find next lowercase character
                searchRange = upperCaseRange.lowerBound..<searchRange.upperBound
                guard let lowerCaseRange = key.rangeOfCharacter(from: .lowercaseLetters, options: [], range: searchRange) else {
                    // There are no more lower case letters. Just end here.
                    wordStart = searchRange.lowerBound
                    break
                }

                // Is the next lowercase letter more than 1 after the uppercase?
                // If so, we encountered a group of uppercase letters that we
                // should treat as its own word
                let nextCharacterAfterCapital = key.index(after: upperCaseRange.lowerBound)
                if lowerCaseRange.lowerBound == nextCharacterAfterCapital {
                    // The next character after capital is a lower case character and therefore not a word boundary.
                    // Continue searching for the next upper case for the boundary.
                    wordStart = upperCaseRange.lowerBound
                } else {
                    // There was a range of >1 capital letters. Turn those into a word, stopping at the capital before
                    // the lower case character.
                    let beforeLowerIndex = key.index(before: lowerCaseRange.lowerBound)
                    words.append(upperCaseRange.lowerBound..<beforeLowerIndex)

                    // Next word starts at the capital before the lowercase we just found
                    wordStart = beforeLowerIndex
                }
                searchRange = lowerCaseRange.upperBound..<searchRange.upperBound
            }
            words.append(wordStart..<searchRange.upperBound)
            let result = words.map { range in
                key[range].lowercased()
            }.joined(separator: separator)

            return result
        }
    }

    /// Encoding to use for nested object and `Encodable` value key paths.
    ///
    /// ```
    /// ["parent" : ["child" : ["grandchild": "value"]]]
    /// ```
    ///
    /// This encoding affects how the `parent`, `child`, `grandchild` path is encoded. Brackets are used by default.
    /// e.g. `parent[child][grandchild]=value`.
    public struct KeyPathEncoding {
        /// Encodes key paths by wrapping each component in brackets. e.g. `parent[child][grandchild]`.
        public static let brackets = KeyPathEncoding { "[\($0)]" }
        /// Encodes key paths by separating each component with dots. e.g. `parent.child.grandchild`.
        public static let dots = KeyPathEncoding { ".\($0)" }

        private let encoding: (_ subkey: String) -> String

        /// Creates an instance with the encoding closure called for each sub-key in a key path.
        ///
        /// - Parameter encoding: Closure used to perform the encoding.
        public init(encoding: @escaping (_ subkey: String) -> String) {
            self.encoding = encoding
        }

        func encodeKeyPath(_ keyPath: String) -> String {
            encoding(keyPath)
        }
    }

    /// Encoding to use for `nil` values.
    public struct NilEncoding {
        /// Encodes `nil` by dropping the entire key / value pair.
        public static let dropKey = NilEncoding { nil }
        /// Encodes `nil` by dropping only the value. e.g. `value1=one&nilValue=&value2=two`.
        public static let dropValue = NilEncoding { "" }
        /// Encodes `nil` as `null`.
        public static let null = NilEncoding { "null" }

        private let encoding: () -> String?

        /// Creates an instance with the encoding closure called for `nil` values.
        ///
        /// - Parameter encoding: Closure used to perform the encoding.
        public init(encoding: @escaping () -> String?) {
            self.encoding = encoding
        }

        func encodeNil() -> String? {
            encoding()
        }
    }

    /// Encoding to use for spaces.
    public enum SpaceEncoding {
        /// Encodes spaces using percent escaping (`%20`).
        case percentEscaped
        /// Encodes spaces as `+`.
        case plusReplaced

        /// Encodes the string according to the encoding.
        ///
        /// - Parameter string: The `String` to encode.
        ///
        /// - Returns:          The encoded `String`.
        func encode(_ string: String) -> String {
            switch self {
            case .percentEscaped: return string.replacingOccurrences(of: " ", with: "%20")
            case .plusReplaced: return string.replacingOccurrences(of: " ", with: "+")
            }
        }
    }
}
