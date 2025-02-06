//
//  SpeechView.swift
//  SoundCheck
//
//  Created by Ajin on 03/02/25.
//

import SwiftUI
import AVFoundation

struct SpeechView: View {
    
    @StateObject var speechRecognizer = SpeechRecogniser()
    
    private var player: AVPlayer { AVPlayer.sharedAudioPlayer }
    
    @State var isTranscribing: Bool = false
    //var frequencyAnalyser: FrequencyAnalyzer = FrequencyAnalyzer()
   // var audioAnalyser: AudioAnalyzer = AudioAnalyzer()
    
    var body: some View {
        ZStack {
            
            VStack(alignment: .leading) {
                Text(speechRecognizer.transcript)
                Spacer()
            }
            .frame(width: UIScreen.main.bounds.width - 50, height: UIScreen.main.bounds.height - 150)
            
            Button {
                self.buttonAction()
            } label: {
                ZStack {
                    Circle()
                        .fill(.gray)
                        .shadow(radius: 20)
                    
                    Image(systemName: self.isTranscribing ? "waveform.and.mic" : "mic")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                }
            }
            .tint(.black)
        }
        .frame(width: 250, height: 250)
    }
    
    private func buttonAction() {
        withAnimation {
            self.isTranscribing.toggle()
        }
        if self.isTranscribing {
            speechRecognizer.startTranscribing()
            //self.audioAnalyser.startMonitoring()
            //self.frequencyAnalyser.startMonitoring()
        } else {
            speechRecognizer.stopTranscribing()
            //self.audioAnalyser.stopMonitoring()
            //self.frequencyAnalyser.stopMonitoring()
        }
    }
}

#Preview {
    SpeechView()
}
