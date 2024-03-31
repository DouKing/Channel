//===----------------------------------------------------------*- Swift -*-===//
//
// Created by wuyikai on 2024/3/29.
// Copyright © 2024 wuyikai. All rights reserved.
//
//===----------------------------------------------------------------------===//

import AVFoundation
import CryptoKit

public extension AVAudioPCMBuffer {
    /// Read the contents of the url into this buffer
    convenience init?(url: URL) throws {
        guard let file = try? AVAudioFile(forReading: url) else { return nil }
        try self.init(file: file)
    }
    
    /// Read entire file and return a new AVAudioPCMBuffer with its contents
    convenience init?(file: AVAudioFile) throws {
        file.framePosition = 0
        
        self.init(pcmFormat: file.processingFormat,
                  frameCapacity: AVAudioFrameCount(file.length))
        
        try file.read(into: self)
    }
}

public extension AVAudioPCMBuffer {
    /// Hash useful for testing
    var md5: String {
        var sampleData = Data()

        if let floatChannelData = floatChannelData {
            for frame in 0 ..< frameCapacity {
                for channel in 0 ..< format.channelCount {
                    let sample = floatChannelData[Int(channel)][Int(frame)]

                    withUnsafePointer(to: sample) { ptr in
                        sampleData.append(UnsafeBufferPointer(start: ptr, count: 1))
                    }
                }
            }
        }

        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            let digest = Insecure.MD5.hash(data: sampleData)
            return digest.map { String(format: "%02hhx", $0) }.joined()
        } else {
            // Fallback on earlier versions
            return "Oh well, old version"
        }
    }

    var isSilent: Bool {
        if let floatChannelData = floatChannelData {
            for channel in 0 ..< format.channelCount {
                for frame in 0 ..< frameLength {
                    if floatChannelData[Int(channel)][Int(frame)] != 0.0 {
                        return false
                    }
                }
            }
        }
        return true
    }

    /// Add to an existing buffer
    ///
    /// - Parameter buffer: Buffer to append
    func append(_ buffer: AVAudioPCMBuffer) {
        append(buffer, startingFrame: 0, frameCount: buffer.frameLength)
    }

    /// Add to an existing buffer with specific starting frame and size
    /// - Parameters:
    ///   - buffer: Buffer to append
    ///   - startingFrame: Starting frame location
    ///   - frameCount: Number of frames to append
    func append(_ buffer: AVAudioPCMBuffer,
                startingFrame: AVAudioFramePosition,
                frameCount: AVAudioFrameCount)
    {
        precondition(format == buffer.format,
                     "Format mismatch")
        precondition(startingFrame + AVAudioFramePosition(frameCount) <= AVAudioFramePosition(buffer.frameLength),
                     "Insufficient audio in buffer")
        precondition(frameLength + frameCount <= frameCapacity,
                     "Insufficient space in buffer")

        let dst1 = floatChannelData![0]
        let src1 = buffer.floatChannelData![0]

        memcpy(dst1.advanced(by: stride * Int(frameLength)),
               src1.advanced(by: stride * Int(startingFrame)),
               Int(frameCount) * stride * MemoryLayout<Float>.size)

        let dst2 = floatChannelData![1]
        let src2 = buffer.floatChannelData![1]

        memcpy(dst2.advanced(by: stride * Int(frameLength)),
               src2.advanced(by: stride * Int(startingFrame)),
               Int(frameCount) * stride * MemoryLayout<Float>.size)

        frameLength += frameCount
    }
}

public typealias FloatChannelData = [[Float]]

extension AVAudioPCMBuffer {
    /// Returns audio data as an `Array` of `Float` Arrays.
    ///
    /// If stereo:
    /// - `floatChannelData?[0]` will contain an Array of left channel samples as `Float`
    /// - `floatChannelData?[1]` will contains an Array of right channel samples as `Float`
    func toFloatChannelData() -> FloatChannelData? {
        // Do we have PCM channel data?
        guard let pcmFloatChannelData = floatChannelData else {
            return nil
        }
        
        let channelCount = Int(format.channelCount)
        let frameLength = Int(self.frameLength)
        let stride = self.stride
        
        // Preallocate our Array so we're not constantly thrashing while resizing as we append.
        var result = Array(repeating: [Float](repeating: 0, count: frameLength), count: channelCount)
        
        // Loop across our channels...
        for channel in 0 ..< channelCount {
            // Make sure we go through all of the frames...
            for sampleIndex in 0 ..< frameLength {
                result[channel][sampleIndex] = pcmFloatChannelData[channel][sampleIndex * stride]
            }
        }
        
        return result
    }
}
