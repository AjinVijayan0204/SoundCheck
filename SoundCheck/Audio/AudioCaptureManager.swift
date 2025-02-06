//
//  AudioCaptureManager.swift
//  SoundCheck
//
//  Created by Ajin on 05/02/25.
//

import Foundation
import AVFoundation

class AudioCaptureManager: NSObject {
    private let audioEngine = AVAudioEngine()
    var onAudioBufferReceived: ((AVAudioPCMBuffer) -> Void)?
    
    func startRecording() {
        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            self.onAudioBufferReceived?(buffer)
        }
        
        do {
            try audioEngine.start()
        } catch {
            print("Error in starting audio engine")
        }
    }
    
    func stopRecording() {
        
    }
}
