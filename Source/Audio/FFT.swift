//===----------------------------------------------------------*- Swift -*-===//
//
// Created by Yikai Wu on 2024/3/31.
// Copyright © 2024 Yikai Wu. All rights reserved.
//
//===----------------------------------------------------------------------===//

import AVFoundation
import Accelerate

public enum FFTState {
    public enum Initial {}
    public enum Processed {}
    public enum Presented {}
}

public enum FFTError: Error {
    case processError
}

public struct Config {
    let buffer: AVAudioPCMBuffer
    let isNormalized: Bool
    let zeroPaddingFactor: UInt32
    let frequencyBands: Int
    fileprivate(set) var amplitudes: [[Float]] = []
    
    public init(buffer: AVAudioPCMBuffer, isNormalized: Bool = true, zeroPaddingFactor: UInt32 = 0, frequencyBands: Int = 64) {
        self.buffer = buffer
        self.isNormalized = isNormalized
        self.zeroPaddingFactor = zeroPaddingFactor
        self.frequencyBands = frequencyBands
    }
}

public struct FFT<State> {
    let config: Config
    private init(_ config: Config) {
        self.config = config
    }
}

extension FFT where State == FFTState.Initial {
    public init(config: Config) {
        self.init(config)
    }
    
    public func perform() throws -> FFT<FFTState.Processed> {
        let buffer = self.config.buffer
        guard let channels = buffer.toFloatChannelData(), !channels.isEmpty else {
            throw FFTError.processError
        }
        var channel = channels[0]
        var amplitudes: [[Float]] = []
        amplitudes.append(process(channel: &channel))
        
        if channels.count > 1 {
            var rightChannel = channels[1]
            amplitudes.append(process(channel: &rightChannel))
        }
        
        var config = self.config
        config.amplitudes = amplitudes
        
        return FFT<FFTState.Processed>(config)
    }
    
    private func process(channel: UnsafeMutablePointer<Float>) -> [Float] {
        let frameLength = self.config.buffer.frameLength
        let isNormalized = self.config.isNormalized
        let zeroPaddingFactor = self.config.zeroPaddingFactor
        let frequencyBands = self.config.frequencyBands
        
        let frameCount = frameLength + frameLength * zeroPaddingFactor
        let log2n = UInt(round(log2(Double(frameCount))))
        let bufferSizePOT = Int(1 << log2n) // 1 << n = 2^n
        let binCount = bufferSizePOT / 2
        
        let fftSetup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2))
        var output = DSPSplitComplex(repeating: 0, count: binCount)
        defer {
            output.deallocate()
            vDSP_destroy_fftsetup(fftSetup)
        }
        
        let windowSize = Int(frameLength)
        var transferBuffer = [Float](repeating: 0, count: bufferSizePOT)
        var window = [Float](repeating: 0, count: windowSize)
        
        // Hann windowing to reduce the frequency leakage
        vDSP_hann_window(&window, vDSP_Length(windowSize), Int32(vDSP_HANN_NORM))
        vDSP_vmul(channel, 1, window,
                  1, &transferBuffer, 1, vDSP_Length(windowSize))
        
        // Transforming the [Float] buffer into a UnsafePointer<Float> object for the vDSP_ctoz method
        // And then pack the input into the complex buffer (output)
        transferBuffer.withUnsafeBufferPointer { pointer in
            pointer.baseAddress!.withMemoryRebound(to: DSPComplex.self,
                                                   capacity: transferBuffer.count) {
                vDSP_ctoz($0, 2, &output, 1, vDSP_Length(binCount))
            }
        }
        
        // Perform the FFT
        vDSP_fft_zrip(fftSetup!, &output, 1, log2n, FFTDirection(FFT_FORWARD))
        
        // Parseval's theorem - Scale with respect to the number of bins
        var scaledOutput = DSPSplitComplex(repeating: 0, count: binCount)
        var scaleMultiplier = DSPSplitComplex(repeatingReal: 1.0 / Float(binCount), repeatingImag: 0, count: 1)
        defer {
            scaledOutput.deallocate()
            scaleMultiplier.deallocate()
        }
        vDSP_zvzsml(&output,
                    1,
                    &scaleMultiplier,
                    &scaledOutput,
                    1,
                    vDSP_Length(binCount))
        
        var magnitudes = [Float](repeating: 0.0, count: frequencyBands)
        vDSP_zvmags(&scaledOutput, 1, &magnitudes, 1, vDSP_Length(frequencyBands))
        
        if !isNormalized {
            return magnitudes
        }
        
        // normalize according to the momentary maximum value of the fft output bins
        var normalizationMultiplier: [Float] = [1.0 / (magnitudes.max() ?? 1.0)]
        var normalizedMagnitudes = [Float](repeating: 0.0, count: frequencyBands)
        vDSP_vsmul(&magnitudes,
                   1,
                   &normalizationMultiplier,
                   &normalizedMagnitudes,
                   1,
                   vDSP_Length(frequencyBands))
        return normalizedMagnitudes
    }
}

