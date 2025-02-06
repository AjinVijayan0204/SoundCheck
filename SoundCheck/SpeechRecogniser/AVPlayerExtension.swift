//
//  AVPlayerExtension.swift
//  SoundCheck
//
//  Created by Ajin on 03/02/25.
//

import Foundation
import AVFoundation

extension AVPlayer {
    static let sharedAudioPlayer: AVPlayer = {
        guard let url = Bundle.main.url(forResource: "audio", withExtension: "wav") else {
            fatalError("Failed to find sound")
        }
        return AVPlayer(url: url)
    }()
}
