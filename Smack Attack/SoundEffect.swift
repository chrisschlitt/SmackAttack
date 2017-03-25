//
//  SoundEffect.swift
//  Smack Attack
//
//  Created by Christopher Schlitt on 3/23/17.
//  Copyright © 2017 Smack Innovations. All rights reserved.
//

import Foundation
import AVFoundation

class SoundEffect {
    
    var player: AVAudioPlayer
    var sound: String
    var loaded = false
    
    init(sound: String){
        self.sound = sound
        self.player = AVAudioPlayer()
        self.loaded = true
    }
    
    init(){
        self.sound = SoundEffect.getSoundEffects()[0]
        self.player = AVAudioPlayer()
    }
    
    static func defaults() -> [Int] {
        return [0, 1, 2, 3, 4, 5, 6, 7]
    }
    
    static func getSoundEffects() -> [String] {
        return ["KickDrum", "Tom", "Crash", "Splash", "Snare", "HighHat", "Ride", "Cowbell", "Accent"]
    }
    
    static func getEffect(_ index: Int) -> String {
        return self.getSoundEffects()[index];
    }
    
    func play() {
        let url = Bundle.main.url(forResource: self.sound, withExtension: "m4a")!
        
        do {
            self.player = try AVAudioPlayer(contentsOf: url)
            
            player.prepareToPlay()
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
