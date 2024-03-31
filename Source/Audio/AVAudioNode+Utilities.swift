//===----------------------------------------------------------*- Swift -*-===//
//
// Created by Yikai Wu on 2024/3/30.
// Copyright © 2024 Yikai Wu. All rights reserved.
//
//===----------------------------------------------------------------------===//

import AVFoundation

public extension AVAudioNode {
    func installTap(
        onBus bus: AVAudioNodeBus,
        fullBufferSize: AVAudioFrameCount,
        format: AVAudioFormat?,
        block tapBlock: @escaping AVAudioNodeTapBlock
    ) {
        self.installTap(onBus: bus, bufferSize: fullBufferSize, format: format) { buffer, time in
            let bufferWithCapacity: AVAudioPCMBuffer
            
            if fullBufferSize > buffer.frameCapacity {
                guard let newBuffer = AVAudioPCMBuffer(pcmFormat: buffer.format, frameCapacity: fullBufferSize) else {
                    return
                }
                
                newBuffer.append(buffer)
                bufferWithCapacity = newBuffer
            } else {
                bufferWithCapacity = buffer
            }
            
            bufferWithCapacity.frameLength = fullBufferSize
            
            tapBlock(bufferWithCapacity, time)
        }
    }
}
