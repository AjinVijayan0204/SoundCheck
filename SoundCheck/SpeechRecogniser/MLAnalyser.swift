//
//  MLAnalyser.swift
//  SoundCheck
//
//  Created by Ajin on 15/02/25.
//
import AVFoundation
import SoundAnalysis

protocol AuthDetector {
    var authUser: String { get set }
    func isAuthenticated()
}

class LiveAudioClassifier: NSObject, SNResultsObserving {
    private let audioEngine = AVAudioEngine()
    private var analyzer: SNAudioStreamAnalyzer?
    private let audioQueue = DispatchQueue(label: "AudioQueue")
    private var request: SNClassifySoundRequest?
    private var currentAudioFormat: AVAudioFormat? // Track the format manually
    private var delagate: AuthDetector?
    
    override init() {
        super.init()
    }

    private func setupAudio() {
        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        currentAudioFormat = format // Store the format
        
        initializeAnalyzer(with: format)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, when in
            self.audioQueue.async {
                // Compare the current format with the new buffer's format
                if let currentFormat = self.currentAudioFormat,
                   buffer.format.sampleRate != currentFormat.sampleRate {
                    print("⚠️ Audio format changed! Restarting analyzer...")
                    self.restartAnalyzer(with: buffer.format)
                }
                self.analyzer?.analyze(buffer, atAudioFramePosition: when.sampleTime)
            }
        }
        do {
            try audioEngine.start()
        } catch {
            print("Audio engine start error: \(error)")
        }
    }

    private func initializeAnalyzer(with format: AVAudioFormat) {
        self.analyzer = SNAudioStreamAnalyzer(format: format)
        self.currentAudioFormat = format // Update stored format
        
        guard let model = try? MySoundClassifier_1(configuration: MLModelConfiguration()).model,
              let classifyRequest = try? SNClassifySoundRequest(mlModel: model) else {
            print("Error loading model or creating classification request")
            return
        }
        
        self.request = classifyRequest
        try? self.analyzer?.add(classifyRequest, withObserver: self)
    }

    private func restartAnalyzer(with newFormat: AVAudioFormat) {
        print("🔄 Restarting analyzer with new format: \(newFormat.sampleRate) Hz")
        initializeAnalyzer(with: newFormat)
    }

    func stopAudio() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }

    func startAudio(delagate: AuthDetector) {
        self.delagate = delagate
        setupAudio()
    }
    // MARK: - Process Classification Results
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let classificationResult = result as? SNClassificationResult,
              let bestClassification = classificationResult.classifications.first else { return }

        //print("Speaker: \(bestClassification.identifier) (Confidence: \(bestClassification.confidence))")
        if self.delagate?.authUser.lowercased() == bestClassification.identifier.lowercased() && bestClassification.confidence > 0.999 {
            delagate?.isAuthenticated()
        }
    }
}


