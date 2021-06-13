//
//  SoundManager.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 3/6/21.
//  Copyright © 2021 Mark Bragg. All rights reserved.
//

import Foundation
import AVFoundation
import AudioToolbox

fileprivate extension String {
    static let start = "start"
    static let countdown = "countdown"
    static let tick = "tick"
}

fileprivate protocol StaticMethods {
    static func getPlayer(_ name: String) -> AVAudioPlayer?
}

class SoundManager: NSObject {
    static let shared = SoundManager()
    private var countdownPlayer1: AVAudioPlayer? = getPlayer(.countdown)
    private var countdownPlayer2: AVAudioPlayer? = getPlayer(.countdown)
    private var startPlayer: AVAudioPlayer? = getPlayer(.start)
    private var tickPlayer1: AVAudioPlayer? = getPlayer(.tick)
    private var tickPlayer2: AVAudioPlayer? = getPlayer(.tick)
    private static var volume: Float = {
        let volumeMultiplier: Float = 0.5
        return AVAudioSession.sharedInstance().outputVolume * volumeMultiplier
    }()
    private override init() {
        super.init()
        try? AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)
    }
    var silenceNextNoise = false
    
    func playCountdownSound() {
        guard let cp1 = countdownPlayer1, let cp2 = countdownPlayer2 else { return }
        cp1.isPlaying ? play(cp2) : play(cp1)
    }
    
    func playStartSound() {
        play(startPlayer)
    }
    
    func playTickSound() {
        guard let tp1 = tickPlayer1, let tp2 = tickPlayer2 else { return }
        tp1.isPlaying ? play(tp2) : play(tp1)
    }
    
    func play(_ player: AVAudioPlayer?) {
        guard !silenceNextNoise else {
            silenceNextNoise = false
            return
        }
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
