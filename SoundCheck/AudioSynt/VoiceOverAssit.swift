//
//  VoiceOverAssit.swift
//  SoundCheck
//
//  Created by Ajin on 16/02/25.
//

import Foundation
import AVFoundation

protocol VoiceOverAssistDelegate {
    func confirmTransaction() async
}

actor VoiceOverAssist: NSObject, AVSpeechSynthesizerDelegate {
    private var speechSynthesizer: AVSpeechSynthesizer?
    private var audioSession: AVAudioSession?
    
    var delegate: VoiceOverAssistDelegate?
    
    func configure(delegate: VoiceOverAssistDelegate) {
        self.delegate = delegate
    }
    
    func speak(command: String) {
        self.audioSession = AVAudioSession()
        do {
            try self.audioSession?.setCategory(.playback, mode: .default, options: .duckOthers)
            try self.audioSession?.setPreferredSampleRate(44100)
            try self.audioSession?.setActive(false)
        } catch let error {
            print("❓", error.localizedDescription)
        }
        
        speechSynthesizer = AVSpeechSynthesizer()
        speechSynthesizer?.delegate = self  
        
        let speechUtterance = AVSpeechUtterance(string: command)
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "en")
        
        speechSynthesizer?.speak(speechUtterance)
    }
    
    func stopAudioSession() {
        //self.audioSession = nil
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task {
            print("debug: end synt")
            await self.delegate?.confirmTransaction()
        }
    }
}

