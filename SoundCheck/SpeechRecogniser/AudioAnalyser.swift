//
//  AudioAnalyser.swift
//  SoundCheck
//
//  Created by Ajin on 03/02/25.
//

import Foundation
import AVFoundation

class AudioAnalyzer {
    private let audioEngine = AVAudioEngine()
    private var amplitudes: [Float] = []
    
    func stopMonitoring() {
        let inputNode = audioEngine.inputNode
        let format = inputNode.inputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        let mean = mean(of: amplitudes) ?? 0.0
        print("amplitude: \(mean)")
    }
    
    func startMonitoring() {
        self.amplitudes.removeAll()
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
            self.analyzeAudioBuffer(buffer: buffer)
        }
        // Start engine
        do {
            try audioEngine.start()
        } catch {
            print("Error starting audio engine: \(error)")
        }
    }

    private func analyzeAudioBuffer(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameLength = Int(buffer.frameLength)

        // Compute RMS amplitude
        let sum = (0..<frameLength).reduce(0.0) { $0 + pow(channelData[$1], 2) }
        let rms = sqrt(sum / Float(frameLength))

        // Convert to decibels
        let amplitude = 20 * log10(rms)
        self.amplitudes.append(amplitude)
    }
    
}
