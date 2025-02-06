//
//  FrequencyAnalyser.swift
//  SoundCheck
//
//  Created by Ajin on 03/02/25.
//

import Foundation
import AVFoundation
import Accelerate

class FrequencyAnalyzer {
    private let audioEngine = AVAudioEngine()
    private let fftSize = 1024 // Power of 2 for FFT
    private let sampleRate: Double = 44100.0 // Standard sample rate
    var freq: [Double] = []

    func stopMonitoring() {
        let inputNode = audioEngine.inputNode
        let format = inputNode.inputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        let meanFreq = mean(of: freq) ?? 0.0
        print("freq: \(meanFreq)")
    }
    
    func startMonitoring() {
        self.freq.removeAll()
        // Setup audio session
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
            return
        }

        // Get input format
        let inputNode = audioEngine.inputNode
        let format = inputNode.inputFormat(forBus: 0) // Ensure correct format

        // Install tap
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            self.analyzeFrequency(buffer: buffer)
        }
        // Start engine
        do {
            try audioEngine.start()
        } catch {
            print("Error starting audio engine: \(error)")
        }
    }
    
    private func analyzeFrequency(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }

        var real = [Float](repeating: 0.0, count: fftSize)
        var imaginary = [Float](repeating: 0.0, count: fftSize)
        var magnitudes = [Float](repeating: 0.0, count: fftSize / 2)

        // Copy data to real part
        for i in 0..<fftSize {
            real[i] = channelData[i]
        }

        // Perform FFT
        var dspSplitComplex = DSPSplitComplex(realp: &real, imagp: &imaginary)
        let log2n = vDSP_Length(log2(Float(fftSize)))
        let fftSetup = vDSP_create_fftsetup(log2n, FFTRadix(kFFTRadix2))!

        vDSP_fft_zip(fftSetup, &dspSplitComplex, 1, log2n, FFTDirection(FFT_FORWARD))
        vDSP_destroy_fftsetup(fftSetup)

        // Compute magnitudes
        vDSP_zvmags(&dspSplitComplex, 1, &magnitudes, 1, vDSP_Length(fftSize / 2))

        // Find peak frequency
        if let maxIndex = magnitudes.indices.max(by: { magnitudes[$0] < magnitudes[$1] }) {
            let frequency = Double(maxIndex) * (sampleRate / Double(fftSize))
            self.freq.append(frequency)
        }
    }
}
