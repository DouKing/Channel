//===----------------------------------------------------------*- Swift -*-===//
//
// Created by wuyikai on 2024/5/6.
// Copyright © 2024 wuyikai. All rights reserved.
//
//===----------------------------------------------------------------------===//

import Foundation

extension HTTP {
    public enum Error: Swift.Error {
        public enum MultipartEncodingFailureReason {
            /// The `fileURL` provided for reading an encodable body part isn't a file `URL`.
            case bodyPartURLInvalid(url: URL)
            /// The filename of the `fileURL` provided has either an empty `lastPathComponent` or `pathExtension`.
            case bodyPartFilenameInvalid(in: URL)
            /// The file at the `fileURL` provided was not reachable.
            case bodyPartFileNotReachable(at: URL)
            /// Attempting to check the reachability of the `fileURL` provided threw an error.
            case bodyPartFileNotReachableWithError(atURL: URL, error: Swift.Error)
            /// The file at the `fileURL` provided is actually a directory.
            case bodyPartFileIsDirectory(at: URL)
            /// The size of the file at the `fileURL` provided was not returned by the system.
            case bodyPartFileSizeNotAvailable(at: URL)
            /// The attempt to find the size of the file at the `fileURL` provided threw an error.
            case bodyPartFileSizeQueryFailedWithError(forURL: URL, error: Swift.Error)
            /// An `InputStream` could not be created for the provided `fileURL`.
            case bodyPartInputStreamCreationFailed(for: URL)
            /// An `OutputStream` could not be created when attempting to write the encoded data to disk.
            case outputStreamCreationFailed(for: URL)
            /// The encoded body data could not be written to disk because a file already exists at the provided `fileURL`.
            case outputStreamFileAlreadyExists(at: URL)
            /// The `fileURL` provided for writing the encoded body data to disk is not a file `URL`.
            case outputStreamURLInvalid(url: URL)
            /// The attempt to write the encoded body data to disk failed with an underlying error.
            case outputStreamWriteFailed(error: Swift.Error)
            /// The attempt to read an encoded body part `InputStream` failed with underlying system error.
            case inputStreamReadFailed(error: Swift.Error)
        }
        
        /// The underlying reason the `.parameterEncodingFailed` error occurred.
        public enum ParameterEncodingFailureReason {
            /// The `URLRequest` did not have a `URL` to encode.
            case missingURL
            /// JSON serialization failed with an underlying system error during the encoding process.
            case jsonEncodingFailed(error: Swift.Error)
            /// Custom parameter encoding failed due to the associated `Error`.
            case customEncodingFailed(error: Swift.Error)
        }
        
        public struct UnexpectedInputStreamLength: Swift.Error {
            /// The expected byte count to read.
            public var bytesExpected: UInt64
            /// The actual byte count read.
            public var bytesRead: UInt64
        }
        
        public enum JSONEncodingError: Swift.Error {
            /// An invalid json object was created by JSONSerialization.
            case invalidJSONObject
        }
        
        case multipartEncodingFailed(reason: MultipartEncodingFailureReason)
        case parameterEncodingFailed(reason: ParameterEncodingFailureReason)
    }
}
