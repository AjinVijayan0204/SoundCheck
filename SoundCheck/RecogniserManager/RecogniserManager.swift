//
//  RecogniserManager.swift
//  SoundCheck
//
//  Created by Ajin on 16/02/25.
//

import Foundation
import AVKit
import SwiftUI

class RecogniserManager: ObservableObject, AuthDetector, TranscriptionDelagate, VoiceOverAssistDelegate {
    
    @Published var isTranscribing: Bool = false
    @Published var receiver: String = ""
    @Published var amount: String = ""
    @Published var totalAmount = 100000
    @Published var tapViewPresented: Bool = false
    
    //dependency
    var recogniser: LiveAudioClassifier
    var transcriber: SpeechRecogniser
    var assit: VoiceOverAssist
    var authUser: String
    var isTransactionApproved: Bool = false
    
    init(user: String) {
        self.authUser = user
        self.recogniser = LiveAudioClassifier()
        self.transcriber = SpeechRecogniser()
        self.assit = VoiceOverAssist()
    }
    
    @MainActor func start() async {
        await self.transcriber.resetAudioSession()
        await self.transcriber.configure(delagate: self)
        self.transcriber.startTranscribing()
        self.recogniser.startAudio(delagate: self)
        await self.assit.configure(delegate: self)
    }
    
    @MainActor func stop() {
        self.transcriber.stopTranscribing()
        self.recogniser.stopAudio()
        Task {
            await self.assit.stopAudioSession()
        }
    }
    
    //delagate function
    func isAuthenticated() {
        print("debug: isAuthenticated")
        self.isTransactionApproved = true
    }
    
    /*
    func didTranscriptionUpdated(_ transcription: String) {
        //sent x rupees to y
        print("debug: \(transcription)")
        let components = transcription.lowercased().components(separatedBy: " ")
        if transcription.contains("\u{20B9}"),
          let toIndex = components.firstIndex(of: "to"),
           components.count >= 4 {
            
            let moneyIndex = components.index(before: toIndex)
            let receiverIndex = components.index(after: toIndex)
            
        }
        
    }
     */
    
    func didTranscriptionStopped(_ transcription: String, _ stoppedTranscribing: Bool) {
    
        DispatchQueue.main.async {
            self.stop()
            self.isTranscribing = !stoppedTranscribing
        }
        //amount x receiver y
        print("debug: \(transcription)")
        
        self.createTransation(transcription)
    }
    
    func confirmTransaction() {
        DispatchQueue.main.async {
            self.tapViewPresented = true
        }
    }
    
    private func createTransation(_ transcription: String) {
        let components = transcription.lowercased().components(separatedBy: " ")
        if let amountIndex = components.firstIndex(of: "amount"),
           let receiverIndex = components.firstIndex(of: "receiver"),
           components.count >= 4 {
            DispatchQueue.main.async {
                self.amount = components[amountIndex + 1]
                self.receiver = components[receiverIndex + 1]
                let receiverInDigits = self.receiver.map({ " \($0)"})
                let assistCommand = (self.isTransactionApproved) ? "Sent \(self.amount) to\(receiverInDigits). Confirm by swiping right" : "Not authorised"
                if (!self.isTransactionApproved) {
                    self.completeProcess()
                }
                Task {
                    await self.assit.speak(command: assistCommand)
                }
            }
        }
    }
    
    func processTranscation(value: DragGesture.Value) {
        if value.velocity.width > 1 {
            self.totalAmount -= Int(self.amount) ?? 0
        }
        completeProcess()
    }
    
    func completeProcess() {
        self.tapViewPresented = false
        self.isTransactionApproved = false
        self.receiver = ""
        self.amount = ""
    }
}
