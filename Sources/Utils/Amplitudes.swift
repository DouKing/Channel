//===----------------------------------------------------------*- swift -*-===//
//
// Created by Yikai Wu on 2024/3/28.
// Copyright © 2024 Yikai Wu. All rights reserved.
//
//===----------------------------------------------------------------------===//

import Accelerate

public func calculateAmplitudes(
    _ fftFloats: [Float],
    maxAmplitude: Float = 0.0,
    minAmplitude: Float = -70.0,
    referenceValueForFFT: Float = 12.0
) async -> [Float] {
    var referenceValueForFFT = referenceValueForFFT
    var fftData = fftFloats
    for index in 0 ..< fftData.count {
        if fftData[index].isNaN { fftData[index] = 0.0 }
    }
    
    var one = Float(1.0)
    var zero = Float(0.0)
    var decibelNormalizationFactor = Float(1.0 / (maxAmplitude - minAmplitude))
    var decibelNormalizationOffset = Float(-minAmplitude / (maxAmplitude - minAmplitude))
    
    var decibels = [Float](repeating: 0, count: fftData.count)
    vDSP_vdbcon(fftData, 1, &referenceValueForFFT, &decibels, 1, vDSP_Length(fftData.count), 0)
    
    vDSP_vsmsa(decibels,
               1,
               &decibelNormalizationFactor,
               &decibelNormalizationOffset,
               &decibels,
               1,
               vDSP_Length(decibels.count))
    
    vDSP_vclip(decibels, 1, &zero, &one, &decibels, 1, vDSP_Length(decibels.count))
    
    return decibels
}
