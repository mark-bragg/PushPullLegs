//
//  SoundManager.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 3/6/21.
//  Copyright © 2021 Mark Bragg. All rights reserved.
//

import Foundation
import AVFoundation

fileprivate extension String {
    static let start = "start"
    static let countdown = "countdown"
}

fileprivate protocol StaticMethods {
    static func getPlayer(_ name: String) -> AVAudioPlayer?
}

class SoundManager: NSObject {
    static let shared = SoundManager()
    private var countdownPlayer1: AVAudioPlayer? = getPlayer(.countdown)
    private var countdownPlayer2: AVAudioPlayer? = getPlayer(.countdown)
    private var startPlayer: AVAudioPlayer? = getPlayer(.start)
    private static var volume: Float = {
        let volumeMultiplier: Float = 0.08
        return AVAudioSession.sharedInstance().outputVolume * volumeMultiplier
    }()
    private override init() {
        super.init()
        try? AVAudioSession.sharedInstance().setCategory(.playback)
    }
    
    func playCountdownSound() {
        guard let cp1 = countdownPlayer1, let cp2 = countdownPlayer2 else { return }
        cp1.isPlaying ? play(cp2) : play(cp1)
    }
    
    func playStartSound() {
        play(startPlayer)
    }
    
    func play(_ player: AVAudioPlayer?) {
        player?.setVolume(SoundManager.volume, fadeDuration: 0)
        player?.play()
    }
}

extension SoundManager: StaticMethods {
    fileprivate static func getPlayer(_ name: String) -> AVAudioPlayer? {
        guard let path = Bundle.main.path(forResource: name, ofType: "m4a"),
              let url = URL(string: path),
              let audioPlayer = try? AVAudioPlayer(contentsOf: url)
        else { return nil }
        audioPlayer.setVolume(volume, fadeDuration: 0)
        return audioPlayer
    }
}
