//
//  SpeechView.swift
//  SoundCheck
//
//  Created by Ajin on 03/02/25.
//

import SwiftUI
import AVFoundation

struct SpeechView: View {
    
    @StateObject var manager: RecogniserManager = RecogniserManager(user: "Ajin")

    
    var body: some View {
        ZStack {
            
            VStack(alignment: .leading) {
                HStack {
                    Text("Receiver:")
                    Spacer()
                    Text(self.manager.receiver)
                }
                HStack {
                    Text("Amount:")
                    Spacer()
                    Text("\u{20B9}")
                    Text(self.manager.amount)
                }
                HStack {
                    Text("Total:")
                    Spacer()
                    Text("\u{20B9}")
                    Text("\(self.manager.totalAmount)")
                }
                Spacer()
            }
            .frame(width: UIScreen.main.bounds.width - 50, height: UIScreen.main.bounds.height - 150)
            
            Button {
                Task {
                    await self.buttonAction()
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(.gray)
                        .shadow(radius: 20)
                    
                    Image(systemName: self.manager.isTranscribing ? "waveform.and.mic" : "mic")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                }
            }
            .tint(.black)
            
            if self.manager.tapViewPresented {
                Color.orange.opacity(0.05)
                    .gesture(
                        DragGesture()
                            .onEnded({ value in
                                self.manager.processTranscation(value: value)
                            })
                    )
            }
        }
        .frame(width: 250, height: 250)
    }
    
    private func buttonAction() async {
        withAnimation {
            self.manager.isTranscribing.toggle()
        }
        if self.manager.isTranscribing {
            await manager.start()
            
        } else {
            manager.stop()
        }
    }
}

#Preview {
    SpeechView()
}