extension FFT where State == FFTState.Processed {
    
    public var fftDatas: [[Float]] {
        self.config.amplitudes
    }
    
    public func present(maxAmplitude: Float = 0.0,
                        minAmplitude: Float = -70.0,
                        referenceValueForFFT: Float = 12.0) -> FFT<FFTState.Presented> {
        var config = self.config
        config.amplitudes = self.calculateAmplitudes(self.fftDatas,
                                                     maxAmplitude: maxAmplitude, 
                                                     minAmplitude: minAmplitude,
                                                     referenceValueForFFT: referenceValueForFFT)
        
        return FFT<FFTState.Presented>(config)
    }
    
    private func calculateAmplitudes(
        _ fftFloats: [[Float]],
        maxAmplitude: Float,
        minAmplitude: Float,
        referenceValueForFFT: Float
    ) -> [[Float]] {
        var referenceValueForFFT = referenceValueForFFT
        
        func block(_ fftData: [Float]) -> [Float] {
            var fftData = fftData
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
            
            return decibels.map { $0.isNaN ? 0.0 : $0 }
        }
        
        return fftFloats.enumerated().map {
            block($0.element)
        }
    }
}

extension FFT where State == FFTState.Presented {
    
    public var amplitudes: [[Float]] {
        self.config.amplitudes
    }
}

// MARK: - FFTModel

public enum FFTModel {
    case initial(FFT<FFTState.Initial>)
    case processed(FFT<FFTState.Processed>)
    case presented(FFT<FFTState.Presented>)
    
    public init(config: Config) {
        self = .initial(.init(config: config))
    }
    
    public mutating func perform() throws {
        if case .initial(let fft) = self {
            let processed = try fft.perform()
            self = .processed(processed)
        }
    }
    
    public var fftDatas: [[Float]]? {
        if case .processed(let fft) = self {
            return fft.config.amplitudes
        }
        return nil
    }
    
    public mutating func present() {
        if case .processed(let fft) = self {
            let presented = fft.present()
            self = .presented(presented)
        }
    }
    
    public var amplitudes: [[Float]]? {
        if case .presented(let fft) = self {
            return fft.config.amplitudes
        }
        return nil
    }
}

// MARK: - FFT data Smooth Help

public struct FFTHelper {
    private var datas: [[Float]] = []
    
    public mutating func smooth(_ amplitudes: [[Float]]) -> [[Float]] {
        if self.datas.isEmpty {
            for values in amplitudes {
                self.datas.append([Float](repeating: 0, count: values.count))
            }
        }
        
        for (i, amplitudes) in amplitudes.enumerated() {
            let spectrum = highlightWaveform(spectrum: amplitudes.map { $0.isNaN ? 0.0 : $0 })
            
            let spectrumSmooth: Float = 0.65
            self.datas[i] = zip(self.datas[i], spectrum)
                .map { value in
                    return value.0 * spectrumSmooth + value.1 * (1 - spectrumSmooth)
                }
        }
        return self.datas
    }
    
    private func highlightWaveform(spectrum: [Float]) -> [Float] {
        //1: 定义权重数组，数组中间的5表示自己的权重
        //   可以随意修改，个数需要奇数
        let weights: [Float] = [1, 2, 3, 5, 3, 2, 1]
        let totalWeights = Float(weights.reduce(0, +))
        let startIndex = weights.count / 2
        //2: 开头几个不参与计算
        var averagedSpectrum = Array(spectrum[0..<startIndex])
        for i in startIndex..<spectrum.count - startIndex {
            //3: zip作用: zip([a,b,c], [x,y,z]) -> [(a,x), (b,y), (c,z)]
            let zipped = zip(Array(spectrum[i - startIndex...i + startIndex]), weights)
            let averaged = zipped.map { $0.0 * $0.1 }.reduce(0, +) / totalWeights
            averagedSpectrum.append(averaged)
        }
        //4：末尾几个不参与计算
        averagedSpectrum.append(contentsOf: Array(spectrum.suffix(startIndex)))
        return averagedSpectrum
    }
}
